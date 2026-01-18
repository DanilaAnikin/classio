-- Ensure the comment column exists in grades table
-- This fixes: "column grades.comment does not exist" error

-- Add comment column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'grades' AND column_name = 'comment'
    ) THEN
        ALTER TABLE grades ADD COLUMN comment TEXT;
    END IF;
END $$;

-- Also ensure grade_type column exists (used as fallback)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'grades' AND column_name = 'grade_type'
    ) THEN
        ALTER TABLE grades ADD COLUMN grade_type TEXT;
    END IF;
END $$;
