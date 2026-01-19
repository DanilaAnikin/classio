-- Migration: Fix message_groups RLS policies for group creation
--
-- Issues fixed:
-- 1. RLS recursion in helper functions used by message_groups policies
-- 2. Add policy for students to create groups (if desired)
-- 3. Ensure message_group_members policies work correctly for group creators

-- =====================================================================
-- SECTION 1: ENSURE HELPER FUNCTIONS ARE RLS-SAFE
-- =====================================================================

-- Fix get_user_school_id to be RLS-safe
CREATE OR REPLACE FUNCTION get_user_school_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _school_id UUID;
BEGIN
    SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid();
    RETURN _school_id;
END;
$$;

-- Fix is_school_admin to be RLS-safe
CREATE OR REPLACE FUNCTION is_school_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role IN ('bigadmin', 'admin');
END;
$$;

-- Fix is_group_member to be RLS-safe
CREATE OR REPLACE FUNCTION is_group_member(p_group_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM message_group_members
        WHERE group_id = p_group_id AND user_id = auth.uid()
    );
END;
$$;

-- =====================================================================
-- SECTION 2: FIX MESSAGE_GROUPS INSERT POLICIES
-- =====================================================================

-- Drop existing insert policy for teachers
DROP POLICY IF EXISTS "teacher_insert_groups" ON message_groups;

-- Create a more inclusive policy that allows teachers, students, and parents to create groups
-- This allows any authenticated user in a school to create a group chat
CREATE POLICY "users_insert_own_school_groups" ON message_groups
    FOR INSERT
    TO authenticated
    WITH CHECK (
        -- Must not be superadmin or school admin (they have their own policies)
        NOT is_superadmin()
        AND NOT is_school_admin()
        -- User must have a school_id
        AND get_user_school_id() IS NOT NULL
        -- Group must be for user's own school
        AND school_id = get_user_school_id()
        -- User must be the creator
        AND created_by = auth.uid()
    );

-- =====================================================================
-- SECTION 3: FIX MESSAGE_GROUP_MEMBERS POLICIES
-- =====================================================================

-- Drop existing policy for teachers
DROP POLICY IF EXISTS "teacher_manage_group_members" ON message_group_members;

-- Create policy that allows group creators to manage members
-- This works for any user who created the group
CREATE POLICY "creator_manage_group_members" ON message_group_members
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM message_groups
            WHERE id = message_group_members.group_id
            AND created_by = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM message_groups
            WHERE id = message_group_members.group_id
            AND created_by = auth.uid()
        )
    );

-- Allow users to remove themselves from groups
DROP POLICY IF EXISTS "users_leave_groups" ON message_group_members;

CREATE POLICY "users_leave_groups" ON message_group_members
    FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());

-- =====================================================================
-- SECTION 4: ADD UPDATE POLICY FOR GROUP CREATORS
-- =====================================================================

-- Allow group creators to update their group (rename, etc.)
DROP POLICY IF EXISTS "creator_update_groups" ON message_groups;

CREATE POLICY "creator_update_groups" ON message_groups
    FOR UPDATE
    TO authenticated
    USING (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND created_by = auth.uid()
    )
    WITH CHECK (
        NOT is_superadmin()
        AND NOT is_school_admin()
        AND created_by = auth.uid()
        AND school_id = get_user_school_id()
    );
