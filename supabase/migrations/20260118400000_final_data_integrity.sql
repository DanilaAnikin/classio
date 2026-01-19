-- Migration: Final Data Integrity Constraints
--
-- This migration ensures all critical foreign key columns have NOT NULL constraints
-- to prevent orphaned or invalid data.

-- =====================================================================
-- SECTION 1: VERIFY EXISTING CONSTRAINTS (informational queries in comments)
-- =====================================================================

-- lessons.subject_id - Already NOT NULL (confirmed in schema)
-- subjects.class_id - Already NOT NULL (confirmed in schema)
-- subjects.school_id - Made NOT NULL in previous migration
-- grades.student_id, subject_id, teacher_id - Already NOT NULL
-- attendance.student_id, lesson_id - Already NOT NULL
-- classes.school_id - Already NOT NULL

-- =====================================================================
-- SECTION 2: ADD ANY MISSING CONSTRAINTS
-- =====================================================================

-- Ensure assignments.created_by is NOT NULL (audit trail requirement)
-- First clean up any NULL values
UPDATE assignments
SET created_by = (SELECT id FROM profiles WHERE role = 'superadmin' LIMIT 1)
WHERE created_by IS NULL
AND EXISTS (SELECT 1 FROM profiles WHERE role = 'superadmin');

-- Delete any that couldn't be fixed (shouldn't happen in practice)
DELETE FROM assignments WHERE created_by IS NULL;

-- Now add the constraint
ALTER TABLE assignments ALTER COLUMN created_by SET NOT NULL;

-- =====================================================================
-- SECTION 3: ENSURE LESSON DATA INTEGRITY
-- =====================================================================

-- Delete any lessons with NULL subject_id (orphaned lessons)
-- This should never happen due to existing NOT NULL constraint, but just in case
DELETE FROM lessons WHERE subject_id IS NULL;

-- Delete lessons whose subjects no longer exist (orphaned by CASCADE failure)
DELETE FROM lessons l
WHERE NOT EXISTS (SELECT 1 FROM subjects s WHERE s.id = l.subject_id);

-- =====================================================================
-- SECTION 4: ENSURE ATTENDANCE DATA INTEGRITY
-- =====================================================================

-- Delete attendance records for non-existent students
DELETE FROM attendance a
WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = a.student_id);

-- Delete attendance records for non-existent lessons
DELETE FROM attendance a
WHERE NOT EXISTS (SELECT 1 FROM lessons l WHERE l.id = a.lesson_id);

-- =====================================================================
-- SECTION 5: LOG COMPLETION
-- =====================================================================

DO $$
BEGIN
  RAISE NOTICE 'Data integrity constraints enforced successfully';
END $$;
