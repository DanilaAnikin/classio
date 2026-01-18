-- =====================================================
-- CLASSIO DATABASE SCHEMA
-- Educational Management System
-- =====================================================

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE user_role AS ENUM (
  'superadmin',
  'admin',
  'teacher',
  'student',
  'parent'
);

-- =====================================================
-- TABLES
-- =====================================================

-- -----------------------------------------------------
-- Schools Table
-- -----------------------------------------------------
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Profiles Table
-- -----------------------------------------------------
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
  role user_role NOT NULL,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Invite Codes Table
-- -----------------------------------------------------
CREATE TABLE invite_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  role user_role NOT NULL,
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  class_id UUID,
  usage_limit INT DEFAULT 1,
  times_used INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Classes Table
-- -----------------------------------------------------
CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  head_teacher_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  grade_level TEXT,
  academic_year TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- -----------------------------------------------------
-- Class Students Junction Table (Many-to-Many)
-- -----------------------------------------------------
CREATE TABLE class_students (
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (class_id, student_id)
);

-- -----------------------------------------------------
-- Subjects Table
-- -----------------------------------------------------
CREATE TABLE subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  teacher_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Class Subjects Junction Table (Many-to-Many)
-- -----------------------------------------------------
CREATE TABLE class_subjects (
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (class_id, subject_id)
);

-- -----------------------------------------------------
-- Lessons Table (Schedule/Timetable)
-- -----------------------------------------------------
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  day_of_week INT CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_time TIME,
  end_time TIME,
  room TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Grades Table
-- -----------------------------------------------------
CREATE TABLE grades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
  score DECIMAL(5,2),
  weight DECIMAL(3,2) DEFAULT 1.0,
  grade_type TEXT,
  comment TEXT,
  graded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Assignments Table
-- -----------------------------------------------------
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMPTZ,
  max_score INT,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Assignment Submissions Table
-- -----------------------------------------------------
CREATE TABLE assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT,
  file_url TEXT,
  submitted_at TIMESTAMPTZ DEFAULT now(),
  score DECIMAL(5,2),
  feedback TEXT
);

-- -----------------------------------------------------
-- Materials Table (Study Materials)
-- -----------------------------------------------------
CREATE TABLE materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  file_url TEXT,
  material_type TEXT,
  uploaded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------
-- Parent Student Junction Table (Many-to-Many)
-- -----------------------------------------------------
CREATE TABLE parent_student (
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  relationship TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (parent_id, student_id),
  CHECK (parent_id != student_id)
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Profiles indexes
CREATE INDEX idx_profiles_school_id ON profiles(school_id);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_school_role ON profiles(school_id, role);

-- Invite codes indexes
CREATE INDEX idx_invite_codes_code ON invite_codes(code);
CREATE INDEX idx_invite_codes_school_id ON invite_codes(school_id);
CREATE INDEX idx_invite_codes_is_active ON invite_codes(is_active);
CREATE INDEX idx_invite_codes_expires_at ON invite_codes(expires_at);

-- Classes indexes
CREATE INDEX idx_classes_school_id ON classes(school_id);
CREATE INDEX idx_classes_academic_year ON classes(academic_year);

-- Class students indexes
CREATE INDEX idx_class_students_student_id ON class_students(student_id);
CREATE INDEX idx_class_students_class_id ON class_students(class_id);

-- Subjects indexes
CREATE INDEX idx_subjects_school_id ON subjects(school_id);
CREATE INDEX idx_subjects_teacher_id ON subjects(teacher_id);

-- Class subjects indexes
CREATE INDEX idx_class_subjects_subject_id ON class_subjects(subject_id);
CREATE INDEX idx_class_subjects_class_id ON class_subjects(class_id);

-- Lessons indexes
CREATE INDEX idx_lessons_subject_id ON lessons(subject_id);
CREATE INDEX idx_lessons_class_id ON lessons(class_id);
CREATE INDEX idx_lessons_day_of_week ON lessons(day_of_week);

-- Grades indexes
CREATE INDEX idx_grades_student_id ON grades(student_id);
CREATE INDEX idx_grades_subject_id ON grades(subject_id);
CREATE INDEX idx_grades_lesson_id ON grades(lesson_id);
CREATE INDEX idx_grades_graded_by ON grades(graded_by);
CREATE INDEX idx_grades_student_subject ON grades(student_id, subject_id);

-- Assignments indexes
CREATE INDEX idx_assignments_subject_id ON assignments(subject_id);
CREATE INDEX idx_assignments_class_id ON assignments(class_id);
CREATE INDEX idx_assignments_created_by ON assignments(created_by);
CREATE INDEX idx_assignments_due_date ON assignments(due_date);

-- Assignment submissions indexes
CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_assignment_submissions_student_id ON assignment_submissions(student_id);
CREATE INDEX idx_assignment_submissions_submitted_at ON assignment_submissions(submitted_at);

-- Materials indexes
CREATE INDEX idx_materials_subject_id ON materials(subject_id);
CREATE INDEX idx_materials_uploaded_by ON materials(uploaded_by);

-- Parent student indexes
CREATE INDEX idx_parent_student_student_id ON parent_student(student_id);
CREATE INDEX idx_parent_student_parent_id ON parent_student(parent_id);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- -----------------------------------------------------
-- Function: Update updated_at timestamp
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- Trigger: Update profiles.updated_at
-- -----------------------------------------------------
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- -----------------------------------------------------
-- Function: Increment invite code usage
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION increment_invite_code_usage()
RETURNS TRIGGER AS $$
BEGIN
  -- Increment times_used when a new profile is created with an invite code
  -- This would be called from application logic when invite code is used
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_student ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------
-- HELPER FUNCTION: Get current user's profile
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS profiles AS $$
  SELECT * FROM profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- -----------------------------------------------------
-- HELPER FUNCTION: Get current user's role
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- -----------------------------------------------------
-- HELPER FUNCTION: Get current user's school_id
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_school_id()
RETURNS UUID AS $$
  SELECT school_id FROM profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- -----------------------------------------------------
-- HELPER FUNCTION: Check if user is superadmin
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'superadmin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- -----------------------------------------------------
-- HELPER FUNCTION: Check if user is admin or superadmin
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION is_admin_or_superadmin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role IN ('admin', 'superadmin')
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- =====================================================
-- RLS POLICIES: SCHOOLS
-- =====================================================

-- Superadmins can view all schools
CREATE POLICY "Superadmins can view all schools"
  ON schools FOR SELECT
  USING (is_superadmin());

-- Users can view their own school
CREATE POLICY "Users can view their own school"
  ON schools FOR SELECT
  USING (id = get_user_school_id());

-- Superadmins can insert schools
CREATE POLICY "Superadmins can insert schools"
  ON schools FOR INSERT
  WITH CHECK (is_superadmin());

-- Superadmins and admins can update their school
CREATE POLICY "Admins can update their school"
  ON schools FOR UPDATE
  USING (
    is_superadmin() OR
    (is_admin_or_superadmin() AND id = get_user_school_id())
  );

-- =====================================================
-- RLS POLICIES: PROFILES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (id = auth.uid());

-- Users can view profiles from their own school
CREATE POLICY "Users can view profiles from their school"
  ON profiles FOR SELECT
  USING (school_id = get_user_school_id());

-- Superadmins can view all profiles
CREATE POLICY "Superadmins can view all profiles"
  ON profiles FOR SELECT
  USING (is_superadmin());

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (id = auth.uid());

-- Admins can update profiles in their school
CREATE POLICY "Admins can update profiles in their school"
  ON profiles FOR UPDATE
  USING (
    is_admin_or_superadmin() AND
    school_id = get_user_school_id()
  );

-- Users can insert their own profile (during registration)
CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (id = auth.uid());

-- =====================================================
-- RLS POLICIES: INVITE CODES
-- =====================================================

-- Admins can view invite codes for their school
CREATE POLICY "Admins can view invite codes for their school"
  ON invite_codes FOR SELECT
  USING (
    is_admin_or_superadmin() AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- Anyone can view active invite codes (for registration)
CREATE POLICY "Anyone can view active invite codes"
  ON invite_codes FOR SELECT
  USING (is_active = true AND (expires_at IS NULL OR expires_at > now()));

-- Admins can create invite codes for their school
CREATE POLICY "Admins can create invite codes"
  ON invite_codes FOR INSERT
  WITH CHECK (
    is_admin_or_superadmin() AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- Admins can update invite codes for their school
CREATE POLICY "Admins can update invite codes"
  ON invite_codes FOR UPDATE
  USING (
    is_admin_or_superadmin() AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- =====================================================
-- RLS POLICIES: CLASSES
-- =====================================================

-- Users can view classes from their school
CREATE POLICY "Users can view classes from their school"
  ON classes FOR SELECT
  USING (
    school_id = get_user_school_id() OR
    is_superadmin()
  );

-- Admins and teachers can create classes
CREATE POLICY "Admins and teachers can create classes"
  ON classes FOR INSERT
  WITH CHECK (
    (is_admin_or_superadmin() OR get_user_role() = 'teacher') AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- Admins and teachers can update classes
CREATE POLICY "Admins and teachers can update classes"
  ON classes FOR UPDATE
  USING (
    (is_admin_or_superadmin() OR get_user_role() = 'teacher') AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- Admins can delete classes
CREATE POLICY "Admins can delete classes"
  ON classes FOR DELETE
  USING (
    is_admin_or_superadmin() AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- =====================================================
-- RLS POLICIES: CLASS STUDENTS
-- =====================================================

-- Students can view their own class enrollments
CREATE POLICY "Students can view their own class enrollments"
  ON class_students FOR SELECT
  USING (student_id = auth.uid());

-- Users can view class students from their school's classes
CREATE POLICY "Users can view class students from their school"
  ON class_students FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM classes
      WHERE classes.id = class_students.class_id
      AND classes.school_id = get_user_school_id()
    ) OR is_superadmin()
  );

-- Admins and teachers can manage class students
CREATE POLICY "Admins and teachers can manage class students"
  ON class_students FOR ALL
  USING (
    (is_admin_or_superadmin() OR get_user_role() = 'teacher') AND
    EXISTS (
      SELECT 1 FROM classes
      WHERE classes.id = class_students.class_id
      AND (classes.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- =====================================================
-- RLS POLICIES: SUBJECTS
-- =====================================================

-- Users can view subjects from their school
CREATE POLICY "Users can view subjects from their school"
  ON subjects FOR SELECT
  USING (
    school_id = get_user_school_id() OR
    is_superadmin()
  );

-- Admins and teachers can create subjects
CREATE POLICY "Admins and teachers can create subjects"
  ON subjects FOR INSERT
  WITH CHECK (
    (is_admin_or_superadmin() OR get_user_role() = 'teacher') AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- Teachers can update their own subjects, admins can update all
CREATE POLICY "Teachers can update their subjects"
  ON subjects FOR UPDATE
  USING (
    teacher_id = auth.uid() OR
    (is_admin_or_superadmin() AND (school_id = get_user_school_id() OR is_superadmin()))
  );

-- Admins can delete subjects
CREATE POLICY "Admins can delete subjects"
  ON subjects FOR DELETE
  USING (
    is_admin_or_superadmin() AND
    (school_id = get_user_school_id() OR is_superadmin())
  );

-- =====================================================
-- RLS POLICIES: CLASS SUBJECTS
-- =====================================================

-- Users can view class subjects from their school
CREATE POLICY "Users can view class subjects from their school"
  ON class_subjects FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM classes
      WHERE classes.id = class_subjects.class_id
      AND (classes.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- Admins and teachers can manage class subjects
CREATE POLICY "Admins and teachers can manage class subjects"
  ON class_subjects FOR ALL
  USING (
    (is_admin_or_superadmin() OR get_user_role() = 'teacher') AND
    EXISTS (
      SELECT 1 FROM classes
      WHERE classes.id = class_subjects.class_id
      AND (classes.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- =====================================================
-- RLS POLICIES: LESSONS
-- =====================================================

-- Students can view lessons for their classes
CREATE POLICY "Students can view lessons for their classes"
  ON lessons FOR SELECT
  USING (
    get_user_role() = 'student' AND
    EXISTS (
      SELECT 1 FROM class_students
      WHERE class_students.class_id = lessons.class_id
      AND class_students.student_id = auth.uid()
    )
  );

-- Teachers can view lessons for their subjects
CREATE POLICY "Teachers can view lessons for their subjects"
  ON lessons FOR SELECT
  USING (
    get_user_role() = 'teacher' AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = lessons.subject_id
      AND subjects.teacher_id = auth.uid()
    )
  );

-- Admins can view all lessons in their school
CREATE POLICY "Admins can view lessons from their school"
  ON lessons FOR SELECT
  USING (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM classes
      WHERE classes.id = lessons.class_id
      AND (classes.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- Teachers can manage lessons for their subjects
CREATE POLICY "Teachers can manage their lessons"
  ON lessons FOR ALL
  USING (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = lessons.subject_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

-- =====================================================
-- RLS POLICIES: GRADES
-- =====================================================

-- Students can view their own grades
CREATE POLICY "Students can view their own grades"
  ON grades FOR SELECT
  USING (student_id = auth.uid());

-- Parents can view their children's grades
CREATE POLICY "Parents can view their children's grades"
  ON grades FOR SELECT
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM parent_student
      WHERE parent_student.parent_id = auth.uid()
      AND parent_student.student_id = grades.student_id
    )
  );

-- Teachers can view grades for their subjects
CREATE POLICY "Teachers can view grades for their subjects"
  ON grades FOR SELECT
  USING (
    get_user_role() = 'teacher' AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = grades.subject_id
      AND subjects.teacher_id = auth.uid()
    )
  );

-- Admins can view all grades in their school
CREATE POLICY "Admins can view grades from their school"
  ON grades FOR SELECT
  USING (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = grades.student_id
      AND (profiles.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- Teachers can create and update grades for their subjects
CREATE POLICY "Teachers can manage grades for their subjects"
  ON grades FOR INSERT
  WITH CHECK (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = grades.subject_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

CREATE POLICY "Teachers can update grades for their subjects"
  ON grades FOR UPDATE
  USING (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = grades.subject_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

-- =====================================================
-- RLS POLICIES: ASSIGNMENTS
-- =====================================================

-- Students can view assignments for their classes
CREATE POLICY "Students can view assignments for their classes"
  ON assignments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM class_students
      WHERE class_students.class_id = assignments.class_id
      AND class_students.student_id = auth.uid()
    ) OR
    -- Or if assignment is not class-specific but for a subject they're enrolled in
    EXISTS (
      SELECT 1 FROM class_students
      JOIN class_subjects ON class_subjects.class_id = class_students.class_id
      WHERE class_subjects.subject_id = assignments.subject_id
      AND class_students.student_id = auth.uid()
    )
  );

-- Teachers can view and manage assignments for their subjects
CREATE POLICY "Teachers can manage assignments for their subjects"
  ON assignments FOR ALL
  USING (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = assignments.subject_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

-- Admins can view all assignments in their school
CREATE POLICY "Admins can view assignments from their school"
  ON assignments FOR SELECT
  USING (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = assignments.subject_id
      AND (subjects.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- =====================================================
-- RLS POLICIES: ASSIGNMENT SUBMISSIONS
-- =====================================================

-- Students can view and manage their own submissions
CREATE POLICY "Students can view their own submissions"
  ON assignment_submissions FOR SELECT
  USING (student_id = auth.uid());

CREATE POLICY "Students can create their own submissions"
  ON assignment_submissions FOR INSERT
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update their own submissions"
  ON assignment_submissions FOR UPDATE
  USING (student_id = auth.uid());

-- Teachers can view submissions for their assignments
CREATE POLICY "Teachers can view submissions for their assignments"
  ON assignment_submissions FOR SELECT
  USING (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM assignments
      JOIN subjects ON subjects.id = assignments.subject_id
      WHERE assignments.id = assignment_submissions.assignment_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

-- Teachers can update submissions (for grading/feedback)
CREATE POLICY "Teachers can grade submissions"
  ON assignment_submissions FOR UPDATE
  USING (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM assignments
      JOIN subjects ON subjects.id = assignments.subject_id
      WHERE assignments.id = assignment_submissions.assignment_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

-- Parents can view their children's submissions
CREATE POLICY "Parents can view their children's submissions"
  ON assignment_submissions FOR SELECT
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM parent_student
      WHERE parent_student.parent_id = auth.uid()
      AND parent_student.student_id = assignment_submissions.student_id
    )
  );

-- =====================================================
-- RLS POLICIES: MATERIALS
-- =====================================================

-- Students can view materials for subjects in their classes
CREATE POLICY "Students can view materials for their subjects"
  ON materials FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM class_students
      JOIN class_subjects ON class_subjects.class_id = class_students.class_id
      WHERE class_subjects.subject_id = materials.subject_id
      AND class_students.student_id = auth.uid()
    )
  );

-- Teachers can manage materials for their subjects
CREATE POLICY "Teachers can manage materials for their subjects"
  ON materials FOR ALL
  USING (
    (get_user_role() = 'teacher' OR is_admin_or_superadmin()) AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = materials.subject_id
      AND (subjects.teacher_id = auth.uid() OR is_admin_or_superadmin())
    )
  );

-- Admins can view all materials in their school
CREATE POLICY "Admins can view materials from their school"
  ON materials FOR SELECT
  USING (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM subjects
      WHERE subjects.id = materials.subject_id
      AND (subjects.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- =====================================================
-- RLS POLICIES: PARENT STUDENT
-- =====================================================

-- Parents can view their own child relationships
CREATE POLICY "Parents can view their children"
  ON parent_student FOR SELECT
  USING (parent_id = auth.uid());

-- Students can view who their parents are
CREATE POLICY "Students can view their parents"
  ON parent_student FOR SELECT
  USING (student_id = auth.uid());

-- Admins can view all parent-student relationships in their school
CREATE POLICY "Admins can view parent-student relationships"
  ON parent_student FOR SELECT
  USING (
    is_admin_or_superadmin() AND
    (EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = parent_student.parent_id
      AND (profiles.school_id = get_user_school_id() OR is_superadmin())
    ) OR EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = parent_student.student_id
      AND (profiles.school_id = get_user_school_id() OR is_superadmin())
    ))
  );

-- Admins can manage parent-student relationships
CREATE POLICY "Admins can manage parent-student relationships"
  ON parent_student FOR INSERT
  WITH CHECK (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = parent_student.parent_id
      AND (profiles.school_id = get_user_school_id() OR is_superadmin())
    )
  );

CREATE POLICY "Admins can update parent-student relationships"
  ON parent_student FOR UPDATE
  USING (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = parent_student.parent_id
      AND (profiles.school_id = get_user_school_id() OR is_superadmin())
    )
  );

CREATE POLICY "Admins can delete parent-student relationships"
  ON parent_student FOR DELETE
  USING (
    is_admin_or_superadmin() AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = parent_student.parent_id
      AND (profiles.school_id = get_user_school_id() OR is_superadmin())
    )
  );

-- =====================================================
-- ADDITIONAL CONSTRAINTS
-- =====================================================

-- Add constraint to invite_codes to link class_id properly
ALTER TABLE invite_codes
  ADD CONSTRAINT fk_invite_codes_class_id
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE;

-- Ensure grade scores are reasonable
ALTER TABLE grades
  ADD CONSTRAINT check_grade_score
  CHECK (score >= 0 AND score <= 100);

-- Ensure weight is between 0 and 1
ALTER TABLE grades
  ADD CONSTRAINT check_grade_weight
  CHECK (weight >= 0 AND weight <= 10);

-- Ensure lesson times are logical
ALTER TABLE lessons
  ADD CONSTRAINT check_lesson_times
  CHECK (start_time < end_time);

-- Ensure assignment max_score is positive
ALTER TABLE assignments
  ADD CONSTRAINT check_assignment_max_score
  CHECK (max_score > 0);

-- Ensure invite code usage is valid
ALTER TABLE invite_codes
  ADD CONSTRAINT check_invite_code_usage
  CHECK (times_used <= usage_limit);

-- Ensure invite code usage limit is positive
ALTER TABLE invite_codes
  ADD CONSTRAINT check_invite_code_usage_limit
  CHECK (usage_limit > 0);

-- =====================================================
-- COMMENTS ON TABLES (Documentation)
-- =====================================================

COMMENT ON TABLE schools IS 'Educational institutions using the platform';
COMMENT ON TABLE profiles IS 'User profiles linked to auth.users with role-based access';
COMMENT ON TABLE invite_codes IS 'Invitation codes for user registration with specific roles';
COMMENT ON TABLE classes IS 'Class/grade groups within a school';
COMMENT ON TABLE class_students IS 'Many-to-many relationship between classes and students';
COMMENT ON TABLE subjects IS 'Academic subjects taught at the school';
COMMENT ON TABLE class_subjects IS 'Many-to-many relationship between classes and subjects';
COMMENT ON TABLE lessons IS 'Scheduled lessons/periods in the timetable';
COMMENT ON TABLE grades IS 'Student grades/scores for subjects';
COMMENT ON TABLE assignments IS 'Homework and assignments for students';
COMMENT ON TABLE assignment_submissions IS 'Student submissions for assignments';
COMMENT ON TABLE materials IS 'Study materials and resources';
COMMENT ON TABLE parent_student IS 'Many-to-many relationship between parents and their children';

-- =====================================================
-- END OF SCHEMA
-- =====================================================
