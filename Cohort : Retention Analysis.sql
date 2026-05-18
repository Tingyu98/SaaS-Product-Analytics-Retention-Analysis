/*
===========================================================
Cohort / Retention Analysis
===========================================================

Business Problem:
The SaaS platform wants to understand how well customers are retained after signup.

This cohort analysis groups customers by their signup month and tracks whether they remain active in the following months.

This helps the business identify:
- which customer cohorts retain better
- whether retention improves or declines over time
- how quickly customers drop off after signup
*/

-- 1. Creating customer cohorts based on signup month.
SELECT customer_id, DATE_FORMAT(signup_date, '%Y-%m') AS cohort_month
FROM clean_customers
ORDER BY cohort_month , customer_id;

-- 2. Identifying the months when each customer had an active subscription.
-- Active users are defined as customers with an active subscription record in a given month.
SELECT customer_id, month AS active_month
FROM subscriptions
GROUP BY customer_id, month
ORDER BY customer_id, active_month;

-- 3. Combining customer signup cohort with monthly subscription activity.
-- This allows us to track how many months after signup each customer remained active

/*
Combining customer signup cohort with monthly subscription activity.
This allows us to track how many months after signup each customer remained active.
*/

SELECT
    c.customer_id,
    DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
    s.month AS active_month,
    TIMESTAMPDIFF( MONTH, DATE_FORMAT(c.signup_date, '%Y-%m-01'), STR_TO_DATE(CONCAT(s.month, '-01'), '%Y-%m-%d')) AS cohort_index
FROM clean_customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
ORDER BY c.customer_id, active_month;

-- 4. Count Retained Users by Cohort Month
WITH cohort_activity AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
        s.month AS active_month,
        TIMESTAMPDIFF(MONTH, DATE_FORMAT(c.signup_date, '%Y-%m-01'), STR_TO_DATE(CONCAT(s.month, '-01'), '%Y-%m-%d') ) AS cohort_index
    FROM clean_customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
)
SELECT cohort_month, cohort_index, COUNT(DISTINCT customer_id) AS active_users
FROM cohort_activity
WHERE cohort_index >= 0
GROUP BY cohort_month, cohort_index
ORDER BY cohort_month, cohort_index;

-- 5. Retention Rate
-- Retention Rate = active users in each cohort month / users in cohort month 0
WITH cohort_activity AS (
    SELECT c.customer_id, DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month, s.month AS active_month,
        TIMESTAMPDIFF(MONTH, DATE_FORMAT(c.signup_date, '%Y-%m-01'), STR_TO_DATE(CONCAT(s.month, '-01'), '%Y-%m-%d') ) AS cohort_index
    FROM clean_customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
),
cohort_counts AS (
    SELECT cohort_month, cohort_index, COUNT(DISTINCT customer_id) AS active_users
    FROM cohort_activity
    WHERE cohort_index >= 0
    GROUP BY cohort_month, cohort_index
),
cohort_size AS (
    SELECT cohort_month, active_users AS cohort_users
    FROM cohort_counts
    WHERE cohort_index = 0
)
SELECT cc.cohort_month, cc.cohort_index, cc.active_users, cs.cohort_users, ROUND(cc.active_users * 100.0 / cs.cohort_users, 2) AS retention_rate
FROM cohort_counts cc
JOIN cohort_size cs ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.cohort_index;

/*
Cohort Retention Results

This analysis tracks how many customers remain active in each month after signup.

A higher retention rate means customers from that signup cohort continued using the subscription service.

Month 0 represents the signup month and should be treated as the cohort baseline.

Declining retention over later months is expected, but a sharp drop may indicate onboarding, activation, or product value issues.
*/