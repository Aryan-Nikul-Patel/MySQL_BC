-- ============================================================
-- 📘 MODULE 07 — Advanced Query Patterns
-- Lesson 02: String Functions
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Basic and advanced string manipulation (CONCAT, SUBSTRING, REPLACE)
--    - LENGTH vs CHAR_LENGTH (bytes vs characters)
--    - Cleaning strings with TRIM, UPPER, and LOWER
--    - Pattern matching using standard and REGEXP operations
--
-- 💡 Prerequisites: Module 7, Lesson 1
-- ============================================================

USE sql_course_m7;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Concatenation & Substrings
-- ────────────────────────────────────────────
-- 💬 String manipulation is common in interviews when dealing with unstructured text,
--    email addresses, or generating user-facing labels.
--
--    - CONCAT(str1, str2, ...): Combines strings. If any argument is NULL, CONCAT returns NULL!
--    - CONCAT_WS(separator, str1, str2, ...): Concatenates with a separator (WS = With Separator). Ignores NULLs!
--    - SUBSTRING(str, pos, len): Extracts a substring starting at 1-based index `pos` for length `len`.
--    - LEFT(str, len) / RIGHT(str, len): Short-hand to extract from the start or end.

-- ▶ Example 1.1: Displaying full name and email domain
--    We use LOCATE('@', email) to find the '@' symbol, then extract everything after it.
SELECT 
    full_name,
    email,
    SUBSTRING(email, LOCATE('@', email) + 1) AS email_domain
FROM user_profiles;

-- ▶ Example 1.2: Formatting a profile greeting
--    Notice how CONCAT_WS elegantly handles spaces or commas.
SELECT 
    CONCAT_WS(' | ', UPPER(username), full_name, email) AS formatted_profile
FROM user_profiles
LIMIT 3;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: LENGTH vs CHAR_LENGTH
-- ────────────────────────────────────────────
-- 🔥 Interview Tip: This is a classic trick question!
--    - LENGTH(str): Returns length in BYTES.
--    - CHAR_LENGTH(str): Returns length in CHARACTER count.
--    For standard ASCII (English), they are identical. But for multibyte characters (like UTF-8 emojis or non-English text),
--    a single character can be 2 to 4 bytes!
--    Always use CHAR_LENGTH if you want the number of letters/characters.

-- ▶ Example 2.1: Comparing lengths of ASCII and emoji
--    Note: 'SQL' is 3 characters/bytes. 'SQL🚀' has 3 letters plus a 4-byte emoji (7 bytes, 4 characters).
SELECT 
    LENGTH('SQL') AS bytes_sql, 
    CHAR_LENGTH('SQL') AS chars_sql,
    LENGTH('SQL🚀') AS bytes_emoji, 
    CHAR_LENGTH('SQL🚀') AS chars_emoji;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: String Cleaning (TRIM, REPLACE, REVERSE)
-- ────────────────────────────────────────────
-- 💬 Interview queries often present dirty data. You must clean leading/trailing spaces
--    or replace portions of a string.
--
--    - TRIM(str): Removes leading and trailing spaces.
--    - REPLACE(str, from_str, to_str): Replaces all occurrences of a substring.
--    - REVERSE(str): Reverses a string (e.g. check for palindromes).

-- ▶ Example 3.1: Cleaning whitespace and replacing text
SELECT 
    bio,
    TRIM(bio) AS cleaned_bio,
    REPLACE(bio, 'engineer', 'developer') AS updated_bio
FROM user_profiles
WHERE id = 10; -- John Doe has spaces in his bio


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: Pattern Matching with REGEXP
-- ────────────────────────────────────────────
-- 💬 While `LIKE` handles simple wildcards (`%` and `_`), real-world string search
--    often requires Regular Expressions.
--    In MySQL, we use the `REGEXP` (or `REGEXP_LIKE()`) operator.
--
--    Common Regex characters:
--       - `^` : Start of string
--       - `$` : End of string
--       - `.` : Any single character
--       - `*` : Zero or more matches
--       - `+` : One or more matches
--       - `[a-z]` : Any character in range
--       - `[0-9]` : Any digit
--       - `|` : OR condition

-- ▶ Example 4.1: Find users whose bio contains a number (like '9999')
SELECT username, bio
FROM user_profiles
WHERE bio REGEXP '[0-9]+';

-- ▶ Example 4.2: Validate if emails end with '.com', '.mil', or '.net'
SELECT username, email
FROM user_profiles
WHERE email REGEXP '\\.(com|mil|net)$';
-- 💬 The double backslash escapes the dot so it matches a literal period.
