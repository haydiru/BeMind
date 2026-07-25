const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase_service');

// CONTEXT VAULT ENDPOINTS
router.get('/contexts/:userId', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('user_contexts')
      .select('*')
      .eq('user_id', req.params.userId)
      .order('timestamp', { ascending: false });

    if (error) throw error;
    res.json({ status: 'success', data: data || [] });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

router.post('/contexts', async (req, res) => {
  const { userId, sourceType, title, content } = req.body;
  try {
    const { data, error } = await supabase
      .from('user_contexts')
      .insert({
        user_id: userId,
        source_type: sourceType || 'text',
        title: title,
        content: content
      })
      .select()
      .single();

    if (error) throw error;
    res.json({ status: 'success', data });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// VOCABULARY VAULT ENDPOINTS
router.get('/vocabularies/:userId', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('vocabularies')
      .select('*')
      .eq('user_id', req.params.userId)
      .order('added_at', { ascending: false });

    if (error) throw error;
    res.json({ status: 'success', data: data || [] });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

router.post('/vocabularies', async (req, res) => {
  const { userId, word, phonetic, definition, contextSentence, indonesianMeaning, masteryStatus } = req.body;
  try {
    const { data, error } = await supabase
      .from('vocabularies')
      .insert({
        user_id: userId,
        word,
        phonetic,
        definition,
        context_sentence: contextSentence,
        indonesian_meaning: indonesianMeaning,
        mastery_status: masteryStatus || 'learning'
      })
      .select()
      .single();

    if (error) throw error;
    res.json({ status: 'success', data });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

router.put('/vocabularies/:id/status', async (req, res) => {
  const { masteryStatus } = req.body;
  try {
    const { data, error } = await supabase
      .from('vocabularies')
      .update({ mastery_status: masteryStatus })
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
