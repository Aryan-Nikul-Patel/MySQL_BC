-- ============================================================
-- 📘 MODULE 03 — Lesson 3: SELF JOIN
-- ============================================================
--
-- 🎯 What you'll learn:
--    - What a SELF JOIN is and when you need it
--    - Manager-employee relationships (org chart)
--    - Finding pairs within the same table
--    - Complex self-join patterns used in interviews
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m3;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What is a SELF JOIN?
-- ────────────────────────────────────────────
-- A SELF JOIN is when a table joins with ITSELF.
-- This sounds weird — why would you do that?
--
-- It's needed when a table has a relationship to its OWN rows.
-- The most classic example: an employees table where
-- each employee has a manager_id that points to ANOTHER employee in the SAME table.
--
-- Our employees table:
SELECT emp_id, name, role, manager_id FROM employees;
-- 💬 Sarah Connor (emp_id=1) has manager_id=NULL → she's the CEO, no manager
--    John Reese (emp_id=2) has manager_id=1 → his manager is Sarah (emp_id=1)
--    Sameen Shaw (emp_id=5) has manager_id=2 → her manager is John (emp_id=2)
--    etc.
--
-- To get "John Reese reports to Sarah Connor", you need to JOIN
-- the employees table with ITSELF — one copy for the employee, one for the manager.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Basic SELF JOIN — Employee + Manager
-- ────────────────────────────────────────────
-- The KEY is to use two aliases for the SAME table.
-- By convention: "e" for employee, "m" for manager

-- ▶ Show each employee with their manager's name:
SELECT
    e.name         AS employee,
    e.role         AS employee_role,
    m.name         AS manager,
    m.role         AS manager_role
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id;
-- 💬 INNER JOIN: Sarah Connor is EXCLUDED because her manager_id = NULL
--    (no match in the manager side).
-- Result: 12 rows — everyone except the CEO.

-- ▶ Include the CEO too (using LEFT JOIN):
SELECT
    e.name                         AS employee,
    e.role                         AS employee_role,
    e.dept,
    COALESCE(m.name, '— Top Level —') AS manager,
    m.role                         AS manager_role
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY e.dept, e.emp_id;
-- 💬 LEFT JOIN: Sarah appears with manager = '— Top Level —'
-- COALESCE(m.name, '— Top Level —') replaces NULL with a readable label.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Multi-level hierarchy
-- ────────────────────────────────────────────
-- What if you want: Employee → their Manager → their Manager's Manager?
-- You just add another self-join!

-- ▶ Three-level org chart: Employee → Manager → VP
SELECT
    e.name                             AS employee,
    e.role,
    m.name                             AS direct_manager,
    COALESCE(gm.name, '— Top Level —') AS grand_manager
FROM employees e
LEFT JOIN employees m  ON e.manager_id  = m.emp_id   -- get direct manager
LEFT JOIN employees gm ON m.manager_id  = gm.emp_id  -- get manager's manager
ORDER BY e.dept, e.emp_id;
-- 💬 For Lionel Fusco (Sales Rep):
--    employee = Lionel Fusco
--    direct_manager = Joss Carter (Sales Manager)
--    grand_manager = Harold Finch (VP Sales)
--
-- For John Reese (VP Engineering):
--    employee = John Reese
--    direct_manager = Sarah Connor (CEO)
--    grand_manager = NULL → shows '— Top Level —'


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: Department headcount per manager
-- ────────────────────────────────────────────

-- ▶ How many direct reports does each manager have?
SELECT
    m.name               AS manager,
    m.role               AS manager_role,
    COUNT(e.emp_id)      AS direct_reports,
    ROUND(AVG(e.salary), 2) AS avg_team_salary,
    MIN(e.salary)        AS lowest_in_team,
    MAX(e.salary)        AS highest_in_team
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
GROUP BY m.emp_id, m.name, m.role
ORDER BY direct_reports DESC;
-- 💬 Sarah Connor manages 4 VPs + 1 IT Admin = 5 direct reports
--    John Reese manages 3 engineers
--    etc.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: Employees earning more than their manager
-- ────────────────────────────────────────────
-- This is a CLASSIC interview question.

-- ▶ Find employees whose salary is higher than their manager's salary:
SELECT
    e.name          AS employee,
    e.salary        AS employee_salary,
    m.name          AS manager,
    m.salary        AS manager_salary,
    e.salary - m.salary  AS salary_difference
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary
ORDER BY salary_difference DESC;
-- 💬 If this returns rows, something unusual is happening in the org!
--    In our data, are any employees paid more than their boss?


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: Employees in the same department
-- ────────────────────────────────────────────
-- SELF JOIN can also find relationships within the same group.

-- ▶ All pairs of employees in the same department:
SELECT
    e1.name   AS employee_1,
    e2.name   AS employee_2,
    e1.dept
FROM employees e1
JOIN employees e2
    ON  e1.dept   = e2.dept       -- same department
    AND e1.emp_id < e2.emp_id     -- avoid duplicates (A,B and B,A) and self-pairing
ORDER BY e1.dept, e1.name;
-- 💬 The condition e1.emp_id < e2.emp_id is critical!
--    Without it:
--      - You'd get (Alice, Alice) — self-pairs
--      - You'd get (Alice, Bob) AND (Bob, Alice) — duplicate pairs
--    With e1.emp_id < e2.emp_id:
--      - Only unique pairs, each appearing once
--      - No self-pairs


-- ────────────────────────────────────────────
-- 📌 CONCEPT 7: Complex SELF JOIN — Full org chart report
-- ────────────────────────────────────────────

-- ▶ Full team report: Show every employee, their manager, and department salary stats
SELECT
    e.dept,
    e.name                              AS employee,
    e.role,
    e.salary,
    COALESCE(m.name, 'No Manager')       AS manager,
    dept_stats.dept_avg_salary,
    ROUND(e.salary - dept_stats.dept_avg_salary, 2) AS vs_dept_avg
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
JOIN (
    -- subquery: average salary per department
    SELECT dept, ROUND(AVG(salary), 2) AS dept_avg_salary
    FROM employees
    GROUP BY dept
) dept_stats ON e.dept = dept_stats.dept
ORDER BY e.dept, e.salary DESC;
-- 💬 This combines SELF JOIN with a subquery (derived table).
--    dept_stats is a mini-table with avg salary per dept.
--    The main query joins it to show each employee's salary vs their dept average.
--    Positive "vs_dept_avg" = above average for their dept.
--    Negative = below average.
--    (We'll learn Window Functions in Module 5 that do this more elegantly!)
