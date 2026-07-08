SELECT * FROM cohort_retention;
CREATE TABLE cohort_retention AS

WITH first_order AS
(
    SELECT
        user_id,
        MIN(order_date) AS first_order_date
    FROM orders_clean
    WHERE order_status = 'Completed'
    GROUP BY user_id
),

cohort_data AS
(
    SELECT
        DATE_FORMAT(f.first_order_date,'%Y-%m') AS cohort_month,

        TIMESTAMPDIFF(
            MONTH,
            f.first_order_date,
            o.order_date
        ) AS month_number,

        COUNT(DISTINCT o.user_id) AS retained_users

    FROM first_order f
    JOIN orders_clean o
        ON f.user_id = o.user_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        cohort_month,
        month_number
),

cohort_size AS
(
    SELECT
        cohort_month,
        MAX(retained_users) AS cohort_size
    FROM cohort_data
    WHERE month_number = 0
    GROUP BY cohort_month
)

SELECT

c.cohort_month,

c.month_number,

c.retained_users,

s.cohort_size,

ROUND(
    c.retained_users * 100.0 / s.cohort_size,
    2
) AS retention_pct

FROM cohort_data c
JOIN cohort_size s
ON c.cohort_month = s.cohort_month

ORDER BY
c.cohort_month,
c.month_number;