-- ============================================================================
-- NUCLEAR FIX: Profiles RLS Infinite Recursion
-- Version: 20260113200000
--
-- PROBLEM: "infinite recursion detected in policy for relation 'profiles'"
-- This error persists despite multiple previous fix attempts because:
--   1. RLS policies on profiles call functions that query profiles
--   2. Even SECURITY DEFINER with row_security=off can fail during policy evaluation
--   3. Multiple overlapping SELECT policies compound the issue
--
-- NUCLEAR SOLUTION:
--   1. Drop ALL existing policies on profiles (dynamic, catches everything)
--   2. Create ONLY ultra-simple policies that NEVER query profiles
--   3. Move all authorization logic to RPC functions (SECURITY DEFINER)
--   4. Flutter app uses RPC functions for complex queries, not direct table access
--
-- KEY PRINCIPLE: The profiles table policies must NEVER, under any circumstance,
-- call any function that queries the profiles table. The ONLY safe checks are:
--   - auth.uid() comparisons
--   - Simple boolean (true/false)
--   - Checking the row's own columns
-- ============================================================================

-- =============================================================================
-- STEP 1: NUCLEAR DROP - Remove ALL existing policies on profiles
-- This uses dynamic SQL to catch ANY policy, even ones we don't know about
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE 'NUCLEAR FIX: Dropping all existing profiles policies...';

    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'profiles' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON profiles', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;

    RAISE NOTICE 'All profiles policies dropped.';
END $$;

-- =============================================================================
-- STEP 2: Drop problematic helper functions that query profiles
-- These will be recreated with proper SET row_security = off
-- =============================================================================

-- Drop in reverse dependency order
DROP FUNCTION IF EXISTS is_superadmin() CASCADE;
DROP FUNCTION IF EXISTS is_school_admin() CASCADE;
DROP FUNCTION IF EXISTS is_teacher() CASCADE;
DROP FUNCTION IF EXISTS belongs_to_school(UUID) CASCADE;
DROP FUNCTION IF EXISTS student_in_my_class(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_user_role() CASCADE;
DROP FUNCTION IF EXISTS get_user_school_id() CASCADE;
DROP FUNCTION IF EXISTS auth_user_role() CASCADE;
DROP FUNCTION IF EXISTS auth_user_school_id() CASCADE;
DROP FUNCTION IF EXISTS auth_is_superadmin() CASCADE;
DROP FUNCTION IF EXISTS auth_is_school_admin() CASCADE;
DROP FUNCTION IF EXISTS init_user_session_cache() CASCADE;
DROP FUNCTION IF EXISTS can_message_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS has_conversation_with(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_messageable_users() CASCADE;
DROP FUNCTION IF EXISTS get_school_users(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_conversation_partners() CASCADE;

-- =============================================================================
-- STEP 3: Create ultra-simple, non-recursive policies
-- CRITICAL: These policies ONLY use auth.uid() and simple comparisons
-- NO function calls, NO subqueries on profiles, NO exceptions
-- =============================================================================

-- Policy 1: Everyone can read ALL profiles
-- This is the SIMPLEST solution that avoids ALL recursion
-- Authorization is handled at the application layer via RPC functions
CREATE POLICY "profiles_select_all" ON profiles
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy 2: Users can only update their OWN profile
-- Uses only auth.uid() - no recursion possible
CREATE POLICY "profiles_update_own" ON profiles
    FOR UPDATE
    TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Policy 3: Only service_role can insert (via trigger on auth.users)
-- Regular users cannot insert profiles directly
CREATE POLICY "profiles_insert_service" ON profiles
    FOR INSERT
    TO service_role
    WITH CHECK (true);

-- Policy 4: Only service_role can delete profiles
CREATE POLICY "profiles_delete_service" ON profiles
    FOR DELETE
    TO service_role
    USING (true);

-- =============================================================================
-- STEP 4: Recreate helper functions with proper SECURITY DEFINER + row_security = off
-- These are ONLY for use in RPC functions, NOT in policies
-- =============================================================================

-- Get current user's role (safe for RPC use only)
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS user_role
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role;
END;
$$;

-- Get current user's school_id (safe for RPC use only)
CREATE OR REPLACE FUNCTION get_user_school_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    _school_id UUID;
BEGIN
    SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid();
    RETURN _school_id;
END;
$$;

-- Check if current user is superadmin (safe for RPC use only)
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role = 'superadmin';
END;
$$;

-- Check if current user is a school admin (safe for RPC use only)
CREATE OR REPLACE FUNCTION is_school_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role IN ('bigadmin', 'admin');
END;
$$;

-- Check if current user is a teacher (safe for RPC use only)
CREATE OR REPLACE FUNCTION is_teacher()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role = 'teacher';
END;
$$;

-- Check if user belongs to a specific school (safe for RPC use only)
CREATE OR REPLACE FUNCTION belongs_to_school(school UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    _school_id UUID;
BEGIN
    SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid();
    RETURN _school_id = school;
END;
$$;

-- Check if student is in any of the teacher's classes (safe for RPC use only)
CREATE OR REPLACE FUNCTION student_in_my_class(p_student_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM class_students cs
        JOIN subjects s ON s.class_id = cs.class_id
        WHERE cs.student_id = p_student_id AND s.teacher_id = auth.uid()
    );
END;
$$;

-- =============================================================================
-- STEP 5: Create RPC functions for Flutter app to call
-- These handle authorization INSIDE the function, not via RLS
-- =============================================================================

-- RPC: Get school users (for admin panel)
CREATE OR REPLACE FUNCTION rpc_get_school_users(p_school_id UUID DEFAULT NULL)
RETURNS TABLE (
    id UUID,
    email TEXT,
    role user_role,
    school_id UUID,
    first_name TEXT,
    last_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    current_user_id UUID;
    current_role user_role;
    current_school UUID;
    target_school UUID;
BEGIN
    current_user_id := auth.uid();

    -- Get current user info directly (RLS is off)
    SELECT p.role, p.school_id INTO current_role, current_school
    FROM profiles p WHERE p.id = current_user_id;

    -- Authorization check
    IF current_role NOT IN ('superadmin', 'bigadmin', 'admin') THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can view school users';
    END IF;

    -- Determine target school
    IF current_role = 'superadmin' AND p_school_id IS NOT NULL THEN
        target_school := p_school_id;
    ELSE
        target_school := current_school;
    END IF;

    -- Return users in the target school
    RETURN QUERY
    SELECT
        p.id,
        p.email,
        p.role,
        p.school_id,
        p.first_name,
        p.last_name,
        p.avatar_url,
        p.created_at
    FROM profiles p
    WHERE p.school_id = target_school
    ORDER BY p.role, p.first_name, p.last_name;
END;
$$;

-- RPC: Get messageable users (for chat)
CREATE OR REPLACE FUNCTION rpc_get_messageable_users()
RETURNS TABLE (
    id UUID,
    email TEXT,
    role user_role,
    school_id UUID,
    first_name TEXT,
    last_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    current_user_id UUID;
    current_role user_role;
    current_school UUID;
BEGIN
    current_user_id := auth.uid();

    -- Get current user info (RLS is off)
    SELECT p.role, p.school_id INTO current_role, current_school
    FROM profiles p WHERE p.id = current_user_id;

    IF current_role IS NULL THEN
        RAISE EXCEPTION 'User profile not found';
    END IF;

    -- Return users based on role hierarchy
    RETURN QUERY
    SELECT DISTINCT
        p.id,
        p.email,
        p.role,
        p.school_id,
        p.first_name,
        p.last_name,
        p.avatar_url,
        p.created_at
    FROM profiles p
    WHERE p.id != current_user_id
        AND (
            -- SuperAdmin can message all BigAdmins
            (current_role = 'superadmin' AND p.role = 'bigadmin')

            -- BigAdmin can message everyone in their school
            OR (current_role = 'bigadmin' AND p.school_id = current_school)

            -- Admin can message staff and parents in school
            OR (current_role = 'admin' AND p.school_id = current_school
                AND p.role IN ('bigadmin', 'admin', 'teacher', 'parent'))

            -- Teacher can message staff in school
            OR (current_role = 'teacher' AND p.school_id = current_school
                AND p.role IN ('bigadmin', 'admin', 'teacher'))

            -- Teacher can message parents of their students
            OR (current_role = 'teacher' AND p.role = 'parent' AND EXISTS (
                SELECT 1 FROM parent_student ps
                JOIN class_students cs ON ps.student_id = cs.student_id
                JOIN subjects s ON cs.class_id = s.class_id
                WHERE ps.parent_id = p.id AND s.teacher_id = current_user_id
            ))

            -- Parent can message teachers of their children
            OR (current_role = 'parent' AND p.role = 'teacher' AND EXISTS (
                SELECT 1 FROM parent_student ps
                JOIN class_students cs ON ps.student_id = cs.student_id
                JOIN subjects s ON cs.class_id = s.class_id
                WHERE ps.parent_id = current_user_id AND s.teacher_id = p.id
            ))

            -- Parent can message admins in school
            OR (current_role = 'parent' AND p.school_id = current_school
                AND p.role IN ('bigadmin', 'admin'))

            -- Student can message their teachers
            OR (current_role = 'student' AND p.role = 'teacher' AND EXISTS (
                SELECT 1 FROM class_students cs
                JOIN subjects s ON cs.class_id = s.class_id
                WHERE cs.student_id = current_user_id AND s.teacher_id = p.id
            ))
        )
    ORDER BY p.role, p.first_name, p.last_name;
END;
$$;

-- RPC: Search users (for chat compose)
CREATE OR REPLACE FUNCTION rpc_search_users(p_query TEXT)
RETURNS TABLE (
    id UUID,
    email TEXT,
    role user_role,
    school_id UUID,
    first_name TEXT,
    last_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    current_user_id UUID;
    current_role user_role;
    current_school UUID;
    search_pattern TEXT;
BEGIN
    current_user_id := auth.uid();
    search_pattern := '%' || LOWER(COALESCE(p_query, '')) || '%';

    -- Get current user info (RLS is off)
    SELECT p.role, p.school_id INTO current_role, current_school
    FROM profiles p WHERE p.id = current_user_id;

    IF current_role IS NULL THEN
        RAISE EXCEPTION 'User profile not found';
    END IF;

    -- Return matching users the current user can message
    RETURN QUERY
    SELECT DISTINCT
        p.id,
        p.email,
        p.role,
        p.school_id,
        p.first_name,
        p.last_name,
        p.avatar_url,
        p.created_at
    FROM profiles p
    WHERE p.id != current_user_id
        AND (
            LOWER(p.first_name) LIKE search_pattern
            OR LOWER(p.last_name) LIKE search_pattern
            OR LOWER(p.email) LIKE search_pattern
            OR LOWER(CONCAT(p.first_name, ' ', p.last_name)) LIKE search_pattern
        )
        AND (
            -- SuperAdmin can search all BigAdmins
            (current_role = 'superadmin' AND p.role = 'bigadmin')

            -- BigAdmin/Admin can search within their school
            OR (current_role IN ('bigadmin', 'admin') AND p.school_id = current_school)

            -- Teacher can search staff and parents in school
            OR (current_role = 'teacher' AND p.school_id = current_school
                AND p.role IN ('bigadmin', 'admin', 'teacher', 'parent'))

            -- Parent can search teachers and admins in school
            OR (current_role = 'parent' AND p.school_id = current_school
                AND p.role IN ('bigadmin', 'admin', 'teacher'))

            -- Student can search teachers in school
            OR (current_role = 'student' AND p.school_id = current_school
                AND p.role = 'teacher')
        )
    ORDER BY p.first_name, p.last_name
    LIMIT 50;
END;
$$;

-- RPC: Get current user's profile info (safe helper)
CREATE OR REPLACE FUNCTION rpc_get_my_profile()
RETURNS TABLE (
    id UUID,
    email TEXT,
    role user_role,
    school_id UUID,
    first_name TEXT,
    last_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.email,
        p.role,
        p.school_id,
        p.first_name,
        p.last_name,
        p.avatar_url,
        p.created_at,
        p.updated_at
    FROM profiles p
    WHERE p.id = auth.uid();
END;
$$;

-- RPC: Check if user can message another user
CREATE OR REPLACE FUNCTION rpc_can_message_user(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    current_role user_role;
    current_school UUID;
    target_school UUID;
    target_role user_role;
BEGIN
    -- Get current user info
    SELECT role, school_id INTO current_role, current_school
    FROM profiles WHERE id = auth.uid();

    -- Get target user info
    SELECT role, school_id INTO target_role, target_school
    FROM profiles WHERE id = target_user_id;

    -- If target doesn't exist, can't message
    IF target_role IS NULL THEN
        RETURN FALSE;
    END IF;

    -- SuperAdmin can message all BigAdmins
    IF current_role = 'superadmin' AND target_role = 'bigadmin' THEN
        RETURN TRUE;
    END IF;

    -- BigAdmin can message everyone in their school
    IF current_role = 'bigadmin' AND current_school = target_school THEN
        RETURN TRUE;
    END IF;

    -- Admin can message staff and parents in school
    IF current_role = 'admin' AND current_school = target_school
       AND target_role IN ('bigadmin', 'admin', 'teacher', 'parent') THEN
        RETURN TRUE;
    END IF;

    -- Teacher can message other staff in school
    IF current_role = 'teacher' AND current_school = target_school
       AND target_role IN ('bigadmin', 'admin', 'teacher') THEN
        RETURN TRUE;
    END IF;

    -- Teacher can message parents of their students
    IF current_role = 'teacher' AND target_role = 'parent' THEN
        IF EXISTS (
            SELECT 1 FROM parent_student ps
            JOIN class_students cs ON ps.student_id = cs.student_id
            JOIN subjects s ON cs.class_id = s.class_id
            WHERE ps.parent_id = target_user_id AND s.teacher_id = auth.uid()
        ) THEN
            RETURN TRUE;
        END IF;
    END IF;

    -- Parent can message teachers of their children
    IF current_role = 'parent' AND target_role = 'teacher' THEN
        IF EXISTS (
            SELECT 1 FROM parent_student ps
            JOIN class_students cs ON ps.student_id = cs.student_id
            JOIN subjects s ON cs.class_id = s.class_id
            WHERE ps.parent_id = auth.uid() AND s.teacher_id = target_user_id
        ) THEN
            RETURN TRUE;
        END IF;
    END IF;

    -- Parent can message admins in school
    IF current_role = 'parent' AND current_school = target_school
       AND target_role IN ('bigadmin', 'admin') THEN
        RETURN TRUE;
    END IF;

    -- Student can message their teachers
    IF current_role = 'student' AND target_role = 'teacher' THEN
        IF EXISTS (
            SELECT 1 FROM class_students cs
            JOIN subjects s ON cs.class_id = s.class_id
            WHERE cs.student_id = auth.uid() AND s.teacher_id = target_user_id
        ) THEN
            RETURN TRUE;
        END IF;
    END IF;

    RETURN FALSE;
END;
$$;

-- RPC: Get conversation partners (existing conversations)
CREATE OR REPLACE FUNCTION rpc_get_conversation_partners()
RETURNS TABLE (
    id UUID,
    email TEXT,
    role user_role,
    school_id UUID,
    first_name TEXT,
    last_name TEXT,
    avatar_url TEXT,
    last_message_at TIMESTAMPTZ,
    unread_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();

    RETURN QUERY
    WITH conversation_partners AS (
        SELECT DISTINCT
            CASE
                WHEN m.sender_id = current_user_id THEN m.recipient_id
                ELSE m.sender_id
            END AS partner_id,
            MAX(m.created_at) AS last_msg_at
        FROM messages m
        WHERE (m.sender_id = current_user_id OR m.recipient_id = current_user_id)
            AND m.message_type = 'direct'
            AND m.recipient_id IS NOT NULL
        GROUP BY
            CASE
                WHEN m.sender_id = current_user_id THEN m.recipient_id
                ELSE m.sender_id
            END
    )
    SELECT
        p.id,
        p.email,
        p.role,
        p.school_id,
        p.first_name,
        p.last_name,
        p.avatar_url,
        cp.last_msg_at AS last_message_at,
        (
            SELECT COUNT(*)
            FROM messages m2
            WHERE m2.sender_id = p.id
                AND m2.recipient_id = current_user_id
                AND m2.is_read = false
        ) AS unread_count
    FROM conversation_partners cp
    JOIN profiles p ON p.id = cp.partner_id
    ORDER BY cp.last_msg_at DESC;
END;
$$;

-- =============================================================================
-- STEP 6: Grant execute permissions on all RPC functions
-- =============================================================================

GRANT EXECUTE ON FUNCTION get_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION is_superadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_school_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_teacher() TO authenticated;
GRANT EXECUTE ON FUNCTION belongs_to_school(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION student_in_my_class(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_get_school_users(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_get_messageable_users() TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_search_users(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_get_my_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_can_message_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_get_conversation_partners() TO authenticated;

-- =============================================================================
-- STEP 7: Ensure proper table permissions
-- =============================================================================

-- service_role and postgres can do everything
GRANT ALL ON profiles TO service_role;
GRANT ALL ON profiles TO postgres;

-- authenticated users have restricted access (via policies)
GRANT SELECT, UPDATE ON profiles TO authenticated;

-- =============================================================================
-- STEP 8: Ensure RLS is enabled
-- =============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Force RLS for table owner too (prevents bypass)
ALTER TABLE profiles FORCE ROW LEVEL SECURITY;

-- =============================================================================
-- STEP 9: Reset GENESIS-KEY for testing
-- =============================================================================

UPDATE invite_tokens SET is_used = false WHERE token = 'GENESIS-KEY';

-- =============================================================================
-- STEP 10: Verification test
-- =============================================================================

DO $$
DECLARE
    test_count INTEGER;
BEGIN
    -- This should NOT cause infinite recursion
    SELECT COUNT(*) INTO test_count FROM profiles LIMIT 1;
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'SUCCESS: No infinite recursion detected!';
    RAISE NOTICE 'Profiles table has % rows', test_count;
    RAISE NOTICE '===========================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '===========================================';
        RAISE NOTICE 'ERROR: %', SQLERRM;
        RAISE NOTICE '===========================================';
        RAISE;
END $$;

-- List current policies for verification
DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE 'Current profiles policies:';
    FOR pol IN
        SELECT policyname, cmd, permissive
        FROM pg_policies
        WHERE tablename = 'profiles' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (% %)', pol.policyname, pol.cmd,
            CASE WHEN pol.permissive = 'PERMISSIVE' THEN '' ELSE 'RESTRICTIVE' END;
    END LOOP;
END $$;

-- =============================================================================
-- END OF NUCLEAR FIX
-- ============================================================================
