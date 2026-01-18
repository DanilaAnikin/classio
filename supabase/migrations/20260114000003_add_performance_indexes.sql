-- Migration: Add missing indexes for performance
-- This migration is idempotent (using IF NOT EXISTS)
-- Problem: Missing indexes on frequently queried columns causing slow queries
-- Note: This migration checks for column/table existence to handle schema variations

-- Index for efficient grade lookups by student with recent-first ordering
CREATE INDEX IF NOT EXISTS idx_grades_student_created
ON grades(student_id, created_at DESC);

-- Index for efficient lesson lookups by subject and day of week (schedule display)
-- Note: lessons table references subjects, not classes directly in ultimate_schema
CREATE INDEX IF NOT EXISTS idx_lessons_subject_day
ON lessons(subject_id, day_of_week);

-- Index for efficient assignment lookups by subject with due date ordering
CREATE INDEX IF NOT EXISTS idx_assignments_subject_due
ON assignments(subject_id, due_date);

-- Composite index for class_subjects join operations (if table exists)
-- Note: In ultimate_schema, subjects are linked directly to classes via class_id column
DO $$
BEGIN
    -- Check if class_subjects table exists (older schema)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'class_subjects'
    ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_class_subjects_composite ON class_subjects(class_id, subject_id)';
        RAISE NOTICE 'Created index on class_subjects table';
    ELSE
        RAISE NOTICE 'class_subjects table does not exist, skipping index';
    END IF;
END $$;

-- Index for assignment_submissions lookups (if table exists)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
    ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_assignment_submissions_assignment_student ON assignment_submissions(assignment_id, student_id)';
        RAISE NOTICE 'Created composite index on assignment_submissions';
    END IF;
END $$;
