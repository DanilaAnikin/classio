-- Migration: Add Missing Performance Indexes

-- Composite index for assignment queries by subject ordered by due date
CREATE INDEX IF NOT EXISTS idx_assignments_subject_due_date
ON assignments(subject_id, due_date ASC);

-- Composite index for inbox queries
CREATE INDEX IF NOT EXISTS idx_messages_recipient_created
ON messages(recipient_id, created_at DESC);

-- Partial index for unread messages
CREATE INDEX IF NOT EXISTS idx_messages_recipient_unread
ON messages(recipient_id, is_read)
WHERE is_read = false;

-- Index for batch assignment completion checks
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student_assignment
ON assignment_submissions(student_id, assignment_id);
