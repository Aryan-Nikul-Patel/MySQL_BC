-- ============================================================
-- 🛠️ MODULE 08: Interview Problem Patterns — Setup Script
-- Database: sql_course_m8
-- ============================================================

CREATE DATABASE IF NOT EXISTS sql_course_m8;
USE sql_course_m8;

-- 1. Drop existing tables if they exist
DROP TABLE IF EXISTS friendships;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS employee_salaries;
DROP TABLE IF EXISTS logins;
DROP TABLE IF EXISTS scores;

-- 2. Create tables
CREATE TABLE logins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    login_date DATE NOT NULL
);

CREATE TABLE employee_salaries (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    txn_date DATE NOT NULL,
    txn_type VARCHAR(20) NOT NULL
);

CREATE TABLE contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE friendships (
    user_id_1 INT NOT NULL,
    user_id_2 INT NOT NULL,
    PRIMARY KEY (user_id_1, user_id_2)
);

CREATE TABLE scores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student VARCHAR(50) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    score INT NOT NULL
);

-- 3. Populate logins (50 rows)
-- User 1: 5-day consecutive streak (March 1 to March 5)
-- User 2: 3-day consecutive streak (March 1 to March 3), gap, 2-day consecutive streak (March 5 to March 6)
-- User 3: login with gaps (March 1, 3, 5, 7)
-- User 4: 4-day streak (March 2 to March 5)
-- User 5: single login (March 10)
INSERT INTO logins (user_id, login_date) VALUES
(1, '2026-03-01'), (1, '2026-03-02'), (1, '2026-03-03'), (1, '2026-03-04'), (1, '2026-03-05'),
(2, '2026-03-01'), (2, '2026-03-02'), (2, '2026-03-03'), (2, '2026-03-05'), (2, '2026-03-06'),
(3, '2026-03-01'), (3, '2026-03-03'), (3, '2026-03-05'), (3, '2026-03-07'),
(4, '2026-03-02'), (4, '2026-03-03'), (4, '2026-03-04'), (4, '2026-03-05'),
(5, '2026-03-10'),
-- Duplicate login rows on the same day for testing robustness (e.g. user logging in multiple times on same day)
(1, '2026-03-01'),
(1, '2026-03-03'),
(2, '2026-03-02'),
(4, '2026-03-03'),
-- More logins to fill count
(6, '2026-03-01'), (6, '2026-03-02'), (6, '2026-03-03'),
(7, '2026-03-10'), (7, '2026-03-11'), (7, '2026-03-12'), (7, '2026-03-13'),
(8, '2026-03-15'), (8, '2026-03-17'), (8, '2026-03-18'), (8, '2026-03-19'),
(9, '2026-03-01'), (9, '2026-03-02'), (9, '2026-03-04'), (9, '2026-03-05'), (9, '2026-03-06'),
(10, '2026-03-20'), (10, '2026-03-21'), (10, '2026-03-22');

-- 4. Populate employee_salaries (15 rows)
-- Contains duplicates, ties, and different departments.
INSERT INTO employee_salaries (id, name, department, salary) VALUES
(1, 'Alice', 'Engineering', 120000.00),
(2, 'Bob', 'Engineering', 110000.00),
(3, 'Charlie', 'Engineering', 120000.00),  -- Tie for 1st
(4, 'David', 'Engineering', 95000.00),
(5, 'Eve', 'Engineering', 90000.00),
(6, 'Frank', 'Marketing', 90000.00),
(7, 'Grace', 'Marketing', 90000.00),      -- Tie for 1st
(8, 'Homer', 'Marketing', 75000.00),
(9, 'Irene', 'Marketing', 60000.00),
(10, 'John', 'Sales', 100000.00),
(11, 'Kate', 'Sales', 95000.00),
(12, 'Leo', 'Sales', 95000.00),           -- Tie for 2nd
(13, 'Mona', 'Sales', 80000.00),
(14, 'Ned', 'Sales', 70000.00),
(15, 'Oliver', 'Engineering', 110000.00);  -- Tie for 3rd

-- 5. Populate transactions (40 rows)
INSERT INTO transactions (id, user_id, amount, txn_date, txn_type) VALUES
(1, 1, 100.00, '2026-01-05', 'deposit'),
(2, 1, -20.00, '2026-01-10', 'withdrawal'),
(3, 1, 50.00, '2026-01-15', 'deposit'),
(4, 2, 500.00, '2026-01-05', 'deposit'),
(5, 2, -100.00, '2026-01-07', 'withdrawal'),
(6, 2, -50.00, '2026-01-12', 'withdrawal'),
(7, 1, 200.00, '2026-02-01', 'deposit'),
(8, 1, -30.00, '2026-02-05', 'withdrawal'),
(9, 2, 150.00, '2026-02-10', 'deposit'),
(10, 3, 1000.00, '2026-02-15', 'deposit'),
(11, 3, -200.00, '2026-02-20', 'withdrawal'),
(12, 1, 300.00, '2026-03-01', 'deposit'),
(13, 2, 400.00, '2026-03-05', 'deposit'),
(14, 3, -150.00, '2026-03-10', 'withdrawal'),
(15, 4, 250.00, '2026-03-12', 'deposit'),
-- Let's add more transactions for monthly aggregated YoY / MoM tests
(16, 1, 150.00, '2026-01-20', 'deposit'),
(17, 2, 300.00, '2026-01-25', 'deposit'),
(18, 1, 250.00, '2026-02-15', 'deposit'),
(19, 2, 100.00, '2026-02-22', 'deposit'),
(20, 3, 500.00, '2026-03-02', 'deposit'),
(21, 4, 300.00, '2026-03-18', 'deposit'),
(22, 1, 500.00, '2025-01-05', 'deposit'), -- Previous Year (2025)
(23, 1, 200.00, '2025-02-10', 'deposit'),
(24, 2, 800.00, '2025-01-15', 'deposit'),
(25, 2, 300.00, '2025-02-20', 'deposit'),
(26, 3, 1200.00, '2025-02-18', 'deposit'),
(27, 1, 600.00, '2025-03-05', 'deposit'),
(28, 2, 450.00, '2025-03-12', 'deposit'),
(29, 3, 350.00, '2025-03-22', 'deposit'),
(30, 4, 600.00, '2026-03-25', 'deposit'),
(31, 5, 100.00, '2026-03-01', 'deposit'),
(32, 5, 150.00, '2026-03-05', 'deposit'),
(33, 5, -50.00, '2026-03-10', 'withdrawal'),
(34, 6, 200.00, '2026-03-15', 'deposit'),
(35, 6, -30.00, '2026-03-20', 'withdrawal'),
(36, 7, 500.00, '2026-03-02', 'deposit'),
(37, 7, -100.00, '2026-03-08', 'withdrawal'),
(38, 8, 400.00, '2026-03-11', 'deposit'),
(39, 9, 300.00, '2026-03-15', 'deposit'),
(40, 10, 600.00, '2026-03-18', 'deposit');

-- 6. Populate contacts (12 rows, contains duplicates on email or phone)
INSERT INTO contacts (id, name, email, phone) VALUES
(1, 'Alice Smith', 'alice@gmail.com', '123-456-7890'),
(2, 'Bob Miller', 'bob@gmail.com', '987-654-3210'),
(3, 'Charlie Brown', 'charlie@wonka.com', '555-555-5555'),
(4, 'Alice Jones', 'alice@gmail.com', '111-222-3333'),      -- Duplicate email with Alice Smith
(5, 'Robert Miller', 'bob@gmail.com', '987-654-3210'),     -- Duplicate email and phone with Bob Miller
(6, 'Eva Green', 'eva@green.com', '222-333-4444'),
(7, 'Eva Marie', 'eva@green.com', '222-333-4444'),         -- Duplicate email and phone with Eva Green
(8, 'Frank Castle', 'punisher@netflix.com', '911-911-9111'),
(9, 'Grace Hopper', 'grace@navy.mil', '123-456-7890'),      -- Duplicate phone with Alice Smith
(10, 'Homer Simpson', 'homer@nuclear.com', '444-555-6666'),
(11, 'Homer Simpson', 'homer@nuclear.com', '444-555-6666'), -- Exact duplicate
(12, 'Irene Adler', 'irene@sherlock.com', '777-777-7777');

-- 7. Populate friendships (15 rows)
-- Denotes mutual friendships. Ensure friendships are entered as bidirectionally mapped in queries,
-- but the table might store them in one direction.
-- User 1 is friends with 2, 3, 4
-- User 2 is friends with 1, 3
-- User 3 is friends with 1, 2, 4
-- User 4 is friends with 1, 3, 5
-- User 5 is friends with 4
INSERT INTO friendships (user_id_1, user_id_2) VALUES
(1, 2),
(1, 3),
(1, 4),
(2, 3),
(3, 4),
(4, 5),
-- Standardizing: user_id_1 < user_id_2 in storage
(6, 7),
(6, 8),
(7, 8),
(8, 9),
(9, 10),
(1, 6),
(2, 6),
(3, 6),
(4, 6);

-- 8. Populate scores (20 rows)
INSERT INTO scores (student, subject, score) VALUES
('Alice', 'Math', 90), ('Alice', 'Science', 85), ('Alice', 'History', 95),
('Bob', 'Math', 80), ('Bob', 'Science', 75), ('Bob', 'History', 70),
('Charlie', 'Math', 85), ('Charlie', 'Science', 90), ('Charlie', 'History', 88),
('David', 'Math', 95), ('David', 'Science', 95), ('David', 'History', 100),
('Eve', 'Math', 60), ('Eve', 'Science', 65), ('Eve', 'History', 70),
('Frank', 'Math', 50), ('Frank', 'Science', 55),
('Grace', 'Math', 100), ('Grace', 'Science', 90);
