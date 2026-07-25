const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase_service');

// GET all public prompt templates
router.get('/templates', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('prompt_templates')
      .select('*')
      .eq('is_public', true)
      .order('use_count', { ascending: false });

    if (error) throw error;
    res.json({ status: 'success', data: data || [] });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// POST publish new prompt template
router.post('/templates', async (req, res) => {
  const { creatorId, creatorName, title, category, description, templateStructure } = req.body;
  try {
    const { data, error } = await supabase
      .from('prompt_templates')
      .insert({
        creator_id: creatorId || null,
        creator_name: creatorName || 'Anonymous Creator',
        title,
        category,
        description,
        template_structure: templateStructure,
        use_count: 1,
        rating: 5.0,
        is_public: true
      })
      .select()
      .single();

    if (error) throw error;
    res.json({ status: 'success', data });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// POST increment remix template usage count
router.post('/templates/:id/remix', async (req, res) => {
  try {
    const { data: template } = await supabase
      .from('prompt_templates')
      .select('use_count')
      .eq('id', req.params.id)
      .single();

    const newCount = (template?.use_count || 0) + 1;

    const { data, error } = await supabase
      .from('prompt_templates')
      .update({ use_count: newCount })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;
    res.json({ status: 'success', data });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

module.exports = router;
