-- ============================================================
-- 📘 MODULE 10 — Bonus (Views, Procedures, Triggers)
-- Lesson 03: Database Triggers
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - What are database triggers and their use cases
--    - BEFORE and AFTER triggers
--    - Using NEW and OLD keywords (Crucial concept!)
--    - Building an audit logging trigger
--
-- 💡 Prerequisites: Module 10, Lesson 2
-- ============================================================

USE sql_course_m10;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What is a Trigger & Hook Events
-- ────────────────────────────────────────────
-- 💬 A **Trigger** is a named database object that is associated with a table, and activates
--    (fires) automatically when a specific data modification event occurs on that table:
--       - `INSERT`
--       - `UPDATE`
--       - `DELETE`
--
--    Triggers can execute either:
--       - `BEFORE` the change is saved (ideal for validating data or setting defaults).
--       - `AFTER` the change is saved (ideal for logging or syncing status across other tables).
--
-- 🔥 Critical Interview Concept: NEW vs OLD modifiers.
--    Inside the trigger body, you can reference columns using `NEW.column_name` and `OLD.column_name`:
--    - **INSERT Triggers:** Have access to `NEW` values only (there is no previous row).
--    - **DELETE Triggers:** Have access to `OLD` values only (the row is being deleted).
--    - **UPDATE Triggers:** Have access to both `OLD` (original state) and `NEW` (updated state) values.

-- ▶ Example 1.1: Creating an Audit Trigger for Inventory Updates
--    When a row in `inventory` is updated, we log the details in the `audit_log` table.
DELIMITER //

CREATE TRIGGER after_inventory_update
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    -- Check if quantity or price changed
    IF OLD.quantity != NEW.quantity OR OLD.price != NEW.price THEN
        INSERT INTO audit_log (table_name, action, record_id, details)
        VALUES (
            'inventory', 
            'UPDATE', 
            NEW.id, 
            CONCAT(
                'Product: ', NEW.product, 
                ' | Quantity changed from ', OLD.quantity, ' to ', NEW.quantity,
                ' | Price changed from $', OLD.price, ' to $', NEW.price
            )
        );
    END IF;
END //

DELIMITER ;

-- ▶ Example 1.2: Triggering the Event
--    Let's perform an update on a row and see if the trigger automatically records it.
UPDATE inventory
SET quantity = 18, price = 1150.00
WHERE product = 'Laptop Pro';

-- View the audit trail table to verify the trigger worked!
SELECT * FROM audit_log;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: BEFORE Triggers for Data Validation
-- ────────────────────────────────────────────
-- 💬 BEFORE triggers are typically used to validate values or abort operations if constraints are broken.
--    In MySQL, you can abort a transaction by throwing a custom SQLSTATE exception using the `SIGNAL` command.

-- ▶ Example 2.1: Preventing negative values in inventory
DELIMITER //

CREATE TRIGGER before_inventory_insert
BEFORE INSERT ON inventory
FOR EACH ROW
BEGIN
    -- Throw error if quantity is negative
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Quantity cannot be negative!';
    END IF;
END //

DELIMITER ;

-- ▶ Example 2.2: Test insertion violation
--    Uncommenting the query below will cause a database error and abort the insertion!
-- INSERT INTO inventory (product, category, quantity, price) 
-- VALUES ('Broken Keyboard', 'Electronics', -10, 5.00);

-- Cleanup triggers for consecutive runs
DROP TRIGGER IF EXISTS after_inventory_update;
DROP TRIGGER IF EXISTS before_inventory_insert;
