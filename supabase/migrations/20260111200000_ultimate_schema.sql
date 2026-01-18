-- CLASSIO ERP: ULTIMATE DATABASE SCHEMA
-- Production-Grade School Management System
-- Version: 2.0.0

-- Reset schema completely
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- ============================================================================
-- SECTION 1: ENUM TYPES
-- ============================================================================

-- User roles in the system hierarchy
CREATE TYPE user_role AS ENUM (
  'superadmin',  -- Platform-wide administrator
  'bigadmin',    -- School owner/principal
  'admin',       -- School administrator
  'teacher',     -- Teaching staff
  'student',     -- Student user
  'parent'       -- Parent/guardian
);

-- School subscription status
CREATE TYPE subscription_status AS ENUM (
  'trial',       -- Trial period
  'active',      -- Active subscription
  'suspended',   -- Temporarily suspended
  'cancelled'    -- Subscription cancelled
);

-- Attendance status options
CREATE TYPE attendance_status AS ENUM (
  'present',     -- Student present
  'absent',      -- Student absent
  'late',        -- Student arrived late
  'excused'      -- Excused absence
);

-- Excuse request status
CREATE TYPE excuse_status AS ENUM (
  'pending',     -- Awaiting review
  'approved',    -- Excuse approved
  'rejected'     -- Excuse rejected
);

-- Message types
CREATE TYPE message_type AS ENUM (
  'direct',      -- Direct message between two users
  'group',       -- Group message
  'announcement' -- School-wide announcement
);

-- ============================================================================
-- SECTION 2: TABLES (in dependency order)
-- ============================================================================

-- -----------------------------------------------------------------------------
-- 2.1 SCHOOLS - Core school entity
-- -----------------------------------------------------------------------------
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  subscription_status subscription_status NOT NULL DEFAULT 'trial',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE schools IS 'Schools registered in the Classio platform';

-- -----------------------------------------------------------------------------
-- 2.2 PROFILES - User profiles linked to auth.users
-- -----------------------------------------------------------------------------
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  role user_role NOT NULL DEFAULT 'student',
  school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE profiles IS 'User profiles extending auth.users with role and school assignment';

-- -----------------------------------------------------------------------------
-- 2.3 CLASSES - School classes/sections
-- -----------------------------------------------------------------------------
CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  head_teacher_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  grade_level TEXT,
  academic_year TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE classes IS 'Classes/sections within a school';

-- -----------------------------------------------------------------------------
-- 2.4 CLASS_STUDENTS - Student enrollment in classes (junction table)
-- -----------------------------------------------------------------------------
CREATE TABLE class_students (
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (class_id, student_id)
);

COMMENT ON TABLE class_students IS 'Maps students to their enrolled classes';

-- -----------------------------------------------------------------------------
-- 2.5 PARENT_STUDENT - Parent-child relationships (junction table)
-- -----------------------------------------------------------------------------
CREATE TABLE parent_student (
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  relationship TEXT,
  PRIMARY KEY (parent_id, student_id)
);

COMMENT ON TABLE parent_student IS 'Maps parents to their children (students)';

-- -----------------------------------------------------------------------------
-- 2.6 SUBJECTS - Subjects taught in classes
-- -----------------------------------------------------------------------------
CREATE TABLE subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  color TEXT,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE subjects IS 'Subjects/courses within a class';

-- -----------------------------------------------------------------------------
-- 2.7 LESSONS - Scheduled lesson periods
-- -----------------------------------------------------------------------------
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  room TEXT,
  day_of_week INTEGER CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_time TIME,
  end_time TIME,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE lessons IS 'Scheduled lesson periods for subjects';
COMMENT ON COLUMN lessons.day_of_week IS '0=Sunday, 1=Monday, ..., 6=Saturday';

-- -----------------------------------------------------------------------------
-- 2.8 GRADES - Student grades/marks
-- -----------------------------------------------------------------------------
CREATE TABLE grades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  score DECIMAL(5,2),
  weight DECIMAL(3,1) DEFAULT 1.0,
  note TEXT,
  grade_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE grades IS 'Student grades and assessments';

-- -----------------------------------------------------------------------------
-- 2.9 ASSIGNMENTS - Class assignments/homework
-- -----------------------------------------------------------------------------
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMPTZ,
  file_url TEXT,
  max_score INTEGER,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE assignments IS 'Assignments and homework for subjects';

-- -----------------------------------------------------------------------------
-- 2.10 SUBMISSIONS - Student assignment submissions
-- -----------------------------------------------------------------------------
CREATE TABLE submissions (
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

COMMENT ON TABLE submissions IS 'Student submissions for assignments';

-- -----------------------------------------------------------------------------
-- 2.11 ATTENDANCE - Student attendance records
-- -----------------------------------------------------------------------------
CREATE TABLE attendance (
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

COMMENT ON TABLE attendance IS 'Student attendance records per lesson';

-- -----------------------------------------------------------------------------
-- 2.12 MESSAGE_GROUPS - Group chat rooms
-- -----------------------------------------------------------------------------
CREATE TABLE message_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE message_groups IS 'Group chat rooms for messaging';

-- -----------------------------------------------------------------------------
-- 2.13 MESSAGE_GROUP_MEMBERS - Group membership (junction table)
-- -----------------------------------------------------------------------------
CREATE TABLE message_group_members (
  group_id UUID NOT NULL REFERENCES message_groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (group_id, user_id)
);

COMMENT ON TABLE message_group_members IS 'Maps users to their message groups';

-- -----------------------------------------------------------------------------
-- 2.14 MESSAGES - Direct and group messages
-- -----------------------------------------------------------------------------
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  group_id UUID REFERENCES message_groups(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type message_type NOT NULL DEFAULT 'direct',
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE messages IS 'Direct and group messages between users';

-- -----------------------------------------------------------------------------
-- 2.15 INVITE_TOKENS - Registration invite tokens
-- -----------------------------------------------------------------------------
CREATE TABLE invite_tokens (
  token TEXT PRIMARY KEY,
  role user_role NOT NULL,
  -- school_id and created_by_user_id are NULLABLE to allow bootstrap/genesis tokens
  -- (e.g., the first SuperAdmin token created before any users or schools exist)
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  created_by_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  specific_class_id UUID REFERENCES classes(id) ON DELETE SET NULL,
  is_used BOOLEAN NOT NULL DEFAULT false,
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '7 days'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE invite_tokens IS 'Invite tokens for user registration with role assignment';
COMMENT ON COLUMN invite_tokens.token IS '6-character unique invite code';
COMMENT ON COLUMN invite_tokens.school_id IS 'NULL for superadmin genesis tokens, required for school-specific roles';
COMMENT ON COLUMN invite_tokens.created_by_user_id IS 'NULL for bootstrap tokens created before any users exist';
COMMENT ON COLUMN invite_tokens.specific_class_id IS 'For student invites: auto-enroll in this class';

-- ============================================================================
-- SECTION 3: HELPER FUNCTIONS (SECURITY DEFINER)
-- ============================================================================

-- Get current user's role
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION get_user_role IS 'Returns the role of the currently authenticated user';

-- Get current user's school ID
CREATE OR REPLACE FUNCTION get_user_school_id()
RETURNS UUID AS $$
  SELECT school_id FROM profiles WHERE id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION get_user_school_id IS 'Returns the school_id of the currently authenticated user';

-- Check if current user is superadmin
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() = 'superadmin'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION is_superadmin IS 'Returns true if current user is a superadmin';

-- Check if current user is a school admin (bigadmin or admin)
CREATE OR REPLACE FUNCTION is_school_admin()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() IN ('bigadmin', 'admin')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION is_school_admin IS 'Returns true if current user is bigadmin or admin';

-- Check if current user is a teacher
CREATE OR REPLACE FUNCTION is_teacher()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() = 'teacher'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION is_teacher IS 'Returns true if current user is a teacher';

-- Check if user belongs to a specific school
CREATE OR REPLACE FUNCTION belongs_to_school(school UUID)
RETURNS BOOLEAN AS $$
  SELECT get_user_school_id() = school
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION belongs_to_school IS 'Returns true if current user belongs to the specified school';

-- Check if teacher teaches a specific class
CREATE OR REPLACE FUNCTION teaches_class(p_class_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM subjects WHERE subjects.class_id = p_class_id AND teacher_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION teaches_class IS 'Returns true if current user teaches any subject in the specified class';

-- Check if current user is parent of a specific student
CREATE OR REPLACE FUNCTION is_parent_of(p_student_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM parent_student WHERE parent_id = auth.uid() AND student_id = p_student_id
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION is_parent_of IS 'Returns true if current user is a parent of the specified student';

-- Check if student is in any of the teacher's classes
CREATE OR REPLACE FUNCTION student_in_my_class(p_student_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM class_students cs
    JOIN subjects s ON s.class_id = cs.class_id
    WHERE cs.student_id = p_student_id AND s.teacher_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION student_in_my_class IS 'Returns true if the specified student is in any class taught by the current user';

-- Check if current user is a member of a message group
CREATE OR REPLACE FUNCTION is_group_member(p_group_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM message_group_members WHERE group_id = p_group_id AND user_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION is_group_member IS 'Returns true if current user is a member of the specified message group';

-- ============================================================================
-- SECTION 4: ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_student ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_tokens ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 4.1 SCHOOLS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access to all schools
CREATE POLICY "superadmin_all_schools" ON schools
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Read and update own school only
CREATE POLICY "admin_select_own_school" ON schools
  FOR SELECT
  TO authenticated
  USING (is_school_admin() AND id = get_user_school_id());

CREATE POLICY "admin_update_own_school" ON schools
  FOR UPDATE
  TO authenticated
  USING (is_school_admin() AND id = get_user_school_id())
  WITH CHECK (is_school_admin() AND id = get_user_school_id());

-- Others: Read own school only
CREATE POLICY "users_select_own_school" ON schools
  FOR SELECT
  TO authenticated
  USING (id = get_user_school_id());

-- -----------------------------------------------------------------------------
-- 4.2 PROFILES POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_profiles" ON profiles
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Full access within own school
CREATE POLICY "bigadmin_all_own_school_profiles" ON profiles
  FOR ALL
  TO authenticated
  USING (get_user_role() = 'bigadmin' AND school_id = get_user_school_id())
  WITH CHECK (get_user_role() = 'bigadmin' AND school_id = get_user_school_id());

-- Admin: Read and update within own school
CREATE POLICY "admin_select_own_school_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'admin' AND school_id = get_user_school_id());

CREATE POLICY "admin_update_own_school_profiles" ON profiles
  FOR UPDATE
  TO authenticated
  USING (get_user_role() = 'admin' AND school_id = get_user_school_id())
  WITH CHECK (get_user_role() = 'admin' AND school_id = get_user_school_id());

-- Teacher: Read students in their classes + same school staff
CREATE POLICY "teacher_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    is_teacher() AND (
      -- Same school staff
      (school_id = get_user_school_id() AND role IN ('bigadmin', 'admin', 'teacher'))
      OR
      -- Students in classes they teach
      student_in_my_class(id)
      OR
      -- Own profile
      id = auth.uid()
    )
  );

-- Parent: Read own profile + children's profiles
CREATE POLICY "parent_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'parent' AND (
      id = auth.uid() OR is_parent_of(id)
    )
  );

-- Student: Read own + classmates + teachers in their school
CREATE POLICY "student_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'student' AND (
      -- Own profile
      id = auth.uid()
      OR
      -- Classmates (students in same classes)
      EXISTS (
        SELECT 1 FROM class_students cs1
        JOIN class_students cs2 ON cs1.class_id = cs2.class_id
        WHERE cs1.student_id = auth.uid() AND cs2.student_id = profiles.id
      )
      OR
      -- Teachers and admins in same school
      (school_id = get_user_school_id() AND role IN ('bigadmin', 'admin', 'teacher'))
    )
  );

-- All users can update their own profile
CREATE POLICY "users_update_own_profile" ON profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- -----------------------------------------------------------------------------
-- 4.3 CLASSES POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_classes" ON classes
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Full access within own school
CREATE POLICY "bigadmin_all_own_school_classes" ON classes
  FOR ALL
  TO authenticated
  USING (get_user_role() = 'bigadmin' AND school_id = get_user_school_id())
  WITH CHECK (get_user_role() = 'bigadmin' AND school_id = get_user_school_id());

-- Admin: Read, insert, update within own school
CREATE POLICY "admin_select_own_school_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'admin' AND school_id = get_user_school_id());

CREATE POLICY "admin_insert_own_school_classes" ON classes
  FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'admin' AND school_id = get_user_school_id());

CREATE POLICY "admin_update_own_school_classes" ON classes
  FOR UPDATE
  TO authenticated
  USING (get_user_role() = 'admin' AND school_id = get_user_school_id())
  WITH CHECK (get_user_role() = 'admin' AND school_id = get_user_school_id());

-- Teacher: Read classes they teach
CREATE POLICY "teacher_select_own_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (is_teacher() AND teaches_class(id));

-- Student: Read enrolled classes
CREATE POLICY "student_select_enrolled_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'student' AND
    EXISTS (SELECT 1 FROM class_students WHERE class_id = classes.id AND student_id = auth.uid())
  );

-- Parent: Read children's classes
CREATE POLICY "parent_select_children_classes" ON classes
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM class_students cs
      JOIN parent_student ps ON cs.student_id = ps.student_id
      WHERE cs.class_id = classes.id AND ps.parent_id = auth.uid()
    )
  );

-- -----------------------------------------------------------------------------
-- 4.4 CLASS_STUDENTS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_class_students" ON class_students
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Full access within own school
CREATE POLICY "admin_all_own_school_class_students" ON class_students
  FOR ALL
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM classes WHERE id = class_students.class_id AND school_id = get_user_school_id())
  )
  WITH CHECK (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM classes WHERE id = class_students.class_id AND school_id = get_user_school_id())
  );

-- Teacher: Read students in classes they teach, insert for their classes
CREATE POLICY "teacher_select_class_students" ON class_students
  FOR SELECT
  TO authenticated
  USING (is_teacher() AND teaches_class(class_id));

CREATE POLICY "teacher_insert_class_students" ON class_students
  FOR INSERT
  TO authenticated
  WITH CHECK (is_teacher() AND teaches_class(class_id));

-- Student: Read own enrollments
CREATE POLICY "student_select_own_enrollment" ON class_students
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'student' AND student_id = auth.uid());

-- Parent: Read children's enrollments
CREATE POLICY "parent_select_children_enrollment" ON class_students
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'parent' AND is_parent_of(student_id));

-- -----------------------------------------------------------------------------
-- 4.5 PARENT_STUDENT POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_parent_student" ON parent_student
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Full access within own school
CREATE POLICY "admin_all_own_school_parent_student" ON parent_student
  FOR ALL
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM profiles WHERE id = parent_student.student_id AND school_id = get_user_school_id())
  )
  WITH CHECK (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM profiles WHERE id = parent_student.student_id AND school_id = get_user_school_id())
  );

-- Parent: Read own relationships
CREATE POLICY "parent_select_own_relationships" ON parent_student
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'parent' AND parent_id = auth.uid());

-- Student: Read relationships involving themselves
CREATE POLICY "student_select_own_parent" ON parent_student
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'student' AND student_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 4.6 SUBJECTS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_subjects" ON subjects
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Full access within own school
CREATE POLICY "bigadmin_all_own_school_subjects" ON subjects
  FOR ALL
  TO authenticated
  USING (
    get_user_role() = 'bigadmin' AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  )
  WITH CHECK (
    get_user_role() = 'bigadmin' AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  );

-- Admin: Read, insert, update within own school
CREATE POLICY "admin_select_own_school_subjects" ON subjects
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'admin' AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  );

CREATE POLICY "admin_insert_own_school_subjects" ON subjects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_user_role() = 'admin' AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  );

CREATE POLICY "admin_update_own_school_subjects" ON subjects
  FOR UPDATE
  TO authenticated
  USING (
    get_user_role() = 'admin' AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  )
  WITH CHECK (
    get_user_role() = 'admin' AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  );

-- Teacher: Full access for own subjects, read others in school
CREATE POLICY "teacher_all_own_subjects" ON subjects
  FOR ALL
  TO authenticated
  USING (is_teacher() AND teacher_id = auth.uid())
  WITH CHECK (is_teacher() AND teacher_id = auth.uid());

CREATE POLICY "teacher_select_school_subjects" ON subjects
  FOR SELECT
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM classes WHERE id = subjects.class_id AND school_id = get_user_school_id())
  );

-- Student: Read subjects in enrolled classes
CREATE POLICY "student_select_enrolled_subjects" ON subjects
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'student' AND
    EXISTS (SELECT 1 FROM class_students WHERE class_id = subjects.class_id AND student_id = auth.uid())
  );

-- Parent: Read children's subjects
CREATE POLICY "parent_select_children_subjects" ON subjects
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM class_students cs
      JOIN parent_student ps ON cs.student_id = ps.student_id
      WHERE cs.class_id = subjects.class_id AND ps.parent_id = auth.uid()
    )
  );

-- -----------------------------------------------------------------------------
-- 4.7 LESSONS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_lessons" ON lessons
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Full access within own school
CREATE POLICY "admin_all_own_school_lessons" ON lessons
  FOR ALL
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN classes c ON s.class_id = c.id
      WHERE s.id = lessons.subject_id AND c.school_id = get_user_school_id()
    )
  )
  WITH CHECK (
    is_school_admin() AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN classes c ON s.class_id = c.id
      WHERE s.id = lessons.subject_id AND c.school_id = get_user_school_id()
    )
  );

-- Teacher: Read and update own subjects' lessons
CREATE POLICY "teacher_select_own_lessons" ON lessons
  FOR SELECT
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = lessons.subject_id AND teacher_id = auth.uid())
  );

CREATE POLICY "teacher_update_own_lessons" ON lessons
  FOR UPDATE
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = lessons.subject_id AND teacher_id = auth.uid())
  )
  WITH CHECK (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = lessons.subject_id AND teacher_id = auth.uid())
  );

-- Student: Read lessons for enrolled classes
CREATE POLICY "student_select_enrolled_lessons" ON lessons
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'student' AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN class_students cs ON s.class_id = cs.class_id
      WHERE s.id = lessons.subject_id AND cs.student_id = auth.uid()
    )
  );

-- Parent: Read children's lessons
CREATE POLICY "parent_select_children_lessons" ON lessons
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN class_students cs ON s.class_id = cs.class_id
      JOIN parent_student ps ON cs.student_id = ps.student_id
      WHERE s.id = lessons.subject_id AND ps.parent_id = auth.uid()
    )
  );

-- -----------------------------------------------------------------------------
-- 4.8 GRADES POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_grades" ON grades
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Read within own school
CREATE POLICY "admin_select_own_school_grades" ON grades
  FOR SELECT
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN classes c ON s.class_id = c.id
      WHERE s.id = grades.subject_id AND c.school_id = get_user_school_id()
    )
  );

-- Teacher: Full access for subjects they teach
CREATE POLICY "teacher_all_own_grades" ON grades
  FOR ALL
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = grades.subject_id AND teacher_id = auth.uid())
  )
  WITH CHECK (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = grades.subject_id AND teacher_id = auth.uid())
  );

-- Student: Read own grades
CREATE POLICY "student_select_own_grades" ON grades
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'student' AND student_id = auth.uid());

-- Parent: Read children's grades
CREATE POLICY "parent_select_children_grades" ON grades
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'parent' AND is_parent_of(student_id));

-- -----------------------------------------------------------------------------
-- 4.9 ASSIGNMENTS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_assignments" ON assignments
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Read within own school
CREATE POLICY "admin_select_own_school_assignments" ON assignments
  FOR SELECT
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN classes c ON s.class_id = c.id
      WHERE s.id = assignments.subject_id AND c.school_id = get_user_school_id()
    )
  );

-- Teacher: Full access for own subjects
CREATE POLICY "teacher_all_own_assignments" ON assignments
  FOR ALL
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = assignments.subject_id AND teacher_id = auth.uid())
  )
  WITH CHECK (
    is_teacher() AND
    EXISTS (SELECT 1 FROM subjects WHERE id = assignments.subject_id AND teacher_id = auth.uid())
  );

-- Student: Read assignments for enrolled classes
CREATE POLICY "student_select_enrolled_assignments" ON assignments
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'student' AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN class_students cs ON s.class_id = cs.class_id
      WHERE s.id = assignments.subject_id AND cs.student_id = auth.uid()
    )
  );

-- Parent: Read children's assignments
CREATE POLICY "parent_select_children_assignments" ON assignments
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM subjects s
      JOIN class_students cs ON s.class_id = cs.class_id
      JOIN parent_student ps ON cs.student_id = ps.student_id
      WHERE s.id = assignments.subject_id AND ps.parent_id = auth.uid()
    )
  );

-- -----------------------------------------------------------------------------
-- 4.10 SUBMISSIONS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_submissions" ON submissions
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Read within own school
CREATE POLICY "admin_select_own_school_submissions" ON submissions
  FOR SELECT
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN subjects s ON a.subject_id = s.id
      JOIN classes c ON s.class_id = c.id
      WHERE a.id = submissions.assignment_id AND c.school_id = get_user_school_id()
    )
  );

-- Teacher: Read and update for own subjects
CREATE POLICY "teacher_select_own_submissions" ON submissions
  FOR SELECT
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN subjects s ON a.subject_id = s.id
      WHERE a.id = submissions.assignment_id AND s.teacher_id = auth.uid()
    )
  );

CREATE POLICY "teacher_update_own_submissions" ON submissions
  FOR UPDATE
  TO authenticated
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

-- Student: Insert and read own submissions
CREATE POLICY "student_insert_own_submissions" ON submissions
  FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'student' AND student_id = auth.uid());

CREATE POLICY "student_select_own_submissions" ON submissions
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'student' AND student_id = auth.uid());

-- Parent: Read children's submissions
CREATE POLICY "parent_select_children_submissions" ON submissions
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'parent' AND is_parent_of(student_id));

-- -----------------------------------------------------------------------------
-- 4.11 ATTENDANCE POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_attendance" ON attendance
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin/Admin: Read within own school
CREATE POLICY "admin_select_own_school_attendance" ON attendance
  FOR SELECT
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (
      SELECT 1 FROM lessons l
      JOIN subjects s ON l.subject_id = s.id
      JOIN classes c ON s.class_id = c.id
      WHERE l.id = attendance.lesson_id AND c.school_id = get_user_school_id()
    )
  );

-- Teacher: Insert, update, read for classes they teach
CREATE POLICY "teacher_insert_attendance" ON attendance
  FOR INSERT
  TO authenticated
  WITH CHECK (
    is_teacher() AND
    EXISTS (
      SELECT 1 FROM lessons l
      JOIN subjects s ON l.subject_id = s.id
      WHERE l.id = attendance.lesson_id AND s.teacher_id = auth.uid()
    )
  );

CREATE POLICY "teacher_update_attendance" ON attendance
  FOR UPDATE
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (
      SELECT 1 FROM lessons l
      JOIN subjects s ON l.subject_id = s.id
      WHERE l.id = attendance.lesson_id AND s.teacher_id = auth.uid()
    )
  )
  WITH CHECK (
    is_teacher() AND
    EXISTS (
      SELECT 1 FROM lessons l
      JOIN subjects s ON l.subject_id = s.id
      WHERE l.id = attendance.lesson_id AND s.teacher_id = auth.uid()
    )
  );

CREATE POLICY "teacher_select_attendance" ON attendance
  FOR SELECT
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (
      SELECT 1 FROM lessons l
      JOIN subjects s ON l.subject_id = s.id
      WHERE l.id = attendance.lesson_id AND s.teacher_id = auth.uid()
    )
  );

-- Student: Read own attendance
CREATE POLICY "student_select_own_attendance" ON attendance
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'student' AND student_id = auth.uid());

-- Parent: Read children's attendance + update excuse notes
CREATE POLICY "parent_select_children_attendance" ON attendance
  FOR SELECT
  TO authenticated
  USING (get_user_role() = 'parent' AND is_parent_of(student_id));

CREATE POLICY "parent_update_excuse" ON attendance
  FOR UPDATE
  TO authenticated
  USING (get_user_role() = 'parent' AND is_parent_of(student_id))
  WITH CHECK (get_user_role() = 'parent' AND is_parent_of(student_id));

-- -----------------------------------------------------------------------------
-- 4.12 MESSAGES POLICIES
-- -----------------------------------------------------------------------------

-- Users can insert messages where they are the sender
CREATE POLICY "users_insert_own_messages" ON messages
  FOR INSERT
  TO authenticated
  WITH CHECK (sender_id = auth.uid());

-- Users can read messages they sent or received (direct or group)
CREATE POLICY "users_select_own_messages" ON messages
  FOR SELECT
  TO authenticated
  USING (
    sender_id = auth.uid()
    OR recipient_id = auth.uid()
    OR (group_id IS NOT NULL AND is_group_member(group_id))
  );

-- Users can update is_read on messages they received
CREATE POLICY "users_update_read_status" ON messages
  FOR UPDATE
  TO authenticated
  USING (recipient_id = auth.uid())
  WITH CHECK (recipient_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 4.13 MESSAGE_GROUPS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_message_groups" ON message_groups
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Admin: Full access within own school
CREATE POLICY "admin_all_own_school_message_groups" ON message_groups
  FOR ALL
  TO authenticated
  USING (is_school_admin() AND school_id = get_user_school_id())
  WITH CHECK (is_school_admin() AND school_id = get_user_school_id());

-- Users can read groups they are members of
CREATE POLICY "users_select_member_groups" ON message_groups
  FOR SELECT
  TO authenticated
  USING (is_group_member(id));

-- Teachers can create groups
CREATE POLICY "teacher_insert_groups" ON message_groups
  FOR INSERT
  TO authenticated
  WITH CHECK (is_teacher() AND school_id = get_user_school_id());

-- -----------------------------------------------------------------------------
-- 4.14 MESSAGE_GROUP_MEMBERS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_group_members" ON message_group_members
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Admin: Full access within own school
CREATE POLICY "admin_all_own_school_group_members" ON message_group_members
  FOR ALL
  TO authenticated
  USING (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM message_groups WHERE id = message_group_members.group_id AND school_id = get_user_school_id())
  )
  WITH CHECK (
    is_school_admin() AND
    EXISTS (SELECT 1 FROM message_groups WHERE id = message_group_members.group_id AND school_id = get_user_school_id())
  );

-- Users can read members of groups they belong to
CREATE POLICY "users_select_group_members" ON message_group_members
  FOR SELECT
  TO authenticated
  USING (is_group_member(group_id));

-- Group creators (teachers) can manage members
CREATE POLICY "teacher_manage_group_members" ON message_group_members
  FOR ALL
  TO authenticated
  USING (
    is_teacher() AND
    EXISTS (SELECT 1 FROM message_groups WHERE id = message_group_members.group_id AND created_by = auth.uid())
  )
  WITH CHECK (
    is_teacher() AND
    EXISTS (SELECT 1 FROM message_groups WHERE id = message_group_members.group_id AND created_by = auth.uid())
  );

-- -----------------------------------------------------------------------------
-- 4.15 INVITE_TOKENS POLICIES
-- -----------------------------------------------------------------------------

-- Superadmin: Full access
CREATE POLICY "superadmin_all_invite_tokens" ON invite_tokens
  FOR ALL
  TO authenticated
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Create tokens for bigadmin, admin, teacher roles in own school
CREATE POLICY "bigadmin_insert_tokens" ON invite_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_user_role() = 'bigadmin'
    AND school_id = get_user_school_id()
    AND role IN ('bigadmin', 'admin', 'teacher')
  );

CREATE POLICY "bigadmin_select_tokens" ON invite_tokens
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'bigadmin'
    AND school_id = get_user_school_id()
  );

-- Admin: Create tokens for teacher, parent roles in own school
CREATE POLICY "admin_insert_tokens" ON invite_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_user_role() = 'admin'
    AND school_id = get_user_school_id()
    AND role IN ('teacher', 'parent')
  );

CREATE POLICY "admin_select_tokens" ON invite_tokens
  FOR SELECT
  TO authenticated
  USING (
    get_user_role() = 'admin'
    AND school_id = get_user_school_id()
  );

-- Teacher: Create tokens for student role with specific_class_id they teach
CREATE POLICY "teacher_insert_tokens" ON invite_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (
    is_teacher()
    AND school_id = get_user_school_id()
    AND role = 'student'
    AND specific_class_id IS NOT NULL
    AND teaches_class(specific_class_id)
  );

CREATE POLICY "teacher_select_tokens" ON invite_tokens
  FOR SELECT
  TO authenticated
  USING (
    is_teacher()
    AND school_id = get_user_school_id()
    AND created_by_user_id = auth.uid()
  );

-- Anyone (including anonymous users) can validate invite tokens during registration
-- They can only SELECT (not insert/update/delete)
-- They can only see unused, non-expired tokens
CREATE POLICY "Anyone can validate invite tokens"
  ON invite_tokens
  FOR SELECT
  TO anon, authenticated
  USING (
    is_used = false
    AND (expires_at IS NULL OR expires_at > now())
  );

-- ============================================================================
-- SECTION 5: AUTO-PROFILE TRIGGER (FAULT-TOLERANT + TOKEN VALIDATION)
-- ============================================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  _role user_role;
  _school_id UUID;
  _token_record RECORD;
  _invite_token TEXT;
  _class_id UUID;
BEGIN
  -- Extract invite token from metadata
  _invite_token := NEW.raw_user_meta_data->>'invite_token';

  IF _invite_token IS NULL OR _invite_token = '' THEN
    RAISE EXCEPTION 'Registration requires a valid invite token';
  END IF;

  -- Validate and fetch token
  SELECT * INTO _token_record FROM invite_tokens
  WHERE token = _invite_token
    AND is_used = false
    AND (expires_at IS NULL OR expires_at > now());

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid or expired invite token';
  END IF;

  -- Mark token as used
  UPDATE invite_tokens SET is_used = true WHERE token = _invite_token;

  -- Set values from token
  _role := _token_record.role;
  _school_id := _token_record.school_id;
  _class_id := _token_record.specific_class_id;

  -- Create profile
  INSERT INTO profiles (id, email, role, school_id, first_name, last_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    _role,
    _school_id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
    NEW.raw_user_meta_data->>'avatar_url'
  );

  -- If student and class specified, enroll in class
  IF _role = 'student' AND _class_id IS NOT NULL THEN
    INSERT INTO class_students (class_id, student_id) VALUES (_class_id, NEW.id);
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION handle_new_user IS 'Automatically creates a profile for new users based on invite token';

-- Create trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- SECTION 6: INDEXES FOR PERFORMANCE
-- ============================================================================

-- Profiles indexes
CREATE INDEX idx_profiles_school_id ON profiles(school_id);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);

-- Classes indexes
CREATE INDEX idx_classes_school_id ON classes(school_id);
CREATE INDEX idx_classes_head_teacher_id ON classes(head_teacher_id);
CREATE INDEX idx_classes_academic_year ON classes(academic_year);

-- Class students indexes
CREATE INDEX idx_class_students_student_id ON class_students(student_id);
CREATE INDEX idx_class_students_class_id ON class_students(class_id);

-- Parent student indexes
CREATE INDEX idx_parent_student_student_id ON parent_student(student_id);
CREATE INDEX idx_parent_student_parent_id ON parent_student(parent_id);

-- Subjects indexes
CREATE INDEX idx_subjects_class_id ON subjects(class_id);
CREATE INDEX idx_subjects_teacher_id ON subjects(teacher_id);

-- Lessons indexes
CREATE INDEX idx_lessons_subject_id ON lessons(subject_id);
CREATE INDEX idx_lessons_day_of_week ON lessons(day_of_week);
CREATE INDEX idx_lessons_subject_day ON lessons(subject_id, day_of_week);

-- Grades indexes
CREATE INDEX idx_grades_student_id ON grades(student_id);
CREATE INDEX idx_grades_subject_id ON grades(subject_id);
CREATE INDEX idx_grades_teacher_id ON grades(teacher_id);
CREATE INDEX idx_grades_student_subject ON grades(student_id, subject_id);

-- Assignments indexes
CREATE INDEX idx_assignments_subject_id ON assignments(subject_id);
CREATE INDEX idx_assignments_due_date ON assignments(due_date);
CREATE INDEX idx_assignments_created_by ON assignments(created_by);

-- Submissions indexes
CREATE INDEX idx_submissions_assignment_id ON submissions(assignment_id);
CREATE INDEX idx_submissions_student_id ON submissions(student_id);
CREATE INDEX idx_submissions_assignment_student ON submissions(assignment_id, student_id);

-- Attendance indexes
CREATE INDEX idx_attendance_student_id ON attendance(student_id);
CREATE INDEX idx_attendance_lesson_id ON attendance(lesson_id);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_student_date ON attendance(student_id, date);
CREATE INDEX idx_attendance_lesson_date ON attendance(lesson_id, date);
CREATE INDEX idx_attendance_status ON attendance(status);

-- Messages indexes
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_messages_group_id ON messages(group_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_is_read ON messages(is_read) WHERE is_read = false;

-- Message groups indexes
CREATE INDEX idx_message_groups_school_id ON message_groups(school_id);
CREATE INDEX idx_message_groups_created_by ON message_groups(created_by);

-- Message group members indexes
CREATE INDEX idx_message_group_members_user_id ON message_group_members(user_id);
CREATE INDEX idx_message_group_members_group_id ON message_group_members(group_id);

-- Invite tokens indexes
CREATE INDEX idx_invite_tokens_school_id ON invite_tokens(school_id);
CREATE INDEX idx_invite_tokens_is_used ON invite_tokens(is_used);
CREATE INDEX idx_invite_tokens_expires_at ON invite_tokens(expires_at);
CREATE INDEX idx_invite_tokens_created_by ON invite_tokens(created_by_user_id);
CREATE INDEX idx_invite_tokens_active ON invite_tokens(school_id, is_used, expires_at)
  WHERE is_used = false;

-- ============================================================================
-- SECTION 7: REALTIME SUBSCRIPTIONS
-- ============================================================================

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- ============================================================================
-- SECTION 8: UPDATED_AT TRIGGERS
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_schools_updated_at
  BEFORE UPDATE ON schools
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SECTION 9: UTILITY FUNCTIONS
-- ============================================================================

-- Generate random invite token (6 characters)
CREATE OR REPLACE FUNCTION generate_invite_token()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_invite_token IS 'Generates a 6-character random invite token (excludes ambiguous characters like 0, O, 1, I)';

-- Function to create an invite token
CREATE OR REPLACE FUNCTION create_invite_token(
  p_role user_role,
  p_school_id UUID,
  p_class_id UUID DEFAULT NULL,
  p_expires_in INTERVAL DEFAULT '7 days'
)
RETURNS TEXT AS $$
DECLARE
  new_token TEXT;
  attempts INTEGER := 0;
BEGIN
  LOOP
    new_token := generate_invite_token();

    BEGIN
      INSERT INTO invite_tokens (token, role, school_id, created_by_user_id, specific_class_id, expires_at)
      VALUES (new_token, p_role, p_school_id, auth.uid(), p_class_id, now() + p_expires_in);

      RETURN new_token;
    EXCEPTION
      WHEN unique_violation THEN
        attempts := attempts + 1;
        IF attempts >= 10 THEN
          RAISE EXCEPTION 'Could not generate unique token after 10 attempts';
        END IF;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_invite_token IS 'Creates a new invite token with the specified role and school';

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
