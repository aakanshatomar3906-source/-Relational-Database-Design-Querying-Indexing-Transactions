# -Relational-Database-Design-Querying-Indexing-Transactions

# CampusConnect Database Assignment

**Engine:** SQLite 3.45  
*(Replace with your actual version if different; check with `SELECT sqlite_version();`)*

---

## Overview

This repository contains the relational database design, sample data, queries, indexes, and transaction logic for the CampusConnect data layer, covering:

- Students, courses, instructors, and enrollments
- A set of reporting queries the backend team will rely on
- Indexing strategy and concurrency / transaction behavior

Files:

- `schema.sql` – Table definitions (CREATE TABLE)
- `data.sql` – Sample data (INSERT statements)
- `indexes.sql` – Index definitions (CREATE INDEX)
- `queries.sql` – Reporting query set
- `transaction.sql` – Multi-statement transaction example
- `README.md` – This file

---

## How to Run

Using the SQLite command-line tool:

```bash
sqlite3 campusconnect.db

-- Inside sqlite3:
PRAGMA foreign_keys = ON;
.read schema.sql
.read data.sql
.read indexes.sql
.read queries.sql
.read transaction.sql
```

**Important for SQLite:**  
Foreign key constraints are not enforced by default. Always run:

```sql
PRAGMA foreign_keys = ON;
```

at the start of every session before inserting data, otherwise referential-integrity violations will silently succeed.

---

## Schema Design Decisions

### Tables

- `students`  
  - Root entity for all students.  
  - Primary key: `student_id`  
  - Constraints: `NOT NULL` on key fields, `CHECK` on email format.

- `instructors`  
  - Root entity for instructors.  
  - Primary key: `instructor_id`  
  - Each instructor belongs to a department.

- `courses`  
  - Represents academic courses.  
  - Primary key: `course_id`  
  - Foreign key: `instructor_id` → `instructors.instructor_id`  
  - Constraints: `credits` between 1–6, `max_seats > 0`.

- `enrollments`  
  - Captures (student, course) pairs with status and timestamp.  
  - Primary key: `enrollment_id`  
  - Foreign keys:  
    - `student_id` → `students.student_id`  
    - `course_id` → `courses.course_id`  
  - Unique constraint: `(student_id, course_id)` to prevent duplicate enrollments.

### Keys and Constraints

- Every table has an explicit primary key declared as `PRIMARY KEY NOT NULL`.
- At least one foreign key relationship exists:
  - `enrollments.student_id` references `students.student_id`
  - `enrollments.course_id` references `courses.course_id`
  - `courses.instructor_id` references `instructors.instructor_id`
- Column-level constraints:
  - `NOT NULL` on required fields
  - `CHECK` constraints for domain integrity (e.g., `credits`, `max_seats`, `status`, email format)
  - `DEFAULT` values (e.g., `enrolled_at`, `status`)

### Normal Form

The schema satisfies **Third Normal Form (3NF)**:

1. **1NF** – No repeating groups; each table has atomic values per column.
2. **2NF** – No partial dependencies on part of a composite key.
3. **3NF** – No transitive dependencies of non-key attributes on other non-key attributes.

See the **Normalization Write‑up** section below for a detailed explanation.

---

## Normalization Write‑up

### Unnormalized Version

An unnormalized “university” table might store all information in one row per enrollment, such as:

- `student_id`, `first_name`, `last_name`, `email`, `enrollment_year`
- `course_id`, `course_code`, `title`, `credits`, `instructor_id`, `instructor_name`, `department`
- `enrolled_at`, `status`

This leads to:

- Repeating course and instructor details for each enrollment of the same student.
- Redundant storage of course titles, credits, instructor names, and departments.
- Update anomalies: changing a course title would require updating many rows.

### 1NF (No Repeating Groups)

We split the data into separate tables:

- `students`: one row per student.
- `instructors`: one row per instructor.
- `courses`: one row per course.
- `enrollments`: one row per (student, course) pair.

Each column holds a single atomic value; there are no repeating groups. A student’s multiple courses are represented as multiple rows in `enrollments`, not as repeated course columns.

### 2NF (No Partial Dependencies)

Consider `enrollments` with a composite key `(student_id, course_id)`. Its non-key attributes:

- `enrolled_at`
- `status`

depend on the **whole** key (a specific enrollment), not just on `student_id` or just on `course_id`. Therefore, there is no partial dependency.

Similarly, `courses` has a single-column primary key `course_id`, and all non-key attributes (`course_code`, `title`, `credits`, `max_seats`, `available_seats`, `instructor_id`) depend fully on `course_id`. Thus, 2NF is satisfied.

### 3NF (No Transitive Dependencies)

Potential transitive dependency:

- In `courses`, we have `instructor_id` → `instructors.instructor_id`.
- If we stored `instructor_name` and `department` directly in `courses`, we would have:
  - `course_id` → `instructor_id`
  - `instructor_id` → `instructor_name`, `department`
  - So `course_id` → `instructor_name` via `instructor_id` (transitive).

To avoid this:

- `courses` stores only `instructor_id`.
- `instructors` stores `instructor_name` and `department`.

Thus, no non-key attribute depends on another non-key attribute; all non-key attributes depend directly on the primary key. The schema is in 3NF.

---

## Indexing Justification

### Indexed Columns

1. **`idx_enrollments_student_id`**  
   - Index on `enrollments.student_id`.  
   - Speeds up:
     - Queries that join `enrollments` with `students` (e.g., “students enrolled in more than 1 course”).
     - Correlated subqueries counting enrollments per student.
   - Reason: `student_id` is frequently used in `JOIN` and `WHERE` conditions.

2. **`idx_enrollments_student_course` (composite)**  
   - Index on `(student_id, course_id)`.  
   - Speeds up:
     - Lookups for a specific student+course pair.
     - Queries filtering or joining on both columns together.
   - Reason: Composite index allows the engine to quickly locate a specific enrollment without scanning the whole table.

3. **`idx_courses_instructor_id`**  
   - Index on `courses.instructor_id`.  
   - Speeds up joins between `courses` and `instructors`.  
   - Reason: `instructor_id` is used in `JOIN` conditions and may be filtered in reporting queries.

### Column Deliberately Not Indexed

- **`students.enrollment_year`**  
  - Reason:
    - Low cardinality (only a few years like 2022–2024).
    - Not frequently used in filtering or joining.
    - Index overhead would outweigh any performance benefit.

---

## Transactions and Isolation-Level Analysis

### Transaction Example

The `transaction.sql` file contains a multi-statement transaction that:

1. Decrements `available_seats` for a course (only if seats are available).
2. Inserts a new row into `enrollments`.
3. Commits if both steps succeed; otherwise, it can be rolled back.

This ensures that both changes (seat decrement and enrollment insertion) succeed or fail together, preventing inconsistent states.

### Concurrent-Access Scenario

**Scenario:** Two students (S1 and S2) try to enroll in a course C that has exactly one seat left (`available_seats = 1`).

Both sessions execute:

1. `UPDATE courses SET available_seats = available_seats - 1 WHERE course_id = C AND available_seats > 0;`
2. `INSERT INTO enrollments ...`

**Problems without proper isolation:**

- **Lost update:** Both sessions might read `available_seats = 1` before either updates, then both decrement, resulting in two enrollments for one seat.
- **Dirty read:** One session might read uncommitted changes from another (e.g., a partially updated seat count), leading to incorrect decisions.

### Isolation Level That Prevents the Problem

- **Serializable** isolation level prevents both lost updates and dirty reads:
  - Transactions appear to execute in some serial order.
  - No transaction can read data that another has modified but not yet committed.
  - Conflicting updates cause one transaction to block or abort, ensuring only one enrollment succeeds for the last seat.

**Justification:**

- For seat-counting logic, correctness is critical: we must never over-enroll.
- Serializable isolation guarantees that if two transactions try to enroll in the last seat, one will succeed and the other will be blocked or aborted.
- While Serializable can reduce concurrency, for this small-scale campus system it is acceptable and safer than weaker levels.

---

## Query Set Overview

The `queries.sql` file contains reporting queries that satisfy all assignment requirements:

- One query using `IN`, one using `BETWEEN`.
- One query using `IS NOT NULL`.
- One query using `GROUP BY` with `HAVING`.
- Three different join types: `INNER JOIN`, `LEFT JOIN`, and a simulated `RIGHT JOIN` behavior (SQLite does not support `RIGHT JOIN` directly; a comment explains the substitution).
- One scalar subquery, one correlated subquery, and one query using `EXISTS`.
- One query using a set operation (`UNION`).
- One query using a window function (`ROW_NUMBER()` with `PARTITION BY`).

Each query is preceded by a one-line comment explaining what it answers and which requirement it satisfies.

---

## Notes for Other Engines

If you use **MySQL** or **PostgreSQL**:

- Foreign keys are enforced by default (unlike SQLite).
- You can use `FULL OUTER JOIN` and `RIGHT JOIN` directly (PostgreSQL supports both; MySQL does not support `FULL OUTER JOIN` natively).
- Isolation levels can be explicitly set (e.g., `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;` in PostgreSQL).

Adjust comments and SQL syntax if needed, but the core schema and logic remain valid.

---

## License

This code and documentation are provided for the CampusConnect database assignment and may be used as a reference for learning purposes.
