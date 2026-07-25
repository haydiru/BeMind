const axios = require('axios');
const { generatePersonalizedEssay } = require('./services/ai_service');

async function testBackendServices() {
  console.log('--- Testing BeMind AI Backend & AI Proxy Connection ---');
  try {
    const result = await generatePersonalizedEssay({
      category: 'Job Interview',
      subTopic: 'STAR Method',
      difficulty: 'C1',
      tone: 'Professional',
      userContext: 'I have 5 years of experience in Fintech microservices architecture and Golang backend systems.',
      promptTemplate: 'Construct a STAR Method answer focusing on technical leadership.'
    });

    console.log('✔ AI Generation SUCCESSFUL!');
    console.log(`Active Model Used: ${result.modelUsed}`);
    console.log(`Generated Essay Preview:\n${result.content.substring(0, 200)}...`);
  } catch (err) {
    console.error('✖ AI Test Failed:', err.message);
  }
}

testBackendServices();
