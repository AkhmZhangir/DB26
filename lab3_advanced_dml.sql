create database advanced_lab;
/*create database*/
create table employees(
    emp_id serial primary key,
    first_name varchar(100),
    last_name varchar(100),
    department int,
    foreign key(department) references departments(dept_id),
    salary int,
    hire_date timestamptz,
    status varchar(10) default 'active'
);
create table departments(
    dept_id serial primary key ,
    dept_name varchar(200),
    budget int
);
drop table employees;
create table projects(
    project_id serial primary key ,
    project_name varchar(200),
    dept_id int,
    foreign key(dept_id) references departments(dept_id),
    start_date timestamptz,
    end_date timestamptz,
    budget int
);
/*create tables with foreign keys*/

insert into departments (dept_name, budget) VALUES ('IT', 200000);

insert into employees (emp_id, first_name, last_name, department) values (1,'zhanga', 'akhm', '1');

insert into departments(dept_name, budget)
values ('HR',100000),
       ('Law',150000),
       ('Money', 900000);

insert into employees(first_name, last_name, department, salary, hire_date) values ('artem','kosov',2,500000*1.1,now());
/*inset data*/
CREATE TEMP TABLE temp_employees
(
    emp_id     INT,
    first_name VARCHAR(100),
    last_name  VARCHAR(100),
    department INT,
    salary     INT,
    hire_date  TIMESTAMPTZ,
    status     VARCHAR(10)
);

INSERT INTO temp_employees (emp_id,
                            first_name,
                            last_name,
                            department,
                            salary,
                            hire_date,
    status
)
SELECT emp_id,
       first_name,
       last_name,
       department,
       salary,
       hire_date,
    status
FROM employees
WHERE department = (
    SELECT dept_id
    FROM departments
    WHERE dept_name = 'IT'
);
/*create temporary table from values of employee*/
SELECT * FROM temp_employees;;

insert into employees(first_name, last_name, department, salary, hire_date)
values ('name','last name', 1, 50000,now()),
       ('alikhan', 'alikhan', 3,100000, now()),
       ('john', 'pork',4,20000, now());
/*multiple input*/
insert into employees(first_name, last_name, department, salary, hire_date) values ('sam', 'jobs', 1,70000,'2019-02-19''14:33:01.12344 +00:00');

update employees set salary = salary *1.1;
/*update*/

update employees set status = 'Senior' where salary > 60000 and hire_date < '2020-01-01''00:00:00.00000 +00:00';
/*i wanted to use status not department because i used foreign key with ID so it was imposible to use names of departments*/
update employees set status= case
    when salary >80000 then status = 'Manager'
    when salary between 50000 and 80000 then status = 'Senior'
    else status= 'Junior'
end;
/*update with case*/

-- 10. UPDATE with DEFAULT
-- department has no DEFAULT defined, so DEFAULT resolves to NULL
update employees
set department = default
where status = 'Inactive';

-- 11. UPDATE with subquery
-- department budget = 120% of the average salary in that department
update departments d
set budget = (select avg(e.salary) * 1.2
              from employees e
              where e.department = d.dept_id)
where exists (select 1 from employees e where e.department = d.dept_id);

-- 12. UPDATE multiple columns
-- department is an int FK, so look up 'Sales' by name via subquery
insert into departments (dept_name, budget) values ('Sales', 300000);

update employees
set salary = salary * 1.15,
    status = 'Promoted'
where department = (select dept_id from departments where dept_name = 'Sales');


-- 13. DELETE with simple WHERE
delete from employees
where status = 'Terminated';

-- 14. DELETE with complex WHERE
delete from employees
where salary < 40000
  and hire_date > '2023-01-01'
  and department is null;

-- 15. DELETE with subquery
-- remove departments that have no employees
delete from departments
where dept_id not in (select distinct department
                      from employees
                      where department is not null);

-- 16. DELETE with RETURNING
-- sample data for projects
insert into projects (project_name, dept_id, start_date, end_date, budget)
values ('Old project', 1, '2021-01-01', '2022-06-01', 60000),
       ('New project', 1, '2024-01-01', '2026-12-31', 80000);

delete from projects
where end_date < '2023-01-01'
returning *;

-- 17. INSERT with NULL values
insert into employees (first_name, last_name, department, salary, hire_date)
values ('null', 'guy', null, null, now());


-- 18. UPDATE NULL handling
insert into departments (dept_name, budget) values ('Unassigned', 0);

update employees
set department = (select dept_id from departments where dept_name = 'Unassigned')
where department is null;

-- 19. DELETE with NULL conditions
delete from employees
where salary is null or department is null;

-- 20. INSERT with RETURNING
-- return generated id and concatenated full name
insert into employees (first_name, last_name, department, salary, hire_date)
values ('ivan', 'petrov', 1, 90000, now())
returning emp_id, first_name || ' ' || last_name as full_name;

-- 21. UPDATE with RETURNING
update employees e
set salary = e.salary + 5000
from (select emp_id, salary as old_salary from employees) old
where e.emp_id = old.emp_id
  and e.department = (select dept_id from departments where dept_name = 'IT')
returning e.emp_id, old.old_salary, e.salary as new_salary;

-- 22. DELETE with RETURNING all columns
delete from employees
where hire_date < '2020-01-01'
returning *;

-- 23. Conditional INSERT
insert into employees (first_name, last_name, department, salary, hire_date)
select 'ivan', 'petrov', 1, 90000, now()
where not exists (select 1
                  from employees
                  where first_name = 'ivan' and last_name = 'petrov');


-- 24. UPDATE with JOIN logic using subqueries\
update employees e
set salary = case
    when (select budget from departments d where d.dept_id = e.department) > 100000
        then salary * 1.10
    else salary * 1.05
end
where department is not null;

-- 25. Bulk operations
insert into employees (first_name, last_name, department, salary, hire_date)
values ('bulk1', 'test', 1, 50000, now()),
       ('bulk2', 'test', 1, 51000, now()),
       ('bulk3', 'test', 2, 52000, now()),
       ('bulk4', 'test', 2, 53000, now()),
       ('bulk5', 'test', 3, 54000, now());

update employees
set salary = salary * 1.10
where last_name = 'test' and first_name like 'bulk%';


-- 26. Data migration simulation
create table employee_archive (like employees);
alter table employee_archive add column archived_at timestamptz default now();

insert into employee_archive (emp_id, first_name, last_name, department, salary, hire_date, status)
select emp_id, first_name, last_name, department, salary, hire_date, status
from employees
where status = 'Inactive';

delete from employees
where status = 'Inactive';

-- 27. Complex business logic
update projects
set end_date = end_date + interval '30 days'
where budget > 50000
  and dept_id in (select department
                  from employees
                  where department is not null
                  group by department
                  having count(*) > 3);

select * from employees;