-- =====================================================================
-- UNIFIED SCHEMA MIGRATION
-- Migration: 20260118000000_unify_schema.sql
-- Purpose: Resolve conflicts between schema.sql and ultimate_schema.sql
-- =====================================================================
--
-- DECISION RATIONALE:
-- After analyzing both schema files and the Flutter application code,
-- this migration unifies the database structure based on what the app
-- actually uses. The source of truth is the Flutter repository code.
--
-- KEY DECISIONS:
--
-- 1. SUBJECTS TABLE: Keep BOTH school_id AND class_id
--    - App code uses subjects.class_id for primary subject-class relationship
--    - App code also uses subjects.school_id for school-wide queries (superadmin)
--    - Both columns coexist with class_id as NOT NULL, school_id as nullable
--
-- 2. INVITE SYSTEM: Use invite_tokens (NOT invite_codes)
--    - All app repositories use 'invite_tokens' table
--    - invite_codes from schema.sql is deprecated
--
-- 3. LESSONS TABLE: Add class_id column if missing
--    - Teacher repository queries lessons.class_id
--    - Schedule repository uses subjects.class_id as fallback
--    - Adding class_id ensures both code paths work
--
-- 4. SUBMISSIONS: Keep BOTH tables
--    - assignment_submissions: Used by student, parent, dashboard repos
--    - submissions: Used by teacher repository
--    - Different column names serve different purposes
--
-- 5. GRADES TABLE: Ensure both column patterns exist
--    - graded_by (schema.sql) and teacher_id (ultimate_schema.sql)
--    - lesson_id (schema.sql) is optional
--    - comment (schema.sql) and note (ultimate_schema.sql)
--
-- 6. CLASS_SUBJECTS: Keep junction table
--    - Used by some repositories for many-to-many relationships
--    - Coexists with subjects.class_id
--
-- =====================================================================

-- =====================================================================
-- SECTION 1: ENSURE CORE ENUMS EXIST
-- =====================================================================

-- Attendance status enum (from ultimate_schema.sql)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attendance_status') THEN
    CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late', 'excused');
  END IF;
END $$;

-- Excuse status enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'excuse_status') THEN
    CREATE TYPE excuse_status AS ENUM ('pending', 'approved', 'rejected');
  END IF;
END $$;

-- Message type enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'message_type') THEN
    CREATE TYPE message_type AS ENUM ('direct', 'group', 'announcement');
  END IF;
END $$;

-- Subscription status enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_status') THEN
    CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'suspended', 'cancelled');
  END IF;
END $$;

-- Add 'bigadmin' to user_role enum if not exists
-- This role is used by ultimate_schema.sql
DO $$
BEGIN
  -- Check if 'bigadmin' already exists in the enum
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'bigadmin'
    AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'user_role')
  ) THEN
    -- Add the new value to the enum
    ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'bigadmin' AFTER 'superadmin';
  END IF;
EXCEPTION
  WHEN duplicate_object THEN
    -- Value already exists, ignore
    NULL;
END $$;

-- =====================================================================
-- SECTION 2: SCHOOLS TABLE - Add subscription columns if missing
-- =====================================================================

ALTER TABLE schools
  ADD COLUMN IF NOT EXISTS subscription_status subscription_status DEFAULT 'trial',
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- =====================================================================
-- SECTION 3: PROFILES TABLE - Add email column if missing
-- =====================================================================

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS email TEXT;

-- =====================================================================
-- SECTION 4: SUBJECTS TABLE - Ensure both school_id and class_id exist
-- =====================================================================

-- class_id should already exist from ultimate_schema.sql or migrations
-- Add it if somehow missing
ALTER TABLE subjects
  ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES classes(id) ON DELETE CASCADE;

-- school_id was added by migration 20260116300000 but ensure it exists
ALTER TABLE subjects
  ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE CASCADE;

-- Add color column (from ultimate_schema.sql)
ALTER TABLE subjects
  ADD COLUMN IF NOT EXISTS color TEXT;

-- Populate school_id from class.school_id where missing
UPDATE subjects s
SET school_id = c.school_id
FROM classes c
WHERE s.class_id = c.id
AND s.school_id IS NULL;

-- Create index if not exists
CREATE INDEX IF NOT EXISTS idx_subjects_school_id ON subjects(school_id);
CREATE INDEX IF NOT EXISTS idx_subjects_class_id ON subjects(class_id);

-- =====================================================================
-- SECTION 5: LESSONS TABLE - Add class_id for teacher repository compat
-- =====================================================================

-- The teacher repository queries lessons.class_id
-- While schedule/deputy repos use subjects.class_id
-- We need class_id in lessons to support both patterns

ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES classes(id) ON DELETE CASCADE;

-- Populate class_id from subjects.class_id where missing
UPDATE lessons l
SET class_id = s.class_id
FROM subjects s
WHERE l.subject_id = s.id
AND l.class_id IS NULL;

-- Create index if not exists
CREATE INDEX IF NOT EXISTS idx_lessons_class_id ON lessons(class_id);

-- =====================================================================
-- SECTION 6: GRADES TABLE - Ensure all column variants exist
-- =====================================================================

-- teacher_id (from ultimate_schema.sql) as alternative to graded_by
ALTER TABLE grades
  ADD COLUMN IF NOT EXISTS teacher_id UUID REFERENCES profiles(id) ON DELETE CASCADE;

-- note (from ultimate_schema.sql) - may coexist with comment
ALTER TABLE grades
  ADD COLUMN IF NOT EXISTS note TEXT;

-- Ensure graded_by exists (from schema.sql)
ALTER TABLE grades
  ADD COLUMN IF NOT EXISTS graded_by UUID REFERENCES profiles(id) ON DELETE SET NULL;

-- lesson_id (from schema.sql) - optional
ALTER TABLE grades
  ADD COLUMN IF NOT EXISTS lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL;

-- comment column (from schema.sql) - also added by migration 20260115000001
ALTER TABLE grades
  ADD COLUMN IF NOT EXISTS comment TEXT;

-- Sync teacher_id and graded_by where one is null
UPDATE grades SET teacher_id = graded_by WHERE teacher_id IS NULL AND graded_by IS NOT NULL;
UPDATE grades SET graded_by = teacher_id WHERE graded_by IS NULL AND teacher_id IS NOT NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_grades_teacher_id ON grades(teacher_id);
CREATE INDEX IF NOT EXISTS idx_grades_lesson_id ON grades(lesson_id);
CREATE INDEX IF NOT EXISTS idx_grades_graded_by ON grades(graded_by);

-- =====================================================================
-- SECTION 7: ASSIGNMENTS TABLE - Ensure all columns exist
-- =====================================================================

-- file_url (from ultimate_schema.sql)
ALTER TABLE assignments
  ADD COLUMN IF NOT EXISTS file_url TEXT;

-- class_id (from schema.sql)
ALTER TABLE assignments
  ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES classes(id) ON DELETE CASCADE;

-- Populate class_id from subjects.class_id where missing
UPDATE assignments a
SET class_id = s.class_id
FROM subjects s
WHERE a.subject_id = s.id
AND a.class_id IS NULL;

-- =====================================================================
-- SECTION 8: ENSURE SUBMISSIONS TABLE EXISTS (for teacher repository)
-- =====================================================================

-- The teacher repository uses 'submissions' table with specific columns
CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  file_url TEXT,
  content TEXT,
  grade DECIMAL(5,2),
  teacher_comment TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  graded_at TIMESTAMPTZ,
  graded_by UUID REFERENCES profiles(id) ON DELETE SET NULL
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS id UUID;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS assignment_id UUID;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS student_id UUID;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS content TEXT;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS grade DECIMAL(5,2);
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS teacher_comment TEXT;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS graded_at TIMESTAMPTZ;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS graded_by UUID;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_submissions_assignment_id ON submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student_id ON submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_submissions_assignment_student ON submissions(assignment_id, student_id);

-- Enable RLS on submissions
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- Submissions RLS policies
DO $$
BEGIN
  -- Drop existing policies to recreate them cleanly
  DROP POLICY IF EXISTS "superadmin_all_submissions" ON submissions;
  DROP POLICY IF EXISTS "student_insert_own_submissions" ON submissions;
  DROP POLICY IF EXISTS "student_select_own_submissions" ON submissions;
  DROP POLICY IF EXISTS "teacher_select_own_submissions" ON submissions;
  DROP POLICY IF EXISTS "teacher_update_own_submissions" ON submissions;
  DROP POLICY IF EXISTS "admin_select_own_school_submissions" ON submissions;
  DROP POLICY IF EXISTS "parent_select_children_submissions" ON submissions;

  -- Superadmin: Full access
  CREATE POLICY "superadmin_all_submissions" ON submissions
    FOR ALL TO authenticated
    USING (is_superadmin())
    WITH CHECK (is_superadmin());

  -- Students can insert and select own submissions
  CREATE POLICY "student_insert_own_submissions" ON submissions
    FOR INSERT TO authenticated
    WITH CHECK (get_user_role() = 'student' AND student_id = auth.uid());

  CREATE POLICY "student_select_own_submissions" ON submissions
    FOR SELECT TO authenticated
    USING (get_user_role() = 'student' AND student_id = auth.uid());

  -- Teachers can select and update submissions for their subjects
  CREATE POLICY "teacher_select_own_submissions" ON submissions
    FOR SELECT TO authenticated
    USING (
      is_teacher() AND
      EXISTS (
        SELECT 1 FROM assignments a
        JOIN subjects s ON a.subject_id = s.id
        WHERE a.id = submissions.assignment_id AND s.teacher_id = auth.uid()
      )
    );

  CREATE POLICY "teacher_update_own_submissions" ON submissions
    FOR UPDATE TO authenticated
    USING (
      is_teacher() AND
      EXISTS (
        SELECT 1 FROM assignments a
        JOIN subjects s ON a.subject_id = s.id
        WHERE a.id = submissions.assignment_id AND s.teacher_id = auth.uid()
      )
    )
    WITH CHECK (
      is_teacher() AND
      EXISTS (
        SELECT 1 FROM assignments a
        JOIN subjects s ON a.subject_id = s.id
        WHERE a.id = submissions.assignment_id AND s.teacher_id = auth.uid()
      )
    );

  -- Admin: Read within own school
  CREATE POLICY "admin_select_own_school_submissions" ON submissions
    FOR SELECT TO authenticated
    USING (
      is_school_admin() AND
      EXISTS (
        SELECT 1 FROM assignments a
        JOIN subjects s ON a.subject_id = s.id
        JOIN classes c ON s.class_id = c.id
        WHERE a.id = submissions.assignment_id AND c.school_id = get_user_school_id()
      )
    );

  -- Parents can read children's submissions
  CREATE POLICY "parent_select_children_submissions" ON submissions
    FOR SELECT TO authenticated
    USING (
      get_user_role() = 'parent' AND
      EXISTS (
        SELECT 1 FROM parent_student ps
        WHERE ps.parent_id = auth.uid() AND ps.student_id = submissions.student_id
      )
    );
EXCEPTION
  WHEN undefined_function THEN
    -- Functions like is_superadmin() might not exist yet, skip policies
    RAISE NOTICE 'Skipping submissions RLS policies due to missing helper functions';
END $$;

COMMENT ON TABLE submissions IS 'Student submissions for assignments (used by teacher repository)';

-- =====================================================================
-- SECTION 9: ENSURE ASSIGNMENT_SUBMISSIONS TABLE EXISTS
-- =====================================================================

-- This table is used by student, parent, dashboard repositories
-- Created by migration 20260113900000 but ensure it exists

CREATE TABLE IF NOT EXISTS assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT,
  file_url TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  score DECIMAL(5,2),
  feedback TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_assignment_student_submission UNIQUE (assignment_id, student_id)
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS id UUID;
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS assignment_id UUID;
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS student_id UUID;
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS content TEXT;
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS score DECIMAL(5,2);
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS feedback TEXT;
ALTER TABLE assignment_submissions ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Enable RLS
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE assignment_submissions IS 'Student submissions for assignments (used by student/parent/dashboard repositories)';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student ON assignment_submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_submitted_at ON assignment_submissions(submitted_at);

-- =====================================================================
-- SECTION 10: ENSURE ATTENDANCE TABLE EXISTS
-- =====================================================================

CREATE TABLE IF NOT EXISTS attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  status attendance_status NOT NULL DEFAULT 'present',
  excuse_note TEXT,
  excuse_status excuse_status,
  marked_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (student_id, lesson_id, date)
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS id UUID;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS student_id UUID;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS lesson_id UUID;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS date DATE;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS status attendance_status DEFAULT 'present';
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS excuse_note TEXT;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS excuse_status excuse_status;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS marked_by UUID;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Enable RLS
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_lesson_id ON attendance(lesson_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_lesson_date ON attendance(lesson_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON attendance(status);

COMMENT ON TABLE attendance IS 'Student attendance records per lesson';

-- =====================================================================
-- SECTION 11: ENSURE MESSAGING TABLES EXIST
-- =====================================================================

-- Message groups table
CREATE TABLE IF NOT EXISTS message_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE message_groups ADD COLUMN IF NOT EXISTS id UUID;
ALTER TABLE message_groups ADD COLUMN IF NOT EXISTS school_id UUID;
ALTER TABLE message_groups ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE message_groups ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE message_groups ADD COLUMN IF NOT EXISTS created_by UUID;
ALTER TABLE message_groups ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

ALTER TABLE message_groups ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_message_groups_school_id ON message_groups(school_id);
CREATE INDEX IF NOT EXISTS idx_message_groups_created_by ON message_groups(created_by);

-- Message group members table
CREATE TABLE IF NOT EXISTS message_group_members (
  group_id UUID NOT NULL REFERENCES message_groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (group_id, user_id)
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE message_group_members ADD COLUMN IF NOT EXISTS group_id UUID;
ALTER TABLE message_group_members ADD COLUMN IF NOT EXISTS user_id UUID;

ALTER TABLE message_group_members ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_message_group_members_user_id ON message_group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_message_group_members_group_id ON message_group_members(group_id);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  group_id UUID REFERENCES message_groups(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type message_type NOT NULL DEFAULT 'direct',
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE messages ADD COLUMN IF NOT EXISTS id UUID;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS sender_id UUID;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS recipient_id UUID;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS group_id UUID;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS content TEXT;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS message_type message_type DEFAULT 'direct';
ALTER TABLE messages ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_group_id ON messages(group_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read) WHERE is_read = false;

-- =====================================================================
-- SECTION 12: ENSURE INVITE_TOKENS TABLE EXISTS
-- =====================================================================

-- The app uses invite_tokens, not invite_codes
CREATE TABLE IF NOT EXISTS invite_tokens (
  token TEXT PRIMARY KEY,
  role user_role NOT NULL,
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  created_by_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  specific_class_id UUID REFERENCES classes(id) ON DELETE SET NULL,
  is_used BOOLEAN NOT NULL DEFAULT false,
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '7 days'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS token TEXT;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS role user_role;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS school_id UUID;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS created_by_user_id UUID;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS specific_class_id UUID;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS is_used BOOLEAN DEFAULT false;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS usage_limit INT DEFAULT 1;
ALTER TABLE invite_tokens ADD COLUMN IF NOT EXISTS times_used INT DEFAULT 0;

ALTER TABLE invite_tokens ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_invite_tokens_school_id ON invite_tokens(school_id);
CREATE INDEX IF NOT EXISTS idx_invite_tokens_is_used ON invite_tokens(is_used);
CREATE INDEX IF NOT EXISTS idx_invite_tokens_expires_at ON invite_tokens(expires_at);
CREATE INDEX IF NOT EXISTS idx_invite_tokens_created_by ON invite_tokens(created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_invite_tokens_active ON invite_tokens(school_id, is_used, expires_at)
  WHERE is_used = false;

COMMENT ON TABLE invite_tokens IS 'Invite tokens for user registration with role assignment';

-- =====================================================================
-- SECTION 13: ENSURE CLASS_SUBJECTS TABLE EXISTS
-- =====================================================================

-- Junction table for many-to-many class-subject relationships
-- Coexists with subjects.class_id

CREATE TABLE IF NOT EXISTS class_subjects (
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (class_id, subject_id)
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE class_subjects ADD COLUMN IF NOT EXISTS class_id UUID;
ALTER TABLE class_subjects ADD COLUMN IF NOT EXISTS subject_id UUID;
ALTER TABLE class_subjects ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ DEFAULT now();

ALTER TABLE class_subjects ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_class_subjects_subject_id ON class_subjects(subject_id);
CREATE INDEX IF NOT EXISTS idx_class_subjects_class_id ON class_subjects(class_id);

COMMENT ON TABLE class_subjects IS 'Many-to-many relationship between classes and subjects';

-- Populate class_subjects from existing subjects.class_id
INSERT INTO class_subjects (class_id, subject_id, assigned_at)
SELECT class_id, id, created_at
FROM subjects
WHERE class_id IS NOT NULL
ON CONFLICT (class_id, subject_id) DO NOTHING;

-- =====================================================================
-- SECTION 14: ENSURE MATERIALS TABLE EXISTS
-- =====================================================================

CREATE TABLE IF NOT EXISTS materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  file_url TEXT,
  material_type TEXT,
  uploaded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE materials ADD COLUMN IF NOT EXISTS id UUID;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS subject_id UUID;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS material_type TEXT;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS uploaded_by UUID;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

ALTER TABLE materials ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_materials_subject_id ON materials(subject_id);
CREATE INDEX IF NOT EXISTS idx_materials_uploaded_by ON materials(uploaded_by);

-- =====================================================================
-- SECTION 15: ENSURE PARENT_STUDENT TABLE EXISTS
-- =====================================================================

CREATE TABLE IF NOT EXISTS parent_student (
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  relationship TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (parent_id, student_id)
);

-- Ensure all columns exist (for tables that pre-exist from older migrations)
ALTER TABLE parent_student ADD COLUMN IF NOT EXISTS parent_id UUID;
ALTER TABLE parent_student ADD COLUMN IF NOT EXISTS student_id UUID;
ALTER TABLE parent_student ADD COLUMN IF NOT EXISTS relationship TEXT;
ALTER TABLE parent_student ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Add check constraint if not exists
DO $$
BEGIN
  ALTER TABLE parent_student ADD CONSTRAINT parent_student_check CHECK (parent_id != student_id);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE parent_student ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_parent_student_student_id ON parent_student(student_id);
CREATE INDEX IF NOT EXISTS idx_parent_student_parent_id ON parent_student(parent_id);

-- =====================================================================
-- SECTION 16: ENSURE HELPER FUNCTIONS EXIST
-- =====================================================================

-- is_teacher function
CREATE OR REPLACE FUNCTION is_teacher()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() = 'teacher'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- is_school_admin function (checks bigadmin or admin)
CREATE OR REPLACE FUNCTION is_school_admin()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() IN ('bigadmin', 'admin')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- is_parent_of function
CREATE OR REPLACE FUNCTION is_parent_of(p_student_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM parent_student WHERE parent_id = auth.uid() AND student_id = p_student_id
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- teaches_class function
CREATE OR REPLACE FUNCTION teaches_class(p_class_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM subjects WHERE subjects.class_id = p_class_id AND teacher_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- is_group_member function
CREATE OR REPLACE FUNCTION is_group_member(p_group_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM message_group_members WHERE group_id = p_group_id AND user_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- =====================================================================
-- SECTION 17: DEPRECATE invite_codes TABLE (if it exists)
-- =====================================================================

-- Rename invite_codes to deprecated if it exists and is not already renamed
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'invite_codes'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'invite_codes_deprecated'
  ) THEN
    -- Only migrate if invite_codes exists AND has data AND invite_tokens needs data
    IF EXISTS (SELECT 1 FROM invite_codes LIMIT 1)
       AND NOT EXISTS (SELECT 1 FROM invite_tokens LIMIT 1) THEN

      -- Check if invite_codes has usage_limit column
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invite_codes' AND column_name = 'usage_limit') THEN
        INSERT INTO invite_tokens (token, role, school_id, specific_class_id, is_used, expires_at, created_at, created_by_user_id, usage_limit, times_used)
        SELECT
          code,
          role,
          school_id,
          class_id,
          COALESCE((times_used >= usage_limit), false) OR NOT COALESCE(is_active, true),
          expires_at,
          created_at,
          created_by,
          COALESCE(usage_limit, 1),
          COALESCE(times_used, 0)
        FROM invite_codes
        ON CONFLICT (token) DO NOTHING;
      ELSE
        -- Simpler insert without usage_limit/times_used
        INSERT INTO invite_tokens (token, role, school_id, specific_class_id, is_used, expires_at, created_at, created_by_user_id, usage_limit, times_used)
        SELECT
          code,
          role,
          school_id,
          class_id,
          NOT COALESCE(is_active, true),
          expires_at,
          created_at,
          created_by,
          1,
          0
        FROM invite_codes
        ON CONFLICT (token) DO NOTHING;
      END IF;
    END IF;

    -- Rename the old table
    ALTER TABLE invite_codes RENAME TO invite_codes_deprecated;

    COMMENT ON TABLE invite_codes_deprecated IS 'DEPRECATED: Use invite_tokens table instead. Data migrated on 2026-01-18.';

    RAISE NOTICE 'Migrated invite_codes to invite_tokens and renamed table to invite_codes_deprecated';
  END IF;
END $$;

-- =====================================================================
-- SECTION 18: SYNC updated_at TRIGGERS
-- =====================================================================

-- Ensure update_updated_at_column function exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to schools if not exists
DROP TRIGGER IF EXISTS update_schools_updated_at ON schools;
CREATE TRIGGER update_schools_updated_at
  BEFORE UPDATE ON schools
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply to profiles if not exists
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- SECTION 19: FINAL COMMENTS AND DOCUMENTATION
-- =====================================================================

COMMENT ON TABLE schools IS 'Educational institutions using the platform';
COMMENT ON TABLE profiles IS 'User profiles linked to auth.users with role-based access';
COMMENT ON TABLE classes IS 'Class/grade groups within a school';
COMMENT ON TABLE class_students IS 'Many-to-many relationship between classes and students';
COMMENT ON TABLE subjects IS 'Academic subjects - linked to classes via class_id, school via school_id';
COMMENT ON TABLE lessons IS 'Scheduled lessons/periods in the timetable - has class_id for backward compat';
COMMENT ON TABLE grades IS 'Student grades/scores for subjects';
COMMENT ON TABLE assignments IS 'Homework and assignments for students';
COMMENT ON TABLE invite_tokens IS 'Invitation tokens for user registration (replaces invite_codes)';
COMMENT ON TABLE materials IS 'Study materials and resources';
COMMENT ON TABLE parent_student IS 'Many-to-many relationship between parents and their children';
COMMENT ON TABLE attendance IS 'Student attendance records per lesson';
COMMENT ON TABLE messages IS 'Direct and group messages between users';
COMMENT ON TABLE message_groups IS 'Group chat rooms for messaging';
COMMENT ON TABLE message_group_members IS 'Maps users to their message groups';
COMMENT ON TABLE submissions IS 'Student submissions for assignments (teacher repo)';
COMMENT ON TABLE assignment_submissions IS 'Student submissions for assignments (student/parent repos)';
COMMENT ON TABLE class_subjects IS 'Junction table for class-subject relationships';

-- =====================================================================
-- ROLLBACK INSTRUCTIONS (manual):
-- =====================================================================
-- To rollback this migration:
--
-- 1. lessons.class_id: ALTER TABLE lessons DROP COLUMN IF EXISTS class_id;
-- 2. subjects.school_id: ALTER TABLE subjects DROP COLUMN IF EXISTS school_id;
-- 3. submissions table: DROP TABLE IF EXISTS submissions;
-- 4. Restore invite_codes: ALTER TABLE invite_codes_deprecated RENAME TO invite_codes;
-- 5. Remove new enums (complex, requires recreating dependent tables)
--
-- Note: Most changes are additive (ADD COLUMN IF NOT EXISTS) so they
-- should be safe to leave in place even if not used.
-- =====================================================================

-- =====================================================================
-- END OF UNIFIED SCHEMA MIGRATION
-- =====================================================================
