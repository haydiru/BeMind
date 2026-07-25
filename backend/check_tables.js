require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function checkTables() {
  console.log('--- Checking Supabase Database Tables ---');
  
  const tables = ['profiles', 'system_config', 'user_contexts', 'prompt_templates', 'generated_essays', 'vocabularies', 'user_settings'];

  for (const table of tables) {
    const { data, error } = await supabase.from(table).select('count', { count: 'exact', head: true });
    if (error) {
      console.log(`❌ Table '${table}': NOT FOUND or ERROR (${error.message})`);
    } else {
      console.log(`✅ Table '${table}': EXISTS!`);
    }
  }
}

checkTables();
