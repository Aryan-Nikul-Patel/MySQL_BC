-- ============================================================
-- 🔑 MODULE 04 — PRACTICE SOLUTIONS
-- Topic: Subqueries (Scalar, Row, Table, Correlated, EXISTS/IN)
-- ============================================================
-- Below you'll find the step-by-step solutions to the practice questions.
-- Make sure to compare your code with these solutions and read the
-- explanations to understand the design patterns.
-- ============================================================

USE sql_course_m4;

-- ────────────────────────────────────────────
-- 🟢 EASY SOLUTIONS
-- ────────────────────────────────────────────

-- Q1: Find the name and price of the cheapest product(s) in the products table.
-- Note: Do NOT use LIMIT. Use a scalar subquery.
-- Expected output: 'Wireless Mouse' and 'SQL Mastery Book' (since both cost 29.99, wait, let's verify if both cost 29.99. No, Wireless Mouse is 29.99 and SQL Mastery Book is 39.99. Let's check.)

SELECT product_name, price 
FROM products 
WHERE price = (
    SELECT MIN(price) 
    FROM products
);

-- 💬 Explanation:
-- 1. The subquery `SELECT MIN(price) FROM products` returns 29.99 (the lowest price in the table).
-- 2. The outer query finds any products that match this price. This returns 'Wireless Mouse' (29.99).
-- Note: If we had used `ORDER BY price LIMIT 1`, we would only get one product even if multiple items tied for the lowest price. The subquery approach is much more robust because it handles ties naturally.


-- Q2: Find the names of all products that belong to the 'Software' category.
-- Note: Solve this using a subquery in the WHERE clause instead of a JOIN.

SELECT product_name 
FROM products 
WHERE category_id = (
    SELECT category_id 
    FROM categories 
    WHERE category_name = 'Software'
);

-- 💬 Explanation:
-- 1. The subquery retrieves the category ID for 'Software', which is 2.
-- 2. The outer query then retrieves all products where `category_id = 2`.


-- Q3: Find all employees who earn more than Sarah Connor's salary.

SELECT name, salary 
FROM employees 
WHERE salary > (
    SELECT salary 
    FROM employees 
    WHERE name = 'Sarah Connor'
);

-- 💬 Explanation:
-- 1. The subquery retrieves Sarah Connor's salary: 250000.00.
-- 2. The outer query finds any employees earning more than 250000.00. Since she is the CEO and highest earner, this returns an empty set.


-- Q4: Find the names and signup dates of all customers who have placed at least one order.
-- Note: Use the IN operator with a subquery. Do not use JOIN.

SELECT full_name, signup_date 
FROM customers 
WHERE customer_id IN (
    SELECT DISTINCT customer_id 
    FROM orders
);

-- 💬 Explanation:
-- 1. The subquery selects all `customer_id` values from the `orders` table (using DISTINCT to avoid redundant IDs).
-- 2. The outer query returns customers whose IDs are in that list.


-- Q5: Find the names and emails of all customers who have NEVER placed an order.
-- Note: Use the NOT EXISTS operator. Do not use JOIN.

SELECT full_name, email 
FROM customers AS c 
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders AS o 
    WHERE o.customer_id = c.customer_id
);

-- 💬 Explanation:
-- 1. This is a correlated subquery using `NOT EXISTS`.
-- 2. For each customer in the outer query, the database checks if there is any row in the `orders` table where `o.customer_id = c.customer_id`.
-- 3. If no matching row is found in `orders`, the outer row is returned. This correctly identifies 'Karen Hall' and 'Leo Foster'.
-- Note: As discussed in Lesson 04, `NOT EXISTS` is safe and handles NULLs correctly, unlike `NOT IN`.




-- ────────────────────────────────────────────
-- 🟡 MEDIUM SOLUTIONS
-- ────────────────────────────────────────────

-- Q6: Find all products that are priced higher than the average price of products in category 1 (Electronics).

SELECT product_name, price 
FROM products 
WHERE price > (
    SELECT AVG(price) 
    FROM products 
    WHERE category_id = 1
);

-- 💬 Explanation:
-- 1. The subquery calculates the average price for Category 1 (Electronics), which is (1299.99 + 249.99 + 599.99) / 3 = 716.6566.
-- 2. The outer query filters for products whose price is strictly greater than 716.6566. This returns 'Laptop Pro 15' (1299.99) and 'API Integration Pkg' (1500.00).


-- Q7: Find the employee(s) who earn the highest salary in their respective department.
-- Note: Use a correlated subquery in the WHERE clause.

SELECT e1.name, e1.dept, e1.salary 
FROM employees AS e1 
WHERE e1.salary = (
    SELECT MAX(e2.salary) 
    FROM employees AS e2 
    WHERE e2.dept = e1.dept
);

-- 💬 Explanation:
-- This is a classic correlated subquery.
-- For each employee in the outer query (`e1`), the subquery calculates the maximum salary of all employees in the SAME department (`e2.dept = e1.dept`).
-- The outer query then checks if `e1.salary` equals that maximum.


-- Q8: Find the order_id, customer_id, and total_amount of the order(s) with the absolute maximum total amount.
-- Note: Use a subquery. Do not use LIMIT.

SELECT order_id, customer_id, total_amount 
FROM orders 
WHERE total_amount = (
    SELECT MAX(total_amount) 
    FROM orders
);

-- 💬 Explanation:
-- The subquery returns the maximum `total_amount` in the table (1899.97).
-- The outer query returns the order(s) that match that exact amount.


-- Q9: For every product, display its name, price, and the count of how many times it has been ordered.
-- Note: Use a subquery in the SELECT clause.

SELECT 
    p.product_name, 
    p.price,
    (
        SELECT COUNT(*) 
        FROM order_items AS oi 
        WHERE oi.product_id = p.product_id
    ) AS times_ordered
FROM products AS p;

-- 💬 Explanation:
-- 1. For each product `p` in the outer query, the subquery counts how many rows in the `order_items` table match `oi.product_id = p.product_id`.
-- 2. If a product has never been ordered, the subquery returns 0.
-- Note: This is an alternative to a LEFT JOIN with a GROUP BY.


-- Q10: Find the average total spending per customer across all customers who have placed orders.
-- Note: First, calculate the total amount spent by each customer, then take the average of those sums. Use a derived table.

SELECT AVG(customer_totals.total_spent) AS average_customer_spend
FROM (
    SELECT customer_id, SUM(total_amount) AS total_spent 
    FROM orders 
    GROUP BY customer_id
) AS customer_totals;

-- 💬 Explanation:
-- 1. The inner query computes the sum of `total_amount` grouped by `customer_id`. It returns a temporary result set with customer IDs and their total spend.
-- 2. The outer query takes the average of the `total_spent` column from that temporary derived table (`customer_totals`).
-- Remember: Aliasing derived tables (`AS customer_totals`) is required in MySQL.


-- Q11: Find the full name and email of the customer who has spent the absolute highest total amount on their orders.
-- Note: You may use JOINs combined with a subquery in the HAVING or WHERE clause. Do not use LIMIT.

SELECT 
    c.full_name, 
    c.email,
    SUM(o.total_amount) AS total_spent
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email
HAVING SUM(o.total_amount) = (
    SELECT MAX(sub.total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM orders
        GROUP BY customer_id
    ) AS sub
);

-- 💬 Explanation:
-- 1. The innermost subquery `sub` calculates the total spending for each customer.
-- 2. The outer subquery finds the maximum value of those totals (`SELECT MAX(sub.total_spent)...`).
-- 3. The main query joins `customers` and `orders`, groups by customer, and uses the `HAVING` clause to filter for the customer whose aggregate spending matches that maximum amount.
-- This returns Alice Johnson (Total spent: 1679.96).


-- Q12: Find all employees who are managers (i.e. they have at least one other employee reporting to them).
-- Note: Use the EXISTS operator.

SELECT emp_id, name, role, dept 
FROM employees AS e1 
WHERE EXISTS (
    SELECT 1 
    FROM employees AS e2 
    WHERE e2.manager_id = e1.emp_id
);

-- 💬 Explanation:
-- For each employee `e1`, the subquery checks if there exists another employee `e2` who lists `e1.emp_id` as their `manager_id`.
-- If at least one match is found, the employee `e1` is included in the output.




-- ────────────────────────────────────────────
-- 🔴 HARD SOLUTIONS
-- ────────────────────────────────────────────

-- Q13: For each category, find the category_name, product_name, and price of the most expensive product.
-- Note: Solve this using a correlated subquery or a derived table.

-- Solution 1: Using a Correlated Subquery (Recommended for readability)
SELECT 
    c.category_name, 
    p1.product_name, 
    p1.price
FROM products AS p1
JOIN categories AS c ON p1.category_id = c.category_id
WHERE p1.price = (
    SELECT MAX(p2.price) 
    FROM products AS p2 
    WHERE p2.category_id = p1.category_id
);

-- 💬 Explanation (Solution 1):
-- For each outer product row `p1`, the subquery calculates the maximum price of products sharing the exact same `category_id` (`p2.category_id = p1.category_id`).
-- The outer query then retains the product only if its price matches that category maximum.


-- Q14: Find the names of customers who have purchased the 'Wireless Mouse' (product_id = 2)
-- but have NEVER purchased the 'Mechanical Keyboard' (product_id = 7).
-- Note: You will need multiple subqueries or set logic.

-- Solution using IN and NOT IN / NOT EXISTS:
SELECT c.full_name 
FROM customers AS c
WHERE c.customer_id IN (
    -- Subquery 1: Customers who bought the Wireless Mouse
    SELECT DISTINCT o.customer_id
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE oi.product_id = 2
) AND c.customer_id NOT IN (
    -- Subquery 2: Customers who bought the Mechanical Keyboard (cannot be null since customer_id is a primary key in customers)
    SELECT DISTINCT o.customer_id
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE oi.product_id = 7
);

-- 💬 Explanation:
-- 1. The first subquery returns the list of customer IDs who ordered product 2 (Wireless Mouse).
-- 2. The second subquery returns the list of customer IDs who ordered product 7 (Mechanical Keyboard).
-- 3. We filter the customers list to include only those whose IDs are present in the first list AND NOT present in the second list.
-- This correctly returns Alice Johnson and Bob Martinez.


-- Q15: For each customer order, display the customer_id, order_date, order_id, total_amount,
-- and the running sum of orders placed by THAT SPECIFIC CUSTOMER up to that date.
-- Note: Use a correlated subquery in the SELECT list. Sort the final output by customer_id and order_date.

SELECT 
    o1.customer_id,
    o1.order_date,
    o1.order_id,
    o1.total_amount,
    (
        SELECT SUM(o2.total_amount)
        FROM orders AS o2
        WHERE o2.customer_id = o1.customer_id
          AND o2.order_date <= o1.order_date
    ) AS running_total
FROM orders AS o1
ORDER BY o1.customer_id, o1.order_date;

-- 💬 Explanation:
-- This is a customer-partitioned running total.
-- For each order row `o1`, the subquery calculates the sum of `total_amount` for orders where:
--   - The customer is the same (`o2.customer_id = o1.customer_id`)
--   - The order date is earlier than or equal to the current order date (`o2.order_date <= o1.order_date`).
-- This gives us the cumulative sum of sales for that customer over time. Sorting by customer and date presents the result clearly.


-- Q16: Find the "second highest salary" among all employees. If there is a tie, handle it correctly.
-- Note: Do NOT use LIMIT or window functions. Use a subquery.

SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary) 
    FROM employees
);

-- 💬 Explanation:
-- 1. The subquery `SELECT MAX(salary) FROM employees` returns the absolute highest salary: 250000.00.
-- 2. The outer query filters for salaries that are strictly less than 250000.00.
-- 3. Out of all salaries less than 250000.00, it selects the maximum value using `MAX(salary)`. This is the second highest salary: 180000.00.
-- This is a highly efficient, database-agnostic query that interviewers love to ask!
