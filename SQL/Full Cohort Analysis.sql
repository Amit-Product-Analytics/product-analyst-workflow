select *  from orders_clean ;
-- Pivot the Cohort Table
with first_order as(
select 
user_id,
min(order_date) as first_order_date
from orders_clean 
where order_status = 'Completed'
group by user_id
)
,
cohort as 
( 
select 
date_format(f.first_order_date,'%y-%m') as Cohort_Month,
timestampdiff(month,f.first_order_date,o.order_date) as Month_Number,
o.user_id

from first_order f join orders_clean o
on f.user_id = o.user_id
where order_status = 'Completed'
),
cohort_size as 
(
select 
Cohort_Month,
COUNT(DISTINCT user_id) AS Cohort_Size
FROM cohort
WHERE Month_Number=0
GROUP BY Cohort_Month
)
select 
c.Cohort_Month,
round(100,2) as M0,
ROUND(COUNT(DISTINCT CASE WHEN Month_Number=1 THEN c.user_id END)*100/cs.Cohort_Size,2) AS M1,
ROUND(COUNT(DISTINCT CASE WHEN Month_Number=2 THEN c.user_id END)*100/cs.Cohort_Size,2) AS M2,
ROUND(COUNT(DISTINCT CASE WHEN Month_Number=3 THEN c.user_id END)*100/cs.Cohort_Size,2) AS M3,
ROUND(COUNT(DISTINCT CASE WHEN Month_Number=4 THEN c.user_id END)*100/cs.Cohort_Size,2) AS M4,
ROUND(COUNT(DISTINCT CASE WHEN Month_Number=5 THEN c.user_id END)*100/cs.Cohort_Size,2) AS M5

from cohort c join cohort_size cs on 
c.Cohort_Month =cs.Cohort_Month
group by 1
order by 1 ;

-- Cohort Retention %

WITH first_order AS
(
SELECT
    user_id,
    MIN(order_date) AS first_order_date
FROM orders_clean
WHERE order_status='Completed'
GROUP BY user_id
),

cohort AS
(
SELECT

DATE_FORMAT(f.first_order_date,'%Y-%m') AS Cohort_Month,

TIMESTAMPDIFF(
MONTH,
f.first_order_date,
o.order_date
) AS Month_Number,

o.user_id

FROM first_order f

JOIN orders_clean o
ON f.user_id=o.user_id

WHERE o.order_status='Completed'
),

cohort_size AS
(
SELECT

Cohort_Month,

COUNT(DISTINCT user_id) AS Cohort_Size

FROM cohort

WHERE Month_Number=0

GROUP BY Cohort_Month
)

SELECT

c.Cohort_Month,

c.Month_Number,

COUNT(DISTINCT c.user_id) AS Active_Users,

cs.Cohort_Size,

ROUND(
COUNT(DISTINCT c.user_id)*100.0/
cs.Cohort_Size
,2) AS Retention_Rate

FROM cohort c

JOIN cohort_size cs

ON c.Cohort_Month=cs.Cohort_Month

GROUP BY
c.Cohort_Month,
c.Month_Number,
cs.Cohort_Size

ORDER BY
1,2;

-- Cohort Size

WITH first_order AS
(
SELECT
user_id,
MIN(order_date) first_order_date
FROM orders_clean
WHERE order_status='Completed'
GROUP BY user_id
)

SELECT

DATE_FORMAT(first_order_date,'%Y-%m') AS Cohort_Month,

COUNT(*) AS Cohort_Size

FROM first_order

GROUP BY 1;









