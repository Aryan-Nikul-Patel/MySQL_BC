-- ============================================================
-- 🔑 MODULE 10 — Practice Solutions (Bonus Topics)
-- ============================================================

USE sql_course_m10;

-- 🟢 Q1 (Easy):
-- Create a view named `v_low_stock` showing inventory with quantity < 15.

CREATE OR REPLACE VIEW v_low_stock AS
SELECT * 
FROM inventory
WHERE quantity < 15;

-- 💬 Explanation:
-- CREATE OR REPLACE VIEW creates a new view or updates it if it already exists. 
-- It saves the SELECT query under `v_low_stock` name.


-- 🟡 Q2 (Medium):
-- Update the quantity of 'Standing Desk' to 6 through the view `v_low_stock`.

UPDATE v_low_stock
SET quantity = 6
WHERE product = 'Standing Desk';

SELECT product, quantity FROM inventory WHERE product = 'Standing Desk';

-- 💬 Explanation:
-- The view `v_low_stock` is updatable because it references a single base table (`inventory`)
-- and contains no complex expressions, joins, distinct keyword, or aggregate functions.
-- Updates directed to it are transparently applied to the `inventory` table.


-- 🟡 Q3 (Medium):
-- Create a stored procedure named `UpdateStockQuantity` to modify product stock.

DROP PROCEDURE IF EXISTS UpdateStockQuantity;

DELIMITER //
CREATE PROCEDURE UpdateStockQuantity(
    IN p_product_name VARCHAR(50),
    IN p_qty_change INT
)
BEGIN
    UPDATE inventory
    SET quantity = quantity + p_qty_change
    WHERE product = p_product_name;
END //
DELIMITER ;

-- 💬 Explanation:
-- DELIMITER // changes the command terminator so MySQL doesn't treat the inner semicolons as query endings.
-- Inside the procedure, we run a parameter-driven UPDATE statement to alter the inventory table.


-- 🔴 Q4 (Hard):
-- Create a stored procedure named `CheckInventoryValue` with an OUT parameter.

DROP PROCEDURE IF EXISTS CheckInventoryValue;

DELIMITER //
CREATE PROCEDURE CheckInventoryValue(
    IN p_id INT,
    OUT p_value DECIMAL(10,2)
)
BEGIN
    SELECT quantity * price
    INTO p_value
    FROM inventory
    WHERE id = p_id;
END //
DELIMITER ;

-- Test call:
CALL CheckInventoryValue(1, @laptop_val);
SELECT @laptop_val AS laptop_total_value;

-- 💬 Explanation:
-- The INTO clause captures the query output and writes it to the output parameter `p_value`.
-- To capture output during execution, we declare session variable `@laptop_val` and call the procedure with it.


-- 🔴 Q5 (Hard):
-- Create an AFTER DELETE trigger on the `inventory` table named `after_inventory_delete`.

DROP TRIGGER IF EXISTS after_inventory_delete;

DELIMITER //
CREATE TRIGGER after_inventory_delete
AFTER DELETE ON inventory
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, details)
    VALUES (
        'inventory',
        'DELETE',
        OLD.id,
        CONCAT('Deleted Product: ', OLD.product, ' | Value was $', (OLD.quantity * OLD.price))
    );
END //
DELIMITER ;

-- Test it out by deleting an item and checking the audit log:
DELETE FROM inventory WHERE product = 'Mixing Bowl Set';
SELECT * FROM audit_log;

-- 💬 Explanation:
-- AFTER DELETE trigger captures record details after removal.
-- We use the `OLD` prefix to read columns of the deleted row (e.g. `OLD.product`, `OLD.quantity`).


-- 🟡 Q6 (Medium):
-- Manipulate a temporary table for kitchenware category.

CREATE TEMPORARY TABLE temp_kitchen AS
SELECT * 
FROM inventory
WHERE category = 'Kitchenware';

UPDATE temp_kitchen
SET price = price * 1.10;

SELECT * FROM temp_kitchen;

DROP TEMPORARY TABLE IF EXISTS temp_kitchen;

-- 💬 Explanation:
-- CREATE TEMPORARY TABLE creates a temporary session table.
-- It supports updates and queries identically to standard tables, but is isolated from other sessions and gets dropped automatically on disconnect.


-- 🟡 Q7 (Medium):
-- Write a transaction block that locks the inventory row for 'Monitor 27"' using pessimistic locking.

START TRANSACTION;

SELECT id, product, quantity
FROM inventory
WHERE product = 'Monitor 27"'
FOR UPDATE;

UPDATE inventory
SET quantity = 10
WHERE product = 'Monitor 27"';

COMMIT;

-- 💬 Explanation:
-- The `FOR UPDATE` clause places an exclusive lock on the queried row, preventing concurrent updates or locks by other transactions until we execute `COMMIT`.
