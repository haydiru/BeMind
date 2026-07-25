require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  { auth: { autoRefreshToken: false, persistSession: false } }
);

// Execute raw SQL via Supabase REST endpoint (pg_query using fetch)
async function runSQL(label, sql) {
  const url = `${process.env.SUPABASE_URL}/rest/v1/rpc/exec_sql`;
  // We'll use fetch with the pg endpoint instead
  try {
    const response = await fetch(`${process.env.SUPABASE_URL}/pg/query`, {
      method: 'POST',
      headers: {
        'apikey': process.env.SUPABASE_SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query: sql })
    });
    const data = await response.json();
    if (response.ok) {
      console.log(`✔ ${label}`);
    } else {
      console.error(`✖ ${label}: ${JSON.stringify(data)}`);
    }
  } catch(e) {
    console.error(`✖ ${label}: ${e.message}`);
  }
}

async function migrate() {
  console.log('=== BeMind Supabase Migration Starting ===\n');

  // Step 1: Create profiles table
  await runSQL('Create profiles table', `
    CREATE TABLE IF NOT EXISTS public.profiles (
      id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
      email TEXT NOT NULL,
      name TEXT NOT NULL,
      target_goal TEXT DEFAULT 'Job Interview Prep',
      role TEXT DEFAULT 'user',
      profile_completeness INT DEFAULT 85,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  // Step 2: Create system_config table
  await runSQL('Create system_config table', `
    CREATE TABLE IF NOT EXISTS public.system_config (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      description TEXT,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  await runSQL('Seed default AI model config', `
    INSERT INTO public.system_config (key, value, description)
    VALUES ('active_ai_model', 'Qwen3.6-35B-A3B', 'Currently active LLM model')
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
  `);

  // Step 3: Create user_contexts
  await runSQL('Create user_contexts table', `
    CREATE TABLE IF NOT EXISTS public.user_contexts (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
      source_type TEXT NOT NULL CHECK (source_type IN ('text', 'voice', 'pdf', 'ocr')),
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  // Step 4: Create prompt_templates
  await runSQL('Create prompt_templates table', `
    CREATE TABLE IF NOT EXISTS public.prompt_templates (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      creator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
      creator_name TEXT NOT NULL,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT NOT NULL,
      template_structure TEXT NOT NULL,
      use_count INT DEFAULT 1,
      rating NUMERIC(3, 1) DEFAULT 5.0,
      is_featured BOOLEAN DEFAULT FALSE,
      is_public BOOLEAN DEFAULT TRUE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  // Step 5: Create generated_essays
  await runSQL('Create generated_essays table', `
    CREATE TABLE IF NOT EXISTS public.generated_essays (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
      template_id UUID REFERENCES public.prompt_templates(id) ON DELETE SET NULL,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      sub_topic TEXT,
      difficulty TEXT NOT NULL,
      tone TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  // Step 6: Create vocabularies
  await runSQL('Create vocabularies table', `
    CREATE TABLE IF NOT EXISTS public.vocabularies (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
      word TEXT NOT NULL,
      phonetic TEXT,
      definition TEXT NOT NULL,
      context_sentence TEXT,
      indonesian_meaning TEXT NOT NULL,
      mastery_status TEXT DEFAULT 'learning' CHECK (mastery_status IN ('learning', 'mastered', 'review')),
      added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  // Step 7: Create user_settings
  await runSQL('Create user_settings table', `
    CREATE TABLE IF NOT EXISTS public.user_settings (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
      is_enabled BOOLEAN DEFAULT TRUE,
      frequency TEXT DEFAULT '5x a day',
      start_hour INT DEFAULT 8,
      end_hour INT DEFAULT 21,
      last_sync_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  `);

  // Step 8: Trigger for auto-creating profile on signup
  await runSQL('Create handle_new_user function', `
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
      );
      INSERT INTO public.user_settings (user_id) VALUES (NEW.id);
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;
  `);

  await runSQL('Create on_auth_user_created trigger', `
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  `);

  // Step 9: Enable RLS
  await runSQL('Enable RLS on all tables', `
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_contexts ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.prompt_templates ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.generated_essays ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.vocabularies ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
  `);

  // Step 10: RLS Policies
  await runSQL('Create public read policies', `
    DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prompt_templates' AND policyname = 'Public prompt templates read policy') THEN
        CREATE POLICY "Public prompt templates read policy" ON public.prompt_templates FOR SELECT USING (is_public = true);
      END IF;
    END $$;
  `);

  await runSQL('Create system_config read policy', `
    DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'system_config' AND policyname = 'Public system config read policy') THEN
        CREATE POLICY "Public system config read policy" ON public.system_config FOR SELECT USING (true);
      END IF;
    END $$;
  `);

  // Step 11: Seed prompt templates
  await runSQL('Seed community prompt templates', `
    INSERT INTO public.prompt_templates (id, creator_name, title, category, description, template_structure, use_count, rating, is_featured, is_public)
    VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Sarah Jenkins (Ex-Google Recruiter)', 'STAR Method Interview Master', 'Job Interview', 'Formats your background into STAR bullet points for tech interviews.', 'Using {USER_CONTEXT}, construct a compelling STAR response for {TARGET_GOAL}.', 1420, 4.9, TRUE, TRUE),
    ('22222222-2222-2222-2222-222222222222', 'David Miller (IELTS Examiner)', 'IELTS Band 8.0 Fluency Synthesizer', 'IELTS/TOEFL', 'Generates speaking cue card responses with C1/C2 vocabulary.', 'Transform {USER_CONTEXT} into an IELTS Speaking Part 2 response.', 980, 4.8, TRUE, TRUE),
    ('33333333-3333-3333-3333-333333333333', 'Marcus Chen (Y Combinator Alumni)', '3-Minute Elevator Pitching Engine', 'Business Pitching', 'Crafts a high-impact startup elevator pitch.', 'Distill {USER_CONTEXT} into a 180-second high-energy pitch narration.', 750, 4.7, FALSE, TRUE)
    ON CONFLICT (id) DO NOTHING;
  `);

  console.log('\n=== Migration Complete ===');
}

migrate().catch(console.error);
