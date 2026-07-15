
-- Multi-statement transaction for enrolling a student

-- IMPORTANT for SQLite: enable FK enforcement
PRAGMA foreign_keys = ON;

-- Begin transaction
BEGIN TRANSACTION;

-- Assume we want to enroll student_id = 10 in course_id = 5 (CS301)
-- Step 1: Check there is at least one seat available
-- (We do this logically; in real code you might use a trigger or application check)
UPDATE courses
SET available_seats = available_seats - 1
WHERE course_id = 5
  AND available_seats > 0;

-- Step 2: Insert enrollment row
INSERT INTO enrollments (enrollment_id, student_id, course_id, enrolled_at, status)
VALUES (11, 10, 5, CURRENT_TIMESTAMP, 'ENROLLED');

-- If everything succeeded, commit
COMMIT;

-- If we had an error condition (e.g., seat count went to 0 unexpectedly), we would ROLLBACK;
-- Example rollback path (not executed unless you force an error):
-- ROLLBACK;
