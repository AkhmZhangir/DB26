create database lab_7;

-- Create table: employees
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000);

--2.1
create view emp_details as
    select e.emp_name,e.salary, d.dept_name,d.location
from employees e
inner join departments d on e.dept_id= d.dept_id;

select * from emp_details;
--2.2
create view dept_statistics as
    select d.dept_id, count(e.emp_id), avg(e.salary),min(e.salary),max(e.salary)
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_id;

select * from dept_statistics;

SELECT * FROM dept_statistics
ORDER BY count DESC;

--2.3

create view project_overview as
    select p.project_name , p.budget, d.dept_name, d.location,count(e.emp_id)
from projects p
join departments d on d.dept_id= p.dept_id
join employees e on d.dept_id = e.dept_id
group by p.project_name, p.budget, d.dept_id, d.location;

select * from project_overview;

--2.4

CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

select * from high_earners;
--with my inner join i cannot see employees with high salary and without department, ez fix to use left join


--3.1
create or replace view emp_details as
    select
        e.emp_name,e.salary,d.dept_name,d.location, case
        when e.salary > 60000 then 'High'
        when e.salary >50000 then 'Medium'
        else 'Standard'
    end as salary_grade
from employees e
join departments d on d.dept_id = e.dept_id;

select * from emp_details;

--3.2

alter view high_earners rename to top_performers;

select * from top_performers;


--3.3

CREATE VIEW temp_view AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary < 50000;

DROP VIEW temp_view;

--4.1

create view employee_salaries as
    select emp_id, emp_name, dept_id, salary
from employees;

--it is updatable because there is no complicated functions

--4.2

update employee_salaries
set salary = 52000
where emp_name = 'John Smith';

--4.3

insert into employee_salaries (emp_id, emp_name, dept_id, salary) VALUES (6,'Alice Johnson',102,58000);

select * from employees;
--yes it was successful

--4.4
drop view it_employees;

create view it_employees as
    select e.emp_id,e.emp_name, e.dept_id,e.salary
    from employees e
    where e.dept_id=101
with local check option ;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);

--[44000] ОШИБКА: новая строка нарушает ограничение-проверку для представления "it_employees"
--Подробности: Ошибочная строка содержит (7, Bob Wilson, 103, 60000.00)

-- 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments d
         LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS total_employees,
        SUM(salary) AS total_salaries
    FROM employees
    GROUP BY dept_id
) e ON e.dept_id = d.dept_id
         LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS total_projects,
        SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
) p ON p.dept_id = d.dept_id
WITH DATA;

SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;


-- 5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

-- Before refresh
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

REFRESH MATERIALIZED VIEW dept_summary_mv;

-- After refresh
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

-- Before refresh: old data.
-- After refresh: IT has one more employee and total salaries increase by 54000.


-- 5.3
CREATE UNIQUE INDEX dept_summary_mv_dept_id_idx
    ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- CONCURRENTLY allows reading the materialized view during refresh.


-- 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS team_size
FROM projects p
         LEFT JOIN departments d ON d.dept_id = p.dept_id
         LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_id,
    d.dept_name
WITH NO DATA;

-- Run separately: this query is expected to fail.
SELECT * FROM project_stats_mv;

-- Error: materialized view "project_stats_mv" has not been populated.
-- Fix: populate it using REFRESH.
REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;


-- 6.1
CREATE ROLE analyst NOLOGIN;

CREATE ROLE data_viewer
    WITH LOGIN PASSWORD 'viewer123';

CREATE USER report_user
    WITH PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';


-- 6.2
CREATE ROLE db_creator
    WITH LOGIN CREATEDB PASSWORD 'creator789';

CREATE ROLE user_manager
    WITH LOGIN CREATEROLE PASSWORD 'manager101';

CREATE ROLE admin_user
    WITH LOGIN SUPERUSER PASSWORD 'admin999';


-- 6.3
GRANT SELECT
    ON employees, departments, projects
    TO analyst;

GRANT ALL PRIVILEGES
    ON employee_details
    TO data_viewer;

GRANT SELECT, INSERT
    ON employees
    TO report_user;


-- 6.4
CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE
    ON employees
    TO hr_team;

GRANT SELECT
    ON dept_statistics
    TO finance_team;


-- 6.5
REVOKE UPDATE
    ON employees
    FROM hr_team;

REVOKE hr_team
    FROM hr_user2;

REVOKE ALL PRIVILEGES
    ON employee_details
    FROM data_viewer;


-- 6.6
ALTER ROLE analyst
    WITH LOGIN PASSWORD 'analyst123';

ALTER ROLE user_manager
    WITH SUPERUSER;

ALTER ROLE analyst
    WITH PASSWORD NULL;

ALTER ROLE data_viewer
    WITH CONNECTION LIMIT 5;


-- 7.1
CREATE ROLE read_only NOLOGIN;

GRANT USAGE ON SCHEMA public
    TO read_only;

GRANT SELECT
    ON ALL TABLES IN SCHEMA public
    TO read_only;

CREATE ROLE junior_analyst
    WITH LOGIN INHERIT PASSWORD 'junior123';

CREATE ROLE senior_analyst
    WITH LOGIN INHERIT PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;

GRANT INSERT, UPDATE
    ON employees
    TO senior_analyst;


-- 7.2
CREATE ROLE project_manager
    WITH LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics
    OWNER TO project_manager;

ALTER TABLE projects
    OWNER TO project_manager;

-- Check table owners
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

-- Check view owners
SELECT viewname, viewowner
FROM pg_views
WHERE schemaname = 'public';


-- 7.3
CREATE ROLE temp_owner WITH LOGIN;

CREATE TABLE temp_table (
                            id INT
);

ALTER TABLE temp_table
    OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;


-- 7.4
CREATE VIEW hr_employee_view AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT
    ON hr_employee_view
    TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary
FROM employees;

GRANT SELECT
    ON finance_employee_view
    TO finance_team;

-- Optional: revoke direct table access to restrict HR to the HR view.
-- REVOKE SELECT ON employees FROM hr_team;


-- 8.1
-- All projects are treated as active because no status column exists.
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    COALESCE(e.avg_salary, 0) AS avg_salary,
    COALESCE(p.active_projects, 0) AS active_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget,
    COALESCE(
            ROUND(
                    p.total_project_budget
                        / NULLIF(e.employee_count, 0),
                    2
            ),
            0
    ) AS budget_per_employee
FROM departments d
         LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS employee_count,
        ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY dept_id
) e ON e.dept_id = d.dept_id
         LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS active_projects,
        SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
) p ON p.dept_id = d.dept_id;


-- 8.2
ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000
            THEN 'Critical Review Required'
        WHEN p.budget > 100000
            THEN 'Management Approval Needed'
        ELSE 'Standard Process'
        END AS approval_status
FROM projects p
         LEFT JOIN departments d ON d.dept_id = p.dept_id
WHERE p.budget > 75000;


-- 8.3
-- Level 1: Viewer
CREATE ROLE viewer_role NOLOGIN;

GRANT USAGE ON SCHEMA public
    TO viewer_role;

GRANT SELECT
    ON ALL TABLES IN SCHEMA public
    TO viewer_role;

-- Level 2: Entry
CREATE ROLE entry_role NOLOGIN INHERIT;

GRANT viewer_role TO entry_role;

GRANT INSERT
    ON employees, projects
    TO entry_role;

-- Level 3: Analyst
CREATE ROLE analyst_role NOLOGIN INHERIT;

GRANT entry_role TO analyst_role;

GRANT UPDATE
    ON employees, projects
    TO analyst_role;

-- Level 4: Manager
CREATE ROLE manager_role NOLOGIN INHERIT;

GRANT analyst_role TO manager_role;

GRANT DELETE
    ON employees, projects
    TO manager_role;

-- Users
CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;