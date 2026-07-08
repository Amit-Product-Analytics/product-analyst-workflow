SELECT * FROM rfm_customer;
CREATE TABLE rfm_customer AS

WITH rfm AS
(
SELECT

user_id,

DATEDIFF(
    (SELECT MAX(order_date) FROM orders_clean WHERE order_status='Completed'),
    MAX(order_date)
) AS Recency,

COUNT(DISTINCT order_id) AS Frequency,

ROUND(SUM(total_amount),2) AS Monetary

FROM orders_clean

WHERE order_status='Completed'

GROUP BY user_id
),

rfm_score AS
(
SELECT

user_id,
Recency,
Frequency,
Monetary,

NTILE(5) OVER(ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER(ORDER BY Frequency) AS F_Score,
NTILE(5) OVER(ORDER BY Monetary) AS M_Score

FROM rfm
)

SELECT

user_id,

Recency,
Frequency,
Monetary,

R_Score,
F_Score,
M_Score,

CONCAT(R_Score,F_Score,M_Score) AS RFM_Score,

CASE

WHEN R_Score=5 AND F_Score>=4 AND M_Score>=4
THEN 'Champions'

WHEN R_Score>=4 AND F_Score>=3
THEN 'Loyal Customers'

WHEN R_Score>=3 AND F_Score>=3
THEN 'Potential Loyalists'

WHEN R_Score<=2 AND F_Score>=3
THEN 'At Risk'

WHEN R_Score=1 AND F_Score<=2
THEN 'Lost'

ELSE 'Others'

END AS Segment

FROM rfm_score;
