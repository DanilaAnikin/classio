-- Migration: Add class_subjects junction table and school_id to subjects
-- This aligns the database schema with the application code expectations
-- Required by deputy repository for schedule management

-- ============================================================================
-- SECTION 1: ADD SCHOOL_ID TO SUBJECTS TABLE
-- ============================================================================

-- The subjects table currently only has class_id, but the application code
-- expects subjects to have a school_id for school-wide subject management.
-- We add school_id and populate it from the class's school_id.

-- Add school_id column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'subjects'
    AND column_name = 'school_id'
  ) THEN
    ALTER TABLE subjects ADD COLUMN school_id UUID REFERENCES schools(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Populate school_id from the class's school_id for existing subjects
UPDATE subjects s
SET school_id = c.school_id
FROM classes c
WHERE s.class_id = c.id
AND s.school_id IS NULL;

-- Create index on school_id for subjects if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_subjects_school_id ON subjects(school_id);

-- ============================================================================
-- SECTION 2: CREATE CLASS_SUBJECTS TABLE
-- ============================================================================

-- The current schema has subjects linked directly to classes via subjects.class_id
-- This migration adds a junction table to support subjects being taught in multiple classes
-- Both approaches can coexist: subjects.class_id for primary class, class_subjects for additional

CREATE TABLE IF NOT EXISTS class_subjects (
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (class_id, subject_id)
);

COMMENT ON TABLE class_subjects IS 'Many-to-many relationship between classes and subjects';

-- ============================================================================
-- SECTION 3: INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_class_subjects_subject_id ON class_subjects(subject_id);
CREATE INDEX IF NOT EXISTS idx_class_subjects_class_id ON class_subjects(class_id);

-- ============================================================================
-- SECTION 4: ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE class_subjects ENABLE ROW LEVEL SECURITY;

-- Superadmin: Full access
CREATE POLICY "superadmin_all_class_subjects" ON class_subjects
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Full access within own school
CREATE POLICY "admin_all_own_school_class_subjects" ON class_subjects
  FOR ALL
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM classes WHERE id = class_subjects.class_id AND school_id = get_user_school_id())
  )
  WITH CHECK (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM classes WHERE id = class_subjects.class_id AND school_id = get_user_school_id())
  );

-- Teacher: Read class subjects for classes they teach, manage for their subjects
CREATE POLICY "teacher_select_class_subjects" ON class_subjects
  FOR SELECT
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = class_subjects.subject_id AND teacher_id = auth.uid())
  );

CREATE POLICY "teacher_manage_own_class_subjects" ON class_subjects
  FOR ALL
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = class_subjects.subject_id AND teacher_id = auth.uid())
  )
  WITH CHECK (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = class_subjects.subject_id AND teacher_id = auth.uid())
  );

-- Student: Read class subjects for enrolled classes
CREATE POLICY "student_select_enrolled_class_subjects" ON class_subjects
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'student' AND
    EXISTS (SELECT 1 FROM class_students WHERE class_id = class_subjects.class_id AND student_id = auth.uid())
  );

-- Parent: Read children's class subjects
CREATE POLICY "parent_select_children_class_subjects" ON class_subjects
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM class_students cs
      JOIN parent_student ps ON cs.student_id = ps.student_id
      WHERE cs.class_id = class_subjects.class_id AND ps.parent_id = auth.uid()
    )
  );

-- ============================================================================
-- SECTION 5: POPULATE FROM EXISTING DATA
-- ============================================================================

-- Populate class_subjects from existing subjects that have class_id set
-- This ensures backward compatibility with existing data
INSERT INTO class_subjects (class_id, subject_id, assigned_at)
SELECT class_id, id, created_at
FROM subjects
WHERE class_id IS NOT NULL
ON CONFLICT (class_id, subject_id) DO NOTHING;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
