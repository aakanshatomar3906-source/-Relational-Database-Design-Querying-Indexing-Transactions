
-- Indexes for CampusConnect schema

-- 1. Index on enrollments.student_id (used in JOIN and WHERE)
-- Speeds up queries that filter or join on student_id, e.g.:
--   - "students enrolled in more than 1 course" (GROUP BY on enrollments)
--   - correlated subquery counting enrollments per student
CREATE INDEX idx_enrollments_student_id
ON enrollments(student_id);


-- 2. Composite index on enrollments (student_id, course_id)
-- Used together in:
--   - UNIQUE constraint and join conditions
--   - queries that filter by both student and course
CREATE INDEX idx_enrollments_student_course
ON enrollments(student_id, course_id);


-- 3. Index on courses.instructor_id (used in JOIN)
-- Speeds up joins between courses and instructors
CREATE INDEX idx_courses_instructor_id
ON courses(instructor_id);
