-- ============================================================
-- ✏️  MODULE 03 — Practice Questions
-- ============================================================
--
-- Instructions:
--   1. Run setup.sql first
--   2. Write your query below each question
--   3. Check solutions.sql if stuck
--
-- Tables: customers | orders | order_items | products | categories | employees
-- ============================================================

USE sql_course_m3;

-- ──────────────────────────────────────────
-- 🟢 EASY — Basic JOINs
-- ──────────────────────────────────────────

-- Q1. List all orders with the customer's full name and city.
--     Show: order_id, order_date, status, total_amount, customer_name, city
--     Order by: order_date DESC
-- YOUR QUERY:


-- Q2. List all order items with the product name and its category name.
--     Show: item_id, product_name, category_name, quantity, unit_price
--     Order by: category_name, product_name
-- YOUR QUERY:


-- Q3. Show each employee with their direct manager's name.
--     Include employees with no manager (CEO).
--     Show: employee_name, employee_role, manager_name
-- YOUR QUERY:


-- Q4. List all products with their category name.
--     Include ALL products, even if somehow they had no category.
--     Show: product_name, category_name, price, stock
-- YOUR QUERY:


-- Q5. Find all customers who have NEVER placed an order.
--     Show: full_name, email, city, signup_date
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🟡 MEDIUM — JOINs + Aggregation
-- ──────────────────────────────────────────

-- Q6. How much has each customer spent in total?
--     Show ALL customers including those with no orders (show 0 for them).
--     Show: customer_name, city, total_orders, total_spent
--     Order by: total_spent DESC
-- YOUR QUERY:


-- Q7. How many times has each product been ordered and what is its total revenue?
--     Show ALL products, including those never ordered (show 0 for revenue).
--     Show: product_name, category_name, times_ordered, total_revenue
--     Order by: total_revenue DESC
-- YOUR QUERY:


-- Q8. How many direct reports does each manager have?
--     Show: manager_name, manager_role, direct_report_count
--     Order by: direct_report_count DESC
-- YOUR QUERY:


-- Q9. What is the total revenue per product category?
--     (Only count delivered orders — use WHERE o.status = 'Delivered')
--     Show ALL categories, even those with no revenue (show 0).
--     Show: category_name, total_revenue
--     Order by: total_revenue DESC
-- YOUR QUERY:


-- Q10. List all orders with the number of items and the calculated total
--      (sum of quantity × unit_price per order).
--      Show: order_id, customer_name, order_date, status,
--            num_items, calculated_total
--      Order by: order_id
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🔴 HARD — Complex JOINs + Conditions
-- ──────────────────────────────────────────

-- Q11. Find customers who have placed orders but have at least one CANCELLED order.
--      Show: customer_name, total_orders, cancelled_orders, delivered_orders
-- YOUR QUERY:


-- Q12. Find all employees who earn MORE than their direct manager.
--      Show: employee_name, employee_salary, manager_name, manager_salary, difference
-- YOUR QUERY:


-- Q13. Find products that have been ordered MORE than 3 times (count item rows).
--      Show: product_name, category_name, times_in_orders, total_units_sold, total_revenue
--      Order by: total_revenue DESC
-- YOUR QUERY:


-- Q14. Write a customer segmentation query using UNION:
--      Segment 1: 'VIP'     — customers who spent more than $1,000 total
--      Segment 2: 'Regular' — customers who ordered but spent $1,000 or less
--      Segment 3: 'Inactive'— customers who never ordered
--      Show: segment, customer_name, city, total_spent
--      Order by: segment, total_spent DESC
-- YOUR QUERY:


-- Q15. For each employee, show their name, salary, department average salary,
--      and whether they are 'Above Average', 'Below Average', or 'Average'
--      compared to their department.
--      Hint: You'll need a subquery for the department average.
-- YOUR QUERY:


-- Q16. Show each order with its full line-item breakdown:
--      customer name, order date, order status,
--      product name, category, quantity, unit price, line total.
--      Filter: ONLY include orders from customers in 'New York'
--              AND only 'Delivered' orders.
--      Order by: order_date, product_name
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 💡 BONUS — Think about this
-- ──────────────────────────────────────────

-- Q17. What's the difference between these two queries?
--      Run both and compare the row counts. Explain WHY they differ.
--
--      Query A:
--      SELECT c.full_name, COUNT(o.order_id) AS cnt
--      FROM customers c
--      LEFT JOIN orders o ON c.customer_id = o.customer_id
--      GROUP BY c.customer_id, c.full_name;
--
--      Query B:
--      SELECT c.full_name, COUNT(*) AS cnt
--      FROM customers c
--      LEFT JOIN orders o ON c.customer_id = o.customer_id
--      GROUP BY c.customer_id, c.full_name;
--
-- YOUR ANSWER (comment):
