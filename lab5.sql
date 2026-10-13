--Akhmedyarov Zhangir 25B030138

create database constrains;

drop table if exists employees;

create table employees(
    employee_id serial primary key,
    first_name varchar(40),
    last_name varchar (40),
    age int check ( age between 18 and 65),
    salary int check ( salary>0 )
    --constraint age_check check ( age between 18 and 65)
);

create table product_catalog(
    product_id serial primary key ,
    product_name varchar(100),
    regular_price int,
    discount_price int,
    constraint valid_discount check ( regular_price>0 and discount_price>0 and discount_price<regular_price )
);

create table bookings(
    booking_id serial primary key,
    check_in_date date,
    check_out_date date,
    num_guests int,
    check ( check_in_date<check_out_date and num_guests between 1 and 10)
);
--valid
insert into employees (first_name, last_name, age, salary) VALUES ('Alikhan','Makhanbet', 18, 10000000);
insert into employees (first_name, last_name, age, salary) VALUES ('Zhangir','Akhmedyarov',19,67676767);
insert into product_catalog (product_name, regular_price, discount_price) VALUES ('Lenovo laptop', 999,799);
insert into product_catalog (product_name, regular_price, discount_price) VALUES ('Samsung s24', 899, 699);
insert into bookings (check_in_date, check_out_date, num_guests) VALUES ('2026-09-14','2026-10-2', 8);
insert into bookings (check_in_date, check_out_date, num_guests) VALUES ('2025-12-20', '2026-01-14',2);

--not valid

insert into employees(first_name, last_name, age, salary) VALUES ('Artem', 'Kosov', 17, -10);
--error because age must be greater than 18 and salary positive
insert into product_catalog (product_name, regular_price, discount_price) VALUES ('Xiaomi 18 ultra', 1500, 1800);
--error because discount must be less than regular price
insert into bookings (check_in_date, check_out_date, num_guests)
values (current_date, '2024-08-17', 12);
--error because current date is greater than 2024 and number of guests more than 10

--part 2
drop table customers cascade ;
--i need to drop it because i wrote not null

create table customers(
    customer_id serial not null ,
    email varchar(200) not null ,
    phone varchar(20) ,
    registration_date date not null
);

drop table inventory cascade ;

create table inventory(
    item_id serial primary key not null ,
    item_name varchar(100) not null,
    quantity int not null check ( quantity>=0 ),
    unit_price numeric not null check ( unit_price>0 ),
    last_updated timestamp not null
);

INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (1, 'alice@example.com', '+77011234567', '2026-10-13');

INSERT INTO inventory
(item_id, item_name, quantity, unit_price, last_updated)
VALUES
    (1, 'Keyboard', 10, 15000, '2026-10-13 21:00:00');


--2 nulls
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (2, NULL, '+77017654321', '2026-10-13');
--email cannot be null
INSERT INTO inventory
(item_id, item_name, quantity, unit_price, last_updated)
VALUES
    (2, 'Mouse', NULL, 5000, '2026-10-13 21:05:00');
--quantity cannot be null because of not null constrain

INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (3, 'bob@example.com', NULL, '2026-10-13');
--it is posible to to add null to phone constrain

drop table departments cascade ;

CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (1, 'IT', 'Almaty'),
    (2, 'HR', 'Astana'),
    (3, 'Finance', 'Shymkent');

SELECT * FROM departments;

CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO departments (dept_id, dept_name, location)
VALUES (1, 'Marketing', 'Almaty');
--error dep_di already exitst
INSERT INTO departments (dept_id, dept_name, location)
VALUES (NULL, 'Sales', 'Astana');
--error dept_id not null

/*
1) unique does not add not null by default, primary key adds it by default. both can be referenced as foreign key
2) composite primary key is used when two or more columns identifies row. individualy columns can have dublicates
3) primary key is main row identifier
*/

CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES
    (1, 'Alex', 1, '2026-01-15'),
    (2, 'Maria', 2, '2026-02-10'),
    (3, 'Daniyar', 3, '2026-03-05');

SELECT * FROM employees_dept;

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (4, 'John', 999, '2026-04-01');
--error because this department does not exits


CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors (author_id, author_name, country)
VALUES
    (1, 'Alex Morgan', 'United Kingdom'),
    (2, 'Dana Smith', 'United States'),
    (3, 'Arman Karimov', 'Kazakhstan');

INSERT INTO publishers (publisher_id, publisher_name, city)
VALUES
    (1, 'North Star Press', 'London'),
    (2, 'Bright Books', 'New York'),
    (3, 'Steppe Publishing', 'Almaty');

INSERT INTO books (
    book_id, title, author_id, publisher_id, publication_year, isbn
)
VALUES
    (1, 'Learning SQL',       1, 1, 2020, '9780000000019'),
    (2, 'Database Design',    2, 2, 2022, '9780000000026'),
    (3, 'Introduction to IT', 3, 3, 2023, '9780000000033'),
    (4, 'Advanced SQL',       1, 2, 2024, '9780000000040');



drop table categories cascade ;
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
drop table products_fk cascade ;
CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id)
        ON DELETE RESTRICT
);
drop table orders cascade ;

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
drop table order_items cascade ;
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories (category_id, category_name)
VALUES
    (1, 'Electronics'),
    (2, 'Stationery');
truncate products_fk cascade ;
INSERT INTO products_fk (product_id, product_name, category_id)
VALUES
    (1, 'Keyboard', 1),
    (2, 'Mouse', 1),
    (3, 'Notebook', 2);

INSERT INTO orders (order_id, order_date)
VALUES
    (1, '2026-10-01'),
    (2, '2026-10-02');

INSERT INTO order_items (item_id, order_id, product_id, quantity)
VALUES
    (1, 1, 1, 1),
    (2, 1, 2, 2),
    (3, 2, 3, 5);

DELETE FROM categories
WHERE category_id = 1;

--error i cant delete item because it is referenced in other table


SELECT * FROM order_items
WHERE order_id = 1;


DELETE FROM orders
WHERE order_id = 1;


SELECT * FROM order_items
WHERE order_id = 1;


SELECT * FROM orders ORDER BY order_id;

SELECT * FROM order_items ORDER BY item_id;


SELECT * FROM products_fk ORDER BY product_id;



CREATE SCHEMA ecommerce;
SET search_path TO ecommerce;

drop table if exists products, customers,orders cascade ;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);


CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'processing',
                'shipped',
                'delivered',
                'cancelled'
            )
        )
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL
        REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL
        REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers (
    customer_id, name, email, phone, registration_date
)
VALUES
    (1, 'Alex', 'alex@example.com', '+77010000001', '2026-09-01'),
    (2, 'Maria', 'maria@example.com', '+77010000002', '2026-09-02'),
    (3, 'Daniyar', 'daniyar@example.com', '+77010000003', '2026-09-03'),
    (4, 'Anna', 'anna@example.com', '+77010000004', '2026-09-04'),
    (5, 'Timur', 'timur@example.com', '+77010000005', '2026-09-05');

INSERT INTO products (
    product_id, name, description, price, stock_quantity
)
VALUES
    (1, 'Keyboard', 'Mechanical keyboard', 25000.00, 20),
    (2, 'Mouse', 'Wireless mouse', 12000.00, 35),
    (3, 'Monitor', '24-inch monitor', 80000.00, 10),
    (4, 'Headphones', 'Gaming headphones', 18000.00, 25),
    (5, 'USB Cable', 'USB-C cable', 3000.00, 100);

INSERT INTO orders (
    order_id, customer_id, order_date, total_amount, status
)
VALUES
    (1, 1, '2026-10-01', 25000.00, 'pending'),
    (2, 2, '2026-10-02', 24000.00, 'processing'),
    (3, 3, '2026-10-03', 80000.00, 'shipped'),
    (4, 4, '2026-10-04', 18000.00, 'delivered'),
    (5, 5, '2026-10-05', 9000.00, 'cancelled');

INSERT INTO order_details (
    order_detail_id, order_id, product_id, quantity, unit_price
)
VALUES
    (1, 1, 1, 1, 25000.00),
    (2, 2, 2, 2, 12000.00),
    (3, 3, 3, 1, 80000.00),
    (4, 4, 4, 1, 18000.00),
    (5, 5, 5, 3, 3000.00);

INSERT INTO customers (customer_id, name, email)
VALUES (1, 'Duplicate', 'duplicate@example.com');
--error already exist
INSERT INTO products (product_id, name, price, stock_quantity)
VALUES (1, 'Duplicate Product', 1000, 10);
--already exist in products
INSERT INTO orders (order_id, customer_id, total_amount)
VALUES (1, 1, 1000);
--err order_id 1 already in table
INSERT INTO customers (customer_id, name, email)
VALUES (NULL, 'Test', 'null-id@example.com');
--err customer id not null because it is a primary key
INSERT INTO products (product_id, name, price, stock_quantity)
VALUES (6, 'Invalid Product', -100, 10);
--err price negative
INSERT INTO products (product_id, name, price, stock_quantity)
VALUES (6, 'Invalid Product', 100, -1);
--err negative stock
INSERT INTO orders (order_id, customer_id, total_amount, status)
VALUES (6, 1, 1000, 'unknown');
--err invalid order status
INSERT INTO order_details (
    order_detail_id, order_id, product_id, quantity, unit_price
)
VALUES (6, 1, 1, 0, 25000);
--err non positive quantity
INSERT INTO order_details (
    order_detail_id, order_id, product_id, quantity, unit_price
)
VALUES (6, 1, 1, 1, -100);
--err negative unit price
INSERT INTO orders (order_id, customer_id, total_amount)
VALUES (6, 1, -100);
--err negative total amount
INSERT INTO orders (order_id, customer_id, total_amount)
VALUES (6, 999, 1000);
--no such customer id
INSERT INTO order_details (
    order_detail_id, order_id, product_id, quantity, unit_price
)
VALUES (6, 999, 1, 1, 25000);
--err no such order_id
DELETE FROM customers
WHERE customer_id = 1;
--err violates restrict
DELETE FROM products
WHERE product_id = 1;
--error violates restrict in products
BEGIN;

SELECT * FROM order_details
WHERE order_id = 1;

DELETE FROM orders
WHERE order_id = 1;

SELECT * FROM orders
WHERE order_id = 1;

SELECT * FROM order_details
WHERE order_id = 1;

SELECT * FROM products
WHERE product_id = 1;

ROLLBACK;

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details;