-- ============================================================
-- 📘 MODULE 08 — Interview Problem Patterns
-- Lesson 04: Duplicate Detection and Deletion
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Identifying duplicate records based on columns
--    - Selecting full rows for duplicate data
--    - Removing duplicates while preserving the first/last entry
--    - 🔥 The MySQL delete-from-same-table subquery trap and workaround
--
-- 💡 Prerequisites: Module 8, Lesson 3
-- ============================================================

USE sql_course_m8;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Finding Duplicate Records
-- ────────────────────────────────────────────
-- 💬 Duplicates can creep into systems due to race conditions, poor API retry logic,
--    or lack of unique constraints.
--    Finding them is simple: GROUP BY the fields that define the duplicate and filter with `HAVING COUNT(*) > 1`.
--    To select the full original rows, JOIN the aggregated duplicates back to the original table.

-- ▶ Example 1.1: Find duplicate emails in contacts
SELECT email, COUNT(*) AS email_occurrences
FROM contacts
GROUP BY email
HAVING COUNT(*) > 1;

-- ▶ Example 1.2: Fetch complete details of contacts with duplicate emails
SELECT c.id, c.name, c.email, c.phone
FROM contacts c
JOIN (
    SELECT email
    FROM contacts
    GROUP BY email
    HAVING COUNT(*) > 1
) dup ON c.email = dup.email
ORDER BY c.email;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Deleting Duplicates (Keeping exactly one)
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: Deleting duplicates but leaving one row.
--    Normally, you want to keep either:
--    - The row with the SMALLEST ID (first/oldest record).
--    - The row with the LARGEST ID (newest record).
--
--    Standard SQL approach:
--    `DELETE FROM contacts WHERE id NOT IN (SELECT MIN(id) FROM contacts GROUP BY email)`
--
--    ⚠️ THE MYSQL TRAP:
--    If you run the query above in MySQL, it will fail with:
--    `ERROR 1093 (HY000): You can't specify target table 'contacts' for update in FROM clause`
--    MySQL prevents you from modifying a table that is being referenced in the subquery of the query.
--
--    Workaround A: Nest the subquery in another subquery, creating a temporary derived table.
--    Workaround B: Use an INNER JOIN inside the DELETE statement (cleaner and faster).

-- ▶ Example 2.1: MySQL Workaround A (Nested Subquery)
--    We wrap the subquery in another `SELECT * FROM (...) AS temp`, which forces MySQL to evaluate
--    the subquery and build a temporary table before performing the delete.
--    (Note: We wrap this in a transaction block so we can ROLLBACK and demonstrate Workaround B).
START TRANSACTION;

DELETE FROM contacts
WHERE id NOT IN (
    SELECT min_id 
    FROM (
        -- This temporary block isolates the select from the delete execution
        SELECT MIN(id) AS min_id
        FROM contacts
        GROUP BY email
    ) AS temp
);

SELECT * FROM contacts;
ROLLBACK; -- Restores the table back to containing duplicates


-- ▶ Example 2.2: MySQL Workaround B (Self-Join Delete — Recommended!)
--    We join the table to itself on matching email, where the left table's ID is larger
--    than the right table's ID. This identifies all "newer" duplicate records.
START TRANSACTION;

DELETE c1 
FROM contacts c1
INNER JOIN contacts c2 
    ON c1.email = c2.email 
    AND c1.id > c2.id; -- Match duplicates and target rows with larger IDs for deletion

SELECT * FROM contacts;
ROLLBACK; -- Restore data for practice files
