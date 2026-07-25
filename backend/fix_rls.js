const fs = require('fs');
const { Client } = require('pg');

const DB_PASSWORD = 'QTteJ&s!/Z2z*28';
const PROJECT_REF = 'vuttrtiqscjviedfwodd';

async function fixRLS() {
  const client = new Client({
    host: `db.${PROJECT_REF}.supabase.co`,
    port: 5432,
    database: 'postgres',
    user: 'postgres',
    password: DB_PASSWORD,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('✔ Connected to Supabase DB');

    const sql = `
      -- Disable RLS on generated_essays and profiles or add permissive policies so anon/auth can read/write
      ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
      ALTER TABLE public.user_contexts DISABLE ROW LEVEL SECURITY;
      ALTER TABLE public.prompt_templates DISABLE ROW LEVEL SECURITY;
      ALTER TABLE public.generated_essays DISABLE ROW LEVEL SECURITY;
      ALTER TABLE public.vocabularies DISABLE ROW LEVEL SECURITY;
      ALTER TABLE public.user_settings DISABLE ROW LEVEL SECURITY;

      -- Make sure handle_new_user trigger works on auth.users insert
      CREATE OR REPLACE FUNCTION public.handle_new_user()
      RETURNS TRIGGER AS $$
      BEGIN
          INSERT INTO public.profiles (id, email, name, target_goal, role, profile_completeness)
          VALUES (
              NEW.id,
              NEW.email,
              COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
              'Job Interview Prep',
              COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
              85
          ) ON CONFLICT (id) DO NOTHING;

          INSERT INTO public.user_settings (user_id)
          VALUES (NEW.id) ON CONFLICT (user_id) DO NOTHING;

          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;

      -- Sync all existing auth users into profiles table right now!
      INSERT INTO public.profiles (id, email, name, target_goal)
      SELECT id, email, COALESCE(raw_user_meta_data->>'name', split_part(email, '@', 1)), 'Job Interview Prep'
      FROM auth.users
      ON CONFLICT (id) DO NOTHING;

      NOTIFY pgrst, 'reload schema';
    `;

    await client.query(sql);
    console.log('✔ RLS Fixed & Existing Users Synced to public.profiles!');

    const res = await client.query('SELECT count(*) FROM public.profiles;');
    console.log('Total Profiles in DB:', res.rows[0].count);

    const essays = await client.query('SELECT count(*) FROM public.generated_essays;');
    console.log('Total Essays in DB:', essays.rows[0].count);

    await client.end();
  } catch (err) {
    console.error('Error fixing DB RLS:', err);
  }
}

fixRLS();
