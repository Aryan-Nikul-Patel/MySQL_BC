-- ============================================================
-- 📘 MODULE 07 — Advanced Query Patterns
-- Lesson 01: Date & Time Operations
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Differences between DATE, DATETIME, and TIMESTAMP
--    - Date arithmetic (DATE_ADD, DATE_SUB, DATEDIFF)
--    - Extracting components and formatting dates
--    - Interview patterns: Grouping and filtering by date/time ranges
--
-- 💡 Prerequisites: Module 1-6
-- ============================================================

USE sql_course_m7;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: DATE, DATETIME, and TIMESTAMP
-- ────────────────────────────────────────────
-- 💬 In SQL interviews, you will frequently be asked about date and time types.
--    Here is the breakdown:
--
--    1. DATE: Stores only the date (YYYY-MM-DD). Range: '1001-01-01' to '9999-12-31'. Uses 3 bytes.
--    2. DATETIME: Stores date AND time (YYYY-MM-DD HH:MM:SS). Range: '1000-01-01 00:00:00' to '9999-12-31 23:59:59'. 
--       It is timezone-agnostic (what you save is what you get). Uses 5-8 bytes.
--    3. TIMESTAMP: Stores date AND time since the Unix Epoch (UTC). Range: '1970-01-01 00:00:01' UTC to '2038-01-19 03:14:07' UTC.
--       It is timezone-aware. MySQL converts value from current timezone to UTC for storage, and back for retrieval. Uses 4 bytes.
--
-- 🔥 Interview Tip: If asked how to choose, TIMESTAMP is great for logging event times (e.g. log files, transactions)
--    because it handles daylight savings and timezones automatically. But it has a hard limit at Year 2038!
--    DATETIME is preferred for future dates or timezone-independent fields (e.g. birth dates, schedule times).

-- ▶ Example 1: View profile creation dates
SELECT username, created_at
FROM user_profiles
LIMIT 3;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Date & Time Arithmetic
-- ────────────────────────────────────────────
-- 💬 To compare dates or find intervals, SQL provides helper functions:
--
--    - DATEDIFF(date1, date2): Returns (date1 - date2) in DAYS. Note: it ignores time portions!
--    - DATE_ADD(date, INTERVAL value unit): Adds time to a date.
--    - DATE_SUB(date, INTERVAL value unit): Subtracts time from a date.
--    - UNITS can be: YEAR, QUARTER, MONTH, WEEK, DAY, HOUR, MINUTE, SECOND, etc.

-- ▶ Example 2.1: Finding age of account in days relative to '2026-03-01'
SELECT username, created_at,
       DATEDIFF('2026-03-01 00:00:00', created_at) AS days_since_creation
FROM user_profiles;

-- ▶ Example 2.2: Add 30 days and subtract 6 months from account creation date
SELECT username, created_at,
       DATE_ADD(created_at, INTERVAL 30 DAY) AS plus_30_days,
       DATE_SUB(created_at, INTERVAL 6 MONTH) AS minus_6_months
FROM user_profiles
LIMIT 3;

-- ⚠️ COMMON MISTAKE:
-- Using standard arithmetic operators on dates (e.g., created_at + 10).
-- In MySQL, created_at + 10 will convert the datetime to an integer (like 20250115083010) and add 10 to it,
-- which results in a garbage number rather than adding 10 days! Always use DATE_ADD or DATE_SUB.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Extracting Components & Formatting
-- ────────────────────────────────────────────
-- 💬 You can extract specific parts of a date using:
--    - YEAR(date), MONTH(date), DAY(date), HOUR(time), MINUTE(time), SECOND(time)
--    - EXTRACT(unit FROM date)
--    - DATE_FORMAT(date, format_string) is incredibly powerful for custom reporting format.
--
--    Common DATE_FORMAT placeholders:
--       - %Y : Year (4 digits)
--       - %m : Month (01-12)
--       - %d : Day (01-31)
--       - %H : Hour (00-23)
--       - %i : Minute (00-59)
--       - %s : Second (00-59)
--       - %M : Month name (January-December)
--       - %W : Weekday name (Sunday-Saturday)

-- ▶ Example 3.1: Extracting year, month, and day
SELECT username, created_at,
       YEAR(created_at) AS yr,
       MONTH(created_at) AS mo,
       DAY(created_at) AS dy,
       EXTRACT(HOUR FROM created_at) AS hr
FROM user_profiles
LIMIT 3;

-- ▶ Example 3.2: Formatting dates for a human-readable report
SELECT username, created_at,
       DATE_FORMAT(created_at, '%W, %M %d, %Y') AS readable_date,
       DATE_FORMAT(created_at, '%Y-%m') AS yr_mo
FROM user_profiles;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: Date Filtering & Aggregating
-- ────────────────────────────────────────────
-- 💬 A classic interview challenge is analyzing events within a specific time window
--    (e.g., weekly active users, hourly event counts, or filtering for a specific date range).
--
-- 🔥 Interview Tip: When filtering by a Date range on a DATETIME column, be careful about boundaries.
--    `WHERE event_time BETWEEN '2026-03-01' AND '2026-03-02'` will only catch events up to '2026-03-02 00:00:00'.
--    Any event on 2026-03-02 at 08:00:00 is missed!
--    To include all events for both days, cast to DATE or use explicit inequalities:
--    `WHERE event_time >= '2026-03-01' AND event_time < '2026-03-03'`

-- ▶ Example 4.1: Counting events per day
SELECT DATE(event_time) AS event_date, COUNT(*) AS total_events
FROM user_events
GROUP BY DATE(event_time)
ORDER BY event_date;

-- ▶ Example 4.2: Hourly distribution of logins (useful for system capacity planning)
SELECT HOUR(event_time) AS login_hour, COUNT(*) AS login_count
FROM user_events
WHERE event_type = 'login'
GROUP BY HOUR(event_time)
ORDER BY login_hour;
