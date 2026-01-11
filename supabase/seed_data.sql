-- =====================================================
-- CLASSIO DATABASE SEED DATA
-- Comprehensive demo data for testing and development
-- =====================================================
--
-- HOW TO RUN THIS SCRIPT IN SUPABASE SQL EDITOR:
-- =====================================================
-- 1. Go to your Supabase Dashboard: https://supabase.com/dashboard
-- 2. Select your project
-- 3. Navigate to "SQL Editor" in the left sidebar
-- 4. Click "New query" button
-- 5. Copy and paste this entire script into the editor
-- 6. Click "Run" (or press Ctrl+Enter / Cmd+Enter)
-- 7. Verify the output shows successful insertions
--
-- IMPORTANT NOTES:
-- - This script is IDEMPOTENT (safe to run multiple times)
-- - Uses ON CONFLICT DO NOTHING to prevent duplicate errors
-- - Uses CURRENT_DATE for dynamic date calculations
-- - Lessons are generated for the CURRENT WEEK (Mon-Fri)
--
-- =====================================================

-- =====================================================
-- CONFIGURATION & HELPER FUNCTIONS
-- =====================================================

-- Function to get Monday of the current week
-- Returns the date of Monday for the week containing CURRENT_DATE
-- (ISODOW: Monday = 1, Sunday = 7)
CREATE OR REPLACE FUNCTION get_current_week_monday()
RETURNS DATE AS $$
BEGIN
  RETURN CURRENT_DATE - (EXTRACT(ISODOW FROM CURRENT_DATE)::INT - 1);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 1. SCHOOL: Gymnazium Budoucnost
-- =====================================================

INSERT INTO schools (id, name, created_at)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'Gymnazium Budoucnost',
  now()
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. CLASS: 3.B
-- =====================================================

INSERT INTO classes (id, school_id, name, grade_level, academic_year, created_at)
VALUES (
  'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  '3.B',
  11,
  '2025/2026',
  now()
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. SUBJECTS (6 subjects with distinct hex colors)
-- =====================================================
-- Colors stored in description for UI reference:
-- Math:    #3B82F6 (Blue)
-- Physics: #EF4444 (Red)
-- English: #F59E0B (Amber)
-- IT:      #10B981 (Emerald)
-- History: #8B5CF6 (Purple)
-- PE:      #F97316 (Orange)

INSERT INTO subjects (id, school_id, name, description, created_at)
VALUES
  (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Matematika',
    'Algebra, geometrie, analyza a dalsi matematicke discipliny. Color: #3B82F6',
    now()
  ),
  (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Fyzika',
    'Mechanika, termodynamika, elektromagnetismus a opticka fyzika. Color: #EF4444',
    now()
  ),
  (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Anglictina',
    'Gramatika, literatura, konverzace a psani v anglickem jazyce. Color: #F59E0B',
    now()
  ),
  (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Informatika',
    'Programovani, databaze, pocitacove site a kyberneticka bezpecnost. Color: #10B981',
    now()
  ),
  (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Dejepis',
    'Svetove a ceske dejiny od staroveku po soucasnost. Color: #8B5CF6',
    now()
  ),
  (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a06',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Telesna vychova',
    'Sport, fitness, zdravy zivotni styl a tymy. Color: #F97316',
    now()
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 4. CLASS SUBJECTS (Link all subjects to 3.B)
-- =====================================================

INSERT INTO class_subjects (class_id, subject_id, assigned_at)
VALUES
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01', now()),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02', now()),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03', now()),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04', now()),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05', now()),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a06', now())
ON CONFLICT (class_id, subject_id) DO NOTHING;

-- =====================================================
-- 5. INVITE CODE: STUDENT-2026
-- =====================================================

INSERT INTO invite_codes (
  id,
  code,
  role,
  school_id,
  class_id,
  usage_limit,
  times_used,
  is_active,
  expires_at,
  created_at
)
VALUES (
  'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  'STUDENT-2026',
  'student',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  100,
  0,
  true,
  CURRENT_DATE + INTERVAL '1 year',
  now()
)
ON CONFLICT (id) DO NOTHING;

-- Also handle conflict on unique code constraint
INSERT INTO invite_codes (
  id,
  code,
  role,
  school_id,
  class_id,
  usage_limit,
  times_used,
  is_active,
  expires_at,
  created_at
)
VALUES (
  'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  'STUDENT-2026',
  'student',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  100,
  0,
  true,
  CURRENT_DATE + INTERVAL '1 year',
  now()
)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- 6. LESSONS - FULL WEEKLY SCHEDULE (Mon-Fri)
-- =====================================================
-- Using day_of_week: 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday
--
-- Time slots (typical Czech school schedule):
-- 1st period: 08:00 - 08:45
-- 2nd period: 08:55 - 09:40
-- 3rd period: 10:00 - 10:45
-- 4th period: 10:55 - 11:40
-- 5th period: 11:50 - 12:35
-- 6th period: 12:45 - 13:30
-- 7th period: 13:40 - 14:25
--
-- Schedule Overview:
-- MONDAY (7 lessons):    Math, English, Physics, IT, History, PE, Math
-- TUESDAY (6 lessons):   English, Math, History, Physics, IT, English
-- WEDNESDAY (6 lessons): Physics, Math, English, History, IT, PE
-- THURSDAY (6 lessons):  Math, Physics, English, IT, History, Math
-- FRIDAY (5 lessons):    English, History, Physics, Math, PE

INSERT INTO lessons (id, subject_id, class_id, day_of_week, start_time, end_time, room, created_at)
VALUES
  -- ========== MONDAY (7 lessons) ==========
  -- 1st period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b01',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '08:00:00', '08:45:00', 'Ucebna 101', now()
  ),
  -- 2nd period: Anglictina
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b02',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '08:55:00', '09:40:00', 'Jazykova ucebna', now()
  ),
  -- 3rd period: Fyzika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b03',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '10:00:00', '10:45:00', 'Laborator fyziky', now()
  ),
  -- 4th period: Informatika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b04',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '10:55:00', '11:40:00', 'Pocitacova ucebna', now()
  ),
  -- 5th period: Dejepis
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b05',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '11:50:00', '12:35:00', 'Ucebna 203', now()
  ),
  -- 6th period: Telesna vychova
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b06',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a06',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '12:45:00', '13:30:00', 'Telocvicna', now()
  ),
  -- 7th period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b07',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    1, '13:40:00', '14:25:00', 'Ucebna 101', now()
  ),

  -- ========== TUESDAY (6 lessons) ==========
  -- 1st period: Anglictina
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b08',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    2, '08:00:00', '08:45:00', 'Jazykova ucebna', now()
  ),
  -- 2nd period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b09',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    2, '08:55:00', '09:40:00', 'Ucebna 101', now()
  ),
  -- 3rd period: Dejepis
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b10',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    2, '10:00:00', '10:45:00', 'Ucebna 203', now()
  ),
  -- 4th period: Fyzika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    2, '10:55:00', '11:40:00', 'Laborator fyziky', now()
  ),
  -- 5th period: Informatika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b12',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    2, '11:50:00', '12:35:00', 'Pocitacova ucebna', now()
  ),
  -- 6th period: Anglictina
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b13',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    2, '12:45:00', '13:30:00', 'Jazykova ucebna', now()
  ),

  -- ========== WEDNESDAY (6 lessons) ==========
  -- 1st period: Fyzika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b14',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    3, '08:00:00', '08:45:00', 'Laborator fyziky', now()
  ),
  -- 2nd period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b15',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    3, '08:55:00', '09:40:00', 'Ucebna 101', now()
  ),
  -- 3rd period: Anglictina
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b16',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    3, '10:00:00', '10:45:00', 'Jazykova ucebna', now()
  ),
  -- 4th period: Dejepis
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b17',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    3, '10:55:00', '11:40:00', 'Ucebna 203', now()
  ),
  -- 5th period: Informatika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b18',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    3, '11:50:00', '12:35:00', 'Pocitacova ucebna', now()
  ),
  -- 6th period: Telesna vychova
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b19',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a06',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    3, '12:45:00', '13:30:00', 'Telocvicna', now()
  ),

  -- ========== THURSDAY (6 lessons) ==========
  -- 1st period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b20',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    4, '08:00:00', '08:45:00', 'Ucebna 101', now()
  ),
  -- 2nd period: Fyzika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b21',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    4, '08:55:00', '09:40:00', 'Laborator fyziky', now()
  ),
  -- 3rd period: Anglictina
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    4, '10:00:00', '10:45:00', 'Jazykova ucebna', now()
  ),
  -- 4th period: Informatika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b23',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    4, '10:55:00', '11:40:00', 'Pocitacova ucebna', now()
  ),
  -- 5th period: Dejepis
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b24',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    4, '11:50:00', '12:35:00', 'Ucebna 203', now()
  ),
  -- 6th period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b25',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    4, '12:45:00', '13:30:00', 'Ucebna 101', now()
  ),

  -- ========== FRIDAY (5 lessons) ==========
  -- 1st period: Anglictina
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b26',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a03',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    5, '08:00:00', '08:45:00', 'Jazykova ucebna', now()
  ),
  -- 2nd period: Dejepis
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b27',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a05',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    5, '08:55:00', '09:40:00', 'Ucebna 203', now()
  ),
  -- 3rd period: Fyzika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b28',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    5, '10:00:00', '10:45:00', 'Laborator fyziky', now()
  ),
  -- 4th period: Matematika
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b29',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    5, '10:55:00', '11:40:00', 'Ucebna 101', now()
  ),
  -- 5th period: Telesna vychova
  (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380b30',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a06',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    5, '11:50:00', '12:35:00', 'Telocvicna', now()
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 7. ASSIGNMENTS (2 dummy assignments due this week)
-- =====================================================
-- Using dynamic dates based on CURRENT_DATE

INSERT INTO assignments (id, subject_id, class_id, title, description, due_date, max_score, created_at)
VALUES
  -- Math assignment - due Thursday this week
  (
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380c01',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'Domaci ukol - Kvadraticke rovnice',
    'Vyres cviceni 1-15 z kapitoly 5. Ukaz postup reseni u kazdeho prikladu. Zamerit se na rozklad na soucin a vzorec pro koreny kvadraticke rovnice.',
    -- Due on Thursday of current week at 23:59
    (CURRENT_DATE - (EXTRACT(ISODOW FROM CURRENT_DATE)::INT - 1) + 3)::DATE + TIME '23:59:00',
    100,
    now()
  ),
  -- Physics assignment - due Friday this week
  (
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380c02',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'Laboratorni protokol - Kyvadlo',
    'Vypracuj kompletni laboratorni protokol z experimentu s kyvadlem. Obsahuje: hypotezu, pomucky, postup, tabulku namerenych hodnot, graf, vypocty, zaver a rozbor chyb mereni.',
    -- Due on Friday of current week at 23:59
    (CURRENT_DATE - (EXTRACT(ISODOW FROM CURRENT_DATE)::INT - 1) + 4)::DATE + TIME '23:59:00',
    100,
    now()
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 8. STUDY MATERIALS (Optional bonus data)
-- =====================================================

INSERT INTO materials (id, subject_id, title, description, file_url, material_type, created_at)
VALUES
  (
    'a6eebc99-9c0b-4ef8-bb6d-6bb9bd380d01',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a01',
    'Vzorce pro kvadraticke rovnice',
    'Prehled vzorcu pro reseni kvadratickych rovnic vcetne diskriminantu a Vietovych vzorcu.',
    'https://storage.classio.app/materials/math/kvadraticke-rovnice.pdf',
    'pdf',
    now()
  ),
  (
    'a6eebc99-9c0b-4ef8-bb6d-6bb9bd380d02',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a02',
    'Bezpecnost v laboratori',
    'Pravidla bezpecnosti pri praci ve fyzikalni laboratori. Povinne cteni pred kazdym pokusem.',
    'https://storage.classio.app/materials/physics/bezpecnost-laborator.pdf',
    'pdf',
    now()
  ),
  (
    'a6eebc99-9c0b-4ef8-bb6d-6bb9bd380d03',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a04',
    'Uvod do programovani v Pythonu',
    'Interaktivni kurz zakladu programovani - promenne, podminky, cykly, funkce.',
    'https://www.codecademy.com/learn/learn-python-3',
    'link',
    now()
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- CLEANUP: Drop helper function (optional)
-- =====================================================
-- Uncomment if you want to remove the helper function after seeding
-- DROP FUNCTION IF EXISTS get_current_week_monday();

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these queries to verify the seed data was inserted correctly:

-- Check school
-- SELECT * FROM schools WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- Check class
-- SELECT * FROM classes WHERE id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22';

-- Check subjects
-- SELECT id, name, description FROM subjects WHERE school_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- Check invite code
-- SELECT * FROM invite_codes WHERE code = 'STUDENT-2026';

-- Check lessons count by day
-- SELECT day_of_week, COUNT(*) as lesson_count
-- FROM lessons
-- WHERE class_id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'
-- GROUP BY day_of_week
-- ORDER BY day_of_week;

-- Check full schedule
-- SELECT l.day_of_week, l.start_time, l.end_time, s.name as subject, l.room
-- FROM lessons l
-- JOIN subjects s ON l.subject_id = s.id
-- WHERE l.class_id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'
-- ORDER BY l.day_of_week, l.start_time;

-- Check assignments
-- SELECT a.title, s.name as subject, a.due_date
-- FROM assignments a
-- JOIN subjects s ON a.subject_id = s.id
-- WHERE a.class_id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22';

-- =====================================================
-- SUMMARY OF SEEDED DATA
-- =====================================================
--
-- School: Gymnazium Budoucnost
--   ID: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
--
-- Class: 3.B
--   ID: b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22
--   Grade Level: 11
--   Academic Year: 2025/2026
--
-- Invite Code: STUDENT-2026
--   Role: student
--   Linked to: Gymnazium Budoucnost + Class 3.B
--   Usage Limit: 100
--   Expires: 1 year from seed date
--
-- Subjects (6):
--   1. Matematika     (#3B82F6 - Blue)
--   2. Fyzika         (#EF4444 - Red)
--   3. Anglictina     (#F59E0B - Amber)
--   4. Informatika    (#10B981 - Emerald)
--   5. Dejepis        (#8B5CF6 - Purple)
--   6. Telesna vychova (#F97316 - Orange)
--
-- Lessons (30 total per week):
--   Monday:    7 lessons (08:00 - 14:25)
--   Tuesday:   6 lessons (08:00 - 13:30)
--   Wednesday: 6 lessons (08:00 - 13:30)
--   Thursday:  6 lessons (08:00 - 13:30)
--   Friday:    5 lessons (08:00 - 12:35)
--
-- Assignments (2):
--   1. Matematika - Domaci ukol (due Thursday this week)
--   2. Fyzika - Laboratorni protokol (due Friday this week)
--
-- Materials (3):
--   1. Matematika - Vzorce pro kvadraticke rovnice (PDF)
--   2. Fyzika - Bezpecnost v laboratori (PDF)
--   3. Informatika - Uvod do programovani v Pythonu (Link)
--
-- =====================================================
-- END OF SEED DATA
-- =====================================================
