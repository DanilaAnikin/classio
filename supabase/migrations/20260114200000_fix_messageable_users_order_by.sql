-- Fix get_messageable_users function ORDER BY clause
-- The previous version had ORDER BY p.role which conflicts with SELECT DISTINCT p.role::TEXT

-- Drop and recreate the function
DROP FUNCTION IF EXISTS get_messageable_users(UUID);

CREATE OR REPLACE FUNCTION get_messageable_users(p_user_id UUID)
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
AS $$
DECLARE
    v_user_role TEXT;
    v_school_id UUID;
BEGIN
    -- Get the current user's role and school
    SELECT p.role::TEXT, p.school_id
    INTO v_user_role, v_school_id
    FROM profiles p
    WHERE p.id = p_user_id;

    -- Return messageable users based on role
    RETURN QUERY
    SELECT DISTINCT
        p.id,
        p.first_name,
        p.last_name,
        p.email,
        p.role::TEXT,
        p.avatar_url
    FROM profiles p
    WHERE
        p.id != p_user_id
        AND (
            -- Superadmins can message anyone
            v_user_role = 'superadmin'
            OR (
                -- Others can message users in their school
                p.school_id = v_school_id
                AND p.school_id IS NOT NULL
            )
        )
    ORDER BY p.first_name, p.last_name;  -- Fixed: removed p.role from ORDER BY
END;
$$;
