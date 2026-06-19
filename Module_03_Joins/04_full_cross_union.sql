-- ============================================================
-- 📘 MODULE 03 — Lesson 4: FULL OUTER JOIN, CROSS JOIN & UNION
-- ============================================================
--
-- 🎯 What you'll learn:
--    - FULL OUTER JOIN (and how to simulate it in MySQL)
--    - CROSS JOIN — the Cartesian product
--    - UNION vs UNION ALL — combining result sets
--    - Simulating INTERSECT and EXCEPT using JOINs
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m3;


-- ════════════════════════════════════════════
-- PART 1: FULL OUTER JOIN
-- ════════════════════════════════════════════

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What is FULL OUTER JOIN?
-- ────────────────────────────────────────────
-- FULL OUTER JOIN = LEFT JOIN + RIGHT JOIN combined.
-- It returns:
--   ✅ All rows from the LEFT table (with NULLs if no right match)
--   ✅ All rows from the RIGHT table (with NULLs if no left match)
--   ✅ All rows that match in BOTH tables
--
-- Venn diagram: the ENTIRE both circles — left, overlap, and right.
--
-- ⚠️ MySQL does NOT support FULL OUTER JOIN syntax directly!
-- You simulate it with: LEFT JOIN UNION ALL RIGHT JOIN (filtered)


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Simulating FULL OUTER JOIN in MySQL
-- ────────────────────────────────────────────

-- ▶ Show ALL customers and ALL orders — match where possible, NULLs otherwise:
-- (Same as LEFT JOIN for our data since all orders have customers,
--  but important to know the pattern!)

-- Step 1: LEFT JOIN — all customers, matched or not
SELECT
    c.customer_id,
    c.full_name,
    o.order_id,
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION ALL

-- Step 2: RIGHT JOIN filtered to ONLY unmatched right-side rows
-- (rows that exist in orders but NOT in customers — orphan orders)
SELECT
    c.customer_id,
    c.full_name,
    o.order_id,
    o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- 💬 UNION ALL combines both result sets.
--    In our data, all orders have valid customers, so the second part is empty.
--    But this pattern is critical when data can be "orphaned" on either side.

-- ▶ Real use case: Find ALL products and ALL order_items — match where possible
-- (products never ordered + hypothetical orphan items)
SELECT
    p.product_name,
    p.price,
    oi.item_id,
    oi.quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id

UNION ALL

SELECT
    p.product_name,
    p.price,
    oi.item_id,
    oi.quantity
FROM products p
RIGHT JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;
-- 💬 The Book (never ordered) shows with NULL item_id/quantity.
--    The second part would show any orphan order_items (none in our data).


-- ════════════════════════════════════════════
-- PART 2: CROSS JOIN
-- ════════════════════════════════════════════

-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: CROSS JOIN — Cartesian Product
-- ────────────────────────────────────────────
-- CROSS JOIN combines EVERY row from Table A with EVERY row from Table B.
-- No ON condition needed.
-- Result size = rows_in_A × rows_in_B
--
-- Use cases:
--   - Generate all possible combinations (e.g., size × color)
--   - Build a date range or sequence table
--   - Testing / populating large datasets

-- ▶ All possible category + product combinations (5 categories × 10 products = 50 rows):
SELECT
    cat.category_name,
    p.product_name
FROM categories cat
CROSS JOIN products p
ORDER BY cat.category_name, p.product_name
LIMIT 20;  -- only showing first 20 of 50
-- 💬 Every category is paired with every product — even nonsensical combos.
--    Notice: this is NOT a join on a key, just every possible combination.

-- ▶ Practical use: Generate a "price matrix" — all products at 3 discount levels:
SELECT
    p.product_name,
    p.price,
    d.discount_label,
    d.discount_pct,
    ROUND(p.price * (1 - d.discount_pct), 2) AS discounted_price
FROM products p
CROSS JOIN (
    SELECT '10% Off'  AS discount_label, 0.10 AS discount_pct UNION ALL
    SELECT '25% Off',                    0.25               UNION ALL
    SELECT '50% Off',                    0.50
) d
ORDER BY p.product_name, d.discount_pct;
-- 💬 The subquery creates 3 "virtual" discount rows.
--    CROSS JOIN pairs every product with every discount level.
--    Result: 10 products × 3 discounts = 30 rows.
--    A real business use: "show all products at sale prices".

-- ⚠️ BE CAREFUL with CROSS JOIN on large tables!
--    1000 rows × 1000 rows = 1,000,000 rows. It grows very fast.


-- ════════════════════════════════════════════
-- PART 3: UNION and SET OPERATIONS
-- ════════════════════════════════════════════

-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: UNION vs UNION ALL
-- ────────────────────────────────────────────
-- UNION combines result sets from two SELECT queries vertically (stacks them).
-- Rules:
--   1. Both queries must have the SAME number of columns
--   2. Columns must be compatible data types
--   3. Column NAMES come from the FIRST query
--
-- UNION     → removes duplicate rows (like SELECT DISTINCT)
-- UNION ALL → keeps ALL rows including duplicates (faster!)

-- ▶ Combine customer cities and employee departments into one list:
SELECT city   AS location, 'Customer City' AS source FROM customers
UNION
SELECT dept,               'Department'              FROM employees
ORDER BY location;
-- 💬 UNION removes duplicates — if "Chicago" appeared in both, it'd show once.
--    Note the column name is "location" (from the first SELECT).

-- ▶ UNION ALL — keeps everything including duplicates:
SELECT city AS location FROM customers
UNION ALL
SELECT dept            FROM employees;
-- 💬 Faster than UNION because it doesn't sort/deduplicate.
--    Use UNION ALL when you KNOW there are no duplicates, or you want them.

-- ▶ Practical: Recent activity log — combine new customers and new orders
SELECT
    'New Customer'      AS event_type,
    full_name           AS description,
    signup_date         AS event_date
FROM customers
WHERE signup_date >= '2024-01-01'

UNION ALL

SELECT
    'New Order',
    CONCAT('Order #', order_id, ' — $', total_amount),
    order_date
FROM orders
WHERE order_date >= '2024-01-01'

ORDER BY event_date DESC;
-- 💬 Two completely different tables, stacked into one timeline.
--    CONCAT() builds a string: 'Order #1 — $1329.98'
--    ORDER BY applies to the COMBINED result.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: Simulating INTERSECT and EXCEPT
-- ────────────────────────────────────────────
-- MySQL doesn't have INTERSECT or EXCEPT keywords (PostgreSQL does).
-- We simulate them with JOINs.
--
-- INTERSECT = rows that appear in BOTH queries
-- EXCEPT    = rows in Query A but NOT in Query B

-- ▶ INTERSECT simulation:
-- "Customers who are from cities that also have employees"

-- With INTERSECT (not supported in MySQL):
-- SELECT city FROM customers INTERSECT SELECT dept FROM employees;

-- MySQL way — using INNER JOIN or IN:
SELECT DISTINCT c.city
FROM customers c
JOIN employees e ON c.city = e.dept;  -- same city name as a dept name

-- Or with IN:
SELECT DISTINCT city
FROM customers
WHERE city IN (SELECT dept FROM employees);

-- ▶ EXCEPT simulation:
-- "Cities where customers live that have NO employees working in that city/dept"
SELECT DISTINCT c.city
FROM customers c
WHERE c.city NOT IN (SELECT dept FROM employees);
-- 💬 Returns cities that don't match any employee department name.

-- ▶ A more common EXCEPT use case:
-- "Products that exist in our catalog but were NEVER ordered"
-- (EXCEPT approach):
SELECT product_id FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);
-- Result: product 9 (SQL Mastery Book)
-- Same result as the LEFT JOIN + IS NULL anti-join from Lesson 2!
-- 💬 Both approaches work — LEFT JOIN anti-join is often faster on large tables.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: Putting it all together — A complex UNION report
-- ────────────────────────────────────────────

-- ▶ Sales funnel report: customers at different stages
SELECT
    'Has Multiple Orders'   AS segment,
    c.full_name,
    c.city,
    COUNT(o.order_id)       AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
HAVING COUNT(o.order_id) >= 2

UNION ALL

SELECT
    'Has One Order',
    c.full_name,
    c.city,
    COUNT(o.order_id)
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
HAVING COUNT(o.order_id) = 1

UNION ALL

SELECT
    'Never Ordered',
    c.full_name,
    c.city,
    0
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL

ORDER BY segment, order_count DESC;
-- 💬 Three segments of customers in one query using UNION ALL.
--    First segment: loyal customers (2+ orders)
--    Second segment: one-time buyers
--    Third segment: registered but never bought
--    This kind of report is very common in real business analytics.
