-- Fence AI Database Schema
-- This migration creates the initial database schema for the Fence AI application

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS TABLE
-- =====================================================
-- Stores user profile information
-- Links to Supabase Auth users via id (UUID)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    name TEXT,
    email TEXT UNIQUE,
    role TEXT DEFAULT 'user',
    CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'premium'))
);

-- Index for faster email lookups
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users(email);

-- Index for role-based queries
CREATE INDEX IF NOT EXISTS users_role_idx ON public.users(role);

-- =====================================================
-- RESEARCH CONVERSATIONS TABLE
-- =====================================================
-- Stores research conversation sessions
-- Each conversation represents a land research project
CREATE TABLE IF NOT EXISTS public.research_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    title TEXT,
    location_data JSONB,
    researcher_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE
);

-- Index for faster researcher lookups
CREATE INDEX IF NOT EXISTS research_conversations_researcher_idx ON public.research_conversations(researcher_id);

-- Index for date-based sorting
CREATE INDEX IF NOT EXISTS research_conversations_created_at_idx ON public.research_conversations(created_at DESC);

-- Index for location data queries (GIN index for JSONB)
CREATE INDEX IF NOT EXISTS research_conversations_location_data_idx ON public.research_conversations USING GIN(location_data);

-- =====================================================
-- RESEARCH MESSAGES TABLE
-- =====================================================
-- Stores messages within research conversations
-- Includes both user messages and AI responses
CREATE TABLE IF NOT EXISTS public.research_messages (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    content TEXT,
    content_type TEXT DEFAULT 'text',
    message_type TEXT DEFAULT 'sent',
    researcher_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    conversation_id UUID NOT NULL REFERENCES public.research_conversations(id) ON DELETE CASCADE,
    CONSTRAINT research_messages_content_type_check CHECK (content_type IN ('text', 'image', 'file', 'audio_file')),
    CONSTRAINT research_messages_message_type_check CHECK (message_type IN ('sent', 'received'))
);

-- Index for conversation message lookups
CREATE INDEX IF NOT EXISTS research_messages_conversation_idx ON public.research_messages(conversation_id, created_at);

-- Index for researcher message lookups
CREATE INDEX IF NOT EXISTS research_messages_researcher_idx ON public.research_messages(researcher_id);

-- Index for message type filtering
CREATE INDEX IF NOT EXISTS research_messages_type_idx ON public.research_messages(message_type);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on research_conversations
CREATE TRIGGER research_conversations_updated_at
    BEFORE UPDATE ON public.research_conversations
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.users IS 'User profile information linked to Supabase Auth';
COMMENT ON COLUMN public.users.id IS 'UUID from auth.users, primary key';
COMMENT ON COLUMN public.users.role IS 'User role: user, admin, or premium';

COMMENT ON TABLE public.research_conversations IS 'Research conversation sessions for land analysis';
COMMENT ON COLUMN public.research_conversations.location_data IS 'JSONB containing map location data, coordinates, and enriched information';
COMMENT ON COLUMN public.research_conversations.researcher_id IS 'Foreign key to users table';

COMMENT ON TABLE public.research_messages IS 'Messages within research conversations (user and AI)';
COMMENT ON COLUMN public.research_messages.content_type IS 'Type of content: text, image, file, or audio_file';
COMMENT ON COLUMN public.research_messages.message_type IS 'Direction: sent (user) or received (AI)';
COMMENT ON COLUMN public.research_messages.conversation_id IS 'Foreign key to research_conversations';
