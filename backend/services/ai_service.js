const axios = require('axios');
const supabase = require('./supabase_service');
require('dotenv').config();

const AI_PROXY_URL = process.env.AI_PROXY_URL || 'https://api.hcnsec.cn/v1/chat/completions';
const AI_API_KEY = process.env.AI_API_KEY;
const DEFAULT_MODEL = process.env.DEFAULT_AI_MODEL || 'Qwen3.6-35B-A3B';

/**
 * Retrieves the active AI model name from Supabase system_config table dynamically.
 */
async function getActiveModel() {
  try {
    const { data, error } = await supabase
      .from('system_config')
      .select('value')
      .eq('key', 'active_ai_model')
      .single();

    if (error || !data || !data.value) {
      console.log(`[AI Service] Using default env model: ${DEFAULT_MODEL}`);
      return DEFAULT_MODEL;
    }
    return data.value;
  } catch (err) {
    console.warn('[AI Service] Error fetching active model from DB, using fallback:', err.message);
    return DEFAULT_MODEL;
  }
}

/**
 * Generate personalized speech essay via OpenAI-compatible Proxy API
 */
async function generatePersonalizedEssay({ category, subTopic, difficulty, tone, userContext, promptTemplate }) {
  const activeModel = await getActiveModel();
  console.log(`[AI Service] Synthesizing essay using model: ${activeModel}`);

  const systemPrompt = `You are BeMind AI, an elite English Fluency Synthesizer.
Your goal is to generate a 100% personalized, high-impact English speech narrative tailored to the user's specific career background and context.

STRICT INSTRUCTIONS:
1. Target Difficulty Level: ${difficulty || 'C1 (Advanced)'}
2. Tone of Voice: ${tone || 'Professional'}
3. Category: ${category || 'Job Interview'}
4. Format requirements: The generated essay MUST be structured into clear, coherent paragraphs suitable for auto-scrolling Teleprompter reading at 60-120 WPM.
5. DO NOT include meta labels like [Hook], [Introduction], [Conclusion], or Markdown syntax explanations. Return ONLY the polished speech narrative content.`;

  const userPrompt = `User Personal Context Background:
${userContext || 'Senior Software Engineer with 5 years experience in Fintech, microservices, and lead engineering.'}

Target Goal & Template Guidance:
${promptTemplate || 'Construct a STAR Method interview answer focusing on leadership and technical execution.'}

Category: ${category} | Sub-Topic: ${subTopic} | Level: ${difficulty} | Tone: ${tone}

Please synthesize the final narrative essay now:`;

  try {
    const response = await axios.post(
      AI_PROXY_URL,
      {
        model: activeModel,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.7
      },
      {
        headers: {
          'Authorization': `Bearer ${AI_API_KEY}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      }
    );

    const generatedText = response.data?.choices?.[0]?.message?.content;
    if (!generatedText) {
      throw new Error('No content returned from AI proxy service');
    }

    return {
      modelUsed: activeModel,
      content: generatedText.trim()
    };
  } catch (error) {
    console.error('[AI Service Error]:', error.response?.data || error.message);
    throw new Error(`AI Generation failed: ${error.response?.data?.error?.message || error.message}`);
  }
}

/**
 * Transcribe recorded voice audio via OpenAI Whisper API
 */
async function transcribeAudioWithWhisper(fileBuffer, originalName) {
  try {
    const FormData = require('form-data');
    const formData = new FormData();
    formData.append('file', fileBuffer, { filename: originalName || 'audio.m4a' });
    formData.append('model', 'whisper-1');

    const whisperUrl = AI_PROXY_URL.includes('/chat/completions')
      ? AI_PROXY_URL.replace('/chat/completions', '/audio/transcriptions')
      : 'https://api.openai.com/v1/audio/transcriptions';

    const response = await axios.post(
      whisperUrl,
      formData,
      {
        headers: {
          'Authorization': `Bearer ${AI_API_KEY}`,
          ...formData.getHeaders()
        },
        timeout: 25000
      }
    );

    return response.data?.text || '';
  } catch (error) {
    console.error('[Whisper STT Error]:', error.response?.data || error.message);
    return '';
  }
}

module.exports = {
  getActiveModel,
  generatePersonalizedEssay,
  transcribeAudioWithWhisper
};
