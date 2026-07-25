const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase_service');
const { getActiveModel } = require('../services/ai_service');

const AVAILABLE_MODELS = [
  'Qwen3.6-35B-A3B',
  'gpt-4o',
  'gpt-4o-mini',
  'claude-3-5-sonnet',
  'gemini-1.5-flash',
  'deepseek-coder'
];

/**
 * GET /api/admin/model
 * Returns current active AI model and available model choices
 */
router.get('/model', async (req, res) => {
  try {
    const activeModel = await getActiveModel();
    res.json({
      status: 'success',
      activeModel: activeModel,
      availableModels: AVAILABLE_MODELS
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

/**
 * POST /api/admin/model
 * Allows Admin to dynamically switch active LLM model on the fly
 */
router.post('/model', async (req, res) => {
  const { model } = req.body;
  if (!model) {
    return res.status(400).json({ status: 'error', message: 'Model parameter is required' });
  }

  try {
    const { data, error } = await supabase
      .from('system_config')
      .upsert({
        key: 'active_ai_model',
        value: model,
        description: 'Currently active LLM model used for narrative essay generation',
        updated_at: new Date().toISOString()
      });

    if (error) throw error;

    console.log(`[Admin Model Switcher] Active model changed to: ${model}`);
    res.json({
      status: 'success',
      message: `Active AI model successfully updated to '${model}'`,
      activeModel: model
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

module.exports = router;
