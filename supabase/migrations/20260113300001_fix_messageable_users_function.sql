-- ============================================================================
-- FIX: get_messageable_users Function
-- Version: 20260113300001
--
-- PROBLEM: "Could not find the function public.get_messageable_users without parameters in schema cache"
--
-- ROOT CAUSE: The previous migration created the function as `rpc_get_messageable_users()`
-- but the Flutter code calls `_supabase.rpc('get_messageable_users')` (without rpc_ prefix)
--
-- SOLUTION: Create the function with the exact name `get_messageable_users` with NO parameters
-- ============================================================================

-- =============================================================================
-- STEP 1: Drop ALL existing versions of the function (with different signatures)
-- =============================================================================

-- Drop the incorrectly named function (if exists)
DROP FUNCTION IF EXISTS rpc_get_messageable_users() CASCADE;

-- Drop any existing versions of get_messageable_users with various signatures
DROP FUNCTION IF EXISTS get_messageable_users() CASCADE;
DROP FUNCTION IF EXISTS get_messageable_users(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_messageable_users(TEXT) CASCADE;

-- =============================================================================
-- STEP 2: Create the function with NO parameters (as expected by Flutter)
-- =============================================================================

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
SET row_security = off
AS $$
DECLARE
    current_user_id UUID;
    current_role user_role;
    current_school UUID;
BEGIN
    current_user_id := auth.uid();

    -- Get current user info (RLS is off, so this is safe)
    SELECT p.role, p.school_id INTO current_role, current_school
    FROM profiles p WHERE p.id = current_user_id;

    IF current_role IS NULL THEN
        RAISE EXCEPTION 'User profile not found';
    END IF;

    -- Return users based on role hierarchy
    RETURN QUERY
    SELECT DISTINCT
        p.id,
        p.first_name,
        p.last_name,
        p.email,
        p.role::TEXT,
        p.avatar_url
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
    ORDER BY p.first_name, p.last_name;
END;
$$;

-- =============================================================================
-- STEP 3: Grant execute permission to authenticated users
-- =============================================================================

GRANT EXECUTE ON FUNCTION get_messageable_users() TO authenticated;

-- =============================================================================
-- STEP 4: Verification
-- =============================================================================

DO $$
BEGIN
    -- Verify the function exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'get_messageable_users'
        AND pronargs = 0
    ) THEN
        RAISE EXCEPTION 'Function get_messageable_users() was not created correctly';
    END IF;

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'SUCCESS: get_messageable_users() created!';
    RAISE NOTICE 'Function has 0 parameters as expected';
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF FIX
-- =============================================================================
