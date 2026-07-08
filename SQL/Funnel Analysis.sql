select * from events_clean;
select * from orders_clean;
select * from products_clean;
select * from subscriptions_clean;
select * from users_clean;

select distinct event_name from events_clean;
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



with funnel_analysis as
(
select 
platform,
sum( case when event_name = 'Homepage_View' then 1 else 0 end) as Homepage_View,
sum( case when event_name = 'Product_View' then 1 else 0 end) as Product_View,
sum( case when event_name = 'Add_To_Cart' then 1 else 0 end) as Add_To_Cart,
sum( case when event_name = 'Checkout_Start' then 1 else 0 end) as Checkout_Start,
sum( case when event_name = 'Purchase_Complete' then 1 else 0 end) as Purchase_Complete
from events_clean
group by platform
) 
select 
platform,
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

-- Time To Purchase

with sessions_events as

(select 
session_id,
min(case when event_name = 'Product_View' 
then timestamp(event_date,event_time) 
end) as Product_View_Time,

min(case when event_name = 'Purchase_Complete' 
then timestamp(event_date,event_time) 
end) as Purchase_Complete_Time

from events_clean
group by session_id )

select 
session_id,
Product_View_Time,
Purchase_Complete_Time,
timestampdiff(MINUTE ,Product_View_Time,Purchase_Complete_Time) as time_to_purchase_minutes
from sessions_events
WHERE Product_View_Time IS NOT NULL
AND Purchase_Complete_Time IS NOT NULL
order by 4 ;

-- Average time taken by Platform

with sessions_events as

(
select 
session_id,
platform,
min(case when event_name = 'Product_View' 
then timestamp(event_date,event_time) 
end) as Product_View_Time,

min(case when event_name = 'Purchase_Complete' 
then timestamp(event_date,event_time) 
end) as Purchase_Complete_Time

from events_clean
group by 1,2 )

select
platform,
round(avg(timestampdiff(MINUTE ,Product_View_Time,Purchase_Complete_Time) ),2)as time_to_purchase_minutes
from sessions_events
WHERE Product_View_Time IS NOT NULL
AND Purchase_Complete_Time IS NOT NULL
group by 1
order by 2 ;







