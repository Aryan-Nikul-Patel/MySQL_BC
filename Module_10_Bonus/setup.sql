-- ============================================================
-- 🛠️ MODULE 10: Bonus — Setup Script
-- Database: sql_course_m10
-- ============================================================

CREATE DATABASE IF NOT EXISTS sql_course_m10;
USE sql_course_m10;

-- 1. Drop existing tables if they exist
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS inventory;

-- 2. Create tables
CREATE TABLE inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,
    record_id INT NOT NULL,
    details TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Populate inventory (15 rows)
INSERT INTO inventory (product, category, quantity, price) VALUES
('Laptop Pro', 'Electronics', 15, 1200.00),
('Smartphone X', 'Electronics', 30, 800.00),
('Wireless Mouse', 'Electronics', 100, 25.00),
('USB-C Hub', 'Electronics', 50, 40.00),
('Desk Chair', 'Furniture', 10, 150.00),
('Standing Desk', 'Furniture', 5, 450.00),
('LED Lamp', 'Furniture', 25, 30.00),
('Coffee Mug', 'Kitchenware', 200, 12.00),
('Water Bottle', 'Kitchenware', 80, 20.00),
('Chef Knife', 'Kitchenware', 15, 75.00),
('Bluetooth Speaker', 'Electronics', 40, 60.00),
('Monitor 27"', 'Electronics', 12, 300.00),
('Bookshelf', 'Furniture', 8, 120.00),
('Mixing Bowl Set', 'Kitchenware', 35, 35.00),
('Frying Pan 10"', 'Kitchenware', 20, 50.00);
