-- =========================================================
-- BEMIND AI MOBILE APP — FULL SUPABASE POSTGRESQL SCHEMA DDL
-- =========================================================

-- 1. PROFILES TABLE (User Profile & Account Info)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    target_goal TEXT DEFAULT 'Job Interview Prep',
    role TEXT DEFAULT 'user', -- 'user' or 'admin'
    profile_completeness INT DEFAULT 85,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. SYSTEM CONFIG TABLE (For Admin Dynamic Model Switcher)
CREATE TABLE IF NOT EXISTS public.system_config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed default active AI model into system_config
INSERT INTO public.system_config (key, value, description)
VALUES ('active_ai_model', 'Qwen3.6-35B-A3B', 'Currently active LLM model used for narrative essay generation')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();

-- 3. USER CONTEXTS TABLE (Context Vault Data: Text, Voice, PDF, OCR)
CREATE TABLE IF NOT EXISTS public.user_contexts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    source_type TEXT NOT NULL CHECK (source_type IN ('text', 'voice', 'pdf', 'ocr')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PROMPT TEMPLATES TABLE (Community Template Marketplace / Canva for Prompts)
CREATE TABLE IF NOT EXISTS public.prompt_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    creator_name TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    template_structure TEXT NOT NULL,
    use_count INT DEFAULT 1,
    rating NUMERIC(3, 1) DEFAULT 5.0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed initial community prompt templates
INSERT INTO public.prompt_templates (id, creator_name, title, category, description, template_structure, use_count, rating, is_featured, is_public)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Sarah Jenkins (Ex-Google Recruiter)', 'STAR Method Interview Master', 'Job Interview', 'Formats your background experience into Situation, Task, Action, and Result bullet points designed for tech interviews.', 'Using the user background in {USER_CONTEXT}, construct a compelling STAR response for a senior tech role focusing on {TARGET_GOAL}.', 1420, 4.9, TRUE, TRUE),
('22222222-2222-2222-2222-222222222222', 'David Miller (IELTS Examiner)', 'IELTS Band 8.0 Fluency Synthesizer', 'IELTS/TOEFL', 'Generates speaking cue card responses rich in idiomatic collocations, advanced cohesion connectors, and C1/C2 vocabulary.', 'Transform user personal context {USER_CONTEXT} into an IELTS Speaking Part 2 response with advanced vocabulary.', 980, 4.8, TRUE, TRUE),
('33333333-3333-3333-3333-333333333333', 'Marcus Chen (Y Combinator Alumni)', '3-Minute Elevator Pitching Engine', 'Business Pitching', 'Crafts a high-impact startup elevator pitch highlighting problem, traction, unique moat, and vision.', 'Distill {USER_CONTEXT} into a 180-second high-energy pitch deck narration.', 750, 4.7, FALSE, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 5. GENERATED ESSAYS TABLE (History of AI-Generated Narratives for Teleprompter)
CREATE TABLE IF NOT EXISTS public.generated_essays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.prompt_templates(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    sub_topic TEXT,
    difficulty TEXT NOT NULL,
    tone TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. VOCABULARIES TABLE (Extracted Foreign Words & Practice Vault)
CREATE TABLE IF NOT EXISTS public.vocabularies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    word TEXT NOT NULL,
    phonetic TEXT,
    definition TEXT NOT NULL,
    context_sentence TEXT,
    indonesian_meaning TEXT NOT NULL,
    mastery_status TEXT DEFAULT 'learning' CHECK (mastery_status IN ('learning', 'mastered', 'review')),
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. USER SETTINGS TABLE (Passive Lockscreen Notification Settings)
CREATE TABLE IF NOT EXISTS public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT TRUE,
    frequency TEXT DEFAULT '5x a day',
    start_hour INT DEFAULT 8,
    end_hour INT DEFAULT 21,
    last_sync_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =========================================================
-- AUTOMATIC USER CREATION TRIGGER FOR SUPABASE AUTH
-- =========================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, name, target_goal, role, profile_completeness)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        'Job Interview Prep',
        COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
        85
    );

    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger execution on auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Enable Row Level Security (RLS) for privacy
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_contexts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prompt_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.generated_essays ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vocabularies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- Allow public reading of prompt_templates & system_config
CREATE POLICY "Public prompt templates read policy" ON public.prompt_templates FOR SELECT USING (is_public = true);
CREATE POLICY "Public system config read policy" ON public.system_config FOR SELECT USING (true);
