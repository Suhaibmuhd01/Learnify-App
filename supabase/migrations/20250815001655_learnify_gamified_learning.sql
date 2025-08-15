-- Location: supabase/migrations/20250815001655_learnify_gamified_learning.sql
-- Schema Analysis: Fresh database with no existing tables
-- Integration Type: Complete new schema for gamified learning platform
-- Dependencies: None (fresh project)

-- 1. Extensions & Types
CREATE TYPE public.user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TYPE public.difficulty_level AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE public.question_type AS ENUM ('multiple_choice', 'true_false', 'fill_blank');
CREATE TYPE public.quiz_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE public.achievement_type AS ENUM ('points', 'streak', 'quiz_complete', 'topic_master', 'daily_challenge');

-- 2. Core Tables
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    username TEXT UNIQUE,
    role public.user_role DEFAULT 'student'::public.user_role,
    avatar_url TEXT,
    total_points INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    level_number INTEGER DEFAULT 1,
    xp_points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_name TEXT,
    color_code TEXT,
    is_featured BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    type public.achievement_type NOT NULL,
    requirement_value INTEGER DEFAULT 0,
    points_reward INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    difficulty public.difficulty_level DEFAULT 'medium'::public.difficulty_level,
    status public.quiz_status DEFAULT 'draft'::public.quiz_status,
    time_limit_minutes INTEGER,
    total_questions INTEGER DEFAULT 0,
    is_daily_challenge BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    type public.question_type DEFAULT 'multiple_choice'::public.question_type,
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    points_value INTEGER DEFAULT 10,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.question_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE public.user_quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
    score INTEGER DEFAULT 0,
    total_questions INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    time_taken_seconds INTEGER,
    completed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_completed BOOLEAN DEFAULT false
);

CREATE TABLE public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);

CREATE TABLE public.user_topic_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES public.topics(id) ON DELETE CASCADE,
    quizzes_completed INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    mastery_percentage DECIMAL(5,2) DEFAULT 0.00,
    last_activity TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, topic_id)
);

CREATE TABLE public.daily_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_date DATE NOT NULL UNIQUE,
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
    bonus_points INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_topics_is_featured ON public.topics(is_featured);
CREATE INDEX idx_topics_sort_order ON public.topics(sort_order);
CREATE INDEX idx_quizzes_topic_id ON public.quizzes(topic_id);
CREATE INDEX idx_quizzes_creator_id ON public.quizzes(creator_id);
CREATE INDEX idx_quizzes_status ON public.quizzes(status);
CREATE INDEX idx_quizzes_is_daily_challenge ON public.quizzes(is_daily_challenge);
CREATE INDEX idx_questions_quiz_id ON public.questions(quiz_id);
CREATE INDEX idx_question_options_question_id ON public.question_options(question_id);
CREATE INDEX idx_user_quiz_attempts_user_id ON public.user_quiz_attempts(user_id);
CREATE INDEX idx_user_quiz_attempts_quiz_id ON public.user_quiz_attempts(quiz_id);
CREATE INDEX idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX idx_user_topic_progress_user_id ON public.user_topic_progress(user_id);
CREATE INDEX idx_daily_challenges_date ON public.daily_challenges(challenge_date);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.update_user_level()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Update level based on XP points (every 1000 XP = 1 level)
  NEW.level_number = GREATEST(1, (NEW.xp_points / 1000) + 1);
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, username, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')::public.user_role
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.calculate_quiz_statistics(quiz_uuid UUID)
RETURNS TABLE(
    total_attempts INTEGER,
    average_score DECIMAL(5,2),
    completion_rate DECIMAL(5,2)
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    COUNT(*)::INTEGER as total_attempts,
    COALESCE(AVG(score), 0)::DECIMAL(5,2) as average_score,
    COALESCE(
        (COUNT(*) FILTER (WHERE is_completed = true) * 100.0 / NULLIF(COUNT(*), 0)), 
        0
    )::DECIMAL(5,2) as completion_rate
FROM public.user_quiz_attempts 
WHERE quiz_id = quiz_uuid;
$$;

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_topic_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_challenges ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Using Updated Pattern System)

-- Pattern 1: Core user table - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for topics
CREATE POLICY "public_can_read_topics"
ON public.topics
FOR SELECT
TO public
USING (true);

CREATE POLICY "teachers_manage_topics"
ON public.topics
FOR ALL
TO authenticated
USING ((SELECT role FROM public.user_profiles WHERE id = auth.uid()) IN ('teacher', 'admin'))
WITH CHECK ((SELECT role FROM public.user_profiles WHERE id = auth.uid()) IN ('teacher', 'admin'));

-- Pattern 4: Public read for achievements
CREATE POLICY "public_can_read_achievements"
ON public.achievements
FOR SELECT
TO public
USING (true);

CREATE POLICY "admins_manage_achievements"
ON public.achievements
FOR ALL
TO authenticated
USING ((SELECT role FROM public.user_profiles WHERE id = auth.uid()) = 'admin')
WITH CHECK ((SELECT role FROM public.user_profiles WHERE id = auth.uid()) = 'admin');

-- Pattern 2: Simple user ownership for quizzes
CREATE POLICY "users_manage_own_quizzes"
ON public.quizzes
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

CREATE POLICY "public_can_read_published_quizzes"
ON public.quizzes
FOR SELECT
TO public
USING (status = 'published'::public.quiz_status);

-- Pattern 2: Quiz creators manage their questions
CREATE POLICY "quiz_creators_manage_questions"
ON public.questions
FOR ALL
TO authenticated
USING ((SELECT creator_id FROM public.quizzes WHERE id = quiz_id) = auth.uid())
WITH CHECK ((SELECT creator_id FROM public.quizzes WHERE id = quiz_id) = auth.uid());

CREATE POLICY "public_can_read_published_questions"
ON public.questions
FOR SELECT
TO public
USING ((SELECT status FROM public.quizzes WHERE id = quiz_id) = 'published'::public.quiz_status);

-- Pattern 2: Question owners manage options
CREATE POLICY "question_owners_manage_options"
ON public.question_options
FOR ALL
TO authenticated
USING ((SELECT q.quiz_id FROM public.questions q WHERE q.id = question_id) IN (SELECT id FROM public.quizzes WHERE creator_id = auth.uid()))
WITH CHECK ((SELECT q.quiz_id FROM public.questions q WHERE q.id = question_id) IN (SELECT id FROM public.quizzes WHERE creator_id = auth.uid()));

CREATE POLICY "public_can_read_published_options"
ON public.question_options
FOR SELECT
TO public
USING (
    (SELECT qz.status FROM public.questions q 
     JOIN public.quizzes qz ON q.quiz_id = qz.id 
     WHERE q.id = question_id) = 'published'::public.quiz_status
);

-- Pattern 2: Simple user ownership for quiz attempts
CREATE POLICY "users_manage_own_quiz_attempts"
ON public.user_quiz_attempts
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for achievements
CREATE POLICY "users_manage_own_achievements"
ON public.user_achievements
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for topic progress
CREATE POLICY "users_manage_own_topic_progress"
ON public.user_topic_progress
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for daily challenges
CREATE POLICY "public_can_read_daily_challenges"
ON public.daily_challenges
FOR SELECT
TO public
USING (true);

CREATE POLICY "admins_manage_daily_challenges"
ON public.daily_challenges
FOR ALL
TO authenticated
USING ((SELECT role FROM public.user_profiles WHERE id = auth.uid()) = 'admin')
WITH CHECK ((SELECT role FROM public.user_profiles WHERE id = auth.uid()) = 'admin');

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_level_trigger
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW 
    WHEN (OLD.xp_points IS DISTINCT FROM NEW.xp_points)
    EXECUTE FUNCTION public.update_user_level();

-- 8. Mock Data
DO $$
DECLARE
    student_uuid UUID := gen_random_uuid();
    teacher_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    topic_math_uuid UUID := gen_random_uuid();
    topic_science_uuid UUID := gen_random_uuid();
    topic_history_uuid UUID := gen_random_uuid();
    quiz_math_uuid UUID := gen_random_uuid();
    quiz_science_uuid UUID := gen_random_uuid();
    achievement1_uuid UUID := gen_random_uuid();
    achievement2_uuid UUID := gen_random_uuid();
    question1_uuid UUID := gen_random_uuid();
    question2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (student_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'student@learnify.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Alex Student", "username": "alex_student"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (teacher_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'teacher@learnify.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Teacher", "username": "sarah_teacher", "role": "teacher"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@learnify.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Admin", "username": "john_admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert topics
    INSERT INTO public.topics (id, name, description, icon_name, color_code, is_featured, sort_order) VALUES
        (topic_math_uuid, 'Mathematics', 'Numbers, algebra, geometry and more', 'calculate', '#2196F3', true, 1),
        (topic_science_uuid, 'Science', 'Physics, chemistry, biology fundamentals', 'science', '#4CAF50', true, 2),
        (topic_history_uuid, 'History', 'World history and historical events', 'history_edu', '#FF9800', false, 3);

    -- Insert achievements
    INSERT INTO public.achievements (id, name, description, icon_name, type, requirement_value, points_reward) VALUES
        (achievement1_uuid, 'First Steps', 'Complete your first quiz', 'star', 'quiz_complete', 1, 50),
        (achievement2_uuid, 'Math Master', 'Score 90% or higher in 5 math quizzes', 'school', 'topic_master', 5, 200);

    -- Insert quizzes
    INSERT INTO public.quizzes (id, title, description, topic_id, creator_id, difficulty, status, time_limit_minutes, is_daily_challenge) VALUES
        (quiz_math_uuid, 'Basic Algebra', 'Test your knowledge of basic algebraic concepts', topic_math_uuid, teacher_uuid, 'easy', 'published', 15, false),
        (quiz_science_uuid, 'States of Matter', 'Learn about solids, liquids, and gases', topic_science_uuid, teacher_uuid, 'medium', 'published', 20, true);

    -- Insert questions
    INSERT INTO public.questions (id, quiz_id, question_text, type, correct_answer, explanation, points_value, sort_order) VALUES
        (question1_uuid, quiz_math_uuid, 'What is the value of x in the equation 2x + 4 = 10?', 'multiple_choice', '3', 'Subtract 4 from both sides, then divide by 2: 2x = 6, so x = 3', 10, 1),
        (question2_uuid, quiz_science_uuid, 'Water turns into ice when it freezes. What state of matter is ice?', 'multiple_choice', 'Solid', 'Ice is the solid form of water. When water freezes, molecules slow down and form a rigid structure.', 10, 1);

    -- Insert question options
    INSERT INTO public.question_options (question_id, option_text, is_correct, sort_order) VALUES
        (question1_uuid, '2', false, 1),
        (question1_uuid, '3', true, 2),
        (question1_uuid, '4', false, 3),
        (question1_uuid, '6', false, 4),
        (question2_uuid, 'Liquid', false, 1),
        (question2_uuid, 'Gas', false, 2),
        (question2_uuid, 'Solid', true, 3),
        (question2_uuid, 'Plasma', false, 4);

    -- Update quiz question counts
    UPDATE public.quizzes SET total_questions = (
        SELECT COUNT(*) FROM public.questions WHERE quiz_id = quiz_math_uuid
    ) WHERE id = quiz_math_uuid;
    
    UPDATE public.quizzes SET total_questions = (
        SELECT COUNT(*) FROM public.questions WHERE quiz_id = quiz_science_uuid
    ) WHERE id = quiz_science_uuid;

    -- Insert sample user quiz attempts
    INSERT INTO public.user_quiz_attempts (user_id, quiz_id, score, total_questions, correct_answers, time_taken_seconds, is_completed) VALUES
        (student_uuid, quiz_math_uuid, 80, 1, 1, 300, true);

    -- Insert user achievements
    INSERT INTO public.user_achievements (user_id, achievement_id) VALUES
        (student_uuid, achievement1_uuid);

    -- Insert topic progress
    INSERT INTO public.user_topic_progress (user_id, topic_id, quizzes_completed, total_points, mastery_percentage) VALUES
        (student_uuid, topic_math_uuid, 1, 80, 80.00);

    -- Insert daily challenge
    INSERT INTO public.daily_challenges (challenge_date, quiz_id, bonus_points) VALUES
        (CURRENT_DATE, quiz_science_uuid, 50);

    -- Update user profile with sample progress
    UPDATE public.user_profiles SET 
        total_points = 130, 
        xp_points = 130,
        current_streak = 1,
        longest_streak = 1,
        level_number = 1
    WHERE id = student_uuid;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;