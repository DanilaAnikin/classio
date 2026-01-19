-- ============================================================================
-- MIGRATION: Fix Infinite Recursion in RLS Policies
-- Version: 20260111240000
--
-- Problem: "infinite recursion detected in policy for relation class_students"
--
-- Root Cause: Circular policy references between tables:
--   - class_students policies call teaches_class()
--   - teaches_class() queries subjects table
--   - subjects policies query class_students → LOOP!
--
-- Also:
--   - classes policies query class_students
--   - class_students policies query classes → LOOP!
--
-- Solution: Make helper functions bypass RLS by querying underlying tables
-- directly with SECURITY DEFINER, avoiding policy evaluation chains.
-- ============================================================================

-- =============================================================================
-- Step 0: Drop ALL dependent policies FIRST before dropping functions
-- =============================================================================

-- Drop policies on class_students that depend on teaches_class()
DROP POLICY IF EXISTS "teacher_select_class_students" ON class_students;
DROP POLICY IF EXISTS "teacher_insert_class_students" ON class_students;

-- Drop policies on classes that depend on teaches_class()
DROP POLICY IF EXISTS "teacher_select_own_classes" ON classes;

-- Drop policies on invite_tokens that depend on teaches_class()
DROP POLICY IF EXISTS "teacher_insert_tokens" ON invite_tokens;

-- Drop policies on subjects that query class_students (causes reverse recursion)
DROP POLICY IF EXISTS "student_select_enrolled_subjects" ON subjects;
DROP POLICY IF EXISTS "parent_select_children_subjects" ON subjects;

-- Drop policies on classes that query class_students
DROP POLICY IF EXISTS "student_select_enrolled_classes" ON classes;
DROP POLICY IF EXISTS "parent_select_children_classes" ON classes;

-- =============================================================================
-- Step 1: Now safe to drop and recreate teaches_class()
-- =============================================================================
DROP FUNCTION IF EXISTS teaches_class(UUID);

CREATE OR REPLACE FUNCTION teaches_class(p_class_id UUID)
RETURNS BOOLEAN AS $$
  -- Use direct table access with SECURITY DEFINER to bypass RLS
  -- This prevents the recursion: class_students -> teaches_class -> subjects -> class_students
  SELECT EXISTS (
    SELECT 1 FROM subjects
    WHERE subjects.class_id = p_class_id
      AND subjects.teacher_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- =============================================================================
-- Step 2: Drop problematic policies on class_students that cause recursion
-- =============================================================================

-- Drop teacher policies that use teaches_class (causes subjects -> class_students loop)
DROP POLICY IF EXISTS "teacher_select_class_students" ON class_students;
DROP POLICY IF EXISTS "teacher_insert_class_students" ON class_students;

-- =============================================================================
-- Step 3: Recreate teacher policies using direct subquery instead of function call
-- This avoids the function -> table -> policy -> function recursion
-- =============================================================================

-- Teacher: Read students in classes they teach
-- Using inline subquery with SECURITY DEFINER function for the auth check
CREATE POLICY "teacher_select_class_students" ON class_students
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'teacher'
    )
    AND EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.class_id = class_students.class_id
        AND subjects.teacher_id = auth.uid()
    )
  );

-- Teacher: Enroll students in classes they teach
CREATE POLICY "teacher_insert_class_students" ON class_students
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'teacher'
    )
    AND EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.class_id = class_students.class_id
        AND subjects.teacher_id = auth.uid()
    )
  );

-- =============================================================================
-- Step 4: Fix subjects policies that query class_students
-- =============================================================================

DROP POLICY IF EXISTS "student_select_enrolled_subjects" ON subjects;
DROP POLICY IF EXISTS "parent_select_children_subjects" ON subjects;

-- Create helper function for checking student enrollment (bypasses RLS)
CREATE OR REPLACE FUNCTION is_enrolled_in_class(p_class_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM class_students
    WHERE class_id = p_class_id
      AND student_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Create helper function for parent checking child enrollment
CREATE OR REPLACE FUNCTION has_child_in_class(p_class_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM class_students cs
    JOIN parent_student ps ON cs.student_id = ps.student_id
    WHERE cs.class_id = p_class_id
      AND ps.parent_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Recreate student subjects policy using helper function
CREATE POLICY "student_select_enrolled_subjects" ON subjects
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'student')
    AND is_enrolled_in_class(class_id)
  );

-- Recreate parent subjects policy using helper function
CREATE POLICY "parent_select_children_subjects" ON subjects
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'parent')
    AND has_child_in_class(class_id)
  );

-- =============================================================================
-- Step 5: Fix classes policies that query class_students
-- =============================================================================

DROP POLICY IF EXISTS "student_select_enrolled_classes" ON classes;
DROP POLICY IF EXISTS "parent_select_children_classes" ON classes;
DROP POLICY IF EXISTS "teacher_select_own_classes" ON classes;

-- Recreate student classes policy using helper function
CREATE POLICY "student_select_enrolled_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'student')
    AND is_enrolled_in_class(id)
  );

-- Recreate parent classes policy using helper function
CREATE POLICY "parent_select_children_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'parent')
    AND has_child_in_class(id)
  );

-- Recreate teacher classes policy (teaches_class is now safe)
CREATE POLICY "teacher_select_own_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'teacher')
    AND teaches_class(id)
  );

-- =============================================================================
-- Step 6: Recreate teacher_insert_tokens policy on invite_tokens
-- =============================================================================

CREATE POLICY "teacher_insert_tokens" ON invite_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'teacher')
    AND school_id = get_user_school_id()
    AND role = 'student'
    AND specific_class_id IS NOT NULL
    AND teaches_class(specific_class_id)
  );

-- =============================================================================
-- Step 7: Grant execute on helper functions
-- =============================================================================
GRANT EXECUTE ON FUNCTION teaches_class(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_enrolled_in_class(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION has_child_in_class(UUID) TO authenticated;

-- =============================================================================
-- Step 8: Ensure class_students RLS is enabled but has bypass for trigger
-- =============================================================================

-- The trigger function already has SECURITY DEFINER which bypasses RLS
-- Just make sure service_role can always access
GRANT ALL ON class_students TO service_role;
GRANT ALL ON subjects TO service_role;
GRANT ALL ON classes TO service_role;

-- NOTE: Hardcoded GENESIS-KEY token removed for security.
-- Use SELECT * FROM generate_genesis_token(); for bootstrap (see migration 20260118000001)

-- =============================================================================
-- END OF MIGRATION
-- ============================================================================
