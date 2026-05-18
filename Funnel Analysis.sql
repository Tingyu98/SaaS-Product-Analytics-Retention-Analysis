/*
===========================================================
Part 2 — Funnel Analysis
===========================================================

Business Problem:
The SaaS platform would like to understand how users move through the subscription funnel and identify where the largest drop-off occurs.

Understanding funnel performance can help the business:
- improve onboarding experience
- optimize conversion rates
- identify friction points in the user journey
- improve paid subscriber growth

The funnel stages are defined as:

1. visit_homepage
2. view_pricing
3. signup
4. start_trial
5. add_payment
6. subscribe

This analysis measures:
- number of users reaching each step
- conversion rates between steps
- funnel drop-off behavior
*/

-- 1. Explore Event Types
-- Reviewing all event types captured in the event log.
SELECT DISTINCT event_type
FROM clean_events;

-- 2. Count Users at Each Funnel Step
-- Calculating the number of unique users reaching each stage of the subscription funnel.
SELECT
    event_type,
    COUNT(DISTINCT customer_id) AS users
FROM clean_events
GROUP BY event_type
ORDER BY users DESC;

/*
This query shows how many unique users reached each stage of the funnel.
As expected, the number of users decreases as they move further down the funnel.
*/

-- 3. Create Funnel Summary Table
/*
Creating a funnel summary table to measure:
- users at each stage
- step-by-step conversion rate
- drop-off percentage
*/

WITH funnel_counts AS (

    SELECT 'visit_homepage' AS funnel_step, 1 AS step_order, COUNT(DISTINCT customer_id) AS users
    FROM clean_events
    WHERE event_type = 'visit_homepage'
    UNION
    SELECT 'view_pricing', 2, COUNT(DISTINCT customer_id)
    FROM clean_events
    WHERE event_type = 'view_pricing'
    UNION
    SELECT 'signup',3,COUNT(DISTINCT customer_id)
    FROM clean_events
    WHERE event_type = 'signup'
    UNION
    SELECT 'start_trial',4,COUNT(DISTINCT customer_id)
    FROM clean_events
    WHERE event_type = 'start_trial'
    UNION
    SELECT 'add_payment',5,COUNT(DISTINCT customer_id)
    FROM clean_events
    WHERE event_type = 'add_payment'
    UNION
    SELECT 'subscribe',6,COUNT(DISTINCT customer_id)
    FROM clean_events
    WHERE event_type = 'subscribe'
)

SELECT
    funnel_step,users,
    ROUND(users * 100.0 /FIRST_VALUE(users) OVER (ORDER BY step_order),2) AS overall_conversion_rate,
    ROUND(users * 100.0 /LAG(users) OVER (ORDER BY step_order),2) AS step_conversion_rate,
    ROUND(100 -(users * 100.0 /LAG(users) OVER (ORDER BY step_order)),2) AS drop_off_rate
FROM funnel_counts
ORDER BY step_order;

/*
Funnel Summary Insights

The largest drop-offs occur between:
- visit_homepage → view_pricing (64.31%)
- start_trial → add_payment (65.92%)

This suggests that:
- many visitors are not sufficiently engaged to explore pricing
- many trial users are not converting into paying customers

Only 2.58% of homepage visitors ultimately became subscribers, indicating significant opportunities to improve activation and trial-to-paid conversion.
*/

-- 4. Funnel Conversion by Acquisition Source
/*
Analyzing funnel conversion performance by acquisition source. 
This helps identify which marketing channels generate the highest-quality users.
*/

/*
Analyzing paid conversion rate by acquisition source.
This analysis focuses on registered users only.
*/

SELECT source,
	COUNT(DISTINCT CASE WHEN event_type = 'signup' THEN customer_id END) AS signups,
	COUNT(DISTINCT CASE WHEN event_type = 'subscribe' THEN customer_id END) AS subscribers,
    ROUND(COUNT(DISTINCT CASE WHEN event_type = 'subscribe' THEN customer_id END) * 100.0 
		/COUNT(DISTINCT CASE WHEN event_type = 'signup' THEN customer_id END),2) AS signup_to_subscriber_conversion_rate
FROM clean_events
GROUP BY source
ORDER BY signup_to_subscriber_conversion_rate DESC;

/*
Conversion Analysis by Acquisition Source

Organic search generated the highest acquisition volume, with 277 signups and 53 subscribers.
Email campaigns achieved one of the highest conversion rates at 18.45%, followed by LinkedIn Ads at 15.92%, suggesting these channels attract higher-intent users.
Referral traffic showed the lowest conversion rate at 14.29%, indicating potential differences in traffic quality.
*/


