require('dotenv').config();
const supabase = require('./services/supabase_service');

async function seedData() {
  console.log('=== Seeding Initial Supabase Database Data ===\n');

  // 1. Seed active_ai_model in system_config
  const { data: configData, error: configError } = await supabase
    .from('system_config')
    .upsert({
      key: 'active_ai_model',
      value: 'Qwen3.6-35B-A3B',
      description: 'Currently active LLM model used for narrative essay generation',
      updated_at: new Date().toISOString()
    });

  if (configError) {
    console.error('✖ System Config Seed Error:', configError.message);
  } else {
    console.log('✔ system_config seeded with active_ai_model = Qwen3.6-35B-A3B');
  }

  // 2. Seed Prompt Templates
  const initialTemplates = [
    {
      id: '11111111-1111-1111-1111-111111111111',
      creator_name: 'Sarah Jenkins (Ex-Google Recruiter)',
      title: 'STAR Method Interview Master',
      category: 'Job Interview',
      description: 'Formats your background experience into Situation, Task, Action, and Result bullet points designed for tech interviews.',
      template_structure: 'Using the user background in {USER_CONTEXT}, construct a compelling STAR response for a senior tech role focusing on {TARGET_GOAL}.',
      use_count: 1420,
      rating: 4.9,
      is_featured: true,
      is_public: true
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      creator_name: 'David Miller (IELTS Examiner)',
      title: 'IELTS Band 8.0 Fluency Synthesizer',
      category: 'IELTS/TOEFL',
      description: 'Generates speaking cue card responses rich in idiomatic collocations, advanced cohesion connectors, and C1/C2 vocabulary.',
      template_structure: 'Transform user personal context {USER_CONTEXT} into an IELTS Speaking Part 2 response with advanced vocabulary.',
      use_count: 980,
      rating: 4.8,
      is_featured: true,
      is_public: true
    },
    {
      id: '33333333-3333-3333-3333-333333333333',
      creator_name: 'Marcus Chen (Y Combinator Alumni)',
      title: '3-Minute Elevator Pitching Engine',
      category: 'Business Pitching',
      description: 'Crafts a high-impact startup elevator pitch highlighting problem, traction, unique moat, and vision.',
      template_structure: 'Distill {USER_CONTEXT} into a 180-second high-energy pitch deck narration.',
      use_count: 750,
      rating: 4.7,
      is_featured: false,
      is_public: true
    }
  ];

  const { data: tmplData, error: tmplError } = await supabase
    .from('prompt_templates')
    .upsert(initialTemplates, { onConflict: 'id' });

  if (tmplError) {
    console.error('✖ Prompt Templates Seed Error:', tmplError.message);
  } else {
    console.log('✔ prompt_templates seeded with 3 initial community templates!');
  }

  console.log('\n=== Database Seeding Complete ===');
}

seedData();
