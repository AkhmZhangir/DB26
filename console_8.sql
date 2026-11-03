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
select e.emp_name, d.dept_name
from employees e
cross join departments d;
--result shows all combinations of employee and department 5(employee) * 4(deptartment)


--2.2
select employees.emp_name,departments.dept_name
from employees, departments;

select employees.emp_name,departments.dept_name
from employees
inner join departments on True;


--2.3
 select employees.emp_name,projects.project_name
 from employees
 cross join projects;

--3.1
select e.emp_name,d.dept_name
from employees e
inner join departments d on e.dept_id= d.dept_id;

--3.2

select e.emp_name,d.dept_name
from employees e
inner join departments d using(dept_id);

--3.3

select e.emp_name,d.dept_name
from employees e
natural join departments d;

--3.4

select e.emp_name, d.dept_name, p.project_name
from employees e
join departments d using(dept_id)
join projects p using(dept_id);


--4.1

select e.emp_name, d.dept_name
from employees e
left join departments d on e.dept_id=d.dept_id;

-- tom brown is shown without dept id just <null>

--4.2

select e.emp_name, d.dept_name
from employees e
left join departments d using(dept_id);

--4.3

select employees.emp_name, departments.dept_name
from employees
left join departments on employees.dept_id = departments.dept_id
where departments.dept_id is NULL;

--4.4

select departments.dept_name,count(employees.emp_id) as emp_count
from departments
left join employees on employees.dept_id=departments.dept_id
group by departments.dept_id, dept_name;

--5.1

select employees.emp_name,departments.dept_name
from employees
right join departments on employees.dept_id=departments.dept_id;

--5.2

select employees.emp_name,departments.dept_name
from departments
left join employees on employees.dept_id=departments.dept_id;

--5.3

select employees.emp_name,departments.dept_name
from employees
right join departments on employees.dept_id=departments.dept_id
where emp_name is null;

--6.1
SELECT e.emp_name, e.dept_id, d.dept_id, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

--6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

--6.3

select case
    when d.dept_id is Null then 'Employee without department'
    when e.emp_id is Null then 'department without employee'
    else 'matched'
    end as record_status, e.emp_name, d.dept_id
from employees e
full join departments d on e.dept_id = d.dept_id
where e.emp_id is null or d.dept_id is null;


--7.1

select e.emp_id, e.salary,d.dept_id, d.location
from employees e
left join departments d on e.dept_id = d.dept_id and d.location = 'Building B';

--7.2

select e.emp_id, e.salary,d.dept_id, d.location
from employees e
left join departments d on e.dept_id = d.dept_id
where location='Building B';

--it does not contain null values, ON clause adds all from employees

--8.1

SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
from departments d
left join employees e on e.dept_id= d.dept_id
left join projects p on p.dept_id = d.dept_id;

--8.2

ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

select e.emp_name ,m.manager_id
from employees e
left join employees m on e.manager_id= m.emp_id;

--8.3

select d.dept_id, avg(e.salary) as salary
from departments d
inner join employees e on d.dept_id=e.dept_id
group by d.dept_id, d.dept_name
having avg(e.salary)>50000;


/*
1) INNER JOIN returns only matching rows. LEFT JOIN returns all rows from the left table, with NULLs for the right table's columns where nothing matches.

2) CROSS JOIN is for generating all combinations: sizes × colors, calendar × categories, or test data.

3) In an outer join, a condition in ON only defines what counts as a match, so left rows are kept. A condition in WHERE filters after the join and removes the NULL-padded rows, which turns the LEFT JOIN into an INNER JOIN. In an inner join, both placements give the same result.

4) 5 × 10 = 50.

5) NATURAL JOIN joins on all columns that have the same name in both tables. If there are none, it behaves like a CROSS JOIN.

6) NATURAL JOIN risks:

    Adding a same-named column to both tables (such as updated_at) silently changes the join.

    Same names don't always mean the same thing.

    The join keys aren't visible in the query, so it's harder to read.

Prefer ON or USING.

7) SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

8) Use FULL OUTER JOIN when you need all rows from both tables. Typical cases are reconciling two data sources, comparing snapshots, and finding orphaned rows on either side.
*/