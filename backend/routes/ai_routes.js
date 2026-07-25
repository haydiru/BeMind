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
  } catch (err) {
    console.error('[AI Essay Route Error]:', err.message);
    res.status(500).json({ status: 'error', message: err.message });
  }
});

module.exports = router;
