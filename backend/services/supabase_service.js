const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://vuttrtiqscjviedfwodd.supabase.co';
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1dHRydGlxc2NqdmllZGZ3b2RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ5MjQ0MzEsImV4cCI6MjEwMDUwMDQzMX0.NTvxDP6ZJydfX2_75fueq92_W92T71CxAp2_KnChu-c';

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

module.exports = supabase;
