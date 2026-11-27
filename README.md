# 🎯 SQL Mastery — Big Tech Interview Course Index

This index page serves as your quick-reference map to navigate lessons, practice questions, and verified solutions. 

> [!TIP]
> **Clicking any file link below will open it directly in your editor.** All links use relative paths to ensure cross-platform compatibility and seamless navigation.

---

## 📂 Interactive Course Directory

### 🗺️ Module 01: Foundations
*Database:* `sql_course_m1` | *Focus:* Core CRUD, constraints, sorting, and base filters.
*   🛠️ **Database Initialization:** [setup.sql](./Module_01_Foundations/setup.sql)
*   📘 **Lesson 01:** [01_databases_and_tables.sql](./Module_01_Foundations/01_databases_and_tables.sql) *(DDL, tables, columns, alterations)*
*   📘 **Lesson 02:** [02_data_types_and_constraints.sql](./Module_01_Foundations/02_data_types_and_constraints.sql) *(Keys, constraints, and datatypes)*
*   📘 **Lesson 03:** [03_crud_operations.sql](./Module_01_Foundations/03_crud_operations.sql) *(Insert, select, update, delete, truncate)*
*   📘 **Lesson 04:** [04_filtering_and_sorting.sql](./Module_01_Foundations/04_filtering_and_sorting.sql) *(Where clauses, ranges, wildcards, sorting, limits)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_01_Foundations/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_01_Foundations/solutions.sql)

---

### 🗺️ Module 02: Aggregation & Grouping
*Database:* `sql_course_m2` | *Focus:* Aggregating data, partitioning rows into groups.
*   🛠️ **Database Initialization:** [setup.sql](./Module_02_Aggregation/setup.sql)
*   📘 **Lesson 01:** [01_aggregate_functions.sql](./Module_02_Aggregation/01_aggregate_functions.sql) *(COUNT, SUM, AVG, MIN, MAX, NULL behavior)*
*   📘 **Lesson 02:** [02_group_by.sql](./Module_02_Aggregation/02_group_by.sql) *(Single and multi-column groupings)*
*   📘 **Lesson 03:** [03_having.sql](./Module_02_Aggregation/03_having.sql) *(WHERE vs HAVING, group filters)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_02_Aggregation/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_02_Aggregation/solutions.sql)

---

### 🗺️ Module 03: JOINs
*Database:* `sql_course_m3` | *Focus:* Multi-table joins and relational query patterns.
*   🛠️ **Database Initialization:** [setup.sql](./Module_03_Joins/setup.sql)
*   📘 **Lesson 01:** [01_inner_join.sql](./Module_03_Joins/01_inner_join.sql) *(Base inner joins)*
*   📘 **Lesson 02:** [02_left_right_join.sql](./Module_03_Joins/02_left_right_join.sql) *(Outer joins, anti-join records lookup)*
*   📘 **Lesson 03:** [03_self_join.sql](./Module_03_Joins/03_self_join.sql) *(Manager trees, sequential comparisons)*
*   📘 **Lesson 04:** [04_full_cross_union.sql](./Module_03_Joins/04_full_cross_union.sql) *(Cross joins, simulating full join, UNION vs UNION ALL)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_03_Joins/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_03_Joins/solutions.sql)

---

### 🗺️ Module 04: Subqueries
*Database:* `sql_course_m4` | *Focus:* Nested expressions, derived tables, and exists filters.
*   🛠️ **Database Initialization:** [setup.sql](./Module_04_Subqueries/setup.sql)
*   📘 **Lesson 01:** [01_scalar_and_row_subqueries.sql](./Module_04_Subqueries/01_scalar_and_row_subqueries.sql) *(Scalar values, multi-row matches)*
*   📘 **Lesson 02:** [02_table_subqueries.sql](./Module_04_Subqueries/02_table_subqueries.sql) *(Derived tables, aliases, derived aggregates)*
*   📘 **Lesson 03:** [03_correlated_subqueries.sql](./Module_04_Subqueries/03_correlated_subqueries.sql) *(Outer dependencies, performance impacts)*
*   📘 **Lesson 04:** [04_exists_and_in.sql](./Module_04_Subqueries/04_exists_and_in.sql) *(EXISTS vs IN, the NOT IN NULL pitfall)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_04_Subqueries/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_04_Subqueries/solutions.sql)

---

### 🗺️ Module 05: Window Functions
*Database:* `sql_course_m5` | *Focus:* Multi-row analytics without grouping.
*   🛠️ **Database Initialization:** [setup.sql](./Module_05_Window_Functions/setup.sql)
*   📘 **Lesson 01:** [01_intro_to_over.sql](./Module_05_Window_Functions/01_intro_to_over.sql) *(OVER, partition by, order by syntax)*
*   📘 **Lesson 02:** [02_row_number_rank_dense_rank.sql](./Module_05_Window_Functions/02_row_number_rank_dense_rank.sql) *(Ties, rankings, Top-N filtering)*
*   📘 **Lesson 03:** [03_aggregate_windows.sql](./Module_05_Window_Functions/03_aggregate_windows.sql) *(Running totals, comparisons against group averages)*
*   📘 **Lesson 04:** [04_lag_lead_value_functions.sql](./Module_05_Window_Functions/04_lag_lead_value_functions.sql) *(LAG/LEAD MoM calculations, FIRST/LAST_VALUE)*
*   📘 **Lesson 05:** [05_frame_specification.sql](./Module_05_Window_Functions/05_frame_specification.sql) *(ROWS vs RANGE boundaries, moving averages)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_05_Window_Functions/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_05_Window_Functions/solutions.sql)

---

### 🗺️ Module 06: CTEs (Common Table Expressions)
*Database:* `sql_course_m6` | *Focus:* Temporary result sets, sequence generation, and recursion trees.
*   🛠️ **Database Initialization:** [setup.sql](./Module_06_CTEs/setup.sql)
*   📘 **Lesson 01:** [01_basic_ctes.sql](./Module_06_CTEs/01_basic_ctes.sql) *(WITH syntax, CTEs vs subqueries)*
*   📘 **Lesson 02:** [02_multiple_ctes.sql](./Module_06_CTEs/02_multiple_ctes.sql) *(Chained CTE statements)*
*   📘 **Lesson 03:** [03_recursive_ctes.sql](./Module_06_CTEs/03_recursive_ctes.sql) *(Recursive traversal, org chart hierarchies, sequence gaps fill)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_06_CTEs/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_06_CTEs/solutions.sql)

---

### 🗺️ Module 07: Advanced Query Patterns
*Database:* `sql_course_m7` | *Focus:* Date/time logic, string manipulation, conditionals, and SARGability.
*   🛠️ **Database Initialization:** [setup.sql](./Module_07_Advanced_Queries/setup.sql)
*   📘 **Lesson 01:** [01_date_and_time.sql](./Module_07_Advanced_Queries/01_date_and_time.sql) *(Date intervals, DATE_FORMAT, hourly events distribution)*
*   📘 **Lesson 02:** [02_string_functions.sql](./Module_07_Advanced_Queries/02_string_functions.sql) *(LENGTH vs CHAR_LENGTH, regex string patterns)*
*   📘 **Lesson 03:** [03_case_when.sql](./Module_07_Advanced_Queries/03_case_when.sql) *(CASE sorting, row-to-column pivoting, NULLIF division-by-zero protection)*
*   📘 **Lesson 04:** [04_type_conversion.sql](./Module_07_Advanced_Queries/04_type_conversion.sql) *(Explicit CAST/CONVERT, MySQL casting, implicit conversion hazards)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_07_Advanced_Queries/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_07_Advanced_Queries/solutions.sql)

---

### 🗺️ Module 08: Interview Problem Patterns
*Database:* `sql_course_m8` | *Focus:* Gaps/Islands, ranking methods, cumulative metrics, deduplication.
*   🛠️ **Database Initialization:** [setup.sql](./Module_08_Interview_Patterns/setup.sql)
*   📘 **Lesson 01:** [01_consecutive_and_gaps.sql](./Module_08_Interview_Patterns/01_consecutive_and_gaps.sql) *(3+ consecutive active days, gaps discovery)*
*   📘 **Lesson 02:** [02_top_n_and_ranking.sql](./Module_08_Interview_Patterns/02_top_n_and_ranking.sql) *(Nth highest salary, Top-N earners per department)*
*   📘 **Lesson 03:** [03_cumulative_calculations.sql](./Module_08_Interview_Patterns/03_cumulative_calculations.sql) *(Running balance ledgers, MoM percentage growth rates)*
*   📘 **Lesson 04:** [04_duplicates.sql](./Module_08_Interview_Patterns/04_duplicates.sql) *(Finding duplicates, safe delete workarounds)*
*   📘 **Lesson 05:** [05_existence_and_matching.sql](./Module_08_Interview_Patterns/05_existence_and_matching.sql) *(Anti-joins, the NOT IN null pitfall, mutual connections)*
*   📘 **Lesson 06:** [06_pivot_and_median.sql](./Module_08_Interview_Patterns/06_pivot_and_median.sql) *(Pivoting/unpivoting, median calculation algorithms)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_08_Interview_Patterns/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_08_Interview_Patterns/solutions.sql)

---

### 🗺️ Module 09: Performance & Optimization
*Database:* `sql_course_m9` | *Focus:* Indexing strategies, execution plan metrics, normalization guidelines.
*   🛠️ **Database Initialization:** [setup.sql](./Module_09_Performance/setup.sql)
*   📘 **Lesson 01:** [01_indexes.sql](./Module_09_Performance/01_indexes.sql) *(B-tree, composite indexes, leftmost prefix rules, covering indexes)*
*   📘 **Lesson 02:** [02_explain_and_optimization.sql](./Module_09_Performance/02_explain_and_optimization.sql) *(EXPLAIN fields, EXPLAIN ANALYZE, sargable rewrites)*
*   📘 **Lesson 03:** [03_normalization_and_acid.sql](./Module_09_Performance/03_normalization_and_acid.sql) *(1NF/2NF/3NF design, transaction commit/rollback, isolation level anomalies)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_09_Performance/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_09_Performance/solutions.sql)

---

### 🗺️ Module 10: Bonus — Views, Procedures, Triggers
*Database:* `sql_course_m10` | *Focus:* Procedural SQL logic, automation hooks, locking.
*   🛠️ **Database Initialization:** [setup.sql](./Module_10_Bonus/setup.sql)
*   📘 **Lesson 01:** [01_views.sql](./Module_10_Bonus/01_views.sql) *(Virtual views, security filters, updatable views rules)*
*   📘 **Lesson 02:** [02_stored_procedures.sql](./Module_10_Bonus/02_stored_procedures.sql) *(Delimiters, IN/OUT params, procedure IF-THEN conditional blocks)*
*   📘 **Lesson 03:** [03_triggers.sql](./Module_10_Bonus/03_triggers.sql) *(BEFORE/AFTER triggers, NEW/OLD record targets, change logging audits)*
*   📘 **Lesson 04:** [04_temp_tables_and_advanced.sql](./Module_10_Bonus/04_temp_tables_and_advanced.sql) *(Temp tables, partitioning, Pessimistic Locking FOR UPDATE)*
*   ✏️ **Practice Exercises:** [practice.sql](./Module_10_Bonus/practice.sql)
*   🔑 **Verified Solutions:** [solutions.sql](./Module_10_Bonus/solutions.sql)

---

## 📊 Database & Table Quick Reference

| Database | Table Name | Key Columns | Purpose |
| :--- | :--- | :--- | :--- |
| **`sql_course_m1`** | `departments` | `id (PK)`, `name`, `floor`, `budget` | Department mapping details |
| | `employees` | `id (PK)`, `first_name`, `last_name`, `salary`, `dept_id` | Core employee database |
| | `sales` | `id (PK)`, `employee_id`, `product`, `amount`, `sale_date` | Sales records for aggregation |
| **`sql_course_m3`** | `customers` | `id (PK)`, `name`, `email`, `city`, `signup_date` | Profile registration data |
| | `orders` | `id (PK)`, `customer_id`, `order_date`, `total_amount` | Customer transactions log |
| | `products` | `id (PK)`, `name`, `category`, `price`, `stock` | E-commerce items catalog |
| | `order_items` | `id (PK)`, `order_id`, `product_id`, `quantity`, `price` | Many-to-many lookup table |
| | `employees` | `id (PK)`, `name`, `manager_id`, `department`, `salary` | Self-referential hierarchies |
| **`sql_course_m5`** | `employees` | `id (PK)`, `name`, `department`, `salary`, `hire_date` | Window rankings and groupings |
| | `monthly_sales` | `id (PK)`, `salesperson`, `month`, `revenue` | Running sum and lag analytics |
| | `user_logins` | `id (PK)`, `user_id`, `login_date` | Login records for analytics |
| **`sql_course_m6`** | `org_chart` | `id (PK)`, `name`, `role`, `manager_id`, `level` | Recursive org structures |
| | `categories` | `id (PK)`, `name`, `parent_id` | Tree structure hierarchy |
| **`sql_course_m7`** | `user_events` | `id (PK)`, `user_id`, `event_type`, `event_time`, `device` | Datetime filtering log |
| | `user_profiles` | `id (PK)`, `username`, `email`, `full_name`, `bio` | Text and parsing functions |
| | `exam_scores` | `id (PK)`, `student`, `subject`, `score`, `grade_date` | CASE pivoting, type conversion |
| **`sql_course_m8`** | `logins` | `id (PK)`, `user_id`, `login_date` | Consecutive streaks & sequence gaps |
| | `employee_salaries`| `id (PK)`, `name`, `department`, `salary` | Ties and Nth rankings |
| | `transactions` | `id (PK)`, `user_id`, `amount`, `txn_date`, `txn_type` | Monthly series, cumulative sum |
| | `contacts` | `id (PK)`, `name`, `email`, `phone` | Duplicate identification and cleanups |
| | `friendships` | `user_id_1 (PK)`, `user_id_2 (PK)` | Social networks, mutual friends |
| | `scores` | `id (PK)`, `student`, `subject`, `score` | Pivots, median score values |
| **`sql_course_m9`** | `large_orders` | `id (PK)`, `customer_id`, `amount`, `order_date`, `region` | Performance tests, composite indexes |
| **`sql_course_m10`**| `inventory` | `id (PK)`, `product`, `category`, `quantity`, `price` | Views, procedures, lock tests |
| | `audit_log` | `id (PK)`, `table_name`, `action`, `details`, `changed_at`| Target for database triggers |

---

## ⚙️ Running & Verifying Scripts

```powershell
# 1. Execute Setup to initialize the database
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -plocalhost -e "source C:/Users/reala/Documents/Github/SQL/Module_XX_Name/setup.sql"

# 2. Run your practice solutions or lesson queries
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -plocalhost -e "source C:/Users/reala/Documents/Github/SQL/Module_XX_Name/solutions.sql"

# 3. Drop the database when finished to return the environment to a clean state
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -plocalhost -e "DROP DATABASE sql_course_mXX"
```
