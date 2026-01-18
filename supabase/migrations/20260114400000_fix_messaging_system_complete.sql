-- ============================================================================
-- Migration: 20260114400000_fix_messaging_system_complete.sql
-- Complete messaging system overhaul with proper role hierarchy
--
-- CHANGES:
-- 1. Updated get_messageable_users() - superadmin can message ANYONE
-- 2. Added can_initiate_conversation() - role hierarchy check
-- 3. Added get_messageable_users_with_hierarchy() - filtered by who can initiate
-- 4. Updated RLS policies for messages, message_groups, message_group_members
-- ============================================================================

-- ============================================================================
-- SECTION 1: DROP EXISTING FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS get_messageable_users() CASCADE;
DROP FUNCTION IF EXISTS get_messageable_users(UUID) CASCADE;
DROP FUNCTION IF EXISTS can_initiate_conversation(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_messageable_users_with_hierarchy() CASCADE;

-- ============================================================================
-- SECTION 2: can_initiate_conversation() FUNCTION
-- Determines if a user with initiator_role can start a conversation with target_role
-- ============================================================================

CREATE OR REPLACE FUNCTION can_initiate_conversation(initiator_role TEXT, target_role TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    role_hierarchy JSONB := '{
        "superadmin": 0,
        "bigadmin": 1,
        "admin": 2,
        "teacher": 3,
        "parent": 4,
        "student": 5
    }'::JSONB;
    initiator_level INT;
    target_level INT;
BEGIN
    initiator_level := COALESCE((role_hierarchy->>initiator_role)::INT, 999);
    target_level := COALESCE((role_hierarchy->>target_role)::INT, 999);
    -- Higher authority (lower number) can initiate conversations with lower authority
    RETURN initiator_level <= target_level;
END;
$$;

COMMENT ON FUNCTION can_initiate_conversation IS 'Returns true if initiator_role can start a conversation with target_role based on hierarchy';

GRANT EXECUTE ON FUNCTION can_initiate_conversation(TEXT, TEXT) TO authenticated;

-- ============================================================================
-- SECTION 3: get_messageable_users() FUNCTION (UPDATED)
-- Superadmin can message ANYONE (all users, all schools)
-- Returns role and computed display_name
-- ============================================================================

CREATE OR REPLACE FUNCTION get_messageable_users()
RETURNS TABLE (
    id UUID,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    role TEXT,
    avatar_url TEXT,
    display_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_user_id UUID;
    v_user_role TEXT;
    v_school_id UUID;
BEGIN
    -- Get the current authenticated user's ID
    v_current_user_id := auth.uid();

    IF v_current_user_id IS NULL THEN
        RETURN;
    END IF;

    -- Get current user's role and school
    SELECT p.role::TEXT, p.school_id
    INTO v_user_role, v_school_id
    FROM profiles p
    WHERE p.id = v_current_user_id;

    IF v_user_role IS NULL THEN
        RETURN;
    END IF;

    -- Return messageable users based on role
    RETURN QUERY
    SELECT
        p.id,
        p.first_name,
        p.last_name,
        p.email,
        p.role::TEXT,
        p.avatar_url,
        -- Computed display_name: Admin prefix for superadmins, full name for others
        CASE
            WHEN p.role = 'superadmin' THEN 'Admin ' || COALESCE(p.first_name, '')
            ELSE COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')
        END AS display_name
    FROM profiles p
    WHERE
        p.id != v_current_user_id
        AND (
            -- Superadmins can message ANYONE (no school restriction)
            v_user_role = 'superadmin'
            OR (
                -- Others can message users in their school (school_id must match and not be NULL)
                p.school_id = v_school_id
                AND p.school_id IS NOT NULL
            )
        )
    ORDER BY p.first_name, p.last_name;
END;
$$;

COMMENT ON FUNCTION get_messageable_users IS 'Returns all users the current user can potentially message. Superadmins can message anyone.';

GRANT EXECUTE ON FUNCTION get_messageable_users() TO authenticated;

-- ============================================================================
-- SECTION 4: get_messageable_users_with_hierarchy() FUNCTION
-- Returns users that the current user CAN initiate conversations with
-- based on role hierarchy (higher authority can initiate with lower)
-- ============================================================================

CREATE OR REPLACE FUNCTION get_messageable_users_with_hierarchy()
RETURNS TABLE (
    id UUID,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    role TEXT,
    avatar_url TEXT,
    display_name TEXT,
    can_initiate BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_user_id UUID;
    v_user_role TEXT;
    v_school_id UUID;
BEGIN
    -- Get the current authenticated user's ID
    v_current_user_id := auth.uid();

    IF v_current_user_id IS NULL THEN
        RETURN;
    END IF;

    -- Get current user's role and school
    SELECT p.role::TEXT, p.school_id
    INTO v_user_role, v_school_id
    FROM profiles p
    WHERE p.id = v_current_user_id;

    IF v_user_role IS NULL THEN
        RETURN;
    END IF;

    -- Return messageable users with hierarchy check
    RETURN QUERY
    SELECT
        p.id,
        p.first_name,
        p.last_name,
        p.email,
        p.role::TEXT,
        p.avatar_url,
        -- Computed display_name
        CASE
            WHEN p.role = 'superadmin' THEN 'Admin ' || COALESCE(p.first_name, '')
            ELSE COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')
        END AS display_name,
        -- Can current user initiate conversation with this user?
        can_initiate_conversation(v_user_role, p.role::TEXT) AS can_initiate
    FROM profiles p
    WHERE
        p.id != v_current_user_id
        AND (
            -- Superadmins can message ANYONE
            v_user_role = 'superadmin'
            OR (
                -- Others can message users in their school
                p.school_id = v_school_id
                AND p.school_id IS NOT NULL
            )
        )
        -- Only return users the current user can initiate conversations with
        AND can_initiate_conversation(v_user_role, p.role::TEXT)
    ORDER BY p.first_name, p.last_name;
END;
$$;

COMMENT ON FUNCTION get_messageable_users_with_hierarchy IS 'Returns users the current user can initiate conversations with, based on role hierarchy';

GRANT EXECUTE ON FUNCTION get_messageable_users_with_hierarchy() TO authenticated;

-- ============================================================================
-- SECTION 5: UPDATE RLS POLICIES FOR messages TABLE
-- Superadmin can INSERT/SELECT any messages
-- ============================================================================

-- Drop existing message policies
DROP POLICY IF EXISTS "users_insert_own_messages" ON messages;
DROP POLICY IF EXISTS "users_select_own_messages" ON messages;
DROP POLICY IF EXISTS "users_update_read_status" ON messages;
DROP POLICY IF EXISTS "superadmin_all_messages" ON messages;

-- Superadmin: Full access to all messages
CREATE POLICY "superadmin_all_messages" ON messages
    FOR ALL
    TO authenticated
    USING (is_superadmin())
    WITH CHECK (is_superadmin());

-- Users can insert messages where they are the sender (non-superadmin)
CREATE POLICY "users_insert_own_messages" ON messages
    FOR INSERT
    TO authenticated
    WITH CHECK (
        sender_id = auth.uid()
        AND NOT is_superadmin()  -- superadmin handled by their own policy
    );

-- Users can read messages they sent or received (direct or group)
CREATE POLICY "users_select_own_messages" ON messages
    FOR SELECT
    TO authenticated
    USING (
        NOT is_superadmin()  -- superadmin handled by their own policy
        AND (
            sender_id = auth.uid()
            OR recipient_id = auth.uid()
            OR (group_id IS NOT NULL AND is_group_member(group_id))
        )
    );

-- Users can update is_read on messages they received
CREATE POLICY "users_update_read_status" ON messages
    FOR UPDATE
    TO authenticated
    USING (
        NOT is_superadmin()  -- superadmin handled by their own policy
        AND recipient_id = auth.uid()
    )
    WITH CHECK (
        NOT is_superadmin()
        AND recipient_id = auth.uid()
    );

-- ============================================================================
-- SECTION 6: UPDATE RLS POLICIES FOR message_groups TABLE
-- Superadmin can create groups without school_id (NULL allowed)
-- Superadmin can add anyone to groups
-- ============================================================================

-- Drop existing message_groups policies
DROP POLICY IF EXISTS "superadmin_all_message_groups" ON message_groups;
DROP POLICY IF EXISTS "admin_all_own_school_message_groups" ON message_groups;
DROP POLICY IF EXISTS "users_select_member_groups" ON message_groups;
DROP POLICY IF EXISTS "teacher_insert_groups" ON message_groups;

-- Superadmin: Full access to all message groups (including NULL school_id)
CREATE POLICY "superadmin_all_message_groups" ON message_groups
    FOR ALL
    TO authenticated
    USING (is_superadmin())
    WITH CHECK (is_superadmin());

-- Admin: Full access within own school (school_id must match)
CREATE POLICY "admin_all_own_school_message_groups" ON message_groups
    FOR ALL
    TO authenticated
    USING (
        NOT is_superadmin()
        AND is_school_admin()
        AND school_id = get_user_school_id()
    )
    WITH CHECK (
        NOT is_superadmin()
        AND is_school_admin()
        AND school_id = get_user_school_id()
    );

-- Users can read groups they are members of
CREATE POLICY "users_select_member_groups" ON message_groups
    FOR SELECT
    TO authenticated
    USING (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND is_group_member(id)
    );

-- Teachers can create groups in their school
CREATE POLICY "teacher_insert_groups" ON message_groups
    FOR INSERT
    TO authenticated
    WITH CHECK (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND is_teacher()
        AND school_id = get_user_school_id()
    );

-- ============================================================================
-- SECTION 7: UPDATE RLS POLICIES FOR message_group_members TABLE
-- Superadmin can add/remove any member from any group
-- ============================================================================

-- Drop existing message_group_members policies
DROP POLICY IF EXISTS "superadmin_all_group_members" ON message_group_members;
DROP POLICY IF EXISTS "admin_all_own_school_group_members" ON message_group_members;
DROP POLICY IF EXISTS "users_select_group_members" ON message_group_members;
DROP POLICY IF EXISTS "teacher_manage_group_members" ON message_group_members;

-- Superadmin: Full access to all group memberships
CREATE POLICY "superadmin_all_group_members" ON message_group_members
    FOR ALL
    TO authenticated
    USING (is_superadmin())
    WITH CHECK (is_superadmin());

-- Admin: Full access within own school's groups
CREATE POLICY "admin_all_own_school_group_members" ON message_group_members
    FOR ALL
    TO authenticated
    USING (
        NOT is_superadmin()
        AND is_school_admin()
        AND EXISTS (
            SELECT 1 FROM message_groups
            WHERE id = message_group_members.group_id
            AND school_id = get_user_school_id()
        )
    )
    WITH CHECK (
        NOT is_superadmin()
        AND is_school_admin()
        AND EXISTS (
            SELECT 1 FROM message_groups
            WHERE id = message_group_members.group_id
            AND school_id = get_user_school_id()
        )
    );

-- Users can read members of groups they belong to
CREATE POLICY "users_select_group_members" ON message_group_members
    FOR SELECT
    TO authenticated
    USING (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND is_group_member(group_id)
    );

-- Group creators (teachers) can manage members of groups they created
CREATE POLICY "teacher_manage_group_members" ON message_group_members
    FOR ALL
    TO authenticated
    USING (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND is_teacher()
        AND EXISTS (
            SELECT 1 FROM message_groups
            WHERE id = message_group_members.group_id
            AND created_by = auth.uid()
        )
    )
    WITH CHECK (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND is_teacher()
        AND EXISTS (
            SELECT 1 FROM message_groups
            WHERE id = message_group_members.group_id
            AND created_by = auth.uid()
        )
    );

-- ============================================================================
-- SECTION 8: VERIFICATION
-- ============================================================================

DO $$
BEGIN
    -- Verify get_messageable_users function exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'get_messageable_users'
        AND pronargs = 0
    ) THEN
        RAISE EXCEPTION 'Function get_messageable_users() was not created correctly';
    END IF;

    -- Verify can_initiate_conversation function exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'can_initiate_conversation'
        AND pronargs = 2
    ) THEN
        RAISE EXCEPTION 'Function can_initiate_conversation(TEXT, TEXT) was not created correctly';
    END IF;

    -- Verify get_messageable_users_with_hierarchy function exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'get_messageable_users_with_hierarchy'
        AND pronargs = 0
    ) THEN
        RAISE EXCEPTION 'Function get_messageable_users_with_hierarchy() was not created correctly';
    END IF;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'SUCCESS: Messaging system migration complete';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Functions created:';
    RAISE NOTICE '  - get_messageable_users()';
    RAISE NOTICE '  - can_initiate_conversation(TEXT, TEXT)';
    RAISE NOTICE '  - get_messageable_users_with_hierarchy()';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'RLS Policies updated for:';
    RAISE NOTICE '  - messages';
    RAISE NOTICE '  - message_groups';
    RAISE NOTICE '  - message_group_members';
    RAISE NOTICE '============================================';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
