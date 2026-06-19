-- ============================================================
-- ✏️ MODULE 10 — Practice Questions (Bonus Topics)
-- ============================================================
-- 
-- Instructions:
--   Write your queries below each question.
--   Run each query to verify your answer.
--   Solutions are in: solutions.sql
-- ============================================================

USE sql_course_m10;

-- 🟢 Q1 (Easy):
-- Create a view named `v_low_stock` that displays all columns from the `inventory` table
-- for items where `quantity` is strictly less than 15.
-- YOUR QUERY:



-- 🟡 Q2 (Medium):
-- Test if the view `v_low_stock` is updatable.
-- Write a query to update the quantity of 'Standing Desk' to 6 through the view `v_low_stock`.
-- Verify that the change is reflected in the underlying `inventory` table.
-- Explain in a comment why it worked.
-- YOUR QUERY:



-- 🟡 Q3 (Medium):
-- Create a stored procedure named `UpdateStockQuantity` that accepts:
--   - An input parameter `p_product_name` (VARCHAR(50))
--   - An input parameter `p_qty_change` (INT)
-- The procedure should update the `inventory` table, adding `p_qty_change` to the `quantity`
-- of the product matching `p_product_name`.
-- Remember to use appropriate DELIMITER declarations!
-- YOUR QUERY:



-- 🔴 Q4 (Hard):
-- Create a stored procedure named `CheckInventoryValue` that accepts:
--   - An input parameter `p_id` (INT)
--   - An output parameter `p_value` (DECIMAL(10,2))
-- The procedure should calculate the total inventory value (quantity * price) for the product with id = `p_id`
-- and store it in `p_value`.
-- Test calling the procedure for product ID = 1 (Laptop Pro) and printing the output.
-- YOUR QUERY:



-- 🔴 Q5 (Hard):
-- Create an AFTER DELETE trigger on the `inventory` table named `after_inventory_delete`.
-- When a product is deleted from inventory:
--   - Insert a row into the `audit_log` table.
--   - The `action` should be 'DELETE'.
--   - The `record_id` should be the ID of the deleted product.
--   - The `details` should contain: "Deleted Product: [product name] | Value was $[quantity * price]".
-- Use the OLD keyword to access deleted row columns.
-- YOUR QUERY:



-- 🟡 Q6 (Medium):
-- Write a query to do the following:
--   1. Create a temporary table named `temp_kitchen` containing all products in the 'Kitchenware' category.
--   2. Update all prices in the temporary table to increase by 10% (multiply by 1.10).
--   3. Select all rows from the temporary table to inspect the changes.
--   4. Drop the temporary table.
-- YOUR QUERY:



-- 🟡 Q7 (Medium):
-- Write a transaction block that locks the inventory row for 'Monitor 27"' using pessimistic locking.
-- Update its quantity to 10 and commit the transaction.
-- YOUR QUERY:
