-- ============================================================
-- ✏️ MODULE 06 — PRACTICE QUESTIONS
-- Topic: CTEs (Basic, Multiple Chained, Recursive)
-- ============================================================
-- Instructions:
--   Write your SQL queries below each question.
--   Try to use CTEs (WITH ... AS) instead of inline subqueries for all Medium+ questions.
--   Solutions are in: solutions.sql
--
-- Difficulty:
--   🟢 Easy (Q1–Q5)
--   🟡 Medium (Q6–Q13)
--   🔴 Hard (Q14–Q18)
-- ============================================================

USE sql_course_m6;

-- ────────────────────────────────────────────
-- 🟢 EASY
-- ────────────────────────────────────────────

-- Q1: Using a CTE, find all employees who earn more than $100,000.
-- Show: name, role, department, salary. Ordered by salary DESC.
-- Expected output: 9 employees (Diana, Bruce, Clark, Barry, Hal, Arthur, Victor, Oliver, Kara)
-- YOUR QUERY:



-- Q2: Using a CTE, compute the average salary per department.
-- Then in the main query, show only departments with average salary above $120,000.
-- Expected output: Executive (avg = 207500), Engineering (avg = 142500)
-- YOUR QUERY:



-- Q3: Write a recursive CTE to generate a sequence of odd numbers from 1 to 19.
-- Expected output: 1, 3, 5, 7, 9, 11, 13, 15, 17, 19
-- YOUR QUERY:



-- Q4: Using a CTE, show the number of direct reports each employee has.
-- Show: manager's name, role, direct_reports count.
-- Show only employees who have at least 1 direct report.
-- YOUR QUERY:



-- Q5: Generate all dates from 2024-03-01 to 2024-03-07 using a recursive CTE.
-- Expected output: 7 rows (one per day in that week).
-- YOUR QUERY:



-- ────────────────────────────────────────────
-- 🟡 MEDIUM
-- ────────────────────────────────────────────

-- Q6: Using a CTE with a window function, find the top 2 highest-paid employees per department.
-- Handle salary ties correctly (use DENSE_RANK).
-- Show: name, department, salary, dept_rank.
-- YOUR QUERY:



-- Q7: Write a 2-CTE pipeline to show:
--   CTE 1: Annual revenue per rep per year (sum up monthly data).
--   Final query: Show year-over-year growth for each rep.
-- Expected output: Roy Harper and Donna Troy with their 2023 revenue, 2024 revenue, and % growth.
-- YOUR QUERY:



-- Q8: Using a recursive CTE, traverse the org chart starting from Diana Prince (emp_id=1).
-- Show each employee's name, their depth (level) in the hierarchy, and their department.
-- Order by depth, then name.
-- Expected output: 15 rows with depths 0–3.
-- YOUR QUERY:



-- Q9: Using a recursive CTE, find the full breadcrumb path for every employee.
-- Path format: "CEO_name > VP_name > Director_name > Employee_name"
-- Show: name, depth, path_string. Order by path_string.
-- YOUR QUERY:



-- Q10: Using a CTE, compute for each rep:
--   - Their total revenue across all years
--   - The percentage of total company revenue they represent
-- Show: rep_name, total_revenue, company_total, pct_of_company.
-- YOUR QUERY:



-- Q11: Using a recursive CTE, find all categories that are descendants of 'Electronics' (cat_id=2).
-- Include Electronics itself. Show: cat_id, cat_name, depth.
-- YOUR QUERY:



-- Q12: Using a 3-CTE pipeline, produce a department salary report:
--   CTE 1: Compute dept-level stats (avg, min, max, headcount).
--   CTE 2: Rank departments by average salary.
--   Final: Show the ranked departments with all stats.
-- YOUR QUERY:



-- Q13: Using a recursive CTE, list all managers in the chain above Cassandra Cain (emp_id=15).
-- Start from Cassandra and walk up to the CEO.
-- Show: name, role, level_above (0 = Cassandra herself).
-- YOUR QUERY:



-- ────────────────────────────────────────────
-- 🔴 HARD
-- ────────────────────────────────────────────

-- Q14: Using a date-series recursive CTE + sales_data, show daily totals from 2023-07-01 to 2023-12-31.
-- If no sales happened on a given day, show 0.
-- (Hint: The sales_data table has monthly data, not daily. So LEFT JOIN on year+month,
--  but generate daily rows first. Adjust: just group by month and fill in months with 0.)
-- Generate a monthly series from month 1 to month 12 for year 2023 using recursive CTE.
-- LEFT JOIN sales_data to show $0 for any month with no sales.
-- YOUR QUERY:



-- Q15: Using CTEs + window functions, for Roy Harper's 2024 data show:
--   - Monthly revenue
--   - 3-month rolling average
--   - Running cumulative total for the year
--   - Month-over-month % change
-- Show all 12 months in a single query.
-- YOUR QUERY:



-- Q16: Using a recursive CTE, compute the total number of employees under each manager
-- (including indirect reports — the entire subtree).
-- Show: manager_name, direct_count, total_subtree_count.
-- Hint: This requires joining the recursive result back to the employees table.
-- YOUR QUERY:



-- Q17: Using multiple CTEs, find employees who meet ALL of the following:
--   1. Their salary is above their department average.
--   2. Their salary is in the top 25% company-wide (NTILE(4) = 1 ordered by salary DESC).
--   3. Their department average salary is above the company-wide average salary.
-- Show: name, department, salary, dept_avg, company_avg, dept_rank_tier.
-- YOUR QUERY:



-- Q18 (Boss Level): Using a recursive CTE, build a complete org chart table that shows,
-- for each employee: their name, their direct manager's name, their grandmanager's name (or NULL),
-- and their level in the hierarchy.
-- Show only employees at depth >= 2 (Directors and below).
-- YOUR QUERY:
