-- ============================================================
-- 🔑 MODULE 08 — Practice Solutions (Interview Patterns)
-- ============================================================

USE sql_course_m8;

-- 🟢 Q1 (Easy):
-- Find the 2nd highest salary of employees in the 'Engineering' department.

SELECT DISTINCT salary
FROM employee_salaries
WHERE department = 'Engineering'
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

-- 💬 Explanation:
-- We filter for 'Engineering', sort the distinct salaries in descending order, and use `LIMIT 1 OFFSET 1` to skip the 1st (highest) salary and return the 2nd highest.


-- 🟢 Q2 (Easy):
-- Find all duplicate email records in the `contacts` table. Return the email and count.

SELECT email, COUNT(*) AS email_count
FROM contacts
GROUP BY email
HAVING COUNT(*) > 1;

-- 💬 Explanation:
-- Grouping by email merges all matching records. HAVING COUNT(*) > 1 filters out unique emails, showing only the ones that have duplicate rows.


-- 🟢 Q3 (Easy):
-- Calculate the total deposit amounts for each user in the month of March 2026.

SELECT user_id, SUM(amount) AS total_deposits
FROM transactions
WHERE txn_type = 'deposit'
  AND txn_date >= '2026-03-01' 
  AND txn_date < '2026-04-01'
GROUP BY user_id;

-- 💬 Explanation:
-- We filter for transaction type 'deposit' and restrict transaction dates to the March range. Then we group by user_id and sum the transaction amount.


-- 🟡 Q4 (Medium):
-- Find the 3rd highest salary in the entire company using the window function `DENSE_RANK()`.

WITH ranked_salaries AS (
    SELECT name, department, salary,
           DENSE_RANK() OVER(ORDER BY salary DESC) AS rnk
    FROM employee_salaries
)
SELECT name, department, salary
FROM ranked_salaries
WHERE rnk = 3;

-- 💬 Explanation:
-- DENSE_RANK() is ideal for salary ranks because ties share the same rank and no ranks are skipped (e.g. if two people tie for 1st, the next highest salary is ranked 2nd).
-- We wrap the window ranking in a CTE and filter on `rnk = 3`.


-- 🟡 Q5 (Medium):
-- Find all users who have logged in on 3 or more consecutive days.

WITH deduped_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM logins
),
ranked_logins AS (
    SELECT user_id, login_date,
           ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS rn
    FROM deduped_logins
),
streaks AS (
    SELECT user_id,
           COUNT(*) AS streak_length
    FROM ranked_logins
    GROUP BY user_id, DATE_SUB(login_date, INTERVAL rn DAY)
)
SELECT DISTINCT user_id
FROM streaks
WHERE streak_length >= 3;

-- 💬 Explanation:
-- We first deduplicate the logins per day in `deduped_logins`.
-- In `ranked_logins`, we assign consecutive row numbers per user.
-- Subtracting `rn` (row number) days from `login_date` yields a constant date if the days are consecutive. Grouping by this date identifies streaks and their lengths.


-- 🟡 Q6 (Medium):
-- Calculate the length of the maximum login streak for each user.

WITH deduped_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM logins
),
ranked_logins AS (
    SELECT user_id, login_date,
           ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS rn
    FROM deduped_logins
),
streaks AS (
    SELECT user_id,
           COUNT(*) AS streak_length
    FROM ranked_logins
    GROUP BY user_id, DATE_SUB(login_date, INTERVAL rn DAY)
)
SELECT user_id, MAX(streak_length) AS max_streak_length
FROM streaks
GROUP BY user_id;

-- 💬 Explanation:
-- We compute all streak lengths using the same subtraction grouping method, then find the `MAX()` streak length for each user.


-- 🟡 Q7 (Medium):
-- Find the Month-over-Month (MoM) growth percentage of total deposit amounts.

WITH monthly_deposits AS (
    SELECT DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
           SUM(amount) AS current_deposits
    FROM transactions
    WHERE txn_type = 'deposit'
    GROUP BY DATE_FORMAT(txn_date, '%Y-%m')
),
lagged_deposits AS (
    SELECT txn_month, current_deposits,
           LAG(current_deposits) OVER(ORDER BY txn_month) AS prev_deposits
    FROM monthly_deposits
)
SELECT txn_month, current_deposits, prev_deposits,
       ROUND((current_deposits - prev_deposits) * 100.0 / NULLIF(prev_deposits, 0), 2) AS MoM_growth_pct
FROM lagged_deposits;

-- 💬 Explanation:
-- LAG() retrieves the deposit value from the previous month row.
-- We use NULLIF(prev_deposits, 0) in the denominator to avoid divide-by-zero errors in case any month has zero deposits.


-- 🟡 Q8 (Medium):
-- Calculate the running balance (cumulative sum of transaction amounts) for all users.

SELECT id, user_id, amount, txn_date,
       SUM(amount) OVER(PARTITION BY user_id ORDER BY txn_date, id) AS running_balance
FROM transactions;

-- 💬 Explanation:
-- Partitioning by user_id separates each user's financial history. Ordering by date and transaction ID ensures a deterministic running sum calculation.


-- 🟡 Q9 (Medium):
-- Write a query to delete all duplicate records in `contacts` table based on matching email, keeping ONLY the record with the smallest `id` value.

-- SELECT QUERY showing IDs that should be deleted:
SELECT c1.id, c1.name, c1.email, c1.phone
FROM contacts c1
INNER JOIN contacts c2
    ON c1.email = c2.email
    AND c1.id > c2.id;

-- 💬 Explanation:
-- The INNER JOIN matches rows with the same email address. The condition `c1.id > c2.id` ensures that for every duplicate pair, c1 points to the row with the larger (newer) ID, targeting it for deletion.


-- 🟡 Q10 (Medium):
-- Find all employees who earn more than the average salary of their respective departments.

WITH dept_avg AS (
    SELECT department, AVG(salary) AS dept_avg_salary
    FROM employee_salaries
    GROUP BY department
)
SELECT e.name, e.department, e.salary, ROUND(da.dept_avg_salary, 2) AS dept_avg_salary
FROM employee_salaries e
JOIN dept_avg da ON e.department = da.department
WHERE e.salary > da.dept_avg_salary;

-- 💬 Explanation:
-- We calculate the average salary per department inside a CTE, join it to the employee table on department, and filter rows where the individual's salary is greater than the department's average.


-- 🟡 Q11 (Medium):
-- Find mutual friends between User 1 and User 6.

WITH RECURSIVE all_friendships AS (
    SELECT user_id_1 AS user_id, user_id_2 AS friend_id FROM friendships
    UNION
    SELECT user_id_2 AS user_id, user_id_1 AS friend_id FROM friendships
)
SELECT f1.friend_id AS mutual_friend_id
FROM all_friendships f1
JOIN all_friendships f2 
    ON f1.friend_id = f2.friend_id
WHERE f1.user_id = 1 
  AND f2.user_id = 6;

-- 💬 Explanation:
-- We compile all friendships bidirectionally using a UNION.
-- By self-joining this bidirectional list, we match records where User 1 and User 6 have friendship records pointing to the same `friend_id`.


-- 🟡 Q12 (Medium):
-- Find the median score of the students in the 'Math' subject.

WITH ranked_scores AS (
    SELECT score,
           ROW_NUMBER() OVER(ORDER BY score ASC) AS rn_asc,
           ROW_NUMBER() OVER(ORDER BY score DESC) AS rn_desc
    FROM scores
    WHERE subject = 'Math'
)
SELECT AVG(score) AS median_score
FROM ranked_scores
WHERE ABS(CAST(rn_asc AS SIGNED) - CAST(rn_desc AS SIGNED)) <= 1;

-- 💬 Explanation:
-- We assign ascending and descending row numbers to scores.
-- Median row(s) lie at the intersection of the two sequences where the absolute difference between asc and desc row number is <= 1.
-- Averaging the resulting scores handles both odd and even counts of rows.


-- 🟡 Q13 (Medium):
-- Pivot the `scores` table to show the score of each student in 'Math', 'Science', and 'History'.

SELECT student,
       MAX(CASE WHEN subject = 'Math' THEN score END) AS math_score,
       MAX(CASE WHEN subject = 'Science' THEN score END) AS science_score,
       MAX(CASE WHEN subject = 'History' THEN score END) AS history_score
FROM scores
GROUP BY student;

-- 💬 Explanation:
-- For each student group, MAX selects the only non-null score generated by the conditional CASE statements for that subject.


-- 🟡 Q14 (Medium):
-- Unpivot the wide format scores to long format rows.

WITH pivoted AS (
    SELECT student,
           MAX(CASE WHEN subject = 'Math' THEN score END) AS math_score,
           MAX(CASE WHEN subject = 'Science' THEN score END) AS science_score,
           MAX(CASE WHEN subject = 'History' THEN score END) AS history_score
    FROM scores
    GROUP BY student
)
SELECT student, 'Math' AS subject, math_score AS score FROM pivoted WHERE math_score IS NOT NULL
UNION ALL
SELECT student, 'Science' AS subject, science_score AS score FROM pivoted WHERE science_score IS NOT NULL
UNION ALL
SELECT student, 'History' AS subject, history_score AS score FROM pivoted WHERE history_score IS NOT NULL
ORDER BY student, subject;

-- 💬 Explanation:
-- We take the pivoted dataset and use UNION ALL to split the columns back into separate row records. We filter out NULL values to maintain original sparsity.


-- 🔴 Q15 (Hard):
-- Identify the start date, end date, and duration of all consecutive login streaks for each user (length >= 2).

WITH deduped_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM logins
),
ranked_logins AS (
    SELECT user_id, login_date,
           ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS rn
    FROM deduped_logins
),
streaks AS (
    SELECT user_id,
           MIN(login_date) AS streak_start,
           MAX(login_date) AS streak_end,
           COUNT(*) AS streak_length
    FROM ranked_logins
    GROUP BY user_id, DATE_SUB(login_date, INTERVAL rn DAY)
)
SELECT user_id, streak_start, streak_end, streak_length
FROM streaks
WHERE streak_length >= 2
ORDER BY user_id, streak_start;

-- 💬 Explanation:
-- Calculates streak islands using the `login_date - rn` grouping technique. Min/Max dates identify the date boundary, and COUNT(*) yields the streak length.


-- 🔴 Q16 (Hard):
-- Find "deposit islands". Group consecutive transactions of the same user that are 'deposit' types.

WITH ranked_txns AS (
    SELECT id, user_id, amount, txn_date, txn_type,
           ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY txn_date, id) AS rn_all
    FROM transactions
),
ranked_deposits AS (
    SELECT id, user_id, amount, txn_date, txn_type, rn_all,
           ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY txn_date, id) AS rn_dep
    FROM ranked_txns
    WHERE txn_type = 'deposit'
)
SELECT 
    user_id,
    MIN(txn_date) AS deposit_start,
    MAX(txn_date) AS deposit_end,
    SUM(amount) AS total_deposited
FROM ranked_deposits
GROUP BY user_id, (rn_all - rn_dep)
ORDER BY user_id, deposit_start;

-- 💬 Explanation:
-- By ranking all transactions (`rn_all`) and only deposits (`rn_dep`), the difference `rn_all - rn_dep` remains constant for consecutive deposit records.
-- Grouping by this difference isolates each sequence of consecutive deposits.


-- 🔴 Q17 (Hard):
-- Friend Recommendation Engine: Find "friends of friends" for User 1.

WITH RECURSIVE all_friendships AS (
    SELECT user_id_1 AS user_id, user_id_2 AS friend_id FROM friendships
    UNION
    SELECT user_id_2 AS user_id, user_id_1 AS friend_id FROM friendships
),
user_1_friends AS (
    SELECT friend_id 
    FROM all_friendships 
    WHERE user_id = 1
)
SELECT 
    f2.friend_id AS recommended_user_id,
    COUNT(*) AS mutual_friend_count
FROM all_friendships f1
JOIN all_friendships f2 
    ON f1.friend_id = f2.user_id
WHERE f1.user_id = 1
  AND f2.friend_id != 1
  AND f2.friend_id NOT IN (SELECT friend_id FROM user_1_friends)
GROUP BY f2.friend_id
ORDER BY mutual_friend_count DESC;

-- 💬 Explanation:
-- We find all friends of User 1 (f1.friend_id), then find their friends (f2.friend_id).
-- We exclude User 1 and any people User 1 is already friends with.
-- GROUP BY counts how many paths exist between User 1 and the recommended user, representing mutual friends.


-- 🟡 Q18 (Medium):
-- Find all users who performed a transaction in BOTH January 2026 AND February 2026.

SELECT DISTINCT t1.user_id
FROM transactions t1
JOIN transactions t2 ON t1.user_id = t2.user_id
WHERE t1.txn_date >= '2026-01-01' AND t1.txn_date < '2026-02-01'
  AND t2.txn_date >= '2026-02-01' AND t2.txn_date < '2026-03-01';

-- 💬 Explanation:
-- We self-join the transactions table on user_id, filtering for January on one side and February on the other.


-- 🟡 Q19 (Medium):
-- Find the difference between the highest and lowest salary in each department.

SELECT department,
       MAX(salary) - MIN(salary) AS salary_spread
FROM employee_salaries
GROUP BY department;

-- 💬 Explanation:
-- Grouping by department allows us to run aggregate functions `MAX(salary)` and `MIN(salary)` to compute the department range.


-- 🔴 Q20 (Hard):
-- Find the percentile rank of each score in the Math subject without analytical functions.

WITH math_scores AS (
    SELECT student, score
    FROM scores
    WHERE subject = 'Math'
)
SELECT 
    m1.student,
    m1.score,
    ROUND(
        COUNT(m2.score) * 1.0 / (SELECT COUNT(*) - 1 FROM math_scores),
        4
    ) AS percentile_rank
FROM math_scores m1
LEFT JOIN math_scores m2 
    ON m2.score < m1.score
GROUP BY m1.student, m1.score
ORDER BY percentile_rank;

-- 💬 Explanation:
-- We left join the math subset with itself (`m2.score < m1.score`) to count how many scores are strictly below the current row.
-- Dividing this count by `(Total rows - 1)` maps the scores to a percentile range from 0.0000 (lowest) to 1.0000 (highest).
