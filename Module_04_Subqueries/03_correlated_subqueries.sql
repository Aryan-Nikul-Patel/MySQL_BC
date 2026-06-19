-- ============================================================
-- 📘 MODULE 04 — SUBQUERIES
-- Lesson 03: Correlated Subqueries
-- ============================================================
-- 🎯 What you'll learn:
--    - What a correlated subquery is
--    - The execution lifecycle: Correlated vs Non-Correlated
--    - Classic pattern: Comparing a row's value to its group's average 🔥
--    - Performance implications (O(N) vs O(N^2) complexity)
--    - Interview-favorite: Running calculations using correlation
-- ============================================================

USE sql_course_m4;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: What is a Correlated Subquery?
-- ────────────────────────────────────────────
-- 💬 In previous lessons, our subqueries were self-contained (non-correlated). They could be executed 
-- independently of the outer query.
--
-- A correlated subquery is a subquery that references one or more columns from the outer query.
-- Because it depends on the outer query, it cannot be run on its own.
--
-- Execution Lifecycle:
--   1. The database engine fetches a row from the outer query.
--   2. For that specific row, it plugs the outer column values into the subquery.
--   3. It runs the subquery and gets the result.
--   4. It uses the result to evaluate the WHERE clause (or SELECT) for that outer row.
--   5. It repeats steps 1-4 for EVERY row in the outer table.
--
-- ⚠️ PERFORMANCE WARNING:
-- While a non-correlated subquery executes ONCE, a correlated subquery executes ONCE FOR EACH ROW 
-- in the outer query. If the outer query has 10,000 rows, the subquery may run 10,000 times!
-- This is like a nested loop in programming: O(N * M) or O(N^2) complexity.

-- ────────────────────────────────────────────
-- 📌 CLASSIC PATTERN: Value vs Group Average
-- ────────────────────────────────────────────
-- ▶ Example 1: Find products priced higher than the average price of products in their OWN category.
-- 💬 Think about the logic:
--   For each product, we look at its `category_id`. 
--   We then run a subquery to find the average price of only that category.
--   Then we check if this product's price is greater than that average.

SELECT 
    p1.product_name,
    p1.category_id,
    p1.price
FROM products AS p1
WHERE p1.price > (
    -- The subquery references 'p1.category_id' from the outer table 'p1'
    SELECT AVG(p2.price) 
    FROM products AS p2
    WHERE p2.category_id = p1.category_id
);

-- 💬 Walkthrough of execution:
--   - Let's say outer row is Laptop Pro 15 (price = 1299.99, category_id = 1).
--     The subquery runs: `SELECT AVG(price) FROM products WHERE category_id = 1`. Average is ~716.65.
--     Since 1299.99 > 716.65, Laptop Pro is kept.
--   - Let's say outer row is Wireless Mouse (price = 29.99, category_id = 3).
--     The subquery runs: `SELECT AVG(price) FROM products WHERE category_id = 3`. Average is ~69.99.
--     Since 29.99 is not > 69.99, Wireless Mouse is filtered out.
--
-- Notice how the subquery results change dynamically for each row!

-- ▶ Example 2: Find employees who earn more than the average salary of their department.
-- 💬 This is a very common big tech interview question.

SELECT 
    e1.name,
    e1.dept,
    e1.salary
FROM employees AS e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.dept = e1.dept
);

-- ────────────────────────────────────────────
-- 📌 ADVANCED PATTERN: Row-by-Row Comparison (Self-Correlation)
-- ────────────────────────────────────────────
-- 💬 You can use correlated subqueries to reference rows that came before the current row.
-- Let's say we want to compute a running total or count occurrences.

-- ▶ Example 3: Running Total of Order Amounts (Before Window Functions existed!)
-- Question: For each order in 2024, show the order_date, order_id, total_amount, 
-- and a running total of order amounts up to that date.

SELECT 
    o1.order_date,
    o1.order_id,
    o1.total_amount,
    (
        -- The subquery sums amounts of all orders that have a date <= the outer order's date
        SELECT SUM(o2.total_amount)
        FROM orders AS o2
        WHERE o2.order_date <= o1.order_date
    ) AS running_total
FROM orders AS o1
ORDER BY o1.order_date;

-- 💬 Walkthrough of execution:
-- For the first order (2024-01-05), the subquery sums all orders <= 2024-01-05.
-- For the second order (2024-01-20), the subquery sums all orders <= 2024-01-20.
-- This effectively creates a running sum.
-- ⚠️ Note: While this works, it is slow for large tables because of the O(N^2) complexity. 
-- In Module 05, we will learn how to write this using Window Functions (`SUM(total_amount) OVER(...)`), 
-- which runs in O(N log N) or O(N) time and is much more efficient!

-- 🔥 INTERVIEW TIP:
-- If an interviewer asks you to compare a row's values to its group's aggregates:
-- 1. A correlated subquery is the most straightforward, conceptual solution.
-- 2. Mention the performance cost (executing per-row).
-- 3. Offer to optimize it using a JOIN with a pre-aggregated derived table (which only aggregates once!).
-- Let's see how to write Example 2 using a JOIN instead:
--
--   SELECT e1.name, e1.dept, e1.salary
--   FROM employees e1
--   JOIN (
--       SELECT dept, AVG(salary) AS avg_sal
--       FROM employees
--       GROUP BY dept
--   ) dept_avg ON e1.dept = dept_avg.dept
--   WHERE e1.salary > dept_avg.avg_sal;
--
-- This JOIN version runs the aggregation ONCE, then performs a JOIN. This is much faster for large tables!
