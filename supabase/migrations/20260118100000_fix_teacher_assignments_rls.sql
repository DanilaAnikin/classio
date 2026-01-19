-- Migration: Fix teacher assignment creation RLS issues
--
-- This migration fixes TWO problems that prevented teachers from creating assignments:
--
-- Problem 1: The is_teacher() function lacks RLS recursion protection
--   - When RLS policies call is_teacher(), and is_teacher() queries the profiles table,
--     the profiles table's RLS policies may also call is_teacher(), causing infinite recursion.
--   - Fixed by adding SET row_security = off to bypass RLS within the function.
--
-- Problem 2: The RLS policy uses a subquery on the subjects table which has its own RLS
--   - The EXISTS subquery checking if teacher owns the subject is subject to the subjects
--     table's RLS policies, which can fail or cause recursion issues.
--   - Fixed by creating a helper function rls_teaches_subject() that bypasses RLS.

-- Fix is_teacher() to have proper RLS recursion protection
CREATE OR REPLACE FUNCTION is_teacher()
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

-- Create helper function to check if user teaches a subject (RLS-safe)
-- This function bypasses RLS to avoid recursion when called from RLS policies
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

-- Drop and recreate the teacher policy for assignments using RLS-safe functions
DROP POLICY IF EXISTS "teacher_all_own_assignments" ON assignments;

CREATE POLICY "teacher_all_own_assignments" ON assignments
  FOR ALL
  TO authenticated
  USING (
    is_teacher() AND rls_teaches_subject(subject_id)
  )
  WITH CHECK (
    is_teacher() AND rls_teaches_subject(subject_id)
  );

-- Also fix the subjects table policy for teachers to use the safe is_teacher() function
-- Note: The teacher_id = auth.uid() check is SAFE because it's a direct column comparison,
-- not a subquery. This does not cause RLS recursion issues - the recursion only occurs
-- when RLS policies contain subqueries that reference tables with their own RLS policies.
DROP POLICY IF EXISTS "teacher_all_own_subjects" ON subjects;

CREATE POLICY "teacher_all_own_subjects" ON subjects
  FOR ALL
  TO authenticated
  USING (
    is_teacher() AND teacher_id = auth.uid()
  )
  WITH CHECK (
    is_teacher() AND teacher_id = auth.uid()
  );