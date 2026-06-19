-- ============================================================
-- ✏️ MODULE 07 — Practice Questions (Advanced Query Patterns)
-- ============================================================
-- 
-- Instructions:
--   Write your queries below each question.
--   Run each query to verify your answer.
--   Solutions are in: solutions.sql
-- ============================================================

USE sql_course_m7;

-- 🟢 Q1 (Easy):
-- Write a query to return the username, email in all uppercase,
-- and the length of the username (character count) for all users.
-- Sort the results by the username length in descending order.
--
-- Expected columns: username, email_upper, username_length
-- YOUR QUERY:



-- 🟢 Q2 (Easy):
-- Find all user events that occurred on a 'desktop' device between 9:00 AM and 6:00 PM (inclusive of both boundaries)
-- on any day in March 2026.
--
-- Expected columns: id, user_id, event_type, event_time, device
-- YOUR QUERY:



-- 🟢 Q3 (Easy):
-- Write a query on the `exam_scores` table. Return the student name, subject, score, and a grade status:
--   - If score is 90 or above: 'Excellent'
--   - If score is between 70 and 80 (inclusive): 'Passing' (Wait, between 70 and 89 inclusive)
--   - If score is below 70: 'Needs Improvement'
--
-- Expected columns: student, subject, score, status
-- YOUR QUERY:



-- 🟡 Q4 (Medium):
-- Extract the domain name from the `email` column in the `user_profiles` table.
-- Group the profiles by email domain and count how many users belong to each domain.
-- Only show domains that have more than 1 user.
-- Hint: Use SUBSTRING and LOCATE or standard string functions.
--
-- Expected columns: email_domain, user_count
-- YOUR QUERY:



-- 🟡 Q5 (Medium):
-- Calculate the number of days between each user's account creation (`created_at`) and the date '2026-03-01 00:00:00'.
-- Bucket the users into three cohorts based on account age:
--   - 'Veteran': Creation date is older than 365 days from '2026-03-01'
--   - 'Regular': Creation date is between 180 and 365 days from '2026-03-01' (inclusive)
--   - 'Newbie': Creation date is less than 180 days from '2026-03-01'
-- Return the cohort name and the count of users in each cohort.
--
-- Expected columns: cohort, user_count
-- YOUR QUERY:



-- 🟡 Q6 (Medium):
-- Find all users whose `bio` contains a special pattern matching 'code-' followed by any word characters 
-- (e.g., 'code-ninja' or similar pattern). Use regular expressions.
-- Ensure you return the username, full_name, and the bio.
--
-- Expected columns: username, full_name, bio
-- YOUR QUERY:



-- 🟡 Q7 (Medium):
-- Pivot the `exam_scores` table to show the average score of each student in 'Mathematics', 'Science', and 'History'.
-- The output should contain one row per student.
--
-- Expected columns: student, avg_math, avg_science, avg_history
-- YOUR QUERY:



-- 🟡 Q8 (Medium):
-- Find the daily distribution of events. For each date, return the total count of events
-- and the percentage of those events that occurred on a 'desktop' device.
-- Round the percentage to 2 decimal places. Ensure you handle potential divide-by-zero errors.
--
-- Expected columns: event_date, total_events, desktop_percentage
-- YOUR QUERY:



-- 🟡 Q9 (Medium):
-- Write a query to find users who logged in and then made a purchase on the same day.
-- For each matching user, display their user_id, the login time, and the purchase time.
-- Note: A user can login multiple times, match the login to the purchase that occurred AFTER it.
--
-- Expected columns: user_id, login_time, purchase_time
-- YOUR QUERY:



-- 🔴 Q10 (Hard):
-- Let's define "Active User Retention". Find all users who had a 'login' event,
-- and then had ANY subsequent event (of any type) on a DIFFERENT day within 3 days of that login.
-- Output the unique user_ids who satisfy this criteria.
--
-- Expected columns: user_id
-- YOUR QUERY:



-- 🟡 Q11 (Medium):
-- Write a query to output a custom formatted sentence for each event in `user_events`.
-- The sentence should look like:
-- "User 1 performed a login event on March 01, 2026 at 08:31 AM."
-- Format the date and time exactly as shown.
--
-- Expected columns: event_sentence
-- YOUR QUERY:



-- 🟡 Q12 (Medium):
-- In `user_profiles`, John Doe (id = 10) has dirty data in his `bio` column containing leading and trailing spaces.
-- Write a query that returns the username, clean bio (spaces removed), and the length of the bio BEFORE and AFTER cleaning.
--
-- Expected columns: username, original_length, cleaned_length, clean_bio
-- YOUR QUERY:



-- 🟡 Q13 (Medium):
-- For each student in `exam_scores`, find the score difference between their 'Mathematics' score and their 'Science' score.
-- Ensure that students who did not take both exams are excluded, and if any calculation risks dividing or resolving to null, it is managed.
--
-- Expected columns: student, math_score, science_score, score_diff
-- YOUR QUERY:



-- 🟡 Q14 (Medium):
-- Group the events by the day of the week they occurred.
-- Return the name of the weekday (e.g., 'Sunday', 'Monday') and the total count of events on that day.
-- Order the results from Sunday to Saturday.
-- Hint: Use DATE_FORMAT or DAYOFWEEK.
--
-- Expected columns: weekday, total_events
-- YOUR QUERY:



-- 🔴 Q15 (Hard):
-- Parse the `bio` column in `user_profiles` using regular expressions.
-- Find all users whose bio contains a key-value pattern (like 'key=value', e.g., 'user_id=9999' or 'secret_key').
-- Extract the key and the value if possible, or filter the users who have such a pattern.
-- Return the username, bio, and the key-value matched text.
--
-- Expected columns: username, bio, pattern_match
-- YOUR QUERY:
