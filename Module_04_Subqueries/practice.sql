-- ============================================================
-- ✏️ MODULE 04 — PRACTICE QUESTIONS
-- Topic: Subqueries (Scalar, Row, Table, Correlated, EXISTS/IN)
-- ============================================================
-- Instructions:
--   Write your SQL queries below each question.
--   Run each query against the `sql_course_m4` database to verify your results.
--   Do not use Window Functions (Module 5) or CTEs (Module 6) yet,
--   solve these using Subqueries and/or JOINs.
--
-- Difficulty Levels:
--   🟢 Easy: 1-5
--   🟡 Medium: 6-12
--   🔴 Hard: 13-16
-- ============================================================

USE sql_course_m4;

-- ────────────────────────────────────────────
-- 🟢 EASY QUESTIONS
-- ────────────────────────────────────────────

-- Q1: Find the name and price of the cheapest product(s) in the products table.
-- Note: Do NOT use LIMIT. Use a scalar subquery.
-- Expected output: 'Wireless Mouse' and 'SQL Mastery Book' (if they have the same min price, show both)
-- YOUR QUERY:



-- Q2: Find the names of all products that belong to the 'Software' category.
-- Note: Solve this using a subquery in the WHERE clause instead of a JOIN.
-- Expected output: 'Dev Suite License', 'Cloud Storage Plan'
-- YOUR QUERY:



-- Q3: Find all employees who earn more than Sarah Connor's salary.
-- Expected output: Empty set (since she is the CEO and highest earner)
-- YOUR QUERY:



-- Q4: Find the names and signup dates of all customers who have placed at least one order.
-- Note: Use the IN operator with a subquery. Do not use JOIN.
-- Expected output: 10 rows (IDs 1 through 10)
-- YOUR QUERY:



-- Q5: Find the names and emails of all customers who have NEVER placed an order.
-- Note: Use the NOT EXISTS operator. Do not use JOIN.
-- Expected output: Karen Hall, Leo Foster
-- YOUR QUERY:




-- ────────────────────────────────────────────
-- 🟡 MEDIUM QUESTIONS
-- ────────────────────────────────────────────

-- Q6: Find all products that are priced higher than the average price of products in category 1 (Electronics).
-- Expected output: products priced higher than Electronics average (~716.65) -> 'Laptop Pro 15', 'API Integration Pkg'
-- YOUR QUERY:



-- Q7: Find the employee(s) who earn the highest salary in their respective department.
-- Note: Use a correlated subquery in the WHERE clause.
-- Expected output: Sarah Connor (Executive), John Reese (Engineering), Root Shaw (Marketing), Harold Finch (Sales), Control Admin (IT)
-- YOUR QUERY:



-- Q8: Find the order_id, customer_id, and total_amount of the order(s) with the absolute maximum total amount.
-- Note: Use a subquery. Do not use LIMIT.
-- Expected output: order 4 (1899.97)
-- YOUR QUERY:



-- Q9: For every product, display its name, price, and the count of how many times it has been ordered.
-- Note: Use a subquery in the SELECT clause.
-- Expected output: 10 rows, showing counts (e.g. Laptop Pro 15 ordered 3 times, SQL Mastery Book ordered 0 times)
-- YOUR QUERY:



-- Q10: Find the average total spending per customer across all customers who have placed orders.
-- Note: First, calculate the total amount spent by each customer, then take the average of those sums. Use a derived table.
-- Expected output: A single value (~632.91)
-- YOUR QUERY:



-- Q11: Find the full name and email of the customer who has spent the absolute highest total amount on their orders.
-- Note: You may use JOINs combined with a subquery in the HAVING or WHERE clause. Do not use LIMIT.
-- Expected output: Alice Johnson (Total spent: 1679.96)
-- YOUR QUERY:



-- Q12: Find all employees who are managers (i.e. they have at least one other employee reporting to them).
-- Note: Use the EXISTS operator.
-- Expected output: Sarah Connor, John Reese, Root Shaw, Harold Finch, Joss Carter
-- YOUR QUERY:




-- ────────────────────────────────────────────
-- 🔴 HARD QUESTIONS
-- ────────────────────────────────────────────

-- Q13: For each category, find the category_name, product_name, and price of the most expensive product.
-- Note: Solve this using a correlated subquery or a derived table.
-- Expected output:
--   Electronics | Laptop Pro 15 | 1299.99
--   Software    | Dev Suite License | 299.99
--   Accessories | Mechanical Keyboard | 129.99
--   Services    | API Integration Pkg | 1500.00
--   Books       | SQL Mastery Book | 39.99
-- YOUR QUERY:



-- Q14: Find the names of customers who have purchased the 'Wireless Mouse' (product_id = 2)
-- but have NEVER purchased the 'Mechanical Keyboard' (product_id = 7).
-- Note: You will need multiple subqueries or set logic.
-- Expected output: Alice Johnson, Bob Martinez
-- YOUR QUERY:



-- Q15: For each customer order, display the customer_id, order_date, order_id, total_amount,
-- and the running sum of orders placed by THAT SPECIFIC CUSTOMER up to that date.
-- Note: Use a correlated subquery in the SELECT list. Sort the final output by customer_id and order_date.
-- Expected output: 15 rows showing the customer-specific running total
-- YOUR QUERY:



-- Q16: Find the "second highest salary" among all employees. If there is a tie, handle it correctly.
-- Note: Do NOT use LIMIT or window functions. Use a subquery.
-- Expected output: 180000.00 (John Reese)
-- YOUR QUERY:
