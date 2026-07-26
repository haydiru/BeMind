const express = require('express');
const router = express.Router();
const { generatePersonalizedEssay } = require('../services/ai_service');
const supabase = require('../services/supabase_service');

/**
 * POST /api/ai/generate-essay
 * Synthesizes personalized essay fusing user context + prompt template via AI Proxy
 */
router.post('/generate-essay', async (req, res) => {
  const { userId, category, subTopic, difficulty, tone, userContext, templateId, promptTemplate } = req.body;

  try {
    const aiResult = await generatePersonalizedEssay({
      category: category || 'Job Interview',
      subTopic: subTopic || 'Technical Leadership & STAR',
      difficulty: difficulty || 'C1 (Advanced)',
      tone: tone || 'Professional',
      userContext: userContext || '',
      promptTemplate: promptTemplate || ''
    });

    const title = `STAR Method: ${category || 'Job Interview'}`;

    // Save generated essay into Supabase generated_essays table if userId is present
    let savedEssay = null;
    if (userId) {
      const { data, error } = await supabase
        .from('generated_essays')
        .insert({
          user_id: userId,
          template_id: templateId || null,
          title: title,
          category: category || 'Job Interview',
          sub_topic: subTopic || 'STAR Method',
          difficulty: difficulty || 'C1',
          tone: tone || 'Professional',
          content: aiResult.content
        })
        .select()
        .single();

      if (!error && data) {
        savedEssay = data;
      }
    }

    res.json({
      status: 'success',
      modelUsed: aiResult.modelUsed,
      essay: {
        id: savedEssay?.id || `ess_${Date.now()}`,
        title: title,
        category: category || 'Job Interview',
        subTopic: subTopic || 'STAR Method',
        difficulty: difficulty || 'C1',
        tone: tone || 'Professional',
        content: aiResult.content,
        createdAt: savedEssay?.created_at || new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error in generate-essay route:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// In-memory cache for dictionary lookups to optimize performance and prevent API abuse
const dictionaryCache = new Map();

/**
 * GET /api/ai/dictionary/:word
 * Free dictionary & translation API lookup (Zero AI cost)
 * Uses FreeDictionaryAPI for phonetics & English definition, plus MyMemory for Indonesian translation.
 */
router.get('/dictionary/:word', async (req, res) => {
  const rawWord = req.params.word.trim().toLowerCase();
  if (!rawWord) {
    return res.status(400).json({ status: 'error', message: 'Word is required' });
  }

  // Check cache first
  if (dictionaryCache.has(rawWord)) {
    return res.json({ status: 'success', source: 'cache', data: dictionaryCache.get(rawWord) });
  }

  try {
    let phonetic = `/${rawWord}/`;
    let definition = 'Kata kunci profesional untuk kefasihan berbicara.';
    let indonesianMeaning = '';

    // 1. Fetch English phonetic & definition from FreeDictionaryAPI (Free Open Source)
    try {
      const dictRes = await fetch(`https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(rawWord)}`);
      if (dictRes.ok) {
        const dictData = await dictRes.json();
        if (Array.isArray(dictData) && dictData.length > 0) {
          const entry = dictData[0];
          if (entry.phonetic) {
            phonetic = entry.phonetic;
          } else if (entry.phonetics && entry.phonetics.length > 0) {
            const foundPhonetic = entry.phonetics.find(p => p.text);
            if (foundPhonetic) phonetic = foundPhonetic.text;
          }

          if (entry.meanings && entry.meanings.length > 0) {
            const defs = entry.meanings[0].definitions;
            if (defs && defs.length > 0) {
              definition = defs[0].definition;
            }
          }
        }
      }
    } catch (err) {
      console.warn(`[DictionaryAPI] Failed lookup for ${rawWord}:`, err.message);
    }

    // 2. Fetch Indonesian translation from MyMemory Free API (Free 1000 requests/day without key)
    try {
      const transRes = await fetch(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(rawWord)}&langpair=en|id`);
      if (transRes.ok) {
        const transData = await transRes.json();
        if (transData.responseData && transData.responseData.translatedText) {
          const text = transData.responseData.translatedText.trim();
          if (text && text.toLowerCase() !== rawWord) {
            indonesianMeaning = text;
          }
        }
      }
    } catch (err) {
      console.warn(`[MyMemory] Failed translation for ${rawWord}:`, err.message);
    }

    if (!indonesianMeaning) {
      indonesianMeaning = rawWord; // fallback
    }

    const resultData = {
      word: rawWord,
      phonetic,
      definition,
      indonesianMeaning
    };

    // Save to cache
    dictionaryCache.set(rawWord, resultData);

    res.json({
      status: 'success',
      source: 'api',
      data: resultData
    });
  } catch (error) {
    console.error(`[DictionaryRoute] Error fetching for ${rawWord}:`, error);
    res.json({
      status: 'success',
      source: 'fallback',
      data: {
        word: rawWord,
        phonetic: `/${rawWord}/`,
        definition: 'Kata kunci kosa kata.',
        indonesianMeaning: rawWord
      }
    });
  }
});

module.exports = router;
