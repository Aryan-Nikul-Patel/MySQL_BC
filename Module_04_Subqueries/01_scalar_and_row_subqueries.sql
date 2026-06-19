-- ============================================================
-- 📘 MODULE 04 — SUBQUERIES
-- Lesson 01: Scalar and Row Subqueries
-- ============================================================
-- 🎯 What you'll learn:
--    - What a subquery is and its execution lifecycle
--    - Scalar subqueries (returning a single value)
--    - Positioning subqueries in the WHERE and SELECT clauses
--    - Row subqueries (returning a single row with multiple columns)
--    - Best practices for performance and readability
-- ============================================================

USE sql_course_m4;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: What is a Subquery?
-- ────────────────────────────────────────────
-- 💬 A subquery (or inner query) is a query nested inside another SQL statement.
-- The query containing the subquery is called the outer query.
--
-- Lifecycle of a Non-Correlated Subquery:
--   1. The database engine executes the inner subquery first.
--   2. The subquery returns its result.
--   3. The outer query uses that result as a constant/value to complete its execution.
--
-- ────────────────────────────────────────────
-- 📌 CONCEPT: Scalar Subqueries
-- ────────────────────────────────────────────
-- 💬 A scalar subquery is a nested query that returns exactly ONE row and ONE column
-- (a single value, like a number, string, or date).
-- Because it returns a single value, it can be used anywhere a literal value or constant is allowed:
-- with comparison operators (=, >, <, !=) in WHERE, in the SELECT list, etc.
--
-- Let's see some interview-friendly examples.

-- ▶ Example 1: Scalar Subquery in the WHERE Clause
-- Question: Find all products that are priced higher than the overall average price of all products.
-- 💬 We can't write `WHERE price > AVG(price)` because aggregate functions aren't allowed in WHERE.
-- Instead, we use a subquery to calculate the average first.

SELECT 
    product_name, 
    price
FROM products
WHERE price > (
    SELECT AVG(price) 
    FROM products
);

-- 💬 How this executes:
-- 1. The inner query `SELECT AVG(price) FROM products` runs once and returns a single value: ~424.99.
-- 2. The outer query runs as: `SELECT product_name, price FROM products WHERE price > 424.99;`
-- This makes the query dynamic. If prices change, the average updates automatically.

-- ▶ Example 2: Scalar Subquery in the SELECT Clause
-- Question: For each product, show its name, category, price, and the price difference from the overall average price.
-- 💬 We can embed the subquery directly in the SELECT list to calculate the average for every row.

SELECT 
    product_name,
    price,
    (SELECT AVG(price) FROM products) AS avg_price,
    price - (SELECT AVG(price) FROM products) AS price_diff
FROM products;

-- 💬 Note: Although this is convenient, running a scalar subquery in SELECT can be slow on very large tables
-- because the database engine might execute the subquery repeatedly, though modern optimizers are smart.
-- We'll learn better ways to do this using JOINs (Module 3) and Window Functions (Module 5).

-- ▶ Example 3: Scalar Subquery in the HAVING Clause
-- Question: Find categories whose maximum product price is lower than the overall average product price.

SELECT 
    category_id, 
    MAX(price) AS max_price
FROM products
GROUP BY category_id
HAVING MAX(price) < (
    SELECT AVG(price) 
    FROM products
);

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Row Subqueries
-- ────────────────────────────────────────────
-- 💬 A row subquery is a subquery that returns a single row, but with MULTIPLE columns.
-- This allows us to compare multiple values at once using row constructors (tuple comparisons).
-- Syntax: `(col1, col2) = (SELECT colA, colB FROM ...)`

-- ▶ Example 4: Row Subquery comparison
-- Question: Find all employees who work in the same department and report to the same manager as Joss Carter.
-- 💬 Let's check Joss Carter's department and manager first:
-- SELECT dept, manager_id FROM employees WHERE name = 'Joss Carter'; -> ('Sales', 4)
-- Now, we can find others who match both criteria without writing separate subqueries.

SELECT 
    name, 
    dept, 
    manager_id
FROM employees
WHERE (dept, manager_id) = (
    SELECT dept, manager_id 
    FROM employees 
    WHERE name = 'Joss Carter'
) AND name != 'Joss Carter';

-- 💬 How this executes:
-- The row subquery returns `('Sales', 4)`.
-- The outer query filters rows where `(dept, manager_id)` matches `('Sales', 4)`.
-- This is clean, readable, and avoids writing two nested subqueries.

-- ⚠️ COMMON MISTAKE: Subquery Returns Multiple Rows
-- What happens if your scalar subquery returns more than 1 row?
-- Let's try to find products in categories that have a budget greater than 100,000 using standard comparison.
-- If we write:
--   `SELECT * FROM products WHERE category_id = (SELECT category_id FROM categories);`
-- MySQL will throw: "ERROR 1242 (21000): Subquery returns more than 1 row".
-- Always ensure that when using operators like `=`, `>`, `<`, etc., the subquery is guaranteed to return at most 1 row.
-- If it can return multiple rows, you must use operators like `IN`, `ANY`, or `ALL` (covered in Lesson 04).

-- 🔥 INTERVIEW TIP:
-- When asked to find the "Nth highest salary" or "highest earner" in an interview:
-- If you are not allowed to use `LIMIT` or Window Functions, a scalar subquery is the classic solution!
--
-- For the maximum salary:
--   `SELECT name, salary FROM employees WHERE salary = (SELECT MAX(salary) FROM employees);`
