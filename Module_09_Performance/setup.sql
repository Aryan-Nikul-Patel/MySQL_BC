-- ============================================================
-- 🛠️ MODULE 09: Performance & Optimization — Setup Script
-- Database: sql_course_m9
-- ============================================================

CREATE DATABASE IF NOT EXISTS sql_course_m9;
USE sql_course_m9;

-- 1. Drop table if exists
DROP TABLE IF EXISTS large_orders;

-- 2. Create table
CREATE TABLE large_orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- 3. Populate large_orders with 500+ rows dynamically using a recursive CTE seed.
--    This builds a realistic transactional dataset.
INSERT INTO large_orders (customer_id, product_id, amount, order_date, region)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT 
    FLOOR(1 + (RAND(n * 123) * 100)) AS customer_id,       -- 100 unique customers
    FLOOR(1 + (RAND(n * 456) * 50)) AS product_id,         -- 50 unique products
    ROUND(10.0 + (RAND(n * 789) * 990.0), 2) AS amount,     -- Amount between $10 and $1000
    DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND(n * 321) * 365) DAY) AS order_date, -- Random date in 2025
    CASE FLOOR(RAND(n * 654) * 4)
        WHEN 0 THEN 'North'
        WHEN 1 THEN 'East'
        WHEN 2 THEN 'South'
        ELSE 'West'
    END AS region
FROM seq;
