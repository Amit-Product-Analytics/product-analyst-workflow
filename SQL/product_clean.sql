select * from products ;
create table products_clean as select * from products;
select * from products_clean;
-- Change Duplicates
with duplicate_row as(

select *, 
row_number() over (partition by product_name,category,unit_price,launch_date order by product_id) as ranks
from products_clean

) 
select * from duplicate_row
where ranks > 1;


select * from products_clean ;

select  * from products_clean 
where product_id is null
or product_name is null
or category is null
or unit_price is null
 or launch_date  is null;
alter table products_clean
modify launch_date date;


UPDATE products_clean
SET category = 'Electronics'
WHERE LOWER(category) = 'electronics';

UPDATE products_clean
SET product_name = TRIM(product_name),
    category = TRIM(category);


SELECT product_id, COUNT(*)
FROM products_clean
GROUP BY product_id
HAVING COUNT(*) > 1;


SELECT *
FROM products_clean
WHERE launch_date > CURDATE();





