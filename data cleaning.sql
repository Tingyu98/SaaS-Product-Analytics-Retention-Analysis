/* 
A SaaS subscription platform would like to better understand customer behavior, conversion funnel performance, retention trends, and customer lifetime value.

The company currently collects:
- customer profile data
- subscription records
- user event logs
- monthly revenue data

The objective of this analysis is to identify:
- which acquisition sources drive the highest-value customers
- where users drop off in the conversion funnel
- which customer cohorts retain best over time
- which subscription plans have the highest churn
- opportunities to improve revenue growth and retention
*/

-- 1. Preview Tables
-- Preview customer profile data.
SELECT *
FROM customers
LIMIT 10;

-- Preview subscription records.
SELECT *
FROM subscriptions
LIMIT 10;

-- Preview revenue records.
SELECT *
FROM revenue
LIMIT 10;

-- Preview user event data.
SELECT *
FROM events
LIMIT 10;

-- 2. Check Row Counts
-- Checking the number of records in each table.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL
SELECT 'revenue', COUNT(*) FROM revenue
UNION ALL
SELECT 'events', COUNT(*) FROM events;

-- 3. Check Duplicates
-- Checking whether each customer_id appears only once in the customer profile table.
SELECT
    customer_id,
    COUNT(*) AS record_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Checking duplicate subscription records.
SELECT
    subscription_id,
    customer_id,
    month,
    COUNT(*) AS record_count
FROM subscriptions
GROUP BY subscription_id, customer_id, month
HAVING COUNT(*) > 1;

-- Checking duplicate revenue records.
SELECT
    subscription_id,
    customer_id,
    month,
    revenue_type,
    COUNT(*) AS record_count
FROM revenue
GROUP BY subscription_id, customer_id, month, revenue_type
HAVING COUNT(*) > 1;

-- Checking duplicate user events.
SELECT
    customer_id,
    event_type,
    event_timestamp,
    COUNT(*) AS record_count
FROM events
GROUP BY customer_id, event_type, event_timestamp
HAVING COUNT(*) > 1;

-- 4. Check Missing Values
-- Checking missing values in the customer table.
-- Replace blank churn dates with real NULL values.
UPDATE customers
SET churn_date = NULL
WHERE churn_date = '';
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS missing_signup_date,
    SUM(CASE WHEN plan_type IS NULL THEN 1 ELSE 0 END) AS missing_plan_type,
    SUM(CASE WHEN monthly_fee IS NULL THEN 1 ELSE 0 END) AS missing_monthly_fee,
    SUM(CASE WHEN acquisition_cost IS NULL THEN 1 ELSE 0 END) AS missing_acquisition_cost,
    SUM(CASE WHEN churn_date IS NULL THEN 1 ELSE 0 END) AS missing_churn_date
FROM customers;

-- Checking missing values in the events table.
SELECT
    SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS missing_event_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN event_type IS NULL THEN 1 ELSE 0 END) AS missing_event_type,
    SUM(CASE WHEN event_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_event_timestamp,
    SUM(CASE WHEN source IS NULL THEN 1 ELSE 0 END) AS missing_source,
    SUM(CASE WHEN device IS NULL THEN 1 ELSE 0 END) AS missing_device,
    SUM(CASE WHEN plan_type IS NULL THEN 1 ELSE 0 END) AS missing_plan_type,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country
FROM events;

-- Checking missing values in the subscription table.
SELECT
    SUM(CASE WHEN subscription_id IS NULL THEN 1 ELSE 0 END) AS missing_subscription_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN month IS NULL THEN 1 ELSE 0 END) AS missing_month,
    SUM(CASE WHEN monthly_fee IS NULL THEN 1 ELSE 0 END) AS missing_monthly_fee
FROM subscriptions;

-- Checking missing values in the revenue table.
SELECT
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS missing_amount
FROM revenue;

-- 5. Create Churn Flag
-- Creating a churn flag to identify whether a customer has churned.
ALTER TABLE customers
ADD COLUMN is_churned INT;

-- Customers with a churn_date are marked as churned.
UPDATE customers
SET is_churned =
    CASE
        WHEN churn_date IS NOT NULL THEN 1
        ELSE 0
    END;
    
-- Checking churned vs active customers.
SELECT
    is_churned,
    COUNT(*) AS customer_count
FROM customers
GROUP BY is_churned;

-- 6. Standardize Text Values
-- Checking unique plan types.
SELECT DISTINCT plan_type
FROM customers;

-- Checking unique event types.
SELECT DISTINCT event_type
FROM events;

-- Checking unique acquisition sources.
SELECT DISTINCT source
FROM events;

-- Checking unique devices.
SELECT DISTINCT device
FROM events;

-- Checking unique countries.
SELECT DISTINCT country
FROM events;

-- 7. Validate Dates
-- Checking if churn_date happens before signup_date, which would be logically incorrect.
SELECT *
FROM customers
WHERE churn_date IS NOT NULL
  AND churn_date < signup_date;
  
-- Checking if event_date happens before signup_date.
SELECT
    e.customer_id,
    e.event_type,
    e.event_date,
    c.signup_date
FROM events e
JOIN customers c
    ON e.customer_id = c.customer_id
WHERE e.event_date < c.signup_date;

-- Checking whether subscription-related events happened before signup.
SELECT
    e.customer_id,
    e.event_type,
    e.event_date,
    c.signup_date
FROM events e
JOIN customers c
    ON e.customer_id = c.customer_id
WHERE e.event_type IN ('signup', 'start_trial', 'add_payment', 'subscribe')
  AND e.event_date < c.signup_date;
  
-- 8. Validate Join Keys
-- Checking whether all event customers exist in the customer table.
SELECT DISTINCT e.customer_id
FROM events e
LEFT JOIN customers c
    ON e.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Checking whether all subscription customers exist in the customer table.
SELECT DISTINCT s.customer_id
FROM subscriptions s
LEFT JOIN customers c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Checking whether all revenue customers exist in the customer table.
SELECT DISTINCT r.customer_id
FROM revenue r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 9. Validate Revenue
-- Checking whether there are negative revenue values.
SELECT *
FROM revenue
WHERE amount < 0;
-- Checking the largest revenue records to detect possible outliers.
SELECT *
FROM revenue
ORDER BY amount DESC
LIMIT 20;

-- Checking whether amount matches monthly_fee.
SELECT *
FROM revenue
WHERE amount <> monthly_fee;

-- 10. Create Clean Analysis Views
-- Creating a clean customer-level view for future analysis.
CREATE OR REPLACE VIEW clean_customers AS
SELECT
    customer_id,
    signup_date,
    DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
    LOWER(TRIM(plan_type)) AS plan_type,
    monthly_fee,
    acquisition_cost,
    churn_date,
    CASE
        WHEN churn_date IS NOT NULL THEN 1
        ELSE 0
    END AS is_churned
FROM customers;

-- Creating a clean event-level view for funnel analysis.
CREATE OR REPLACE VIEW clean_events AS
SELECT
    event_id,
    customer_id,
    subscription_id,
    LOWER(TRIM(event_type)) AS event_type,
    event_timestamp,
    event_date,
    event_month,
    funnel_step_order,
    LOWER(TRIM(source)) AS source,
    LOWER(TRIM(device)) AS device,
    LOWER(TRIM(plan_type)) AS plan_type,
    UPPER(TRIM(country)) AS country
FROM events;

-- Creating a clean revenue view for revenue growth and CLV analysis.
CREATE OR REPLACE VIEW clean_revenue AS
SELECT
    subscription_id,
    customer_id,
    month,
    monthly_fee,
    revenue_type,
    amount
FROM revenue;