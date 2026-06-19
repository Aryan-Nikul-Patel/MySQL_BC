-- ============================================================
-- 🛠️ MODULE 07: Advanced Query Patterns — Setup Script
-- Database: sql_course_m7
-- ============================================================

CREATE DATABASE IF NOT EXISTS sql_course_m7;
USE sql_course_m7;

-- 1. Drop existing tables if they exist
DROP TABLE IF EXISTS exam_scores;
DROP TABLE IF EXISTS user_events;
DROP TABLE IF EXISTS user_profiles;

-- 2. Create tables
CREATE TABLE user_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    bio TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_time DATETIME NOT NULL,
    device VARCHAR(20) NOT NULL
);

CREATE TABLE exam_scores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student VARCHAR(50) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    score INT NOT NULL,
    grade_date DATE NOT NULL
);

-- 3. Populate user_profiles (10 rows)
INSERT INTO user_profiles (id, username, email, full_name, bio, created_at) VALUES
(1, 'alice_w', 'alice.wonderland@google.com', 'Alice Wonderland', 'Software engineer who loves solving complex SQL queries! code-ninja.', '2025-01-15 08:30:00'),
(2, 'bob_builder', 'bob.builder@outlook.com', 'Bob The Builder', 'Can we fix it? Yes we can! Handyman & DBMS lover.', '2025-02-20 14:15:22'),
(3, 'charlie_chocolate', 'charlie.c@wonka.net', 'Charlie Bucket', 'Candy enthusiast. Always looking for the Golden Ticket of databases.', '2025-03-05 10:00:00'),
(4, 'david_g', 'david.goliath@meta.com', 'David Goliath', 'Data scientist. I take down giant data pipelines with simple queries.', '2025-04-12 18:45:00'),
(5, 'eve_spy', 'eve.secret@protonmail.com', 'Eve Hacker', 'Security engineer. My bio has special patterns: user_id=9999 & secret_key.', '2025-05-18 23:59:59'),
(6, 'frank_castle', 'punisher@netflix.com', 'Frank Castle', 'Unforgiving SQL performance tuner. I punish slow queries.', '2025-06-01 06:00:00'),
(7, 'grace_hopper', 'grace.cobol@navy.mil', 'Grace Hopper', 'Pioneering computer scientist. Debugging moths since 1947.', '2025-01-01 00:00:00'),
(8, 'homer_s', 'homer.simpson@nuclear.com', 'Homer Simpson', 'Safety Inspector. D\'oh! Forgot my SQL password again.', '2025-08-25 16:33:12'),
(9, 'irene_adler', 'the_woman@london.co.uk', 'Irene Adler', 'The ultimate master of disguise and regex puzzles.', '2025-09-10 11:11:11'),
(10, 'john_doe', 'john.doe@gmail.com', 'John Doe', '   Just a regular guy with spaces in his bio   ', '2025-10-01 12:00:00');

-- 4. Populate user_events (40 rows)
INSERT INTO user_events (user_id, event_type, event_time, device) VALUES
(1, 'login', '2026-03-01 08:31:00', 'desktop'),
(1, 'search', '2026-03-01 08:35:12', 'desktop'),
(1, 'click', '2026-03-01 08:36:00', 'desktop'),
(1, 'purchase', '2026-03-01 08:45:30', 'desktop'),
(1, 'logout', '2026-03-01 09:00:00', 'desktop'),
(2, 'login', '2026-03-01 14:20:00', 'mobile'),
(2, 'search', '2026-03-01 14:25:00', 'mobile'),
(2, 'logout', '2026-03-01 14:30:00', 'mobile'),
(3, 'login', '2026-03-01 10:15:00', 'tablet'),
(3, 'click', '2026-03-01 10:20:00', 'tablet'),
(4, 'login', '2026-03-01 19:00:00', 'desktop'),
(4, 'purchase', '2026-03-01 19:15:00', 'desktop'),
(1, 'login', '2026-03-02 08:30:00', 'desktop'),
(1, 'search', '2026-03-02 08:32:00', 'desktop'),
(1, 'logout', '2026-03-02 08:45:00', 'desktop'),
(2, 'login', '2026-03-02 15:00:00', 'mobile'),
(2, 'click', '2026-03-02 15:10:00', 'mobile'),
(5, 'login', '2026-03-02 23:00:00', 'desktop'),
(5, 'click', '2026-03-02 23:15:00', 'desktop'),
(5, 'logout', '2026-03-02 23:45:00', 'desktop'),
(1, 'login', '2026-03-03 08:15:00', 'desktop'),
(1, 'click', '2026-03-03 08:18:00', 'desktop'),
(1, 'purchase', '2026-03-03 08:22:00', 'desktop'),
(3, 'login', '2026-03-03 11:00:00', 'tablet'),
(3, 'search', '2026-03-03 11:15:00', 'tablet'),
(3, 'logout', '2026-03-03 11:30:00', 'tablet'),
(4, 'login', '2026-03-04 18:00:00', 'desktop'),
(4, 'click', '2026-03-04 18:10:00', 'desktop'),
(4, 'purchase', '2026-03-04 18:25:00', 'desktop'),
(6, 'login', '2026-03-05 07:00:00', 'desktop'),
(6, 'click', '2026-03-05 07:15:00', 'desktop'),
(6, 'logout', '2026-03-05 07:30:00', 'desktop'),
(2, 'login', '2026-03-05 16:00:00', 'mobile'),
(2, 'search', '2026-03-05 16:12:00', 'mobile'),
(7, 'login', '2026-03-06 09:00:00', 'desktop'),
(7, 'click', '2026-03-06 09:30:00', 'desktop'),
(8, 'login', '2026-03-06 17:00:00', 'mobile'),
(8, 'click', '2026-03-06 17:05:00', 'mobile'),
(9, 'login', '2026-03-06 12:00:00', 'tablet'),
(9, 'logout', '2026-03-06 12:15:00', 'tablet');

-- 5. Populate exam_scores (30 rows)
INSERT INTO exam_scores (student, subject, score, grade_date) VALUES
('Alice', 'Mathematics', 95, '2026-01-15'),
('Alice', 'Science', 88, '2026-01-20'),
('Alice', 'History', 92, '2026-02-10'),
('Bob', 'Mathematics', 78, '2026-01-15'),
('Bob', 'Science', 82, '2026-01-20'),
('Bob', 'History', 65, '2026-02-10'),
('Charlie', 'Mathematics', 85, '2026-01-15'),
('Charlie', 'Science', 90, '2026-01-20'),
('Charlie', 'History', 88, '2026-02-10'),
('David', 'Mathematics', 92, '2026-01-15'),
('David', 'Science', 95, '2026-01-20'),
('David', 'History', 97, '2026-02-10'),
('Eve', 'Mathematics', 60, '2026-01-15'),
('Eve', 'Science', 72, '2026-01-20'),
('Eve', 'History', 80, '2026-02-10'),
('Frank', 'Mathematics', 45, '2026-01-15'),
('Frank', 'Science', 58, '2026-01-20'),
('Frank', 'History', 55, '2026-02-10'),
('Grace', 'Mathematics', 100, '2026-01-15'),
('Grace', 'Science', 99, '2026-01-20'),
('Grace', 'History', 98, '2026-02-10'),
('Homer', 'Mathematics', 32, '2026-01-15'),
('Homer', 'Science', 40, '2026-01-20'),
('Homer', 'History', 50, '2026-02-10'),
('Irene', 'Mathematics', 89, '2026-01-15'),
('Irene', 'Science', 92, '2026-01-20'),
('Irene', 'History', 94, '2026-02-10'),
('John', 'Mathematics', 75, '2026-01-15'),
('John', 'Science', 76, '2026-01-20'),
('John', 'History', 82, '2026-02-10');
