-- ============================================================
-- 📘 MODULE 10 — Bonus (Views, Procedures, Triggers)
-- Lesson 02: Stored Procedures
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - What are Stored Procedures and when to use them
--    - The DELIMITER statement (crucial for script parsing)
--    - IN and OUT parameters
--    - Basic control flow (IF-THEN-ELSE)
--    - Executing procedures with CALL
--
-- 💡 Prerequisites: Module 10, Lesson 1
-- ============================================================

USE sql_course_m10;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What is a Stored Procedure & DELIMITER
-- ────────────────────────────────────────────
-- 💬 A **Stored Procedure** is a batch of SQL statements compiled and saved in the database server.
--    Instead of sending multiple individual queries from your application over the network,
--    you execute a single command: `CALL procedure_name()`.
--
--    Benefits:
--       - **Reduced Network Traffic:** Multiple statements execute locally on the database server.
--       - **Security:** Users can be granted permission to run a procedure without having read/write
--         access to the underlying raw tables.
--
--    ⚠️ THE DELIMITER TRAP:
--    A standard SQL statement ends with a semicolon `;`.
--    However, a stored procedure contains multiple statements, each ending with a semicolon.
--    If we send a `CREATE PROCEDURE` script to MySQL, the engine sees the first semicolon INSIDE the procedure
--    and stops parsing, resulting in a syntax error.
--    To fix this, we use the `DELIMITER //` statement to temporarily change the end-of-statement symbol to `//`.
--    At the end of the procedure creation, we restore the delimiter back to `;`.

-- ▶ Example 1.1: Creating and Calling a Basic Procedure (No Parameters)
DELIMITER //

CREATE PROCEDURE GetLowStockItems()
BEGIN
    SELECT product, quantity, price
    FROM inventory
    WHERE quantity < 10
    ORDER BY quantity ASC;
END //

DELIMITER ;

-- Call the procedure
CALL GetLowStockItems();


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Parameters (IN and OUT)
-- ────────────────────────────────────────────
-- 💬 Procedures can accept parameters:
--    - `IN`: Input parameter passed from the caller (default if not specified).
--    - `OUT`: Output parameter returned back to the caller.
--    - `INOUT`: Parameter that acts as both input and output.

-- ▶ Example 2.1: Procedure with IN and OUT parameters and IF logic
--    Given a category, return the total count of distinct products in that category.
--    Additionally, set a status text depending on the size of the inventory category.
DELIMITER //

CREATE PROCEDURE GetCategorySummary(
    IN p_category VARCHAR(50),
    OUT p_product_count INT,
    OUT p_stock_status VARCHAR(50)
)
BEGIN
    -- 1. Count product rows in category and write to output parameter
    SELECT COUNT(*) 
    INTO p_product_count
    FROM inventory
    WHERE category = p_category;
    
    -- 2. Evaluate conditional logic to determine status
    IF p_product_count > 5 THEN
        SET p_stock_status = 'Well Stocked Category';
    ELSEIF p_product_count BETWEEN 1 AND 5 THEN
        SET p_stock_status = 'Under Stocked Category';
    ELSE
        SET p_stock_status = 'Empty Category';
    END IF;
END //

DELIMITER ;

-- ▶ Example 2.2: Calling a Procedure with OUT parameters
--    To receive the output values, we pass user-defined session variables prefixed with `@`.
CALL GetCategorySummary('Electronics', @count_out, @status_out);

SELECT @count_out AS products_in_electronics, @status_out AS category_status;

-- Cleanup procedure declarations for consecutive runs
DROP PROCEDURE IF EXISTS GetLowStockItems;
DROP PROCEDURE IF EXISTS GetCategorySummary;
