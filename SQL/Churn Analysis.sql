/*
===========================================================
Project: E-Commerce Product Analytics
File: C Analytics.sql
Author: Amit Kumar

Description:
This script analyzes subscription performance by calculating:
1. Overall subscription metrics
2. Plan-wise subscription performance
3. Average subscription lifetime
4. Monthly churn trend
===========================================================
*/

-- KPI 1 : Overall Subscription Summary
-- =========================================================

SELECT
    COUNT(DISTINCT subscription_id) AS total_users,

    SUM(
        CASE
            WHEN status = 'Active' THEN 1
            ELSE 0
        END
    ) AS active_users,

    SUM(
        CASE
            WHEN status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_users,

    ROUND(
        SUM(
            CASE
                WHEN status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) * 100
        /
        COUNT(DISTINCT subscription_id),
        2
    ) AS churn_rate

FROM subscriptions_clean;


-- =========================================================
-- KPI 2 : Plan-wise Subscription Performance
-- =========================================================

SELECT

    plan_type,

    COUNT(DISTINCT subscription_id) AS total_users,

    SUM(
        CASE
            WHEN status = 'Active' THEN 1
            ELSE 0
        END
    ) AS active_users,

    SUM(
        CASE
            WHEN status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_users,

    ROUND(
        SUM(
            CASE
                WHEN status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) * 100
        /
        COUNT(DISTINCT subscription_id),
        2
    ) AS churn_rate

FROM subscriptions_clean

GROUP BY plan_type

ORDER BY churn_rate DESC;


-- =========================================================
-- KPI 3 : Average Subscription Lifetime
-- (Cancelled Users Only)
-- =========================================================

SELECT

    plan_type,

    ROUND(
        AVG(
            DATEDIFF(end_date, start_date)
        ),
        2
    ) AS avg_subscription_lifetime_days

FROM subscriptions_clean

WHERE status = 'Cancelled'

GROUP BY plan_type

ORDER BY avg_subscription_lifetime_days DESC;


-- =========================================================
-- KPI 4 : Monthly Churn Trend
-- =========================================================

SELECT

    DATE_FORMAT(start_date, '%Y-%m') AS subscription_month,

    COUNT(DISTINCT subscription_id) AS total_users,

    SUM(
        CASE
            WHEN status = 'Active' THEN 1
            ELSE 0
        END
    ) AS active_users,

    SUM(
        CASE
            WHEN status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_users,

    ROUND(
        SUM(
            CASE
                WHEN status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) * 100
        /
        COUNT(DISTINCT subscription_id),
        2
    ) AS churn_rate

FROM subscriptions_clean

GROUP BY subscription_month

ORDER BY subscription_month;