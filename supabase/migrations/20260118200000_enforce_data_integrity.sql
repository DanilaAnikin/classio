-- Migration: Enforce Data Integrity Constraints
--
-- This migration:
-- 1. Cleans up subjects with NULL school_id (orphaned data)
-- 2. Adds NOT NULL constraint to subjects.school_id
-- 3. Ensures referential integrity across critical tables

-- =====================================================================
-- SECTION 1: CLEAN UP ORPHANED SUBJECTS
-- =====================================================================

-- First, try to repair subjects by inferring school_id from their class
UPDATE subjects s
SET school_id = c.school_id
FROM classes c
WHERE s.class_id = c.id
  AND s.school_id IS NULL
  AND c.school_id IS NOT NULL;

-- Delete any subjects that still have NULL school_id (cannot be repaired)
-- This also cascades to delete related assignments, grades, lessons
DELETE FROM subjects WHERE school_id IS NULL;

-- =====================================================================
-- SECTION 2: ADD NOT NULL CONSTRAINTS
-- =====================================================================

-- Now that all subjects have school_id, add the NOT NULL constraint
ALTER TABLE subjects ALTER COLUMN school_id SET NOT NULL;

-- =====================================================================
-- SECTION 3: VERIFY AND LOG
-- =====================================================================

-- Create a function to validate data integrity (can be called anytime)
CREATE OR REPLACE FUNCTION validate_data_integrity()
RETURNS TABLE(
  check_name TEXT,
  status TEXT,
  details TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check subjects without school_id (should be 0 after this migration)
  RETURN QUERY
  SELECT
    'subjects.school_id'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Subjects with NULL school_id: ' || COUNT(*)::TEXT
  FROM subjects WHERE school_id IS NULL;

  -- Check subjects without class_id
  RETURN QUERY
  SELECT
    'subjects.class_id'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Subjects with NULL class_id: ' || COUNT(*)::TEXT
  FROM subjects WHERE class_id IS NULL;

  -- Check classes without school_id
  RETURN QUERY
  SELECT
    'classes.school_id'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Classes with NULL school_id: ' || COUNT(*)::TEXT
  FROM classes WHERE school_id IS NULL;

  -- Check grades without required fields
  RETURN QUERY
  SELECT
    'grades.student_id'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Grades with NULL student_id: ' || COUNT(*)::TEXT
  FROM grades WHERE student_id IS NULL;

  -- Check attendance without required fields
  RETURN QUERY
  SELECT
    'attendance.student_id'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Attendance with NULL student_id: ' || COUNT(*)::TEXT
  FROM attendance WHERE student_id IS NULL;

  -- Check lessons without subject_id
  RETURN QUERY
  SELECT
    'lessons.subject_id'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Lessons with NULL subject_id: ' || COUNT(*)::TEXT
  FROM lessons WHERE subject_id IS NULL;
END;
$$;

-- Run the validation immediately to log results
DO $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE 'Data Integrity Validation Results:';
  FOR rec IN SELECT * FROM validate_data_integrity() LOOP
    RAISE NOTICE '  % - % - %', rec.check_name, rec.status, rec.details;
  END LOOP;
END $$;
