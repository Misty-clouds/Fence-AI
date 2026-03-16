# Supabase Database Setup Guide

This guide will walk you through setting up the Supabase database for the Fence AI application, including creating tables, setting up Row Level Security (RLS) policies, and configuring authentication.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [Detailed Setup Steps](#detailed-setup-steps)
- [Database Schema](#database-schema)
- [Row Level Security (RLS)](#row-level-security-rls)
- [Testing the Setup](#testing-the-setup)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The Fence AI database consists of three main tables:

1. **users** - User profile information
2. **research_conversations** - Land research conversation sessions
3. **research_messages** - Messages within conversations (user and AI)

All tables are protected with Row Level Security (RLS) policies to ensure users can only access their own data.

---

## ✅ Prerequisites

Before you begin, ensure you have:

- A Supabase account ([Sign up here](https://supabase.com))
- A Supabase project created
- Your Supabase project URL and anon key
- Access to the Supabase SQL Editor

---

## 🚀 Quick Setup

### Option 1: Using Supabase Dashboard (Recommended)

1. **Go to your Supabase project dashboard**
   - Navigate to [https://app.supabase.com](https://app.supabase.com)
   - Select your project

2. **Open the SQL Editor**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Run the schema migration**
   - Copy the contents of `supabase/migrations/001_initial_schema.sql`
   - Paste into the SQL Editor
   - Click "Run" or press `Cmd/Ctrl + Enter`
   - Wait for success confirmation

4. **Run the RLS policies migration**
   - Create a new query
   - Copy the contents of `supabase/migrations/002_rls_policies.sql`
   - Paste into the SQL Editor
   - Click "Run"
   - Wait for success confirmation

5. **Verify the setup**
   - Go to "Table Editor" in the left sidebar
   - You should see three tables: `users`, `research_conversations`, `research_messages`

### Option 2: Using Supabase CLI

```bash
# Install Supabase CLI (if not already installed)
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push

# Or apply migrations manually
supabase db execute -f supabase/migrations/001_initial_schema.sql
supabase db execute -f supabase/migrations/002_rls_policies.sql
```

---

## 📝 Detailed Setup Steps

### Step 1: Create a Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Fill in the project details:
   - **Name**: Fence AI (or your preferred name)
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Select the closest region to your users
4. Click "Create new project"
5. Wait for the project to be provisioned (2-3 minutes)

### Step 2: Get Your API Credentials

1. In your project dashboard, go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (starts with `eyJ...`)
3. Add these to your mobile app's `.env` file:
   ```env
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGc...
   ```

### Step 3: Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Ensure **Email** is enabled
3. Configure email templates (optional):
   - Go to **Authentication** → **Email Templates**
   - Customize confirmation and password reset emails

### Step 4: Run Database Migrations

#### Using SQL Editor (Recommended for First-Time Setup)

1. **Navigate to SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "+ New query"

2. **Execute Initial Schema**
   ```sql
   -- Copy and paste the entire contents of:
   -- supabase/migrations/001_initial_schema.sql
   ```
   - Click "Run" (or `Cmd/Ctrl + Enter`)
   - You should see: "Success. No rows returned"

3. **Execute RLS Policies**
   - Create another new query
   ```sql
   -- Copy and paste the entire contents of:
   -- supabase/migrations/002_rls_policies.sql
   ```
   - Click "Run"
   - You should see: "Success. No rows returned"

### Step 5: Verify Tables Were Created

1. Go to **Table Editor** in the left sidebar
2. You should see three tables:
   - ✅ `users`
   - ✅ `research_conversations`
   - ✅ `research_messages`

3. Click on each table to verify the columns:

   **users table:**
   - `id` (uuid, primary key)
   - `created_at` (timestamptz)
   - `name` (text)
   - `email` (text)
   - `role` (text)

   **research_conversations table:**
   - `id` (uuid, primary key)
   - `created_at` (timestamptz)
   - `updated_at` (timestamptz)
   - `title` (text)
   - `location_data` (jsonb)
   - `researcher_id` (uuid, foreign key)

   **research_messages table:**
   - `id` (bigint, primary key)
   - `created_at` (timestamptz)
   - `content` (text)
   - `content_type` (text)
   - `message_type` (text)
   - `researcher_id` (uuid, foreign key)
   - `conversation_id` (uuid, foreign key)

### Step 6: Verify RLS Policies

1. Go to **Authentication** → **Policies**
2. Select each table and verify policies are enabled:

   **users table** should have:
   - ✅ "Users can view own profile"
   - ✅ "Users can insert own profile"
   - ✅ "Users can update own profile"
   - ✅ "Users can delete own profile"
   - ✅ "Admins can view all users"

   **research_conversations table** should have:
   - ✅ "Users can view own conversations"
   - ✅ "Users can insert own conversations"
   - ✅ "Users can update own conversations"
   - ✅ "Users can delete own conversations"
   - ✅ "Admins can view all conversations"

   **research_messages table** should have:
   - ✅ "Users can view messages in own conversations"
   - ✅ "Users can insert messages in own conversations"
   - ✅ "Allow AI received messages"
   - ✅ "Users can update messages in own conversations"
   - ✅ "Users can delete messages in own conversations"
   - ✅ "Admins can view all messages"

---

## 🗄️ Database Schema

### Entity Relationship Diagram

```
┌─────────────────────┐
│     auth.users      │ (Supabase Auth)
│  (Built-in table)   │
└──────────┬──────────┘
           │
           │ 1:1
           │
┌──────────▼──────────┐
│       users         │
├─────────────────────┤
│ id (PK, FK)         │
│ created_at          │
│ name                │
│ email               │
│ role                │
└──────────┬──────────┘
           │
           │ 1:N
           │
┌──────────▼──────────────────┐
│  research_conversations     │
├─────────────────────────────┤
│ id (PK)                     │
│ created_at                  │
│ updated_at                  │
│ title                       │
│ location_data (JSONB)       │
│ researcher_id (FK)          │
└──────────┬──────────────────┘
           │
           │ 1:N
           │
┌──────────▼──────────────────┐
│    research_messages        │
├─────────────────────────────┤
│ id (PK)                     │
│ created_at                  │
│ content                     │
│ content_type                │
│ message_type                │
│ researcher_id (FK)          │
│ conversation_id (FK)        │
└─────────────────────────────┘
```

### Table Details

#### users
Stores user profile information linked to Supabase Auth.

| Column     | Type         | Description                          |
|------------|--------------|--------------------------------------|
| id         | UUID (PK)    | Links to auth.users                  |
| created_at | TIMESTAMPTZ  | Account creation timestamp           |
| name       | TEXT         | User's display name                  |
| email      | TEXT         | User's email (unique)                |
| role       | TEXT         | User role: 'user', 'admin', 'premium'|

#### research_conversations
Stores land research conversation sessions.

| Column        | Type         | Description                              |
|---------------|--------------|------------------------------------------|
| id            | UUID (PK)    | Unique conversation identifier           |
| created_at    | TIMESTAMPTZ  | Conversation creation timestamp          |
| updated_at    | TIMESTAMPTZ  | Last update timestamp (auto-updated)     |
| title         | TEXT         | Conversation title/name                  |
| location_data | JSONB        | Map location data and enriched info      |
| researcher_id | UUID (FK)    | Foreign key to users table               |

#### research_messages
Stores messages within conversations (user and AI).

| Column          | Type         | Description                                    |
|-----------------|--------------|------------------------------------------------|
| id              | BIGINT (PK)  | Unique message identifier (auto-increment)     |
| created_at      | TIMESTAMPTZ  | Message creation timestamp                     |
| content         | TEXT         | Message content                                |
| content_type    | TEXT         | 'text', 'image', 'file', 'audio_file'          |
| message_type    | TEXT         | 'sent' (user) or 'received' (AI)               |
| researcher_id   | UUID (FK)    | Foreign key to users (nullable for AI messages)|
| conversation_id | UUID (FK)    | Foreign key to research_conversations          |

---

## 🔒 Row Level Security (RLS)

### What is RLS?

Row Level Security (RLS) is a PostgreSQL feature that allows you to control which rows users can access in a table. Supabase uses RLS to ensure users can only see and modify their own data.

### RLS Policies Overview

#### Users Table
- ✅ Users can **view**, **insert**, **update**, and **delete** their own profile
- ✅ Admins can **view** all user profiles

#### Research Conversations Table
- ✅ Users can **view**, **insert**, **update**, and **delete** their own conversations
- ✅ Admins can **view** all conversations

#### Research Messages Table
- ✅ Users can **view**, **insert**, **update**, and **delete** messages in their own conversations
- ✅ AI can **insert** received messages (special policy)
- ✅ Admins can **view** all messages

### Helper Functions

Three helper functions are provided for easier policy management:

```sql
-- Check if current user is admin
SELECT public.is_admin();

-- Check if current user is premium
SELECT public.is_premium();

-- Check if current user owns a conversation
SELECT public.owns_conversation('conversation-uuid-here');
```

---

## 🧪 Testing the Setup

### Test 1: Create a Test User

1. Go to **Authentication** → **Users**
2. Click "Add user" → "Create new user"
3. Enter email and password
4. Click "Create user"

### Test 2: Verify User Profile Creation

1. Go to **Table Editor** → **users**
2. You should see the test user's profile
3. If not, manually insert:
   ```sql
   INSERT INTO public.users (id, email, name, role)
   VALUES (
     'auth-user-uuid-here',
     'test@example.com',
     'Test User',
     'user'
   );
   ```

### Test 3: Test RLS Policies

1. Go to **SQL Editor**
2. Run this test query:
   ```sql
   -- This should only return the authenticated user's data
   SELECT * FROM public.users WHERE id = auth.uid();
   ```

### Test 4: Test from Mobile App

1. Ensure your `.env` file has correct Supabase credentials
2. Run the mobile app
3. Sign up a new user
4. Verify the user appears in **Authentication** → **Users**
5. Verify the user profile is created in **Table Editor** → **users**

---

## 🔧 Troubleshooting

### Issue: "relation does not exist" error

**Solution**: The tables haven't been created yet. Run the migrations again.

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

### Issue: "new row violates row-level security policy"

**Solution**: RLS is blocking the operation. Check:
1. User is authenticated (`auth.uid()` returns a value)
2. The correct policies are in place
3. The user owns the resource they're trying to access

```sql
-- Check current user
SELECT auth.uid();

-- Temporarily disable RLS for testing (NOT for production!)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
```

### Issue: Foreign key constraint violation

**Solution**: Ensure the referenced record exists.

```sql
-- Check if user exists
SELECT * FROM public.users WHERE id = 'user-uuid-here';

-- Check if conversation exists
SELECT * FROM public.research_conversations WHERE id = 'conversation-uuid-here';
```

### Issue: "permission denied for table"

**Solution**: Grant necessary permissions.

```sql
-- Grant permissions to authenticated users
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.research_conversations TO authenticated;
GRANT ALL ON public.research_messages TO authenticated;

-- Grant usage on sequences
GRANT USAGE, SELECT ON SEQUENCE research_messages_id_seq TO authenticated;
```

### Issue: UUID generation not working

**Solution**: Enable the UUID extension.

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

---

## 📊 Database Maintenance

### Backup Your Database

1. Go to **Settings** → **Database**
2. Scroll to "Database backups"
3. Click "Create backup"

### View Database Statistics

```sql
-- Count records in each table
SELECT 
    'users' as table_name, 
    COUNT(*) as record_count 
FROM public.users
UNION ALL
SELECT 
    'research_conversations', 
    COUNT(*) 
FROM public.research_conversations
UNION ALL
SELECT 
    'research_messages', 
    COUNT(*) 
FROM public.research_messages;
```

### Monitor Performance

1. Go to **Reports** in the Supabase dashboard
2. View:
   - Database size
   - API requests
   - Active connections
   - Query performance

---

## 🚀 Next Steps

After setting up the database:

1. ✅ Configure your mobile app's `.env` file with Supabase credentials
2. ✅ Test user authentication in the mobile app
3. ✅ Test creating conversations and messages
4. ✅ Set up email templates for authentication
5. ✅ Configure storage buckets (if using file uploads)
6. ✅ Set up database backups
7. ✅ Monitor usage and performance

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase Database Documentation](https://supabase.com/docs/guides/database)

---

## 🆘 Support

If you encounter issues:

1. Check the [Supabase Discord](https://discord.supabase.com)
2. Review [Supabase GitHub Discussions](https://github.com/supabase/supabase/discussions)
3. Contact the Fence AI development team

---

**Database setup complete! 🎉**
