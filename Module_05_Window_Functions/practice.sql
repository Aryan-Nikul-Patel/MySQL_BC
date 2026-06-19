-- ============================================================
-- ✏️ MODULE 05 — PRACTICE QUESTIONS
-- Topic: Window Functions (OVER, PARTITION BY, Ranking, Aggregates, LAG/LEAD, Frames)
-- ============================================================
-- Instructions:
--   Write your SQL queries below each question.
--   Do NOT use GROUP BY to solve questions where a window function is the intended approach.
--   Solutions are in: solutions.sql
--
-- Difficulty:
--   🟢 Easy (Q1–Q6)
--   🟡 Medium (Q7–Q14)
--   🔴 Hard (Q15–Q20)
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 🟢 EASY
-- ────────────────────────────────────────────

-- Q1: Show each employee's name, department, salary, and the total salary for their department.
-- Do NOT group rows — every employee should appear individually.
-- Expected output: 20 rows, each employee shows their personal salary + dept total.
-- YOUR QUERY:



-- Q2: Assign a row number to each employee ordered by salary descending (company-wide, no partitioning).
-- Expected output: Sam Nguyen = 1, Tina Johansson = 2, Alice Kim / Carol Davis = 3 and 4 (arbitrary order between ties)
-- YOUR QUERY:



-- Q3: For each employee, show their salary and the company-wide average salary as a separate column.
-- Expected output: 20 rows, all showing the same avg_salary (~96,450)
-- YOUR QUERY:



-- Q4: Show each monthly_sales row for Grace Lee, along with the previous month's revenue.
-- Use LAG. If no previous month exists, show 0.
-- Expected output: 24 rows, first row shows 0 for prev_month_revenue
-- YOUR QUERY:



-- Q5: For each employee, show their name, department, salary, and how many employees are in their department.
-- Expected output: 20 rows, each showing the headcount of their department.
-- YOUR QUERY:



-- Q6: Show each employee's salary, the highest salary in their department, and the lowest salary in their department.
-- Expected output: 20 rows with dept_max and dept_min per row.
-- YOUR QUERY:



-- ────────────────────────────────────────────
-- 🟡 MEDIUM
-- ────────────────────────────────────────────

-- Q7: Rank all employees by salary within their department using DENSE_RANK.
-- Show: name, department, salary, dense_rank. Order by department and rank.
-- Expected output: 20 rows, rank resets per department, ties get the same rank.
-- YOUR QUERY:



-- Q8: Find the top 2 earners per department. Handle ties correctly (if two people tie for 2nd, include both).
-- Expected output: Engineering should show Alice Kim, Carol Davis (both 120000), Eva Ramos (110000) — 3 rows for Engineering.
-- YOUR QUERY:



-- Q9: For each month in Grace Lee's sales data, compute the month-over-month % change in revenue.
-- Show: salesperson, year, month, revenue, prev_revenue, pct_change (rounded to 2 decimal places).
-- The first row should have NULL for prev_revenue and pct_change.
-- YOUR QUERY:



-- Q10: For each employee, compute what percentage of their department's total salary they represent.
-- Show: name, department, salary, dept_total, pct_of_dept (rounded to 2 decimal places).
-- YOUR QUERY:



-- Q11: Show each employee alongside their department's average salary and whether they are
-- 'Above Average', 'Average', or 'Below Average'. Use CASE WHEN.
-- Expected output: 20 rows with a classification column.
-- YOUR QUERY:



-- Q12: For Grace Lee's monthly_sales, compute a 3-month rolling average revenue.
-- Show: salesperson, year, month, revenue, rolling_3m_avg (rounded to 2 decimal places).
-- YOUR QUERY:



-- Q13: Use NTILE(4) to divide all employees into salary quartiles company-wide.
-- Show: name, salary, quartile. 
-- Quartile 1 = lowest salaries, Quartile 4 = highest salaries.
-- YOUR QUERY:



-- Q14: For each user in user_logins, show each login_date alongside the number of days since their previous login.
-- If it's their first login, show NULL.
-- Expected output: 20 rows showing gap_days per login.
-- YOUR QUERY:



-- ────────────────────────────────────────────
-- 🔴 HARD
-- ────────────────────────────────────────────

-- Q15: Find the employee who has the highest salary in their department, AND whose salary is also
-- above the company-wide average. Show their name, department, and salary.
-- Note: Use window functions only (no subqueries using GROUP BY separately).
-- YOUR QUERY:



-- Q16: For each salesperson and year, compute:
--   - Total annual revenue
--   - What % of their career total this year represents
-- Show: salesperson, year, annual_revenue, career_total, pct_of_career
-- YOUR QUERY:



-- Q17: Show a "running max revenue" for Grace Lee by month.
-- This should show: for each month, the highest single-month revenue Grace has ever achieved up to this month.
-- Expected: starts at 42000, grows over time, reaches 115000 by the last month.
-- YOUR QUERY:



-- Q18: For each employee, show their name, department, salary, and where they rank in the
-- company-wide salary distribution expressed as a percentage (i.e., what % of employees earn less).
-- Use PERCENT_RANK(). Round to 2 decimal places.
-- YOUR QUERY:



-- Q19: For each salesperson in monthly_sales, show:
--   - Current month revenue
--   - Previous 2 months revenue (LAG 1 and LAG 2)
--   - A 3-month "weighted moving average" where: (LAG 2 * 1 + LAG 1 * 2 + current * 3) / 6
--   Hint: You will need multiple LAG calls.
-- YOUR QUERY:



-- Q20 (Boss Level): Find all employees whose salary is BOTH:
--   1. Above the average of their own department
--   2. In the top 25% of salary company-wide (salary quartile = 4, using NTILE(4))
-- Show: name, department, salary, dept_avg, salary_quartile
-- YOUR QUERY:
