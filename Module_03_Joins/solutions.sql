-- ============================================================
-- ✅  MODULE 03 — Solutions
-- ============================================================
-- ⚠️  Try the practice questions yourself first!
-- ============================================================

USE sql_course_m3;

-- ──────────────────────────────────────────
-- 🟢 EASY
-- ──────────────────────────────────────────

-- Q1. All orders with customer name and city.
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    c.full_name  AS customer_name,
    c.city
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- Q2. Order items with product name and category.
SELECT
    oi.item_id,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price
FROM order_items oi
JOIN products   p   ON oi.product_id  = p.product_id
JOIN categories cat ON p.category_id  = cat.category_id
ORDER BY cat.category_name, p.product_name;

-- Q3. Employees with their manager's name (including CEO).
SELECT
    e.name                             AS employee_name,
    e.role                             AS employee_role,
    COALESCE(m.name, '— No Manager —') AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY e.dept, e.emp_id;

-- Q4. All products with their category name.
SELECT
    p.product_name,
    cat.category_name,
    p.price,
    p.stock
FROM products p
JOIN categories cat ON p.category_id = cat.category_id;
-- 💬 INNER JOIN is fine here — all products have a category in our data.
--    Use LEFT JOIN if you want to guard against products without a category.

-- Q5. Customers with no orders.
SELECT
    c.full_name,
    c.email,
    c.city,
    c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ──────────────────────────────────────────
-- 🟡 MEDIUM
-- ──────────────────────────────────────────

-- Q6. Total spent per customer including $0 for non-buyers.
SELECT
    c.full_name                         AS customer_name,
    c.city,
    COUNT(o.order_id)                   AS total_orders,
    COALESCE(ROUND(SUM(o.total_amount), 2), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent DESC;

-- Q7. Product revenue including $0 for unordered products.
SELECT
    p.product_name,
    cat.category_name,
    COUNT(oi.item_id)                              AS times_ordered,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0)  AS total_revenue
FROM products p
JOIN      categories  cat ON p.category_id = cat.category_id
LEFT JOIN order_items oi  ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY total_revenue DESC;

-- Q8. Direct report count per manager.
SELECT
    m.name          AS manager_name,
    m.role          AS manager_role,
    COUNT(e.emp_id) AS direct_report_count
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
GROUP BY m.emp_id, m.name, m.role
ORDER BY direct_report_count DESC;

-- Q9. Total revenue per category for delivered orders (all categories shown).
SELECT
    cat.category_name,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0) AS total_revenue
FROM categories cat
LEFT JOIN products    p   ON p.category_id  = cat.category_id
LEFT JOIN order_items oi  ON oi.product_id  = p.product_id
LEFT JOIN orders      o   ON oi.order_id    = o.order_id AND o.status = 'Delivered'
GROUP BY cat.category_id, cat.category_name
ORDER BY total_revenue DESC;
-- 💬 The status filter is in the JOIN condition, not WHERE.
--    If it were in WHERE, we'd lose categories with no delivered orders entirely.
--    Putting it in the JOIN condition keeps all categories and just filters which
--    order_items are included in the aggregation.

-- Q10. Orders with item count and calculated total.
SELECT
    o.order_id,
    c.full_name       AS customer_name,
    o.order_date,
    o.status,
    COUNT(oi.item_id)                           AS num_items,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS calculated_total
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY o.order_id, c.full_name, o.order_date, o.status
ORDER BY o.order_id;

-- ──────────────────────────────────────────
-- 🔴 HARD
-- ──────────────────────────────────────────

-- Q11. Customers with at least one cancelled order.
SELECT
    c.full_name                                               AS customer_name,
    COUNT(o.order_id)                                         AS total_orders,
    SUM(CASE WHEN o.status = 'Cancelled'  THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN o.status = 'Delivered'  THEN 1 ELSE 0 END) AS delivered_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) >= 1;

-- Q12. Employees earning more than their manager.
SELECT
    e.name              AS employee_name,
    e.salary            AS employee_salary,
    m.name              AS manager_name,
    m.salary            AS manager_salary,
    e.salary - m.salary AS difference
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary
ORDER BY difference DESC;

-- Q13. Products ordered more than 3 times.
SELECT
    p.product_name,
    cat.category_name,
    COUNT(oi.item_id)                              AS times_in_orders,
    SUM(oi.quantity)                               AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)     AS total_revenue
FROM products p
JOIN categories   cat ON p.category_id = cat.category_id
JOIN order_items  oi  ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, cat.category_name
HAVING COUNT(oi.item_id) > 3
ORDER BY total_revenue DESC;

-- Q14. Customer segmentation with UNION.
SELECT 'VIP'     AS segment, c.full_name AS customer_name, c.city,
       ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
HAVING SUM(o.total_amount) > 1000

UNION ALL

SELECT 'Regular', c.full_name, c.city,
       ROUND(SUM(o.total_amount), 2)
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
HAVING SUM(o.total_amount) <= 1000

UNION ALL

SELECT 'Inactive', c.full_name, c.city, 0
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL

ORDER BY segment, total_spent DESC;

-- Q15. Employee vs department average salary.
SELECT
    e.name,
    e.dept,
    e.salary,
    dept_avg.avg_salary                     AS dept_avg_salary,
    ROUND(e.salary - dept_avg.avg_salary, 2) AS difference,
    CASE
        WHEN e.salary > dept_avg.avg_salary THEN 'Above Average'
        WHEN e.salary < dept_avg.avg_salary THEN 'Below Average'
        ELSE                                     'Average'
    END                                     AS vs_dept_avg
FROM employees e
JOIN (
    SELECT dept, ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY dept
) dept_avg ON e.dept = dept_avg.dept
ORDER BY e.dept, e.salary DESC;

-- Q16. Full line-item detail for New York customers, delivered orders only.
SELECT
    c.full_name      AS customer,
    o.order_date,
    o.status,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers   c   ON o.customer_id = c.customer_id
JOIN order_items oi  ON oi.order_id   = o.order_id
JOIN products    p   ON oi.product_id = p.product_id
JOIN categories  cat ON p.category_id = cat.category_id
WHERE c.city = 'New York'
  AND o.status = 'Delivered'
ORDER BY o.order_date, p.product_name;

-- ──────────────────────────────────────────
-- 💡 BONUS — Q17 Explanation
-- ──────────────────────────────────────────

-- Query A: COUNT(o.order_id)
SELECT c.full_name, COUNT(o.order_id) AS cnt
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

-- Query B: COUNT(*)
SELECT c.full_name, COUNT(*) AS cnt
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

-- EXPLANATION:
-- Query A: COUNT(o.order_id) skips NULLs.
--   → Karen and Leo show 0 (their order_id is NULL from the LEFT JOIN)
--
-- Query B: COUNT(*) counts ALL rows including those with NULL.
--   → Karen and Leo show 1 (the row exists, just has NULL values)
--
-- For LEFT JOIN + COUNT, ALWAYS use COUNT(right_table.key) to get 0 for unmatched rows.
-- COUNT(*) in this context is almost always a BUG.
