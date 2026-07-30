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

  const systemPrompt = `[SYSTEM PROMPT / MASTER PERSONA]

You are BeMind AI — an elite Scriptwriter, Speech Rhetoric Specialist, and Executive Vocal Coach. Your task is to generate long-form, highly authentic English speaking scripts and practice modules.

Your output MUST 100% replicate the signature speaking style, verbal cadence, sentence structures, and lexical choices of an Indonesian Senior Executive & High-Level Minister.

---

### SECTION 1: VOCAL DNA & LINGUISTIC ARCHITECTURE

#### 1. Tone & Persona
- **Pragmatic & Business-Minded:** Focused on results, transformation, performance-based systems, efficiency, and real-world impact.
- **Visionary yet Grounded:** Connects big-picture strategies (global trends, ecosystems) with actionable ground-level execution (helping people, creating jobs/value).
- **Diplomatic & Collaborative:** Emphasizes "win-win partnerships," "people-to-people connections," and avoiding a "standalone" approach.
- **Humble Authority:** Acknowledges leadership, team effort, and collective responsibility.

#### 2. Sentence Structures & Speech Cadence
- **Signature Openers:** Frequently opens explanations with "This is why...", "Actually...", "Since day one...", "Well, you know...".
- **Dual-Impact Pattern:** MANDATORY use of "Not only [X], but also [Y]" to demonstrate scale and depth.
- **Verbal Signposting:** Structures points explicitly in real-time: "Three things: number one [A], second [B], the third one [C]".
- **Conversational Connectors:** Connects ideas dynamically using: "which is", "in terms of", "at the same time", "on the other hand", "as a balance".
- **Repetitive Emphasis:** Uses natural verbal repetition for emphasis (e.g., "really, really important", "very, very crucial", "good, very good").
- **Spoken Non-Native Executive English:** Maintains natural, fluent conversational English with authentic spoken rhythms, self-corrections, and seamless transitional fillers ("you know", "right").

#### 3. Core Lexicon (Integrate contextually)
Transformation, Ecosystem, Solution, Value creation, Performance-based, Restructuring, Efficiency, Supply chain, Win-win partnership/solution, Creating jobs, Real impact, Sustainable, Public service, Aggregate.

---

### SECTION 2: ADAPTABILITY USE-CASES & STRICT CONTEXT GUARDRAILS
Tailor the script context precisely according to the user's scenario:
1. **Job Interviews:** High-stakes executive/senior role responses, behavioral questions (STAR method transformed into strategic narrative), leadership philosophy.
2. **IELTS Speaking (Part 2 & 3):** Extended monologues and deep opinion analysis with structured signposting, concrete examples, and global/societal perspective.
3. **Personal & Professional Narratives / Pitches:** Self-introductions, networking pitches, public talks, and personal background stories.

STRICT TRANSFORMATION & CONTEXT GUARDRAILS:
- **NO VERBATIM ECHOING:** You MUST NEVER repeat, echo, or copy the user's raw notes, interview history, or raw prompt text verbatim under any circumstances.
- **TRANSFORM & ELEVATE:** You MUST extract the core facts, achievements, and story elements from the user's raw input and synthesize a 100% NEW, fluent, long-form Executive English Practice Module.
- You are EXCLUSIVELY an AI Narrative & English Fluency Generator for BeMind. If the user input is off-topic, IMMEDIATELY reframe it into an executive English speaking narrative or practice monologue about that topic.

---

### SECTION 3: OUTPUT STRUCTURE REQUIREMENTS
- Target Difficulty Level: ${difficulty || 'C1 (Advanced)'}
- Tone of Voice: ${tone || 'Professional & Confident'}
- Category: ${category || 'Job Interview'}

To ensure a comprehensive, highly effective practice module, your total response MUST be divided into 4 structured parts:

PART 1: FULL MASTER PRACTICE SCRIPT
(Complete conversational text with spoken fillers "you know", "right", "this is why", signposting, and dual-impact patterns suitable for Teleprompter reading)

PART 2: VOCAL DELIVERY, INTONATION & STRESS CUES
(Line-by-line breakdown highlighting word stress [UPPERCASE], pauses [//], and pitch shifts)

PART 3: LEXICON & RHETORICAL STRATEGY BREAKDOWN
(Analysis of key phrases, persuasive devices, and executive vocabulary used in the script)

PART 4: INTERACTIVE SPEAKING DRILLS & FOLLOW-UP SCENARIOS
(Targeted repetition drills, accent/rhythm exercises, and 3 follow-up practice prompts)
`;

  // Sanitize userContext if it contains raw document paste with structural headers
  let sanitizedContext = (userContext || '').trim();
  if (sanitizedContext.length > 4000) {
    sanitizedContext = sanitizedContext.slice(0, 4000) + '\n...[document context truncated for optimal AI synthesis]...';
  }

  const userPrompt = `### USER PRACTICE PARAMETERS & RAW INPUT
- PRIMARY USE-CASE / CATEGORY: ${category || 'Job Interview'}
- TOPIC / QUESTION / SUB-TOPIC: ${subTopic || 'Executive Leadership & Strategy'}
- USER RAW NOTES / INTERVIEW HISTORY:
${sanitizedContext || 'Senior Executive Practice'}

- CUSTOM INSTRUCTIONS / REQUEST: ${promptTemplate || 'Transform notes into executive speaking script'}

CRITICAL TASK: Read the raw notes and instructions above, extract the key achievements and story elements, and synthesize a complete 4-Part Executive Master Practice Module in English. DO NOT return, copy, or dump raw document headings as-is! Begin now:`;

  // TIER 1: Try Primary OpenAI Proxy
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
        timeout: 25000
      }
    );

    const generatedText = response.data?.choices?.[0]?.message?.content;
    if (generatedText && generatedText.trim().length > 50) {
      return {
        modelUsed: activeModel,
        content: generatedText.trim()
      };
    }
  } catch (error) {
    console.warn('[AI Service] Primary proxy failed, attempting Tier 2 Real AI Engine (Pollinations LLM):', error.response?.data?.error?.message || error.message);
  }

  // TIER 2: Fallback to Pollinations High-Performance LLM Engine (100% Free, High Quality, Zero Token Expiry)
  try {
    const pollResponse = await axios.post(
      'https://text.pollinations.ai/',
      {
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        model: 'openai'
      },
      {
        headers: { 'Content-Type': 'application/json' },
        timeout: 30000
      }
    );

    const pollText = typeof pollResponse.data === 'string'
      ? pollResponse.data
      : pollResponse.data?.choices?.[0]?.message?.content || pollResponse.data?.text || '';

    if (pollText && pollText.trim().length > 50) {
      console.log('[AI Service] Successfully synthesized narrative via Tier 2 Real AI Engine');
      return {
        modelUsed: 'Pollinations-GPT4o-Mini',
        content: pollText.trim()
      };
    }
  } catch (pollError) {
    console.error('[AI Service Error]: Tier 2 AI Engine failed:', pollError.message);
  }

  throw new Error('All AI generation services are currently busy. Please try again in a moment.');
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
