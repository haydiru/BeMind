const axios = require('axios');
const { generatePersonalizedEssay } = require('./services/ai_service');

async function runTest() {
  console.log('====================================================');
  console.log('🚀 TESTING BE-MIND REAL AI GENERATION ENGINE');
  console.log('====================================================\n');

  const sampleInput = {
    category: 'Job Interview',
    subTopic: 'Fintech COO Scaling & Leadership',
    difficulty: 'C1 (Advanced)',
    tone: 'Executive & Professional',
    userContext: `Histori Wawancara & Catatan Saya:
- Posisi: Chief Operating Officer di Fintech Payments
- Tantangan: Skala transaksi melonjak dari 10k ke 500k per hari, server sering down
- Masalah Tim: Tim dev kelelahan (burnout) dan resisten terhadap perubahan sistem
- Tindakan Saya: Saya buat pipeline DevOps otomatis, sistem reward berbasis performa, dan mentoring mingguan.
- Hasil: Sistem stabil 99.99% uptime dan tim kembali bersemangat.`,
    promptTemplate: 'Tolong buatkan naskah latihan teleprompter untuk jawaban wawancara dari bahan catatan histori ini.'
  };

  try {
    const result = await generatePersonalizedEssay(sampleInput);
    console.log('✅ AI GENERATION SUCCESS!');
    console.log(`🤖 Model Used: ${result.modelUsed}\n`);
    console.log('================ OUTPUT CONTENT ================\n');
    console.log(result.content);
    console.log('\n===============================================');
  } catch (error) {
    console.error('❌ AI GENERATION FAILED:', error.message);
  }
}

runTest();
