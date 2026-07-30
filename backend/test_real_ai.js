const axios = require('axios');
const { generatePersonalizedEssay } = require('./services/ai_service');

async function runTest() {
  console.log('====================================================');
  console.log('🚀 TESTING REAL AI GENERATION WITH HUGE DOCUMENT PASTE');
  console.log('====================================================\n');

  const sampleInput = {
    category: 'Job Interview',
    subTopic: 'buatkan script dari bahan interview diatas',
    difficulty: 'C1 (Advanced)',
    tone: 'Executive & Professional',
    userContext: `INTERVIEW PREP
Company Details 2
Company Name: Medor
Job Title: AI & Automation Engineer
JOB DESCRIPTION
About the customer: The customer is a logistics and supply chain specialist...
Responsibilities: Manage and optimize existing technology systems and processes...
Requirements: Proven experience in automation engineering or AI-related roles, N8N, Make.com, Python, JavaScript.
Behavioral Questions:
Tell me a little bit about yourself: For the past year, I've been working as a freelance AI and Automation Engineer...
Why should we hire you? You should hire me because I offer a unique combination of three things...`,
    promptTemplate: 'Tolong buatkan script untuk latihan prompter dari bahan tersebut.'
  };

  try {
    const result = await generatePersonalizedEssay(sampleInput);
    console.log('✅ AI GENERATION SUCCESS!');
    console.log(`🤖 Model Used: ${result.modelUsed}\n`);
    console.log('================ OUTPUT CONTENT ================\n');
    console.log(result.content.slice(0, 1000));
    console.log('\n===============================================');
  } catch (error) {
    console.error('❌ AI GENERATION FAILED:', error.message);
  }
}

runTest();
