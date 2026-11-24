-- ============================================================
-- Laboratory Work 9: Stored Procedures and User-Defined Functions
-- Part 1: Database Setup  (CityBike rental network)
-- ============================================================

DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

-- Create table: stations
CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

-- Create table: bikes
CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

-- Create table: rentals
CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);



SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes) AS bikes,
       (SELECT COUNT(*) FROM members) AS members,
       (SELECT COUNT(*) FROM rentals) AS rentals;


CREATE OR REPLACE FUNCTION inc(val INTEGER) RETURNS INTEGER AS $$
DECLARE
    result INTEGER;
BEGIN
    result := val + 1;
    RETURN result;
END; $$
    LANGUAGE plpgsql;
SELECT inc(10); -- 11

create or replace function dex(num numeric) returns numeric as
    $$
    declare result numeric;
    begin result =  num+1;
    return result;
    end;
    $$
language plpgsql;
select dex(40);

--2.1

create function rental_days(id int) returns int as
    $$
    declare days int;
    begin
        select r.end_date- r.start_date
        into days
        from rentals r
        where r.rental_id = id;
        return days;
    end;
    $$
language plpgsql;

SELECT rental_days(2);    -- 5
SELECT rental_days(11);   -- 8
SELECT rental_days(19);   -- NULL
SELECT rental_days(999);  -- NULL

--2.2

create function member_rental_count(member int) returns int as
    $$
    declare days int;
    begin
        return(select count(r.member_id)
               from rentals r
               where r.member_id= member
        );
    end;
    $$
language plpgsql;
SELECT member_rental_count(1);   -- 5
SELECT member_rental_count(5);   -- 4
SELECT member_rental_count(6);   -- 0
SELECT member_rental_count(99);  -- 0

--2.3

create function station_city(station int) returns varchar as
    $$
    begin return(
        select s.city
        from stations s
        where s.station_id= station
        );
    end;
    $$
language plpgsql;
SELECT station_city(30);  -- Astana
SELECT station_city(77);  -- NULL

--2.4

select r.rental_id, r.member_id, rental_days(r.rental_id) as days
from rentals r
where rental_days(r.rental_id)>4
order by days desc , r.rental_id;

--3.1
drop function fee_with_discount;
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
    RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$;

SELECT fee_with_discount(74.00, 15);  -- 62.90

--3.2

CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT, OUT rental_cnt INT,
    OUT total_fee NUMERIC, OUT last_start DATE
)
    LANGUAGE plpgsql AS $$
    begin
        select count(*)::INT , coalesce(sum(r.fee),0), max(r.start_date)
        into rental_cnt, total_fee, last_start
        from rentals r where r.member_id= p_member_id;
    end;
    $$

SELECT member_stats(3);          -- (5,164.75,2025-06-01)
SELECT * FROM member_stats(3);   -- 5 | 164.75 | 2025-06-01
SELECT * FROM member_stats(6);   -- 0 | 0 | NULL

--3.3

create function apply_late_fee(inout p_free numeric) as $$
    begin
        p_free= p_free+5.00;
    end;
    $$
language plpgsql;

SELECT apply_late_fee(r.fee)
FROM rentals AS r WHERE r.rental_id = 1;  -- 18.50

-- 3.4
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC, OUT average NUMERIC, OUT largest NUMERIC
)
    LANGUAGE plpgsql AS $$
BEGIN
    SELECT SUM(p_fees[g.i]), ROUND(AVG(p_fees[g.i]), 2), MAX(p_fees[g.i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$;


SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
-- 98.50 | 24.63 | 35.00

-- SELECT * FROM fee_summary();   -- error no arguments
SELECT * FROM fee_summary(VARIADIC ARRAY[]::NUMERIC[]);
-- NULL | NULL | NULL

-- 4.1
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
    RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(r.fee), 0)
        FROM rentals AS r
        WHERE r.member_id = p_member_id
    );
END;
$$;

SELECT total_fees(1);  -- 98.50
SELECT total_fees(6);  -- 0

-- 4.2
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
    RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(r.fee), 0)
        FROM rentals AS r
        WHERE r.member_id = p_member_id AND r.start_date >= p_from_date
    );
END;
$$;

SELECT total_fees(1, DATE '2024-01-01');  -- 98.50
SELECT total_fees(1, DATE '2025-01-01');  -- 50.00


SELECT p.oid::regprocedure AS signature
FROM pg_proc AS p
         JOIN pg_namespace AS n ON n.oid = p.pronamespace
WHERE p.proname = 'total_fees' AND n.nspname = current_schema()
ORDER BY p.pronargs;
-- total_fees(integer)
-- total_fees(integer,date)

-- 4.3
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT, p_from_date DATE DEFAULT DATE '2025-01-01'
)
    RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(r.fee), 0)
        FROM rentals AS r
        WHERE r.member_id = p_member_id AND r.start_date >= p_from_date
    );
END;
$$;

-- SELECT total_fees(1);

-- 4.4
DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1);  -- 50.00

-- 4.5
CREATE OR REPLACE FUNCTION total_fees(p_full_name VARCHAR)
    RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(r.fee), 0)
        FROM members AS m
                 JOIN rentals AS r ON r.member_id = m.member_id
        WHERE m.full_name = p_full_name
    );
END;
$$;

SELECT total_fees('Aisha Nurlanova');  -- 98.50
SELECT total_fees(1);                 -- 50.00


-- 5.1
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
    RETURNS TABLE (found_id INT, found_model VARCHAR, found_rate NUMERIC)
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT b.bike_id, b.model, b.daily_rate
        FROM bikes AS b
        WHERE b.model ILIKE p_pattern
        ORDER BY b.bike_id;
END;
$$;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');

-- 5.2
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
    RETURNS TABLE (
                      rental_id INT, bike_model VARCHAR, station_name VARCHAR,
                      days INT, fee NUMERIC
                  )
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT r.rental_id, b.model, s.station_name,
               r.end_date - r.start_date, r.fee
        FROM rentals AS r
                 LEFT JOIN bikes AS b ON b.bike_id = r.bike_id
                 LEFT JOIN stations AS s ON s.station_id = b.station_id
        WHERE r.member_id = p_member_id
        ORDER BY r.start_date, r.rental_id;
END;
$$;

SELECT * FROM member_history(3);

-- 5.3:
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
    RETURNS TABLE (bike_id INT, model VARCHAR)
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END;
$$;

-- SELECT * FROM bike_list(10);

-- 5.3: 1
DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
    RETURNS TABLE (found_id INT, found_model VARCHAR)
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END;
$$;

SELECT * FROM bike_list(10);

--5.3: 2
DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
    RETURNS TABLE (bike_id INT, model VARCHAR)
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT b.bike_id, b.model FROM bikes AS b
        WHERE b.station_id = p_station_id;
END;
$$;

SELECT * FROM bike_list(10);

-- 5.4
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
    RETURNS TABLE (s_name VARCHAR, s_bikes INT, s_free INT)
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT s.station_name, COUNT(b.bike_id)::INT,
               s.capacity - COUNT(b.bike_id)::INT
        FROM stations AS s
                 LEFT JOIN bikes AS b ON b.station_id = s.station_id
        WHERE s.city = p_city
        GROUP BY s.station_id, s.station_name, s.capacity
        ORDER BY s.station_id;
END;
$$;

SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');

-- 6.1
DO $$
    <<rental_report>>
        DECLARE
        total_rentals INT := 0;
    BEGIN
        SELECT COUNT(*)::INT INTO total_rentals FROM rentals;
        RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
    END rental_report;
$$;

-- 6.2
DO $$
    <<rental_report>>
        DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(r.fee) INTO fee_total FROM rentals AS r;
        RAISE NOTICE 'Outer before: %', fee_total;

        DECLARE
            fee_total NUMERIC;
        BEGIN
            SELECT SUM(r.fee) INTO fee_total
            FROM rentals AS r WHERE r.start_date >= DATE '2025-01-01';
            RAISE NOTICE 'Inner: %', fee_total;
            RAISE NOTICE 'Outer from inside: %', rental_report.fee_total;
        END;

        RAISE NOTICE 'Outer after: %', fee_total;
    END rental_report;
$$;


-- 6.3:
DO $$
    DECLARE
        v_shared INT := 10;
    BEGIN
        BEGIN
            RAISE NOTICE 'First: %', v_shared;
        END;
        BEGIN
            RAISE NOTICE 'Second: %', v_shared;
        END;
    END;
$$;

-- 6.4
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE, OUT before_total NUMERIC, OUT after_total NUMERIC
)
    LANGUAGE plpgsql AS $$
BEGIN
    SELECT COALESCE(SUM(r.fee) FILTER (WHERE r.start_date < p_from_date), 0),
           COALESCE(SUM(r.fee) FILTER (WHERE r.start_date >= p_from_date), 0)
    INTO before_total, after_total
    FROM rentals AS r;
END;
$$;

SELECT * FROM fee_split(DATE '2025-01-01');

SELECT f.before_total + f.after_total AS split_total,
       (SELECT SUM(r.fee) FROM rentals AS r) AS table_total
FROM fee_split(DATE '2025-01-01') AS f;

-- 7.1
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT, OUT bikes_parked INT, OUT capacity_pct NUMERIC
)
    LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(b.bike_id)::INT,
           ROUND(100.0 * COUNT(b.bike_id) / NULLIF(s.capacity, 0), 1)
    INTO bikes_parked, capacity_pct
    FROM stations AS s
             LEFT JOIN bikes AS b ON b.station_id = s.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.station_id, s.capacity;
END;
$$;

SELECT s.station_id, s.station_name, l.*
FROM stations AS s
         CROSS JOIN LATERAL station_load(s.station_id) AS l
ORDER BY s.station_id;

-- 7.2
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
    RETURNS TABLE (member_name VARCHAR, rental_cnt INT, total_spent NUMERIC)
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT m.full_name, COUNT(r.rental_id)::INT, COALESCE(SUM(r.fee), 0)
        FROM members AS m
                 LEFT JOIN rentals AS r ON r.member_id = m.member_id
        GROUP BY m.member_id, m.full_name
        ORDER BY COALESCE(SUM(r.fee), 0) DESC, m.member_id
        LIMIT p_limit;
END;
$$;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- 7.3
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
    RETURNS TABLE (
                      member_name VARCHAR, bike_model VARCHAR,
                      days INT, amount_owed NUMERIC, status TEXT
                  )
    LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
        SELECT m.full_name, b.model,
               COALESCE(r.end_date, CURRENT_DATE) - r.start_date,
               ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate, 2),
               CASE WHEN r.end_date IS NULL THEN 'OPEN' ELSE 'CLOSED' END
        FROM rentals AS r
                 LEFT JOIN members AS m ON m.member_id = r.member_id
                 LEFT JOIN bikes AS b ON b.bike_id = r.bike_id
        WHERE r.rental_id = p_rental_id;
END;
$$;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- 7.4:
CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR, OUT member_cnt INT, OUT rental_cnt INT, OUT revenue NUMERIC
)
    LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT, COALESCE(SUM(r.fee), 0)
    INTO member_cnt, rental_cnt, revenue
    FROM members AS m
             LEFT JOIN rentals AS r ON r.member_id = m.member_id
    WHERE m.city = p_city;
END;
$$;

-- 7.4:
CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR, p_from_date DATE,
    OUT member_cnt INT, OUT rental_cnt INT, OUT revenue NUMERIC
)
    LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT, COALESCE(SUM(r.fee), 0)
    INTO member_cnt, rental_cnt, revenue
    FROM members AS m
             LEFT JOIN rentals AS r
                       ON r.member_id = m.member_id AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$;

SELECT * FROM city_report('Almaty');                     -- 3 | 9 | 236.50
SELECT * FROM city_report('Almaty', DATE '2025-01-01');  -- 3 | 5 | 135.50


SELECT COUNT(DISTINCT m.member_id)::INT AS member_cnt,
       COUNT(r.rental_id)::INT AS rental_cnt,
       COALESCE(SUM(r.fee), 0) AS revenue
FROM members AS m
         LEFT JOIN rentals AS r ON r.member_id = m.member_id
WHERE m.city = 'Almaty' AND r.start_date >= DATE '2025-01-01';
-- 2 | 5 | 135.50