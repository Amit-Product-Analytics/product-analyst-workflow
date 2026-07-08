select * from orders_clean;
select * from users_clean;


-- Revenue trend by month, and by acquisition channel
select
date_format(oc.order_date,'%y-%m') as Months,
uc.acquisition_channel,
round((sum(oc.total_amount)),2) as Total_Revenue
from orders_clean oc join users_clean uc on 
oc.user_id =uc.user_id
where oc.order_status = 'Completed'
group by 1,2
order by 3 desc ;


-- Repeat Purchase Rate 
    
   select 
* from orders_clean;
select 
round(count( case when Order_count >1 then user_id end)*100/count(distinct user_id ),2) as Repeat_rate
from
(select user_id,
count(distinct order_id) as Order_count
from orders_clean
where order_status = 'Completed'
group by 1)as t;

-- Average order value (AOV) and revenue by category 
  select 
* from orders_clean;
  select 
* from products_clean;

select 
count(distinct order_id)as Total_users,
count(case when order_status = 'Completed' then order_id end) as Active_users,
sum(case when order_status = 'Completed' then total_amount end) as Active_user_amount,
round(sum(case when order_status = 'Completed' then total_amount end)*100/count(distinct order_id),2) as Aov
from orders_clean;

select
  pc.category,
round(sum(case when oc.order_status = 'Completed' then oc.total_amount end),2) as Total_Amount_Purchase_Completed
from orders_clean oc join products_clean pc on 
oc.product_id =pc.product_id  
group by 1
order by 2 desc;
    
 -- Funnel Analysis
with funnel_analysis as
(
select 
sum( case when event_name = 'Homepage_View' then 1 else 0 end) as Homepage_View,
sum( case when event_name = 'Product_View' then 1 else 0 end) as Product_View,
sum( case when event_name = 'Add_To_Cart' then 1 else 0 end) as Add_To_Cart,
sum( case when event_name = 'Checkout_Start' then 1 else 0 end) as Checkout_Start,
sum( case when event_name = 'Purchase_Complete' then 1 else 0 end) as Purchase_Complete
from events_clean
) 
select 
Homepage_View,
Product_View,
Add_To_Cart,
Checkout_Start,
Purchase_Complete,
round(Product_View *100/Homepage_View,2) as Product_to_Homepage_rate,
round(Add_To_Cart *100/Product_View ,2) as Add_to_Product_rate,
round(Checkout_Start *100/Add_To_Cart,2) as Checkout_to_Add_rate,
round(Purchase_Complete *100/Checkout_Start,2) as Purchase_to_Checkout_rate,
round(Purchase_Complete *100/Homepage_View,2) as Conversion
from funnel_analysis ;   
    
    
    select * from events_clean;
    -- Stickiness Ratio (DAU / MAU)
    WITH daily AS
(
SELECT
    DATE_FORMAT(event_date,'%Y-%m') AS Month,
    event_date,
    COUNT(DISTINCT user_id) AS DAU
FROM events_clean
GROUP BY Month,event_date
),

monthly AS
(
SELECT
    DATE_FORMAT(event_date,'%Y-%m') AS Month,
    COUNT(DISTINCT user_id) AS MAU
FROM events_clean
GROUP BY Month
)

SELECT
    d.Month,
    ROUND(AVG(d.DAU),2) AS Avg_DAU,
    m.MAU,
    ROUND(AVG(d.DAU)*100/m.MAU,2) AS Stickiness_Ratio
FROM daily d
JOIN monthly m
ON d.Month=m.Month
GROUP BY d.Month,m.MAU
ORDER BY d.Month;

   
    
    