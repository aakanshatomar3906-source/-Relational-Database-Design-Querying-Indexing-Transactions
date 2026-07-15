-- data.sql
-- Sample data for CampusConnect schema
-- IMPORTANT for SQLite: enable FK enforcement before inserts
PRAGMA foreign_keys = ON;

-- Insert students (root table; no outgoing FK)
INSERT INTO students (student_id, first_name, last_name, email, enrollment_year) VALUES
(1, 'Aarav', 'Sharma', 'aarav.sharma@campus.edu', 2023),
(2, 'Priya', 'Verma', 'priya.verma@campus.edu', 2023),
(3, 'Rohan', 'Kapoor', 'rohan.kapoor@campus.edu', 2022),
(4, 'Neha', 'Singh', 'neha.singh@campus.edu', 2024),
(5, 'Vikram', 'Mehta', 'vikram.mehta@campus.edu', 2022),
(6, 'Ananya', 'Iyer', 'ananya.iyer@campus.edu', 2023),
(7, 'Karan', 'Dixit', 'karan.dixit@campus.edu', 2024),
(8, 'Sara', 'Joshi', 'sara.joshi@campus.edu', 2022),
(9, 'Aditya', 'Rao', 'aditya.rao@campus.edu', 2023),
(10, 'Isha', 'Pandey', 'isha.pandey@campus.edu', 2024);

-- Insert instructors (root table; no outgoing FK)
INSERT INTO instructors (instructor_id, first_name, last_name, department, email) VALUES
(1, 'Dr. Amit', 'Nair', 'Computer Science', 'amit.nair@campus.edu'),
(2, 'Dr. Sunita', 'Reddy', 'Mathematics', 'sunita.reddy@campus.edu'),
(3, 'Dr. Rajiv', 'Malhotra', 'Physics', 'rajiv.malhotra@campus.edu'),
(4, 'Dr. Meera', 'Khan', 'Computer Science', 'meera.khan@campus.edu'),
(5, 'Dr. Sanjay', 'Gupta', 'Economics', 'sanjay.gupta@campus.edu');

-- Insert courses (child of instructors)
INSERT INTO courses (course_id, course_code, title, credits, max_seats, available_seats, instructor_id) VALUES
(1, 'CS101', 'Intro to Programming', 3, 40, 40, 1),
(2, 'CS201', 'Data Structures', 4, 35, 35, 1),
(3, 'MATH101', 'Calculus I', 4, 50, 50, 2),
(4, 'PHYS101', 'Fundamentals of Physics', 4, 45, 45, 3),
(5, 'CS301', 'Algorithms', 4, 30, 30, 4),
(6, 'ECO101', 'Microeconomics', 3, 40, 40, 5),
(7, 'CS250', 'Database Systems', 4, 30, 30, 1),
(8, 'MATH201', 'Linear Algebra', 3, 35, 35, 2),
(9, 'PHYS201', 'Electromagnetism', 4, 30, 30, 3),
(10, 'CS401', 'AI Fundamentals', 4, 25, 25, 4);

-- Insert enrollments (child of students and courses)
-- Normal enrollments (first 8 rows)
INSERT INTO enrollments (enrollment_id, student_id, course_id, enrolled_at, status) VALUES
(1, 1, 1, '2023-08-20 10:00:00', 'ENROLLED'),
(2, 1, 3, '2023-08-21 11:00:00', 'ENROLLED'),
(3, 2, 1, '2023-08-20 10:30:00', 'ENROLLED'),
(4, 2, 2, '2023-08-22 09:00:00', 'COMPLETED'),
(5, 3, 2, '2022-08-15 14:00:00', 'COMPLETED'),
(6, 3, 4, '2022-08-16 15:00:00', 'COMPLETED'),
(7, 4, 5, '2024-08-10 10:00:00', 'ENROLLED'),
(8, 5, 6, '2022-08-17 11:00:00', 'COMPLETED');

-- Example rows that would trigger referential integrity violations if inserted
-- before their parent rows exist:

-- 9: student_id = 99 (no such student)
INSERT INTO enrollments (enrollment_id, student_id, course_id, enrolled_at, status) VALUES
(9, 99, 1, '2023-09-01 10:00:00', 'ENROLLED');

-- 10: course_id = 999 (no such course)
INSERT INTO enrollments (enrollment_id, student_id, course_id, enrolled_at, status) VALUES
(10, 1, 999, '2023-09-02 10:00:00', 'ENROLLED');
