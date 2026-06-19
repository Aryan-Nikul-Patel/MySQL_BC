-- ============================================================
-- 📘 MODULE 03 — Lesson 2: LEFT JOIN & RIGHT JOIN
-- ============================================================
--
-- 🎯 What you'll learn:
--    - Why INNER JOIN isn't always enough
--    - LEFT JOIN — keep all rows from the LEFT table
--    - RIGHT JOIN — keep all rows from the RIGHT table
--    - The NULL pattern: finding rows with NO match (anti-join)
--    - Complex LEFT JOIN queries
--    - When to use LEFT vs RIGHT (and why LEFT is preferred)
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m3;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: The problem with INNER JOIN
-- ────────────────────────────────────────────
-- Remember: INNER JOIN only returns rows with a match in BOTH tables.
-- Sometimes you want ALL rows from one table, even if there's no match.
--
-- Real example: "List all customers and their orders."
-- With INNER JOIN, customers who never ordered are INVISIBLE.
-- That could be a problem if you're doing customer analysis!

-- ▶ INNER JOIN — Karen and Leo are missing:
SELECT c.full_name, o.order_id, o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
-- 💬 Only 15 rows. Karen (id=11) and Leo (id=12) don't appear at all.

-- ▶ LEFT JOIN — Karen and Leo appear with NULLs:
SELECT c.full_name, o.order_id, o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;
-- 💬 Now 17 rows. Karen and Leo appear, but order_id and total_amount are NULL.
--    NULL here means "this customer has no orders" — not that data is missing!


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: LEFT JOIN explained
-- ────────────────────────────────────────────
-- LEFT JOIN = "Keep EVERYTHING from the LEFT table.
--              For rows with no match in the right table, fill right columns with NULL."
--
-- Left table  = the table in FROM
-- Right table = the table after LEFT JOIN
--
--  customers (LEFT)        orders (RIGHT)
--  ──────────────          ──────────────
--  Alice     ──────────→  order_id=1  ✅ match
--  Alice     ──────────→  order_id=2  ✅ match
--  Bob       ──────────→  order_id=3  ✅ match
--  ...
--  Karen     ──────────→  NULL        ⚠️ no order, but Karen still shows up
--  Leo       ──────────→  NULL        ⚠️ no order, but Leo still shows up


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: The NULL trick — finding "no match" rows (Anti-join)
-- ────────────────────────────────────────────
-- LEFT JOIN + WHERE right.key IS NULL is THE most important pattern.
-- It finds rows in the LEFT table that have NO match in the RIGHT table.
-- This is called an ANTI-JOIN.

-- ▶ Find customers who have NEVER placed an order:
SELECT
    c.full_name,
    c.email,
    c.city,
    c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;               -- ← THE KEY: only rows with no match
-- 💬 Returns Karen and Leo — the two customers with no orders.
--    Step by step:
--    1. LEFT JOIN gives all customers, with NULL order_id for unmatched ones
--    2. WHERE o.order_id IS NULL filters to ONLY those NULLs
--    Result: customers with no orders.

-- ▶ Find products that have NEVER been ordered:
SELECT
    p.product_name,
    p.price,
    p.stock
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.item_id IS NULL;
-- 💬 Returns "SQL Mastery Book" — never appeared in any order_items row.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: LEFT JOIN with aggregation
-- ────────────────────────────────────────────
-- Even customers with no orders should show up in reports — often as 0.
-- COUNT(*) on NULLs is dangerous — use COUNT(o.order_id) instead!

-- ▶ Count orders per customer — including zero-order customers:
SELECT
    c.full_name                    AS customer,
    c.city,
    COUNT(o.order_id)              AS total_orders,  -- NULL order_id counted as 0
    COALESCE(SUM(o.total_amount), 0) AS total_spent  -- NULL sum becomes 0
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_orders DESC, c.full_name;
-- 💬 COUNT(o.order_id) → NULL values are skipped → Karen and Leo show 0 orders.
--    COUNT(*) would count Karen's NULL row as 1 — WRONG!
--    COALESCE(SUM(...), 0) replaces NULL with 0 for display.

-- ▶ Same but also show how much each customer spent per order status:
SELECT
    c.full_name                       AS customer,
    COUNT(o.order_id)                 AS total_orders,
    SUM(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE 0 END) AS delivered_revenue,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END)              AS cancelled_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_orders DESC;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: LEFT JOIN across 3+ tables
-- ────────────────────────────────────────────

-- ▶ All products with their category name AND total revenue
-- (products never ordered should still show up with 0 revenue)
SELECT
    p.product_name,
    cat.category_name,
    COALESCE(COUNT(oi.item_id), 0)               AS times_ordered,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM products p
JOIN      categories   cat ON p.category_id  = cat.category_id  -- every product HAS a category
LEFT JOIN order_items  oi  ON oi.product_id  = p.product_id     -- but may have 0 orders
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY total_revenue DESC;
-- 💬 Mix of JOIN and LEFT JOIN:
--    - categories JOIN is INNER — every product has a category
--    - order_items LEFT JOIN — some products have never been ordered (Book)
--    "SQL Mastery Book" appears at the bottom with 0 revenue.

-- ▶ All categories and their product count AND revenue
-- (Books category has products but none ordered)
SELECT
    cat.category_name,
    COUNT(DISTINCT p.product_id)                   AS num_products,
    COALESCE(COUNT(oi.item_id), 0)                 AS total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0)  AS total_revenue
FROM categories cat
LEFT JOIN products    p   ON p.category_id  = cat.category_id
LEFT JOIN order_items oi  ON oi.product_id  = p.product_id
GROUP BY cat.category_id, cat.category_name
ORDER BY total_revenue DESC;
-- 💬 'Books' shows 1 product but 0 revenue (book was never ordered).
--    'Services' category shows 1 product and the API integration revenue.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: RIGHT JOIN
-- ────────────────────────────────────────────
-- RIGHT JOIN is the mirror of LEFT JOIN:
-- Keep EVERYTHING from the RIGHT table, NULLs for unmatched LEFT rows.
--
-- Honestly? RIGHT JOIN is rarely used in practice.
-- ANY RIGHT JOIN can be rewritten as a LEFT JOIN by swapping table order.
-- Most developers just always write LEFT JOIN for consistency.

-- ▶ RIGHT JOIN: keep all orders, even if customer data is missing
SELECT
    c.full_name,
    o.order_id,
    o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;
-- 💬 Same result as LEFT JOIN with tables swapped. All 15 orders appear.
--    If an order had no matching customer, full_name would be NULL.

-- ▶ The EXACT same query rewritten with LEFT JOIN (preferred style):
SELECT
    c.full_name,
    o.order_id,
    o.total_amount
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id;
-- 💬 Same result! Just swapped which table is "FROM" vs which is "JOIN".
--    Convention: always LEFT JOIN, put the "main" table in FROM.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 7: Complex LEFT JOIN — real world scenarios
-- ────────────────────────────────────────────

-- ▶ COMPLEX 1: Customer re-engagement report
-- "All customers, their last order date, days since last order,
--  and flag if they haven't ordered in 90+ days"
SELECT
    c.full_name,
    c.city,
    c.signup_date,
    MAX(o.order_date)                        AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date))   AS days_since_order,
    CASE
        WHEN MAX(o.order_date) IS NULL                            THEN 'Never Ordered'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 90         THEN 'At Risk'
        ELSE                                                           'Active'
    END                                      AS customer_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city, c.signup_date
ORDER BY days_since_order DESC;
-- 💬 This is a real business report:
--    - LEFT JOIN: keeps customers with no orders (never_ordered)
--    - MAX(o.order_date): most recent order per customer
--    - DATEDIFF: days between today and last order
--    - CASE WHEN: labels them based on activity

-- ▶ COMPLEX 2: Product performance report with categories
-- "All products, their category, stock, times ordered, and status"
SELECT
    cat.category_name,
    p.product_name,
    p.price,
    p.stock,
    COUNT(oi.item_id)                              AS times_ordered,
    COALESCE(SUM(oi.quantity), 0)                  AS total_units_sold,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0) AS revenue,
    CASE
        WHEN COUNT(oi.item_id) = 0 THEN 'Never Ordered'
        WHEN COUNT(oi.item_id) >= 5 THEN 'Best Seller'
        ELSE 'Regular'
    END                                            AS product_status
FROM products p
JOIN      categories  cat ON p.category_id = cat.category_id
LEFT JOIN order_items oi  ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.price, p.stock, cat.category_name
ORDER BY revenue DESC;
