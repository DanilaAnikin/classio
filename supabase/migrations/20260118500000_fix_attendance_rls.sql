-- Migration: Fix Attendance RLS Policies
--
-- Issue: Attendance policies use helper functions that can cause RLS recursion:
-- 1. is_teacher(), is_superadmin(), is_school_admin() don't have SET row_security = off
-- 2. Subquery joins lessons and subjects tables which have their own RLS
--
-- Fix: Use rls_* prefixed functions and create a helper for the teacher-lesson check

-- =====================================================================
-- SECTION 1: CREATE ALL RLS-SAFE HELPER FUNCTIONS
-- =====================================================================
-- These MUST be defined BEFORE the policies that use them

-- rls_is_superadmin: Check if current user is superadmin
CREATE OR REPLACE FUNCTION rls_is_superadmin()
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
    RETURN _role = 'superadmin';
END;
$$;

-- rls_is_school_admin: Check if current user is bigadmin or admin
CREATE OR REPLACE FUNCTION rls_is_school_admin()
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

-- rls_is_teacher: Check if current user is a teacher
CREATE OR REPLACE FUNCTION rls_is_teacher()
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
    RETURN _role = 'teacher';
END;
$$;

-- rls_get_user_role: Get the current user's role
CREATE OR REPLACE FUNCTION rls_get_user_role()
RETURNS user_role
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
    RETURN _role;
END;
$$;

-- rls_get_user_school_id: Get the current user's school_id
CREATE OR REPLACE FUNCTION rls_get_user_school_id()
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

-- rls_is_parent_of: Check if current user is parent of given student
CREATE OR REPLACE FUNCTION rls_is_parent_of(p_student_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM parent_student
        WHERE parent_id = auth.uid() AND student_id = p_student_id
    );
END;
$$;

-- rls_teacher_owns_lesson: Check if teacher owns the subject of a lesson (bypasses RLS on lessons/subjects)
CREATE OR REPLACE FUNCTION rls_teacher_owns_lesson(p_lesson_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM lessons l
        JOIN subjects s ON l.subject_id = s.id
        WHERE l.id = p_lesson_id AND s.teacher_id = auth.uid()
    );
END;
$$;

-- =====================================================================
-- SECTION 2: DROP ALL EXISTING ATTENDANCE POLICIES
-- =====================================================================

DROP POLICY IF EXISTS "superadmin_all_attendance" ON attendance;
DROP POLICY IF EXISTS "admin_select_own_school_attendance" ON attendance;
DROP POLICY IF EXISTS "teacher_insert_attendance" ON attendance;
DROP POLICY IF EXISTS "teacher_update_attendance" ON attendance;
DROP POLICY IF EXISTS "teacher_select_attendance" ON attendance;
DROP POLICY IF EXISTS "student_select_own_attendance" ON attendance;
DROP POLICY IF EXISTS "parent_select_children_attendance" ON attendance;
DROP POLICY IF EXISTS "parent_update_excuse" ON attendance;

-- =====================================================================
-- SECTION 3: CREATE ALL NEW ATTENDANCE POLICIES
-- =====================================================================

-- Superadmin: full access
CREATE POLICY "superadmin_all_attendance" ON attendance
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- School admin: read access to their school's attendance
CREATE POLICY "admin_select_own_school_attendance" ON attendance
    FOR SELECT
    TO authenticated
    USING (
        rls_is_school_admin() AND
        EXISTS (
            SELECT 1 FROM lessons l
            JOIN subjects s ON l.subject_id = s.id
            JOIN classes c ON s.class_id = c.id
            WHERE l.id = attendance.lesson_id
            AND c.school_id = rls_get_user_school_id()
        )
    );

-- Teacher: INSERT attendance for their lessons
CREATE POLICY "teacher_insert_attendance" ON attendance
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_teacher() AND rls_teacher_owns_lesson(lesson_id)
    );

-- Teacher: UPDATE attendance for their lessons
CREATE POLICY "teacher_update_attendance" ON attendance
    FOR UPDATE
    TO authenticated
    USING (
        rls_is_teacher() AND rls_teacher_owns_lesson(lesson_id)
    )
    WITH CHECK (
        rls_is_teacher() AND rls_teacher_owns_lesson(lesson_id)
    );

-- Teacher: SELECT attendance for their lessons
CREATE POLICY "teacher_select_attendance" ON attendance
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher() AND rls_teacher_owns_lesson(lesson_id)
    );

-- Student: read own attendance
CREATE POLICY "student_select_own_attendance" ON attendance
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student' AND student_id = auth.uid()
    );

-- Parent: read children's attendance
CREATE POLICY "parent_select_children_attendance" ON attendance
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent' AND rls_is_parent_of(student_id)
    );

-- Parent: update excuse for children's attendance
CREATE POLICY "parent_update_excuse" ON attendance
    FOR UPDATE
    TO authenticated
    USING (
        rls_get_user_role() = 'parent' AND rls_is_parent_of(student_id)
    )
    WITH CHECK (
        rls_get_user_role() = 'parent' AND rls_is_parent_of(student_id)
    );
