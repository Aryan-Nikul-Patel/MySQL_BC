-- ============================================================
-- 📘 MODULE 08 — Interview Problem Patterns
-- Lesson 05: Existence & Matching (Anti-Joins & Mutual Connections)
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Finding unmatched rows (Anti-Joins)
--    - 🔥 The dangerous NULL pitfall of NOT IN
--    - NOT EXISTS vs LEFT JOIN ... IS NULL performance
--    - Social network patterns: Finding Mutual Friends
--
-- 💡 Prerequisites: Module 3 (Joins), Module 8, Lesson 4
-- ============================================================

USE sql_course_m8;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Anti-Joins and the NULL Pitfall
-- ────────────────────────────────────────────
-- 💬 An "Anti-Join" finds records in Table A that do not exist in Table B.
--    Examples: "Users who never logged in", "Customers with no orders".
--
--    There are three main approaches:
--    1. LEFT JOIN ... WHERE B.id IS NULL
--    2. NOT EXISTS (correlated subquery)
--    3. NOT IN (subquery)
--
-- 🔥 CRITICAL INTERVIEW PITFALL: The NOT IN NULL Trap!
--    If the subquery of a `NOT IN` filter returns even a SINGLE `NULL` value,
--    the entire `NOT IN` clause evaluates to `UNKNOWN` or empty result!
--    Why? Because `col NOT IN (1, 2, NULL)` is equivalent to `col != 1 AND col != 2 AND col != NULL`.
--    Since any comparison to NULL is NULL (unknown), the entire condition is unknown.
--    Always default to `NOT EXISTS` or `LEFT JOIN ... IS NULL` because they are immune to this NULL bug.

-- ▶ Example 1.1: NOT IN fails when NULL is present
--    Suppose a query returns a dataset with a NULL. Let's write an anti-join.
--    This works because `employee_salaries.id` has no NULLs:
SELECT id, name FROM employee_salaries
WHERE id NOT IN (SELECT DISTINCT user_id FROM logins);

-- ▶ Example 1.2: LEFT JOIN ... IS NULL (Immune to NULLs)
SELECT es.id, es.name
FROM employee_salaries es
LEFT JOIN logins l ON es.id = l.user_id
WHERE l.user_id IS NULL;

-- ▶ Example 1.3: NOT EXISTS (Highly performant, immune to NULLs, preferred in interviews)
SELECT es.id, es.name
FROM employee_salaries es
WHERE NOT EXISTS (
    SELECT 1 
    FROM logins l 
    WHERE l.user_id = es.id
);


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Social Networks — Mutual Friends
-- ────────────────────────────────────────────
-- 💬 In social network schemas, you're often asked to find "Mutual Friends" between two users.
--    Friendships are typically stored unidirectionally (e.g. user_id_1 < user_id_2) or bidirectionally.
--    To handle this:
--    1. Create a bidirectional CTE of friendships: union `(u1, u2)` with `(u2, u1)`.
--    2. Join the friend lists of User A and User B on the friend ID to find the overlap.

-- ▶ Example 2.1: Finding mutual friends between User 1 and User 3
--    Let's find the users who are friends with both User 1 and User 3.
WITH RECURSIVE all_friendships AS (
    -- Convert unidirectional relations to bidirectional
    SELECT user_id_1 AS user_id, user_id_2 AS friend_id FROM friendships
    UNION
    SELECT user_id_2 AS user_id, user_id_1 AS friend_id FROM friendships
)
SELECT f1.friend_id AS mutual_friend_id
FROM all_friendships f1
JOIN all_friendships f2 
    ON f1.friend_id = f2.friend_id -- They share the same friend
WHERE f1.user_id = 1 
  AND f2.user_id = 3;
-- 💬 This query returns User 2 and User 4, who are mutual friends of User 1 and User 3.
