-- =====================================================
-- STABLE TIMETABLE MIGRATION
-- Adds support for stable (baseline) timetables and week-specific modifications
-- =====================================================

-- Add stable timetable columns to lessons table
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS is_stable BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS stable_lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS modified_from_stable BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS week_start_date DATE;

-- Add indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_lessons_is_stable ON lessons(is_stable);
CREATE INDEX IF NOT EXISTS idx_lessons_stable_lesson_id ON lessons(stable_lesson_id);
CREATE INDEX IF NOT EXISTS idx_lessons_week_start_date ON lessons(week_start_date);
CREATE INDEX IF NOT EXISTS idx_lessons_subject_week ON lessons(subject_id, week_start_date);
CREATE INDEX IF NOT EXISTS idx_lessons_subject_stable ON lessons(subject_id, is_stable);

-- Add comments for documentation
COMMENT ON COLUMN lessons.is_stable IS 'True if this is a stable/baseline lesson that repeats weekly';
COMMENT ON COLUMN lessons.stable_lesson_id IS 'Reference to the original stable lesson if this is a week-specific copy';
COMMENT ON COLUMN lessons.modified_from_stable IS 'True if this week-specific lesson differs from its stable version';
COMMENT ON COLUMN lessons.week_start_date IS 'The Monday of the week this lesson belongs to (NULL for stable lessons)';

-- =====================================================
-- RLS POLICIES UPDATE
-- Update existing policies to handle new columns
-- =====================================================

-- Parents can view lessons for their children's classes
DROP POLICY IF EXISTS "Parents can view lessons for their children's classes" ON lessons;
CREATE POLICY "Parents can view lessons for their children's classes"
  ON lessons FOR SELECT
  USING (
    get_user_role() = 'parent' AND
    EXISTS (
      SELECT 1 FROM parent_student ps
      JOIN class_students cs ON cs.student_id = ps.student_id
      JOIN class_subjects csub ON csub.class_id = cs.class_id
      WHERE ps.parent_id = auth.uid()
      AND csub.subject_id = lessons.subject_id
    )
  );

-- =====================================================
-- FUNCTION: Get Monday of a given week
-- =====================================================
CREATE OR REPLACE FUNCTION get_week_start(date_val DATE)
RETURNS DATE AS $$
BEGIN
  -- Returns the Monday of the week containing the given date
  -- EXTRACT(DOW FROM date) returns 0=Sunday, 1=Monday, ..., 6=Saturday
  RETURN date_val - (EXTRACT(DOW FROM date_val)::INTEGER + 6) % 7;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_week_start(DATE) IS 'Returns the Monday of the week containing the given date';

-- =====================================================
-- FUNCTION: Copy stable timetable to a specific week
-- =====================================================
CREATE OR REPLACE FUNCTION copy_stable_timetable_to_week(
  p_class_id UUID,
  p_week_start DATE
)
RETURNS SETOF lessons AS $$
DECLARE
  v_lesson RECORD;
  v_new_lesson lessons%ROWTYPE;
BEGIN
  -- Validate that week_start is actually a Monday
  IF EXTRACT(DOW FROM p_week_start) != 1 THEN
    RAISE EXCEPTION 'week_start must be a Monday';
  END IF;

  -- Check if lessons already exist for this week (via class_subjects relationship)
  IF EXISTS (
    SELECT 1 FROM lessons l
    JOIN class_subjects cs ON cs.subject_id = l.subject_id
    WHERE cs.class_id = p_class_id
    AND l.week_start_date = p_week_start
  ) THEN
    -- Return existing lessons for this week
    RETURN QUERY
    SELECT l.* FROM lessons l
    JOIN class_subjects cs ON cs.subject_id = l.subject_id
    WHERE cs.class_id = p_class_id
    AND l.week_start_date = p_week_start
    ORDER BY l.day_of_week, l.start_time;
    RETURN;
  END IF;

  -- Copy stable lessons to this week (via class_subjects relationship)
  FOR v_lesson IN
    SELECT l.* FROM lessons l
    JOIN class_subjects cs ON cs.subject_id = l.subject_id
    WHERE cs.class_id = p_class_id
    AND l.is_stable = true
  LOOP
    INSERT INTO lessons (
      subject_id,
      day_of_week,
      start_time,
      end_time,
      room,
      is_stable,
      stable_lesson_id,
      modified_from_stable,
      week_start_date
    ) VALUES (
      v_lesson.subject_id,
      v_lesson.day_of_week,
      v_lesson.start_time,
      v_lesson.end_time,
      v_lesson.room,
      false,  -- Not a stable lesson
      v_lesson.id,  -- Reference to the stable lesson
      false,  -- Not modified yet
      p_week_start
    )
    RETURNING * INTO v_new_lesson;

    RETURN NEXT v_new_lesson;
  END LOOP;

  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION copy_stable_timetable_to_week(UUID, DATE) IS 'Copies stable timetable lessons to a specific week for a class';

-- =====================================================
-- FUNCTION: Get or create week timetable
-- =====================================================
CREATE OR REPLACE FUNCTION get_or_create_week_timetable(
  p_class_id UUID,
  p_week_start DATE
)
RETURNS SETOF lessons AS $$
BEGIN
  -- Validate that week_start is actually a Monday
  IF EXTRACT(DOW FROM p_week_start) != 1 THEN
    RAISE EXCEPTION 'week_start must be a Monday';
  END IF;

  -- Check if lessons exist for this week (via class_subjects relationship)
  IF EXISTS (
    SELECT 1 FROM lessons l
    JOIN class_subjects cs ON cs.subject_id = l.subject_id
    WHERE cs.class_id = p_class_id
    AND l.week_start_date = p_week_start
  ) THEN
    -- Return existing lessons for this week
    RETURN QUERY
    SELECT l.* FROM lessons l
    JOIN class_subjects cs ON cs.subject_id = l.subject_id
    WHERE cs.class_id = p_class_id
    AND l.week_start_date = p_week_start
    ORDER BY l.day_of_week, l.start_time;
  ELSE
    -- Copy stable lessons to this week
    RETURN QUERY
    SELECT * FROM copy_stable_timetable_to_week(p_class_id, p_week_start);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_or_create_week_timetable(UUID, DATE) IS 'Gets existing week timetable or creates one from stable timetable';

-- =====================================================
-- FUNCTION: Update lesson and mark as modified
-- =====================================================
CREATE OR REPLACE FUNCTION update_week_lesson(
  p_lesson_id UUID,
  p_subject_id UUID DEFAULT NULL,
  p_day_of_week INT DEFAULT NULL,
  p_start_time TIME DEFAULT NULL,
  p_end_time TIME DEFAULT NULL,
  p_room TEXT DEFAULT NULL
)
RETURNS lessons AS $$
DECLARE
  v_lesson lessons%ROWTYPE;
  v_stable_lesson lessons%ROWTYPE;
  v_is_modified BOOLEAN := false;
BEGIN
  -- Get the current lesson
  SELECT * INTO v_lesson FROM lessons WHERE id = p_lesson_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lesson not found: %', p_lesson_id;
  END IF;

  -- Cannot modify stable lessons directly
  IF v_lesson.is_stable THEN
    RAISE EXCEPTION 'Cannot modify stable lessons. Create a week-specific copy first.';
  END IF;

  -- Get the stable lesson for comparison
  IF v_lesson.stable_lesson_id IS NOT NULL THEN
    SELECT * INTO v_stable_lesson FROM lessons WHERE id = v_lesson.stable_lesson_id;
  END IF;

  -- Update the lesson
  UPDATE lessons SET
    subject_id = COALESCE(p_subject_id, subject_id),
    day_of_week = COALESCE(p_day_of_week, day_of_week),
    start_time = COALESCE(p_start_time, start_time),
    end_time = COALESCE(p_end_time, end_time),
    room = COALESCE(p_room, room)
  WHERE id = p_lesson_id
  RETURNING * INTO v_lesson;

  -- Check if lesson is now different from stable
  IF v_stable_lesson.id IS NOT NULL THEN
    v_is_modified := (
      v_lesson.subject_id != v_stable_lesson.subject_id OR
      v_lesson.day_of_week != v_stable_lesson.day_of_week OR
      v_lesson.start_time != v_stable_lesson.start_time OR
      v_lesson.end_time != v_stable_lesson.end_time OR
      COALESCE(v_lesson.room, '') != COALESCE(v_stable_lesson.room, '')
    );

    -- Update modified_from_stable flag
    UPDATE lessons SET modified_from_stable = v_is_modified
    WHERE id = p_lesson_id
    RETURNING * INTO v_lesson;
  END IF;

  RETURN v_lesson;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_week_lesson(UUID, UUID, INT, TIME, TIME, TEXT) IS 'Updates a week-specific lesson and marks it as modified if different from stable';

-- =====================================================
-- FUNCTION: Get stable lesson differences
-- =====================================================
CREATE OR REPLACE FUNCTION get_lesson_changes(p_lesson_id UUID)
RETURNS TABLE (
  field_name TEXT,
  stable_value TEXT,
  current_value TEXT
) AS $$
DECLARE
  v_lesson lessons%ROWTYPE;
  v_stable_lesson lessons%ROWTYPE;
BEGIN
  -- Get the current lesson
  SELECT * INTO v_lesson FROM lessons WHERE id = p_lesson_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lesson not found: %', p_lesson_id;
  END IF;

  -- Get the stable lesson
  IF v_lesson.stable_lesson_id IS NULL THEN
    RETURN;  -- No stable lesson to compare
  END IF;

  SELECT * INTO v_stable_lesson FROM lessons WHERE id = v_lesson.stable_lesson_id;

  IF NOT FOUND THEN
    RETURN;  -- Stable lesson not found
  END IF;

  -- Compare and return differences
  IF v_lesson.subject_id != v_stable_lesson.subject_id THEN
    RETURN QUERY SELECT 'subject_id'::TEXT, v_stable_lesson.subject_id::TEXT, v_lesson.subject_id::TEXT;
  END IF;

  IF v_lesson.day_of_week != v_stable_lesson.day_of_week THEN
    RETURN QUERY SELECT 'day_of_week'::TEXT, v_stable_lesson.day_of_week::TEXT, v_lesson.day_of_week::TEXT;
  END IF;

  IF v_lesson.start_time != v_stable_lesson.start_time THEN
    RETURN QUERY SELECT 'start_time'::TEXT, v_stable_lesson.start_time::TEXT, v_lesson.start_time::TEXT;
  END IF;

  IF v_lesson.end_time != v_stable_lesson.end_time THEN
    RETURN QUERY SELECT 'end_time'::TEXT, v_stable_lesson.end_time::TEXT, v_lesson.end_time::TEXT;
  END IF;

  IF COALESCE(v_lesson.room, '') != COALESCE(v_stable_lesson.room, '') THEN
    RETURN QUERY SELECT 'room'::TEXT, COALESCE(v_stable_lesson.room, '')::TEXT, COALESCE(v_lesson.room, '')::TEXT;
  END IF;

  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_lesson_changes(UUID) IS 'Returns the differences between a week lesson and its stable version';

-- =====================================================
-- END OF MIGRATION
-- =====================================================
