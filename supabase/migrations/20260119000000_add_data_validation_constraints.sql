-- Migration: Add Data Validation Constraints
-- Adds CHECK constraints to ensure data integrity

-- Clean up any invalid data first
UPDATE grades
SET score = GREATEST(0, LEAST(100, score))
WHERE score IS NOT NULL AND (score < 0 OR score > 100);

UPDATE grades
SET weight = 1.0
WHERE weight IS NOT NULL AND weight <= 0;

-- Add CHECK constraints
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'check_grades_score_range') THEN
        ALTER TABLE grades ADD CONSTRAINT check_grades_score_range
        CHECK (score IS NULL OR (score >= 0 AND score <= 100));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'check_grades_weight_positive') THEN
        ALTER TABLE grades ADD CONSTRAINT check_grades_weight_positive
        CHECK (weight IS NULL OR weight > 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'check_times_used_non_negative') THEN
        ALTER TABLE invite_tokens ADD CONSTRAINT check_times_used_non_negative
        CHECK (times_used >= 0);
    END IF;
END $$;
