-- Migration: 20260114300000_fix_messageable_users_final.sql
-- Fixes the get_messageable_users function to work with Dart RPC call (no parameters)
-- and resolves the SELECT DISTINCT / ORDER BY conflict

-- Drop ALL versions of this function (with and without parameters)
DROP FUNCTION IF EXISTS get_messageable_users();
DROP FUNCTION IF EXISTS get_messageable_users(UUID);

CREATE OR REPLACE FUNCTION get_messageable_users()
RETURNS TABLE (
    id UUID,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    role TEXT,
    avatar_url TEXT
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

    -- Return messageable users (no DISTINCT needed, just use proper WHERE clause)
    RETURN QUERY
    SELECT
        p.id,
        p.first_name,
        p.last_name,
        p.email,
        p.role::TEXT,
        p.avatar_url
    FROM profiles p
    WHERE
        p.id != v_current_user_id
        AND (
            -- Superadmins can message anyone
            v_user_role = 'superadmin'
            OR (
                -- Others can message users in their school
                p.school_id = v_school_id
                AND p.school_id IS NOT NULL
            )
        )
    ORDER BY p.first_name, p.last_name;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_messageable_users() TO authenticated;
