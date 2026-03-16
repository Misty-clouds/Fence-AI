-- Fence AI Row Level Security (RLS) Policies
-- This migration sets up security policies to ensure users can only access their own data

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_messages ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- USERS TABLE POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete own profile"
    ON public.users
    FOR DELETE
    USING (auth.uid() = id);

-- Admins can view all users
CREATE POLICY "Admins can view all users"
    ON public.users
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- RESEARCH CONVERSATIONS TABLE POLICIES
-- =====================================================

-- Users can view their own conversations
CREATE POLICY "Users can view own conversations"
    ON public.research_conversations
    FOR SELECT
    USING (auth.uid() = researcher_id);

-- Users can insert their own conversations
CREATE POLICY "Users can insert own conversations"
    ON public.research_conversations
    FOR INSERT
    WITH CHECK (auth.uid() = researcher_id);

-- Users can update their own conversations
CREATE POLICY "Users can update own conversations"
    ON public.research_conversations
    FOR UPDATE
    USING (auth.uid() = researcher_id)
    WITH CHECK (auth.uid() = researcher_id);

-- Users can delete their own conversations
CREATE POLICY "Users can delete own conversations"
    ON public.research_conversations
    FOR DELETE
    USING (auth.uid() = researcher_id);

-- Admins can view all conversations
CREATE POLICY "Admins can view all conversations"
    ON public.research_conversations
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- RESEARCH MESSAGES TABLE POLICIES
-- =====================================================

-- Users can view messages in their own conversations
CREATE POLICY "Users can view messages in own conversations"
    ON public.research_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.research_conversations
            WHERE id = research_messages.conversation_id
            AND researcher_id = auth.uid()
        )
    );

-- Users can insert messages in their own conversations
CREATE POLICY "Users can insert messages in own conversations"
    ON public.research_messages
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.research_conversations
            WHERE id = conversation_id
            AND researcher_id = auth.uid()
        )
    );

-- Allow AI to insert received messages (no researcher_id check)
CREATE POLICY "Allow AI received messages"
    ON public.research_messages
    FOR INSERT
    WITH CHECK (
        message_type = 'received'
        AND EXISTS (
            SELECT 1 FROM public.research_conversations
            WHERE id = conversation_id
            AND researcher_id = auth.uid()
        )
    );

-- Users can update messages in their own conversations
CREATE POLICY "Users can update messages in own conversations"
    ON public.research_messages
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.research_conversations
            WHERE id = research_messages.conversation_id
            AND researcher_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.research_conversations
            WHERE id = conversation_id
            AND researcher_id = auth.uid()
        )
    );

-- Users can delete messages in their own conversations
CREATE POLICY "Users can delete messages in own conversations"
    ON public.research_messages
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.research_conversations
            WHERE id = research_messages.conversation_id
            AND researcher_id = auth.uid()
        )
    );

-- Admins can view all messages
CREATE POLICY "Admins can view all messages"
    ON public.research_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- HELPER FUNCTIONS FOR RLS
-- =====================================================

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is premium
CREATE OR REPLACE FUNCTION public.is_premium()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND role IN ('premium', 'admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user owns conversation
CREATE OR REPLACE FUNCTION public.owns_conversation(conversation_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.research_conversations
        WHERE id = conversation_uuid AND researcher_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON POLICY "Users can view own profile" ON public.users IS 'Users can only view their own profile data';
COMMENT ON POLICY "Admins can view all users" ON public.users IS 'Admin users can view all user profiles';
COMMENT ON POLICY "Users can view own conversations" ON public.research_conversations IS 'Users can only view conversations they created';
COMMENT ON POLICY "Users can view messages in own conversations" ON public.research_messages IS 'Users can only view messages in their own conversations';
COMMENT ON POLICY "Allow AI received messages" ON public.research_messages IS 'Allows AI-generated messages to be inserted without researcher_id';

COMMENT ON FUNCTION public.is_admin() IS 'Helper function to check if current user is an admin';
COMMENT ON FUNCTION public.is_premium() IS 'Helper function to check if current user has premium access';
COMMENT ON FUNCTION public.owns_conversation(UUID) IS 'Helper function to check if current user owns a conversation';
