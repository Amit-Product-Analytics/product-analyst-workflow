select * from orders_clean;
select 
max(order_date)
from orders_clean
where order_status = 'Completed';

select
user_id, 
datediff(2025-01-20,min(order_date)) as Recency,
count(*) as Frequency,
round(sum(total_amount),2) as Monetary
from orders_clean
where order_status = 'Completed'
group by 1;




with RFM as
(select
user_id, 
 DATEDIFF(
        (SELECT MAX(order_date)
         FROM orders_clean
         WHERE order_status='Completed'),
        MAX(order_date)
    )  as Recency,
count(*) as Frequency,
round(sum(total_amount),2) as Monetary
from orders_clean
where order_status = 'Completed'
group by 1
)
,
RFM_Score as
(
select *,
ntile(5) over ( order by Recency desc) as R,
ntile(5) over ( order by Frequency desc) as F,
ntile(5) over ( order by Monetary desc) as M
from RFM
),
RFM_Segments as
(
select *,
case when R = 5 and F >=4 and m>=4 then 'Champions'
when R >= 4 and F >=3 and m>=3 then 'Loyal Customer'
when R >=  3 and F >= 2  then 'Potential Loyalists'
when R <=2  and F >=3 then 'At Risk'
when R = 1 and F <=2 then 'Lost'

Else 'Need Attention'
end as Customer_Segment
from RFM_Score)

select 
Customer_Segment,
count(*) as Total_Customer
from RFM_Segments
group by 1 
order by 2 desc ;











