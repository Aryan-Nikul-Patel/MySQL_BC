-- ============================================================
-- 📘 MODULE 01 — Lesson 4: Filtering & Sorting
-- ============================================================
--
-- 🎯 What you'll learn:
--    - WHERE clause — filter rows
--    - Comparison operators, AND/OR/NOT                
--    - IN, BETWEEN, LIKE, IS NULL
--    - ORDER BY — sort results
--    - LIMIT / OFFSET — paginate results
--    - DISTINCT — remove duplicates
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m1;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: WHERE — Filtering rows
-- ────────────────────────────────────────────
-- WHERE filters which rows come back. Only rows where the
-- condition is TRUE are returned.

-- ▶ Basic comparison operators:
SELECT first_name, last_name, salary FROM employees WHERE salary > 90000;
-- 💬 Returns employees earning more than 90,000

SELECT first_name, last_name, age FROM employees WHERE age = 29;
-- 💬 Exact match with =

SELECT first_name, last_name, dept_id FROM employees WHERE dept_id != 1;
-- 💬 != means "not equal to". You can also write <> instead of !=


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: AND, OR, NOT — Combining conditions
-- ────────────────────────────────────────────

-- ▶ AND — BOTH conditions must be true:
SELECT first_name, last_name, salary, dept_id
FROM employees
WHERE dept_id = 1 AND salary > 90000;
-- 💬 Must be in Engineering AND earning > 90k

-- ▶ OR — at least ONE condition must be true:
SELECT first_name, last_name, dept_id
FROM employees
WHERE dept_id = 1 OR dept_id = 2;
-- 💬 Either Engineering or Marketing

-- ▶ NOT — flips the condition:
SELECT first_name, last_name, is_active
FROM employees
WHERE NOT is_active;
-- 💬 Returns only inactive employees (is_active = FALSE)

-- ▶ Combining AND + OR — use parentheses to be explicit!
SELECT first_name, last_name, salary, dept_id, is_active
FROM employees
WHERE (dept_id = 1 OR dept_id = 3) AND salary > 80000;
-- 💬 Engineering or Sales, AND earning more than 80k
-- ⚠️ Without parentheses, AND has higher priority than OR — can give wrong results!


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: IN — Match against a list
-- ────────────────────────────────────────────
-- IN is a cleaner alternative to writing many OR conditions.

-- ▶ Without IN (messy):
SELECT first_name, dept_id FROM employees
WHERE dept_id = 1 OR dept_id = 2 OR dept_id = 5;

-- ▶ With IN (clean and identical result):
SELECT first_name, dept_id FROM employees
WHERE dept_id IN (1, 2, 5);

-- ▶ NOT IN — exclude a list:
SELECT first_name, dept_id FROM employees
WHERE dept_id NOT IN (1, 2);
-- 💬 Everyone NOT in Engineering or Marketing


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: BETWEEN — Range check
-- ────────────────────────────────────────────
-- BETWEEN is inclusive on both ends (>= AND <=)

-- ▶ Salary between 70k and 100k:
SELECT first_name, last_name, salary FROM employees
WHERE salary BETWEEN 70000 AND 100000;
-- 💬 Includes 70000 and 100000 themselves

-- ▶ NOT BETWEEN:
SELECT first_name, last_name, salary FROM employees
WHERE salary NOT BETWEEN 70000 AND 100000;
-- 💬 Below 70k OR above 100k

-- ▶ BETWEEN also works with dates:
SELECT first_name, hire_date FROM employees
WHERE hire_date BETWEEN '2020-01-01' AND '2022-12-31';
-- 💬 Everyone hired in 2020, 2021, or 2022


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: LIKE — Pattern matching
-- ────────────────────────────────────────────
-- % matches ZERO or more characters
-- _ matches EXACTLY one character

-- ▶ Names starting with 'A':
SELECT first_name FROM employees WHERE first_name LIKE 'A%';

-- ▶ Names ending with 'n':
SELECT first_name FROM employees WHERE first_name LIKE '%n';

-- ▶ Names containing 'ar' anywhere:
SELECT first_name FROM employees WHERE first_name LIKE '%ar%';

-- ▶ Exactly 3 characters using _ (one _ = one char):
SELECT first_name FROM employees WHERE first_name LIKE '___';
-- 💬 Matches names that are exactly 3 characters: 'Mia', 'Leo', 'Eva', 'Bob'

-- ▶ Emails from a specific domain:
SELECT first_name, email FROM employees WHERE email LIKE '%@corp.com';

-- ▶ NOT LIKE:
SELECT first_name, email FROM employees WHERE email NOT LIKE '%corp%';
-- 💬 Returns nothing here since all are @corp.com — just showing the syntax


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: IS NULL / IS NOT NULL
-- ────────────────────────────────────────────
-- NULL means "no value / unknown". It is NOT the same as 0 or empty string.
-- You CANNOT use = NULL. You must use IS NULL.

-- ▶ Our employees all have a dept_id. Let's insert one without:
INSERT INTO employees (first_name, last_name, email, age, salary, dept_id, hire_date)
VALUES ('Temp', 'Contractor', 'temp@external.com', 30, 50000, NULL, '2024-06-01');

-- ▶ Find employees with no department:
SELECT first_name, dept_id FROM employees WHERE dept_id IS NULL;

-- ▶ Find employees WITH a department:
SELECT first_name, dept_id FROM employees WHERE dept_id IS NOT NULL;

-- ⚠️ This is WRONG — always returns 0 rows even if NULLs exist:
-- SELECT * FROM employees WHERE dept_id = NULL;   ← NEVER DO THIS

-- Clean up:
DELETE FROM employees WHERE email = 'temp@external.com';


-- ────────────────────────────────────────────
-- 📌 CONCEPT 7: ORDER BY — Sorting results
-- ────────────────────────────────────────────

-- ▶ Sort by salary, lowest first (ASC = ascending, default):
SELECT first_name, last_name, salary FROM employees ORDER BY salary ASC;

-- ▶ Sort by salary, highest first (DESC = descending):
SELECT first_name, last_name, salary FROM employees ORDER BY salary DESC;

-- ▶ Sort by multiple columns:
SELECT first_name, dept_id, salary FROM employees
ORDER BY dept_id ASC, salary DESC;
-- 💬 First sorts by department, then within each department by salary (highest first)

-- ▶ Sort using column alias:
SELECT first_name, salary / 12 AS monthly_salary
FROM employees
ORDER BY monthly_salary DESC;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 8: LIMIT & OFFSET — Pagination
-- ────────────────────────────────────────────

-- ▶ Get top 5 highest paid:
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 5;

-- ▶ Pagination — OFFSET skips rows:
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 5 OFFSET 0;  -- Page 1
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 5 OFFSET 5;  -- Page 2
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 5 OFFSET 10; -- Page 3

-- 💬 Think of OFFSET as "skip N rows before starting"


-- ────────────────────────────────────────────
-- 📌 CONCEPT 9: Putting it all together
-- ────────────────────────────────────────────
-- A real-world query combining multiple concepts:

SELECT
    first_name,
    last_name,
    salary,
    hire_date,
    dept_id
FROM employees
WHERE
    dept_id IN (1, 3)             -- Engineering or Sales
    AND salary > 75000            -- earning more than 75k
    AND is_active = TRUE          -- currently active
    AND hire_date >= '2020-01-01' -- hired in or after 2020
ORDER BY
    salary DESC
LIMIT 5;

-- 💬 Read WHERE conditions top to bottom like a sentence:
-- "Give me active Engineering/Sales employees hired after 2020
--  who earn more than 75k — sorted by salary, top 5 only."
