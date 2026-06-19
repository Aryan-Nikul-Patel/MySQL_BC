-- ============================================================
-- 🔑 MODULE 07 — Practice Solutions (Advanced Query Patterns)
-- ============================================================

USE sql_course_m7;

-- 🟢 Q1 (Easy):
-- Write a query to return the username, email in all uppercase,
-- and the length of the username (character count) for all users.
-- Sort the results by the username length in descending order.

SELECT username, UPPER(email) AS email_upper, CHAR_LENGTH(username) AS username_length
FROM user_profiles
ORDER BY username_length DESC;

-- 💬 Explanation:
-- UPPER() converts the email string to uppercase.
-- CHAR_LENGTH() returns the number of characters in the username.
-- We use CHAR_LENGTH() rather than LENGTH() because CHAR_LENGTH() measures character count rather than byte count, avoiding bugs with multibyte characters.


-- 🟢 Q2 (Easy):
-- Find all user events that occurred on a 'desktop' device between 9:00 AM and 6:00 PM (inclusive of both boundaries)
-- on any day in March 2026.

SELECT id, user_id, event_type, event_time, device
FROM user_events
WHERE device = 'desktop'
  AND TIME(event_time) BETWEEN '09:00:00' AND '18:00:00'
  AND event_time >= '2026-03-01 00:00:00' 
  AND event_time < '2026-04-01 00:00:00';

-- 💬 Explanation:
-- TIME(event_time) extracts the time component (HH:MM:SS) of the datetime for comparison.
-- For date range filtering, we use `>= '2026-03-01 00:00:00' AND < '2026-04-01 00:00:00'` to ensure we capture all events during March without missing boundary records.


-- 🟢 Q3 (Easy):
-- Write a query on the `exam_scores` table. Return the student name, subject, score, and a grade status:
--   - If score is 90 or above: 'Excellent'
--   - If score is between 70 and 89 (inclusive): 'Passing'
--   - If score is below 70: 'Needs Improvement'

SELECT student, subject, score,
       CASE 
           WHEN score >= 90 THEN 'Excellent'
           WHEN score >= 70 THEN 'Passing'
           ELSE 'Needs Improvement'
       END AS status
FROM exam_scores;

-- 💬 Explanation:
-- CASE evaluations stop at the first matching condition. Since score >= 90 is handled first, the next WHEN clause (score >= 70) automatically captures values in the [70, 89] range.


-- 🟡 Q4 (Medium):
-- Extract the domain name from the `email` column in the `user_profiles` table.
-- Group the profiles by email domain and count how many users belong to each domain.
-- Only show domains that have more than 1 user.

SELECT SUBSTRING(email, LOCATE('@', email) + 1) AS email_domain, COUNT(*) AS user_count
FROM user_profiles
GROUP BY email_domain
HAVING user_count > 1;

-- 💬 Explanation:
-- LOCATE('@', email) finds the index of the '@' character.
-- SUBSTRING(email, position) extracts the substring from that position + 1 to the end.
-- We group by the custom expression `email_domain` and use HAVING to filter groups with count > 1.


-- 🟡 Q5 (Medium):
-- Calculate the number of days between each user's account creation (`created_at`) and the date '2026-03-01 00:00:00'.
-- Bucket the users into three cohorts based on account age:
--   - 'Veteran': Creation date is older than 365 days from '2026-03-01'
--   - 'Regular': Creation date is between 180 and 365 days from '2026-03-01' (inclusive)
--   - 'Newbie': Creation date is less than 180 days from '2026-03-01'
-- Return the cohort name and the count of users in each cohort.

SELECT 
    CASE 
        WHEN DATEDIFF('2026-03-01 00:00:00', created_at) > 365 THEN 'Veteran'
        WHEN DATEDIFF('2026-03-01 00:00:00', created_at) BETWEEN 180 AND 365 THEN 'Regular'
        ELSE 'Newbie'
    END AS cohort,
    COUNT(*) AS user_count
FROM user_profiles
GROUP BY cohort;

-- 💬 Explanation:
-- DATEDIFF() computes the difference in days between two datetimes.
-- We can group directly by the alias `cohort` in MySQL. For database engines that do not support grouping by select aliases, we would copy the CASE WHEN block to the GROUP BY clause or use a CTE.


-- 🟡 Q6 (Medium):
-- Find all users whose `bio` contains a special pattern matching 'code-' followed by any word characters 
-- (e.g., 'code-ninja' or similar pattern). Use regular expressions.

SELECT username, full_name, bio
FROM user_profiles
WHERE bio REGEXP 'code-[a-zA-Z0-9_]+';

-- 💬 Explanation:
-- The REGEXP operator compares the bio column to the pattern 'code-[a-zA-Z0-9_]+', which matches 'code-' followed by one or more letters, numbers, or underscores.


-- 🟡 Q7 (Medium):
-- Pivot the `exam_scores` table to show the average score of each student in 'Mathematics', 'Science', and 'History'.
-- The output should contain one row per student.

SELECT 
    student,
    AVG(CASE WHEN subject = 'Mathematics' THEN score ELSE NULL END) AS avg_math,
    AVG(CASE WHEN subject = 'Science' THEN score ELSE NULL END) AS avg_science,
    AVG(CASE WHEN subject = 'History' THEN score ELSE NULL END) AS avg_history
FROM exam_scores
GROUP BY student;

-- 💬 Explanation:
-- Pivoting uses conditional aggregation: the CASE WHEN statement filters values for each subject, and AVG() calculates the average of those specific rows, ignoring NULLs.


-- 🟡 Q8 (Medium):
-- Find the daily distribution of events. For each date, return the total count of events
-- and the percentage of those events that occurred on a 'desktop' device.
-- Round the percentage to 2 decimal places. Ensure you handle potential divide-by-zero errors.

SELECT 
    DATE(event_time) AS event_date,
    COUNT(*) AS total_events,
    ROUND(
        SUM(CASE WHEN device = 'desktop' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 
        2
    ) AS desktop_percentage
FROM user_events
GROUP BY DATE(event_time)
ORDER BY event_date;

-- 💬 Explanation:
-- NULLIF(COUNT(*), 0) evaluates to NULL instead of 0 if there are no events (preventing division-by-zero errors).
-- SUM(CASE WHEN device = 'desktop' THEN 1 ELSE 0 END) counts only the desktop events inside each daily group.


-- 🟡 Q9 (Medium):
-- Write a query to find users who logged in and then made a purchase on the same day.
-- For each matching user, display their user_id, the login time, and the purchase time.

SELECT 
    e1.user_id,
    e1.event_time AS login_time,
    e2.event_time AS purchase_time
FROM user_events e1
JOIN user_events e2 
    ON e1.user_id = e2.user_id 
    AND e2.event_type = 'purchase' 
    AND DATE(e1.event_time) = DATE(e2.event_time)
    AND e2.event_time > e1.event_time
WHERE e1.event_type = 'login';

-- 💬 Explanation:
-- We perform a self-join on `user_events`.
-- The join condition matches on the same `user_id`, same day (`DATE(e1.event_time) = DATE(e2.event_time)`), where the second event is a purchase (`e2.event_type = 'purchase'`) occurring after the login (`e2.event_time > e1.event_time`).


-- 🔴 Q10 (Hard):
-- Find all users who had a 'login' event, and then had ANY subsequent event on a DIFFERENT day within 3 days of that login.

SELECT DISTINCT e1.user_id
FROM user_events e1
JOIN user_events e2
    ON e1.user_id = e2.user_id
    AND DATEDIFF(e2.event_time, e1.event_time) BETWEEN 1 AND 3
WHERE e1.event_type = 'login';

-- 💬 Explanation:
-- DATEDIFF(e2.event_time, e1.event_time) BETWEEN 1 AND 3 ensures the subsequent event (e2) occurred at least 1 day and at most 3 days after the login event (e1).
-- DISTINCT prevents the same user from appearing multiple times if they meet the criteria through multiple events.


-- 🟡 Q11 (Medium):
-- Write a query to output a custom formatted sentence for each event in `user_events`.

SELECT 
    CONCAT('User ', user_id, ' performed a ', event_type, ' event on ', 
           DATE_FORMAT(event_time, '%M %d, %Y at %h:%i %p'), '.') AS event_sentence
FROM user_events;

-- 💬 Explanation:
-- CONCAT combines text and date columns.
-- DATE_FORMAT(event_time, '%M %d, %Y at %h:%i %p') formats the date component to "Month Day, Year at Hour:Minute AM/PM".


-- 🟡 Q12 (Medium):
-- Return the username, clean bio (spaces removed), and the length of the bio BEFORE and AFTER cleaning for John Doe.

SELECT 
    username, 
    CHAR_LENGTH(bio) AS original_length, 
    CHAR_LENGTH(TRIM(bio)) AS cleaned_length,
    TRIM(bio) AS clean_bio
FROM user_profiles
WHERE id = 10;

-- 💬 Explanation:
-- TRIM() cuts leading and trailing whitespaces.
-- CHAR_LENGTH() measures character lengths to illustrate the difference before and after cleaning.


-- 🟡 Q13 (Medium):
-- For each student in `exam_scores`, find the score difference between their 'Mathematics' score and their 'Science' score.

SELECT 
    student,
    MAX(CASE WHEN subject = 'Mathematics' THEN score END) AS math_score,
    MAX(CASE WHEN subject = 'Science' THEN score END) AS science_score,
    MAX(CASE WHEN subject = 'Mathematics' THEN score END) - MAX(CASE WHEN subject = 'Science' THEN score END) AS score_diff
FROM exam_scores
GROUP BY student
HAVING math_score IS NOT NULL AND science_score IS NOT NULL;

-- 💬 Explanation:
-- Conditional aggregation (MAX + CASE) retrieves the math and science scores per student as columns.
-- The HAVING clause filters out students who did not take both exams, avoiding NULL differences.


-- 🟡 Q14 (Medium):
-- Group the events by the day of the week they occurred. Order from Sunday to Saturday.

SELECT 
    DATE_FORMAT(event_time, '%W') AS weekday,
    COUNT(*) AS total_events
FROM user_events
GROUP BY weekday, DAYOFWEEK(event_time)
ORDER BY DAYOFWEEK(event_time);

-- 💬 Explanation:
-- DATE_FORMAT(event_time, '%W') returns 'Sunday', 'Monday', etc.
-- DAYOFWEEK(event_time) returns a number from 1 (Sunday) to 7 (Saturday), which we use for correct chronological ordering.


-- 🔴 Q15 (Hard):
-- Find all users whose bio contains a key-value pattern (like 'key=value'). Extract the matched pattern.

SELECT 
    username, 
    bio,
    REGEXP_SUBSTR(bio, '[a-zA-Z0-9_]+=[a-zA-Z0-9_]+') AS pattern_match
FROM user_profiles
WHERE bio REGEXP '[a-zA-Z0-9_]+=[a-zA-Z0-9_]+';

-- 💬 Explanation:
-- REGEXP filters rows where the bio contains the pattern.
-- REGEXP_SUBSTR() is a MySQL 8.0+ function that extracts the actual matching substring from the column, proving highly useful for log parsers.
