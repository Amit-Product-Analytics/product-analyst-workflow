select * from orders ;
create table orders_clean as select * from orders;
select * from orders_clean;
-- Change Duplicates
with duplicate_row as(

select *, 
row_number() over (partition by user_id,order_date,product_id,quantity,unit_price,discount_pct,total_amount,payment_method,order_status  order by order_id) as ranks
from orders_clean

) 
select * from duplicate_row
where ranks > 1;
create table orders_clean_new as select * from (select *, 
row_number() over (partition by user_id,order_date,product_id,quantity,unit_price,discount_pct,total_amount,payment_method,order_status  order by order_id) as ranks
from orders_clean) as rn
where ranks = 1;



select * from orders_clean_new ;
alter table orders_clean_new
drop column ranks;
rename table orders_clean_new to orders_clean;
select user_id from orders_clean
where user_id is null ;

-- Fix order_date
select order_date from orders_clean;

select order_date from orders_clean
where order_date is null ;

UPDATE orders_clean
SET order_date = STR_TO_DATE(order_date,'%Y-%m-%d')
WHERE order_date IS NOT NULL;

ALTER TABLE orders_clean
MODIFY order_date DATE;


-- Fix quantity
select quantity from orders_clean
order by 1 ;

UPDATE orders_clean
SET quantity = abs(quantity);

UPDATE orders_clean
SET quantity = null
where quantity = 0;

UPDATE orders_clean
SET quantity = 3
where quantity is null;

select discount_pct from orders_clean
order by 1 ;


select * from orders_clean ;

-- Fix  total_amount
SELECT *
FROM orders_clean
WHERE ROUND(quantity * unit_price * (1 - discount_pct),2) <> total_amount;

UPDATE orders_clean
SET total_amount = ROUND(quantity * unit_price * (1 - discount_pct),2);

select payment_method from orders_clean ;


-- Fix  payment_method
UPDATE orders_clean
SET payment_method = CASE
    WHEN LOWER(TRIM(payment_method)) = 'credit card' THEN 'Credit Card'
    WHEN LOWER(TRIM(payment_method)) = 'debit card' THEN 'Debit Card'
    WHEN LOWER(TRIM(payment_method)) = 'upi' THEN 'UPI'
    WHEN LOWER(TRIM(payment_method)) = 'net banking' THEN 'Net Banking'
    WHEN LOWER(TRIM(payment_method)) = 'wallet' THEN 'Wallet'
    ELSE payment_method
END;

SELECT DISTINCT order_status
FROM orders_clean;

-- Fix order_status
UPDATE orders_clean
SET order_status = CASE
    WHEN LOWER(TRIM(order_status)) = 'completed' THEN 'Completed'
    WHEN LOWER(TRIM(order_status)) = 'cancelled' THEN 'Cancelled'
    WHEN LOWER(TRIM(order_status)) = 'refunded' THEN 'Refunded'
    ELSE NULL
END;
select * from orders_clean
where order_status is null ;


SELECT *
FROM orders_clean
WHERE order_id IS NULL
   OR user_id IS NULL
   OR order_date IS NULL
   OR product_id IS NULL
   OR quantity IS NULL
   OR unit_price IS NULL
   OR discount_pct IS NULL
   OR total_amount IS NULL
   OR payment_method IS NULL
   OR order_status IS NULL
   OR TRIM(order_status) = '';
   
   UPDATE orders_clean
SET order_status = 'Pending'
WHERE order_status IS NULL
   OR TRIM(order_status) = '';

