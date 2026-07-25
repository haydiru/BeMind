const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const DB_PASSWORD = 'QTteJ&s!/Z2z*28';
const PROJECT_REF = 'vuttrtiqscjviedfwodd';

// Try standard Supabase Direct DB connection strings
const connectionStrings = [
  `postgres://postgres:${encodeURIComponent(DB_PASSWORD)}@db.${PROJECT_REF}.supabase.co:5432/postgres`,
  `postgres://postgres.${PROJECT_REF}:${encodeURIComponent(DB_PASSWORD)}@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres`,
  `postgres://postgres.${PROJECT_REF}:${encodeURIComponent(DB_PASSWORD)}@aws-0-us-east-1.pooler.supabase.com:6543/postgres`,
  `postgres://postgres.${PROJECT_REF}:${encodeURIComponent(DB_PASSWORD)}@aws-0-eu-central-1.pooler.supabase.com:6543/postgres`
];

async function executeMigration() {
  console.log('=== Connecting to Supabase PostgreSQL Database ===\n');
  const sqlPath = path.join(__dirname, 'database', 'schema.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');

  let client = null;
  let connected = false;

  for (const connStr of connectionStrings) {
    try {
      console.log(`Attempting connection to Supabase DB...`);
      client = new Client({
        connectionString: connStr,
        ssl: { rejectUnauthorized: false }
      });
      await client.connect();
      connected = true;
      console.log('✔ Connected to Supabase PostgreSQL Database SUCCESSFUL!\n');
      break;
    } catch (err) {
      console.warn(`Connection failed: ${err.message}`);
    }
  }

  if (!connected || !client) {
    console.error('✖ Unable to connect to Supabase DB via all pooler hosts.');
    process.exit(1);
  }

  try {
    console.log('Executing database schema.sql DDL...');
    await client.query(sql);
    console.log('✔ Database Migration & Seeding Executed 100% SUCCESSFULLY!\n');

    // Verify created tables
    const res = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public';
    `);

    console.log('--- Created Public Tables in Supabase ---');
    res.rows.forEach(r => console.log(` - public.${r.table_name}`));

    await client.end();
    console.log('\n=== All Database Migrations Fully Completed! ===');
  } catch (err) {
    console.error('✖ Migration Execution Error:', err.message);
    if (client) await client.end();
    process.exit(1);
  }
}

executeMigration();
