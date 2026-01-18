-- Migration: Add UNIQUE constraint on (assignment_id, student_id)
-- This migration is idempotent
-- Problem: Students can submit multiple times for the same assignment (duplicates allowed)
-- Prerequisite: Requires 20260113900000_create_assignment_submissions_table.sql to run first
-- Note: The table creation migration already includes this constraint, so this is a safety fallback

DO $$
BEGIN
    -- Only proceed if the table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
    ) THEN
        RAISE NOTICE 'assignment_submissions table does not exist, skipping unique constraint';
        RETURN;
    END IF;

    -- Remove duplicate submissions (keep most recent)
    -- This handles the case where duplicates exist before adding the constraint
    DELETE FROM assignment_submissions a
    USING assignment_submissions b
    WHERE a.assignment_id = b.assignment_id
      AND a.student_id = b.student_id
      AND a.submitted_at < b.submitted_at;

    -- Add unique constraint (idempotent)
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'unique_assignment_student_submission'
    ) THEN
        ALTER TABLE assignment_submissions
        ADD CONSTRAINT unique_assignment_student_submission
        UNIQUE (assignment_id, student_id);
        RAISE NOTICE 'Added unique constraint on (assignment_id, student_id)';
    ELSE
        RAISE NOTICE 'Unique constraint already exists, skipping';
    END IF;
END $$;
