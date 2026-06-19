-- ============================================================
-- 📘 MODULE 03 — Lesson 1: INNER JOIN
-- ============================================================
--
-- 🎯 What you'll learn:
--    - What a JOIN is and WHY we need it
--    - How INNER JOIN works (with a visual mental model)
--    - Joining 2 tables
--    - Joining 3 and 4 tables
--    - Using aliases to keep queries clean
--    - Combining JOINs with WHERE, GROUP BY, ORDER BY
--    - Complex real-world INNER JOIN queries
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m3;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Why do we even need JOINs?
-- ────────────────────────────────────────────
-- In the real world, data lives in MULTIPLE tables.
-- Databases split data to avoid repetition (normalization).
--
-- Example: Instead of storing the customer's name on every order row,
-- we store a customer_id in orders and keep the name in customers table.
--
-- Without JOIN:
SELECT * FROM orders LIMIT 5;
-- 💬 You see customer_id = 1, 2, 3 — but WHO is that? You don't know.

SELECT * FROM customers LIMIT 5;
-- 💬 You see Alice, Bob, Carol — but which orders are theirs? You don't know.
--
-- JOIN is how you CONNECT these two tables and see the full picture.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: INNER JOIN — Only matching rows
-- ────────────────────────────────────────────
-- INNER JOIN returns ONLY rows where a match exists in BOTH tables.
-- If a row exists in Table A but not Table B → it is EXCLUDED.
-- If a row exists in Table B but not Table A → it is EXCLUDED.
--
-- Think of it as a VENN DIAGRAM — only the overlapping center is returned.
--
-- Syntax:
--   SELECT columns
--   FROM table_a
--   INNER JOIN table_b ON table_a.key = table_b.key;
--   (the word INNER is optional — JOIN alone means INNER JOIN)

-- ▶ Basic INNER JOIN: Connect orders to customers
SELECT
    orders.order_id,
    orders.order_date,
    orders.status,
    orders.total_amount,
    customers.full_name,
    customers.city
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id;
-- 💬 Only 15 rows returned — orders 1-15 all have a matching customer.
-- Karen (customer 11) and Leo (customer 12) have NO orders, so they are EXCLUDED.
-- That's the key behavior of INNER JOIN — no match = no row.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Table aliases — cleaner syntax
-- ────────────────────────────────────────────
-- Writing table_name.column every time is verbose.
-- Use short aliases (o, c, p) to keep things clean.

-- ▶ Same query with aliases — much more readable:
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    c.full_name      AS customer_name,
    c.city
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
-- 💬 "orders o" means "from the orders table, call it o"
--    Then use o.anything to reference its columns


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: Joining 3 tables
-- ────────────────────────────────────────────
-- Each JOIN adds another table. You chain them one after another.
-- The ON clause for each JOIN links it to an already-joined table.

-- ▶ orders + customers + order_items
-- "Show me each order line with the customer name and quantity"
SELECT
    o.order_id,
    c.full_name        AS customer,
    o.order_date,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price  AS line_total
FROM orders o
JOIN customers   c  ON o.order_id     = c.customer_id   -- ← WRONG! let me fix
JOIN order_items oi ON oi.order_id    = o.order_id;

-- ⚠️ Wait — that ON clause above is wrong! Let me correct it:
SELECT
    o.order_id,
    c.full_name        AS customer,
    o.order_date,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price  AS line_total
FROM orders o
JOIN customers   c  ON o.customer_id  = c.customer_id   -- orders ↔ customers
JOIN order_items oi ON oi.order_id    = o.order_id;     -- orders ↔ order_items
-- 💬 Read as: "Start with orders, connect to customers on customer_id,
--    then connect to order_items on order_id."


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: Joining 4 tables
-- ────────────────────────────────────────────
-- Add products to the chain above to get product names too.

-- ▶ Full order detail: customer → order → item → product
SELECT
    o.order_id,
    c.full_name          AS customer,
    o.order_date,
    o.status,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers   c  ON o.customer_id  = c.customer_id
JOIN order_items oi ON oi.order_id    = o.order_id
JOIN products    p  ON oi.product_id  = p.product_id
ORDER BY o.order_id, p.product_name;
-- 💬 26 rows — one per order_item line. Multiple rows per order (one per product).
-- This is the most common real-world JOIN pattern: fact table + multiple dimensions.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: INNER JOIN + WHERE
-- ────────────────────────────────────────────
-- Filter the joined result just like a normal WHERE.

-- ▶ All delivered orders with their customer names:
SELECT
    o.order_id,
    c.full_name   AS customer,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'Delivered'
ORDER BY o.total_amount DESC;
-- 💬 WHERE runs AFTER the join — it filters the combined result set.

-- ▶ All items ordered by customers from New York:
SELECT
    c.full_name     AS customer,
    c.city,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM order_items oi
JOIN orders   o  ON oi.order_id   = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON oi.product_id = p.product_id
WHERE c.city = 'New York'
ORDER BY c.full_name, p.product_name;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 7: INNER JOIN + GROUP BY
-- ────────────────────────────────────────────
-- This is where things get powerful — aggregate PER group after joining.

-- ▶ Total amount spent per customer (name, not just ID):
SELECT
    c.full_name      AS customer,
    c.city,
    COUNT(o.order_id)           AS num_orders,
    ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent DESC;
-- 💬 Note: GROUP BY uses customer_id (unique) + full_name for display.
--    This prevents issues if two people share the same name.

-- ▶ Total revenue per product (from order_items):
SELECT
    p.product_name,
    cat.category_name,
    COUNT(oi.item_id)           AS times_ordered,
    SUM(oi.quantity)            AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM products p
JOIN categories   cat ON p.category_id  = cat.category_id
JOIN order_items  oi  ON oi.product_id  = p.product_id
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY total_revenue DESC;
-- 💬 Notice: 'SQL Mastery Book' won't appear — it was never ordered (INNER JOIN excludes it)


-- ────────────────────────────────────────────
-- 📌 CONCEPT 8: Complex INNER JOIN queries
-- ────────────────────────────────────────────

-- ▶ COMPLEX 1: Customer order summary — only customers with 2+ orders
SELECT
    c.full_name            AS customer,
    c.city,
    COUNT(o.order_id)                 AS total_orders,
    SUM(CASE WHEN o.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(SUM(o.total_amount), 2)     AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
HAVING COUNT(o.order_id) >= 2
ORDER BY lifetime_value DESC;
-- 💬 CASE WHEN inside SUM is a common pattern: count only rows matching a condition.
--    Think of it as: "for each row, give 1 if Delivered else 0, then sum those 1s"

-- ▶ COMPLEX 2: Top product per category by revenue
-- "Which product earned the most in each category?"
SELECT
    cat.category_name,
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM categories cat
JOIN products    p   ON p.category_id  = cat.category_id
JOIN order_items oi  ON oi.product_id  = p.product_id
GROUP BY cat.category_id, cat.category_name, p.product_id, p.product_name
ORDER BY cat.category_name, revenue DESC;
-- 💬 We'll learn how to get exactly ONE "top" per category in Module 5 (Window Functions)
--    For now this shows ALL products per category, sorted by revenue.

-- ▶ COMPLEX 3: Monthly revenue breakdown
SELECT
    YEAR(o.order_date)              AS yr,
    MONTH(o.order_date)             AS mo,
    COUNT(DISTINCT o.order_id)      AS num_orders,
    COUNT(DISTINCT o.customer_id)   AS unique_customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status != 'Cancelled'
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY yr, mo;
-- 💬 COUNT(DISTINCT o.order_id) counts unique orders even though
--    there are multiple items per order (multiple oi rows per order).
--    Without DISTINCT, an order with 3 items would be counted 3 times!

-- ▶ COMPLEX 4: Full order report with category
SELECT
    o.order_id,
    o.order_date,
    o.status,
    c.full_name         AS customer,
    c.city,
    cat.category_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers   c   ON o.customer_id  = c.customer_id
JOIN order_items oi  ON oi.order_id    = o.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN categories  cat ON p.category_id  = cat.category_id
WHERE o.status = 'Delivered'
  AND o.order_date >= '2024-03-01'
ORDER BY o.order_date, o.order_id, cat.category_name;
-- 💬 Five-table JOIN! Start from orders, fan out to customers, items, products, categories.
--    WHERE filters to delivered orders from March onwards.
