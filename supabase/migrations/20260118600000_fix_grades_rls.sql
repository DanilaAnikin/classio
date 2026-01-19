-- Migration: Fix Grades RLS Policies
-- Issue: Grades policies use old is_teacher() function without SET row_security = off
-- and query subjects table which has RLS, causing recursion
-- Fix: Use rls_* prefixed functions that bypass RLS

-- =====================================================================
-- SECTION 1: ENSURE RLS-SAFE HELPER FUNCTIONS EXIST
-- =====================================================================

-- rls_is_superadmin
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

-- rls_is_school_admin (bigadmin or admin)
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

-- rls_is_teacher
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

-- rls_get_user_role
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

-- rls_get_user_school_id
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

-- rls_teaches_subject - Check if teacher teaches a specific subject (bypasses subjects RLS)
CREATE OR REPLACE FUNCTION rls_teaches_subject(p_subject_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM subjects
        WHERE id = p_subject_id AND teacher_id = auth.uid()
    );
END;
$$;

-- rls_is_parent_of - Check if current user is parent of given student
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

-- rls_grade_in_user_school - Check if a grade belongs to user's school (via subject -> class -> school)
CREATE OR REPLACE FUNCTION rls_grade_in_user_school(p_subject_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM subjects s
        JOIN classes c ON s.class_id = c.id
        WHERE s.id = p_subject_id
        AND c.school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
    );
END;
$$;

-- =====================================================================
-- SECTION 2: DROP ALL EXISTING GRADES POLICIES
-- =====================================================================

DROP POLICY IF EXISTS "superadmin_all_grades" ON grades;
DROP POLICY IF EXISTS "admin_select_own_school_grades" ON grades;
DROP POLICY IF EXISTS "teacher_all_own_grades" ON grades;
DROP POLICY IF EXISTS "student_select_own_grades" ON grades;
DROP POLICY IF EXISTS "parent_select_children_grades" ON grades;

-- =====================================================================
-- SECTION 3: CREATE NEW RLS-SAFE GRADES POLICIES
-- =====================================================================

-- Superadmin: full access to all grades
CREATE POLICY "superadmin_all_grades" ON grades
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- School admin (principal/deputy): read grades in their school
CREATE POLICY "admin_select_own_school_grades" ON grades
    FOR SELECT
    TO authenticated
    USING (
        rls_is_school_admin() AND rls_grade_in_user_school(subject_id)
    );

-- Teacher: full access to grades for subjects they teach
CREATE POLICY "teacher_insert_grades" ON grades
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_teacher() AND rls_teaches_subject(subject_id)
    );

CREATE POLICY "teacher_update_grades" ON grades
    FOR UPDATE
    TO authenticated
    USING (
        rls_is_teacher() AND rls_teaches_subject(subject_id)
    )
    WITH CHECK (
        rls_is_teacher() AND rls_teaches_subject(subject_id)
    );

CREATE POLICY "teacher_delete_grades" ON grades
    FOR DELETE
    TO authenticated
    USING (
        rls_is_teacher() AND rls_teaches_subject(subject_id)
    );

CREATE POLICY "teacher_select_grades" ON grades
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher() AND rls_teaches_subject(subject_id)
    );

-- Student: read own grades
CREATE POLICY "student_select_own_grades" ON grades
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student' AND student_id = auth.uid()
    );

-- Parent: read children's grades
CREATE POLICY "parent_select_children_grades" ON grades
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent' AND rls_is_parent_of(student_id)
    );
