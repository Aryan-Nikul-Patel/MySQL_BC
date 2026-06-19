-- ============================================================
-- ✏️ MODULE 08 — Practice Questions (Interview Patterns)
-- ============================================================
-- 
-- Instructions:
--   Write your queries below each question.
--   Run each query to verify your answer.
--   Solutions are in: solutions.sql
-- ============================================================

USE sql_course_m8;

-- 🟢 Q1 (Easy):
-- Find the 2nd highest salary of employees in the 'Engineering' department.
-- Expected output: A single value representing the salary.
-- YOUR QUERY:



-- 🟢 Q2 (Easy):
-- Find all duplicate email records in the `contacts` table. Return the email
-- and the number of times it appears.
-- Expected columns: email, email_count
-- YOUR QUERY:



-- 🟢 Q3 (Easy):
-- Calculate the total deposit amounts for each user in the month of March 2026.
-- Expected columns: user_id, total_deposits
-- YOUR QUERY:



-- 🟡 Q4 (Medium):
-- Find the 3rd highest salary in the entire company using the window function `DENSE_RANK()`.
-- Return the employee's name, department, and salary.
-- Expected columns: name, department, salary
-- YOUR QUERY:



-- 🟡 Q5 (Medium):
-- Find all users who have logged in on 3 or more consecutive days.
-- Return the unique user_id values.
-- Expected columns: user_id
-- YOUR QUERY:



-- 🟡 Q6 (Medium):
-- Calculate the length of the maximum login streak for each user.
-- For example, if User 2 logged in for a 3-day streak and a 2-day streak, their max streak is 3.
-- Expected columns: user_id, max_streak_length
-- YOUR QUERY:



-- 🟡 Q7 (Medium):
-- Find the Month-over-Month (MoM) growth percentage of total deposit amounts.
-- Return the month (YYYY-MM), monthly deposit sum, previous month's deposit sum, and the growth percentage.
-- Expected columns: txn_month, current_deposits, prev_deposits, MoM_growth_pct
-- YOUR QUERY:



-- 🟡 Q8 (Medium):
-- Calculate the running balance (cumulative sum of transaction amounts) for all users,
-- ordered by user_id and txn_date.
-- Expected columns: id, user_id, amount, txn_date, running_balance
-- YOUR QUERY:



-- 🟡 Q9 (Medium):
-- Write a query to delete all duplicate records in `contacts` table based on matching email,
-- keeping ONLY the record with the smallest `id` value. 
-- Note: Write this query as a SELECT query first, showing the IDs that should be DELETED.
-- Expected columns: id, name, email, phone (of records that should be removed)
-- YOUR QUERY:



-- 🟡 Q10 (Medium):
-- Find all employees who earn more than the average salary of their respective departments.
-- Expected columns: name, department, salary, dept_avg_salary
-- YOUR QUERY:



-- 🟡 Q11 (Medium):
-- Find mutual friends between User 1 and User 6.
-- Expected columns: mutual_friend_id
-- YOUR QUERY:



-- 🟡 Q12 (Medium):
-- Find the median score of the students in the 'Math' subject.
-- Expected columns: median_score
-- YOUR QUERY:



-- 🟡 Q13 (Medium):
-- Pivot the `scores` table to show the score of each student in 'Math', 'Science', and 'History'.
-- Expected columns: student, math_score, science_score, history_score
-- YOUR QUERY:



-- 🟡 Q14 (Medium):
-- Suppose we have the pivoted score table. Write a query to unpivot it back to long format.
-- Hint: Use UNION ALL.
-- Expected columns: student, subject, score
-- YOUR QUERY:



-- 🔴 Q15 (Hard):
-- Identify the start date, end date, and duration of all consecutive login streaks for each user.
-- Only return streaks that are 2 or more days in length.
-- Expected columns: user_id, streak_start, streak_end, streak_length
-- YOUR QUERY:



-- 🔴 Q16 (Hard):
-- Find "deposit islands". Group consecutive transactions of the same user that are 'deposit' types.
-- For each island, return the user_id, the start date of the deposits, the end date, and the total amount deposited.
-- Expected columns: user_id, deposit_start, deposit_end, total_deposited
-- YOUR QUERY:



-- 🔴 Q17 (Hard):
-- Friend Recommendation Engine: Find "friends of friends" (2nd-degree connections) for User 1.
-- Recommend users who are friends with User 1's friends, but are NOT already friends with User 1.
-- Include the count of mutual friends between User 1 and the recommended user.
-- Expected columns: recommended_user_id, mutual_friend_count
-- YOUR QUERY:



-- 🟡 Q18 (Medium):
-- Find all users who performed a transaction in BOTH January 2026 AND February 2026.
-- Expected columns: user_id
-- YOUR QUERY:



-- 🟡 Q19 (Medium):
-- Find the difference between the highest and lowest salary in each department.
-- Expected columns: department, salary_spread
-- YOUR QUERY:



-- 🔴 Q20 (Hard):
-- Find the percentile rank of each score in the Math subject.
-- Formula: (Number of scores below current score) / (Total number of scores - 1)
-- Do not use built-in analytic percentile functions. Calculate it manually using joins or window aggregates.
-- Expected columns: student, score, percentile_rank
-- YOUR QUERY:
