-- queries.sql
-- CampusConnect Query Set

-- ------------------------------------------------------------------
-- 1. Query using IN
-- Question: List all students enrolled in any of these courses: CS101, CS201, CS301
-- ------------------------------------------------------------------
SELECT s.student_id, s.first_name, s.last_name, c.course_code, c.title
FROM students s
JOIN enrollments e ON e.student_id = s.student_id
JOIN courses c ON c.course_id = e.course_id
WHERE c.course_code IN ('CS101', 'CS201', 'CS301');


-- ------------------------------------------------------------------
-- 2. Query using BETWEEN
-- Question: Find all courses with credits between 3 and 4 (inclusive)
-- ------------------------------------------------------------------
SELECT course_id, course_code, title, credits
FROM courses
WHERE credits BETWEEN 3 AND 4;


-- ------------------------------------------------------------------
-- 3. Query using IS NOT NULL (not = NULL)
-- Question: List students whose email is not null and not empty (email is always NOT NULL by schema,
--           but we demonstrate IS NOT NULL usage)
-- ------------------------------------------------------------------
SELECT student_id, first_name, last_name, email
FROM students
WHERE email IS NOT NULL;


-- ------------------------------------------------------------------
-- 4. Query using GROUP BY with HAVING (filter an aggregate)
-- Question: Find students enrolled in more than 1 course
-- ------------------------------------------------------------------
SELECT s.student_id, s.first_name, s.last_name, COUNT(e.course_id) AS course_count
FROM students s
JOIN enrollments e ON e.student_id = s.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(e.course_id) > 1;


-- ------------------------------------------------------------------
-- 5. Three different join types
-- (a) INNER JOIN: students who are enrolled in at least one course
-- ------------------------------------------------------------------
SELECT s.student_id, s.first_name, s.last_name, c.course_code
FROM students s
INNER JOIN enrollments e ON e.student_id = s.student_id
INNER JOIN courses c ON c.course_id = e.course_id;


-- (b) LEFT JOIN: all students, with their enrollments (including those with no enrollments)
-- ------------------------------------------------------------------
SELECT s.student_id, s.first_name, s.last_name, e.enrollment_id, c.course_code
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
LEFT JOIN courses c ON c.course_id = e.course_id;


-- (c) RIGHT JOIN equivalent using LEFT JOIN (SQLite does not support RIGHT JOIN directly)
-- Question: all courses, with enrollments (including courses with no enrollments)
-- We use LEFT JOIN with tables swapped to simulate RIGHT JOIN behavior.
-- ------------------------------------------------------------------
-- Note: SQLite lacks RIGHT JOIN; we simulate it with LEFT JOIN.
SELECT c.course_id, c.course_code, c.title, e.enrollment_id, s.first_name
FROM enrollments e
LEFT JOIN courses c ON c.course_id = e.course_id
LEFT JOIN students s ON s.student_id = e.student_id;


-- If you use PostgreSQL, you could write:
-- SELECT c.course_id, c.course_code, c.title, e.enrollment_id, s.first_name
-- FROM enrollments e
-- RIGHT JOIN courses c ON c.course_id = e.course_id
-- LEFT JOIN students s ON s.student_id = e.student_id;


-- ------------------------------------------------------------------
-- 6. Scalar subquery
-- Question: For each course, show how many seats are left compared to the course with the most seats
-- ------------------------------------------------------------------
SELECT
    course_code,
    title,
    max_seats,
    available_seats,
    (SELECT MAX(max_seats) FROM courses) AS max_seats_any_course
FROM courses;


-- ------------------------------------------------------------------
-- 7. Correlated subquery
-- Question: For each student, show how many courses they are enrolled in
-- ------------------------------------------------------------------
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    (
        SELECT COUNT(*)
        FROM enrollments e
        WHERE e.student_id = s.student_id
    ) AS enrolled_course_count
FROM students s;


-- ------------------------------------------------------------------
-- 8. Query using EXISTS
-- Question: List students who are enrolled in at least one CS course (course_code starts with 'CS')
-- ------------------------------------------------------------------
SELECT s.student_id, s.first_name, s.last_name
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM enrollments e
    JOIN courses c ON c.course_id = e.course_id
    WHERE e.student_id = s.student_id
      AND c.course_code LIKE 'CS%'
);


-- ------------------------------------------------------------------
-- 9. Set operation (UNION)
-- Question: Get a unified list of all first names from students and instructors
-- ------------------------------------------------------------------
SELECT first_name FROM students
UNION
SELECT first_name FROM instructors;


-- ------------------------------------------------------------------
-- 10. Window function (ROW_NUMBER() with PARTITION BY)
-- Question: For each course, rank enrollments by enrolled_at date
-- ------------------------------------------------------------------
SELECT
    c.course_code,
    c.title,
    s.first_name,
    s.last_name,
    e.enrolled_at,
    ROW_NUMBER() OVER (
        PARTITION BY c.course_id
        ORDER BY e.enrolled_at
    ) AS enrollment_rank_in_course
FROM enrollments e
JOIN courses c ON c.course_id = e.course_id
JOIN students s ON s.student_id = e.student_id
ORDER BY c.course_id, enrollment_rank_in_course;
