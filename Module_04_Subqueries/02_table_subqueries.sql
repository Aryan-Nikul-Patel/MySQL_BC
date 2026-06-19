-- ============================================================
-- 📘 MODULE 04 — SUBQUERIES
-- Lesson 02: Table Subqueries (Derived Tables)
-- ============================================================
-- 🎯 What you'll learn:
--    - Table subqueries (queries returning multiple rows and columns)
--    - Using subqueries in the FROM clause (Derived Tables)
--    - Why aliases are MANDATORY for derived tables in MySQL
--    - Aggregating aggregated data (e.g., average of sums)
--    - Joining a standard table to a derived table
-- ============================================================

USE sql_course_m4;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Table Subqueries & Derived Tables
-- ────────────────────────────────────────────
-- 💬 A table subquery is a nested query that returns a full result set (multiple rows, multiple columns).
-- When a subquery is placed in the FROM clause, it acts as a temporary virtual table.
-- This is called a "Derived Table" (or inline view).
--
-- ⚠️ MANDATORY RULE IN SQL (especially MySQL):
-- Every derived table MUST be given an alias.
-- If you run:
--   `SELECT * FROM (SELECT * FROM products WHERE price > 100);`
-- MySQL will throw: "ERROR 1248 (42000): Every derived table must have its own alias".
-- You must name it, for example, using `AS high_priced_products` or simply `p`.

-- ▶ Example 1: Basic Derived Table
-- Question: Get the list of names and prices of products in category 1 (Electronics) priced above 300,
-- using a subquery in the FROM clause.

SELECT 
    sub.product_name, 
    sub.price
FROM (
    SELECT * 
    FROM products 
    WHERE category_id = 1
) AS sub
WHERE sub.price > 300;

-- 💬 Why do this instead of a simple WHERE clause?
-- For simple queries, a derived table is overkill. But it becomes essential when you need to perform
-- two-step data processing, such as aggregating aggregated data.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Aggregating Aggregated Data
-- ────────────────────────────────────────────
-- 💬 In SQL, you cannot nest aggregate functions. Writing `SELECT AVG(SUM(total_amount)) FROM orders;` is invalid.
-- If you want to find the "average of total sales per customer", you must:
--   Step 1: Calculate the total sales for each customer (using GROUP BY).
--   Step 2: Calculate the average of those totals (using a subquery in FROM).

-- ▶ Example 2: Average of Sums
-- Question: Find the average total amount spent by customers who have placed at least one order.

SELECT 
    AVG(customer_totals.total_spent) AS average_customer_spend
FROM (
    -- This inner query groups orders by customer and calculates total spending per customer.
    -- It returns a table with columns: customer_id, total_spent
    SELECT 
        customer_id, 
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) AS customer_totals;

-- 💬 How this executes:
-- 1. The inner query runs first and builds a temporary table containing each customer's total spent.
-- 2. The outer query runs `AVG()` over the `total_spent` column of that temporary table.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Joining a Table with a Derived Table
-- ────────────────────────────────────────────
-- 💬 Often in interviews, you need to combine raw customer data with complex aggregate statistics.
-- A very clean way to do this is to write a subquery that computes the statistics, and then
-- JOIN that subquery to your main table just like any other table.

-- ▶ Example 3: Joining with a Derived Table
-- Question: For each customer, display their name, city, total amount spent, and number of orders placed.
-- 💬 We can write a subquery that computes totals and order counts, then JOIN it to the `customers` table.

SELECT 
    c.full_name,
    c.city,
    COALESCE(stats.total_spent, 0) AS total_spent,
    COALESCE(stats.order_count, 0) AS order_count
FROM customers AS c
LEFT JOIN (
    -- Subquery computing order stats per customer
    SELECT 
        customer_id,
        SUM(total_amount) AS total_spent,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) AS stats 
ON c.customer_id = stats.customer_id;

-- 💬 Why is this LEFT JOIN pattern great?
-- 1. Performance: The aggregation is performed on the `orders` table first (which reduces the row count),
--    and only then is it joined to the `customers` table. This is often faster than joining first and grouping later.
-- 2. Readability: It cleanly separates the aggregation logic from the customer profile columns.
-- 3. We use `COALESCE` to display 0 instead of NULL for customers who have never ordered (like Karen and Leo).

-- 🔥 INTERVIEW TIP:
-- When asked to solve complex grouping problems, think of your query in layers.
-- "Can I write a subquery that gets the counts/sums first, and then query it like a table?"
-- This "Divide and Conquer" approach makes writing complex queries much easier under pressure.
