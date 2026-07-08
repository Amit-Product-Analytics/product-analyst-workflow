select * from subscriptions;


create table subscriptions_clean as select * from subscriptions;
select * from subscriptions_clean;
-- Change Duplicates
with duplicate_row as(

select *, 
row_number() over (partition by user_id ,plan_type,start_date,end_date,status,monthly_fee order by subscription_id) as ranks
from subscriptions_clean

) 
select * from duplicate_row
where ranks > 1;

-- Fix monthly_fee
select monthly_fee
from subscriptions_clean
order by 1;
update subscriptions_clean
set monthly_fee = abs(monthly_fee);

-- Fix status
select  distinct status
from subscriptions_clean ;

update subscriptions_clean
set status =
case 
when lower(trim(status)) = 'cancelled' then 'Cancelled'
when lower(trim(status)) = 'active' then 'Active'
else status end ;

-- Fix start_date 
select  distinct start_date
from subscriptions_clean ;

SELECT *
FROM subscriptions_clean
WHERE start_date IS NULL
   OR TRIM(start_date) = '';
   
   UPDATE subscriptions_clean
SET start_date = STR_TO_DATE(start_date,'%Y-%m-%d')
WHERE start_date IS NOT NULL;

ALTER TABLE subscriptions_clean
MODIFY start_date DATE;

select   plan_type 
from subscriptions_clean
order by 1 ;

UPDATE subscriptions_clean
SET end_date = 'Ongoing'
WHERE TRIM(end_date) = '';
select  *
from subscriptions_clean
 ; 

select * 
from subscriptions_clean
where subscription_id is null
or user_id is null
or  plan_type is null
or start_date is null
or status is null
or monthly_fee is null;

select * 
from subscriptions_clean;

ALTER TABLE subscriptions_clean
 drop COLUMN end_date_new ;
 
SELECT *
FROM subscriptions_clean
WHERE (plan_type = 'Monthly' AND monthly_fee <> 199)
   OR (plan_type = 'Annual' AND monthly_fee <> 1999);
 
 
 
 
 
 
 
 
 
 
 
 
 
 