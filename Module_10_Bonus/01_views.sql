-- ============================================================
-- 📘 MODULE 10 — Bonus (Views, Procedures, Triggers)
-- Lesson 01: Database Views
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - What is a view (virtual tables)
--    - Creating and querying views
--    - Benefits: Simplification and security
--    - 🔥 Updatable Views (Crucial interview rules!)
--
-- 💡 Prerequisites: Module 10, Setup
-- ============================================================

USE sql_course_m10;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What is a View?
-- ────────────────────────────────────────────
-- 💬 A **View** is a virtual table representing the result of a pre-defined SELECT query.
--    It does not store the query results physically on disk (it only stores the query definition).
--    Every time you query the view, the database engine runs the underlying SELECT query.
--
--    Benefits of Views:
--    1. **Simplification:** Hides complex joins, aggregates, or calculations from end-users.
--    2. **Security:** Exposes only a subset of columns or rows (e.g. hiding salaries or social security numbers).
--    3. **Consistency:** Centralizes business logic so developers don't write matching complex queries repeatedly.

-- ▶ Example 1.1: Create a view representing high-value stock items
--    High-value items are defined as products worth more than $1000 in total inventory value.
CREATE OR REPLACE VIEW v_high_value_stock AS
SELECT 
    id, 
    product, 
    category, 
    quantity, 
    price,
    (quantity * price) AS inventory_value
FROM inventory
WHERE (quantity * price) > 1000.00;

-- ▶ Example 1.2: Querying the View like a standard table
SELECT * 
FROM v_high_value_stock
WHERE category = 'Electronics';


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Updatable Views
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: Updatable Views.
--    Can you run `UPDATE`, `INSERT`, or `DELETE` on a View?
--    Answer: Yes, but ONLY if the view maps directly to a single table and does not perform
--    complex row calculations or aggregations.
--
--    A view is NOT updatable if it contains any of the following:
--       - Aggregate functions (SUM, AVG, MIN, MAX, COUNT)
--       - DISTINCT keyword
--       - GROUP BY or HAVING clauses
--       - UNION or UNION ALL operators
--       - Subqueries in the SELECT list
--       - JOINs (although some simple joins allow updates on single columns, it is highly restricted)
--
--    Let's test updating a simple view vs trying to update an aggregated view.

-- Create a simple updatable view
CREATE OR REPLACE VIEW v_electronics AS
SELECT id, product, quantity, price
FROM inventory
WHERE category = 'Electronics';

-- ▶ Example 2.1: Update the quantity of a product through the view
--    This successfully updates the record inside the base `inventory` table!
UPDATE v_electronics
SET quantity = quantity + 5
WHERE product = 'Wireless Mouse';

SELECT product, quantity FROM inventory WHERE product = 'Wireless Mouse';

-- ⚠️ COMMON MISTAKE:
-- Trying to update a calculated column or aggregated view.
-- The column `inventory_value` in `v_high_value_stock` is a derived column (`quantity * price`).
-- Running `UPDATE v_high_value_stock SET inventory_value = 5000 WHERE id = 1` will fail
-- because MySQL does not know how to distribute this new value back into `quantity` and `price`.
