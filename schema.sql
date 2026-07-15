-- schema.sql
-- CampusConnect Relational Schema (students, courses, enrollments, instructors)

-- Students table (root table)
CREATE TABLE students (
    student_id      INTEGER PRIMARY KEY NOT NULL,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    enrollment_year INTEGER NOT NULL,
    -- domain constraint: email must contain '@'
    CHECK (email LIKE '%@%.%')
);

-- Instructors table (root table)
CREATE TABLE instructors (
    instructor_id   INTEGER PRIMARY KEY NOT NULL,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    department      VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL
);

-- Courses table (depends on instructors)
CREATE TABLE courses (
    course_id       INTEGER PRIMARY KEY NOT NULL,
    course_code     VARCHAR(20) NOT NULL,
    title           VARCHAR(150) NOT NULL,
    credits         INTEGER NOT NULL CHECK (credits BETWEEN 1 AND 6),
    max_seats       INTEGER NOT NULL CHECK (max_seats > 0),
    available_seats INTEGER NOT NULL,
    instructor_id   INTEGER NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

-- Enrollments table (depends on students and courses)
CREATE TABLE enrollments (
    enrollment_id   INTEGER PRIMARY KEY NOT NULL,
    student_id      INTEGER NOT NULL,
    course_id       INTEGER NOT NULL,
    enrolled_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(20) NOT NULL DEFAULT 'ENROLLED'
        CHECK (status IN ('ENROLLED', 'COMPLETED', 'CANCELLED')),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    -- avoid duplicate enrollments for same student+course
    UNIQUE (student_id, course_id)
);
