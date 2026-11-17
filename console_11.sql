create database lab_8;

-- Create tables
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(100),
                           dept_id INT,
                           salary DECIMAL(10,2),
                           FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
                          proj_id INT PRIMARY KEY,
                          proj_name VARCHAR(100),
                          budget DECIMAL(12,2),
                          dept_id INT,
                          FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
                            (101, 'IT', 'Building A'),
                            (102, 'HR', 'Building B'),
                            (103, 'Operations', 'Building C');
INSERT INTO employees VALUES
                          (1, 'John Smith', 101, 50000),
                          (2, 'Jane Doe', 101, 55000),
                          (3, 'Mike Johnson', 102, 48000),
                          (4, 'Sarah Williams', 102, 52000),
                          (5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
                         (201, 'Website Redesign', 75000, 101),
                         (202, 'Database Migration', 120000, 101),
                         (203, 'HR System Upgrade', 50000, 102);

--2.1
create index idx_emp_salary on employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

--employees_pkey,CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (emp_id)
--idx_emp_salary,CREATE INDEX idx_emp_salary ON public.employees USING btree (salary)
--it means this table has 2 indexes, primary key and my idx_emp_salary


--2.2
create index idx_emp_dept_id on employees(dept_id);

select * from employees where dept_id= 101;
--indexing helps with filtering and joins;

--2.3
SELECT
 tablename,
 indexname,
 indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

--i see 5 indexes, departments_pkey, employees_pkey,projects_pkey are created automatically

--3.1

create index idx_emp_dept_salary on employees(dept_id,salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- The index can be used for salary-only queries, but it is generally
-- less suitable than a separate index on salary because dept_id
-- is the leading column.

--3.2

create index idx_emp_salary_dept on employees(salary,dept_id);

-- by dept first
explain
    select * FROM employees WHERE dept_id = 102 AND salary > 50000;
-- by salary
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

/*
Yes, column order in an index matters.
In (dept_id, salary), entries are sorted first by dept_id, then by salary within each department.
In (salary, dept_id), it is the other way around.
However, the order of conditions in the WHERE clause does not matter.
*/

--4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

create unique index u_idx_emp_email on employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Expected error: duplicate email violates the unique index.
-- Run this statement separately.
--4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

--it created employees_phone_key create unique index

--5.1
create index idx_emp_salary_desc on employees(salary desc);

select emp_name, salary
from employees
order by salary desc;

/*
The index stores salary values in descending order, allowing PostgreSQL to retrieve rows in the required order without an additional sorting step.
This can improve the performance of ORDER BY salary DESC queries.
*/

--5.2
CREATE INDEX idx_proj_budget_nulls_first ON projects(budget NULLS FIRST);

sELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--6.1
CREATE INDEX idx_emp_name_lower ON employees(lower(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
--without index it will apply lower for every element and then compare

--6ю2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;


CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--7.1

alter index idx_emp_salary rename to employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--7.2

drop index idx_emp_dept_salary;

--it consumes disc space

--7.3
reindex index employees_salary_index;

-- REINDEX rebuilds an index from the table data.
-- It is useful when an index becomes bloated or corrupted.

--8.1


SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;
/*
1) optimize where
2) optimize join
3) optimize order
*/
create index idx_emp_salary on employees(salary) where salary>50000;
--create index idx_emp_dept_id on employees(dept_id);--2.2
--create index idx_emp_salary_desc on employees(salary desc);--5.1

--8.2
create index idx_proj_high_budget on projects(budget) where budget> 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

--it takes less disc space, improves performance

explain select * from employees where salary >52000;
--it says seq scan, it says to me that it scans whole table. because table is small it is cheaper to use table than index

--9.1

create index idx_hash_dept_name on departments using hash(dept_name);

select * from departments where dept_name = 'IT';
-- A HASH index can be useful for equality comparisons only. B-tree index is more versatile and supports both equality and range comparisons.


--9.2
-- B-tree index
CREATE INDEX idx_proj_name_btree ON projects(proj_name);
-- Hash index
CREATE INDEX idx_proj_name_hash ON projects USING HASH (proj_name);

-- Equality search for b tree and hash
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
-- Range search suitable only for b tree
SELECT * FROM projects WHERE proj_name > 'Database';

--10.1

SELECT
 schemaname,
 tablename,
 indexname,
 pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

--the largest is idx_proj_name_hash and idx_hash_dept_name they are 32 kB while others are 16kB.
--It is because it has to store metadata and bucket management;

--10.2
DROP INDEX IF EXISTS idx_proj_name_hash;

--10.3

CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

/*
Summary Questions

1. What is the default index type in PostgreSQL?
B-tree.

2. Name three scenarios where you should create an index:
- A column is frequently used in selective WHERE conditions.
- A column is frequently used to find matching rows in JOINs.
- An index can support a frequently used ORDER BY clause.

3. Name two scenarios where you should NOT create an index:
- The table is very small and sequential scans are already efficient.
- The index is unused or duplicates an existing index without
  providing a useful benefit.

4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
PostgreSQL maintains indexes automatically as data changes.
This maintenance adds overhead to write operations.

5. How can you check if a query is using an index?
Use EXPLAIN to inspect the planned execution.
Use EXPLAIN ANALYZE to execute the query and inspect actual execution.
Look for Index Scan, Index Only Scan, or Bitmap Index Scan.
*/

--additional

-- 1
-- Create an expression index for searches by hiring month.

CREATE INDEX idx_emp_hire_month
    ON employees (EXTRACT(MONTH FROM hire_date));

-- Find employees hired in January, regardless of the year.
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 1;

-- Expected result: John Smith, 2020-01-15.

-- 2
-- Enforce uniqueness of each department/email combination.

CREATE UNIQUE INDEX u_idx_emp_dept_email
    ON employees (dept_id, email);

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname = 'u_idx_emp_dept_email';
-- Duplicate department/email combinations are not allowed.
-- The existing unique index on email already enforces a stricter rule.

-- 3
-- Use a separate temporary table to preserve the original tables.

CREATE TEMP TABLE employees_index_test AS
SELECT
    g AS emp_id,
    'Employee ' || g AS emp_name,
    (g % 100000)::NUMERIC(10, 2) AS salary
FROM generate_series(1, 100000) AS g;

-- Refresh statistics before comparing execution plans.
ANALYZE employees_index_test;

-- Test without an index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM employees_index_test
WHERE salary > 99000;

-- Create an index.
CREATE INDEX idx_test_emp_salary
    ON employees_index_test (salary);

-- Test the same query with an index available.
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM employees_index_test
WHERE salary > 99000;

-- Compare scan types, Execution Time, and buffer usage.
-- The first plan is expected to use a Seq Scan.
-- The second plan may use an Index Scan or a Bitmap Index Scan.
-- Repeat the measurements because caching can affect execution time.

-- Remove the test table and its index.
DROP TABLE employees_index_test;


-- 4
-- Cover a query that filters by department and returns name and salary.

CREATE INDEX idx_emp_dept_covering
    ON employees (dept_id)
    INCLUDE (emp_name, salary);

EXPLAIN ANALYZE
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101;

-- The index contains every column required by this query.
-- This makes an Index Only Scan possible.
-- PostgreSQL may still choose a Seq Scan because the table is small.

/*
Reflection

Indexes are useful for frequently executed queries that filter,
join, or sort data. However, they consume disk space and add
maintenance overhead to write operations. Indexes should match
actual query patterns, and their usefulness should be checked
with EXPLAIN or EXPLAIN ANALYZE. On small tables, PostgreSQL may
prefer a sequential scan even when an index exists.
*/