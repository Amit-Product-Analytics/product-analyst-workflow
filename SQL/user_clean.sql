select * from users;
create table users_clean as 
select * from users;
select * from users_clean;



with duplicate_row as
(
select * ,
row_number() over (partition by signup_date,country,city,age,gender,acquisition_channel,device_type,plan_type order by user_id) as Ranks
from users_clean
)
select * 
from duplicate_row
where Ranks > 1;

CREATE TABLE users_new AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY signup_date,
                            country,
                            city,
                            age,
                            gender,
                            acquisition_channel,
                            device_type,
                            plan_type
               ORDER BY user_id
           ) AS rn
    FROM users_clean
) t
WHERE rn = 1;
select *  from users_new;

ALTER TABLE users_new
DROP COLUMN rn;

RENAME TABLE users_new TO users_clean;
select *  from users_clean;

-- Fix Date 
select signup_date from users_clean;
update users_clean
set signup_date = Null
Where trim(signup_date) = '';

UPDATE users_clean
SET signup_date =
CASE

    -- Already in YYYY-MM-DD
    WHEN signup_date LIKE '____-__-__'
    THEN STR_TO_DATE(signup_date,'%Y-%m-%d')

    -- DD/MM/YYYY
    WHEN signup_date LIKE '__/__/____'
    THEN STR_TO_DATE(signup_date,'%d/%m/%Y')

END;


select  country from users_clean;

update users_clean
set country = 
case 
when lower(trim(country)) = 'india' then 'India'
when lower(trim(country)) = 'germany' then 'Germany'
when lower(trim(country)) = 'canada' then 'Canada'
when lower(trim(country)) = 'usa' then 'USA'
when lower(trim(country)) = 'australia' then 'Australia'
when lower(trim(country)) = 'uk' then 'UK'
when lower(trim(country)) = 'uae' then 'UAE'
else country end;

select  distinct city from users_clean;
update users_clean
set city = 'Unknown'
where city ='';
update users_clean
set city = trim(city);
UPDATE users_clean
SET city = CASE
    WHEN LOWER(TRIM(city)) = 'kolkata' THEN 'Kolkata'
    WHEN LOWER(TRIM(city)) = 'pune' THEN 'Pune'
    WHEN LOWER(TRIM(city)) = 'hyderabad' THEN 'Hyderabad'
    WHEN LOWER(TRIM(city)) = 'ahmedabad' THEN 'Ahmedabad'
    WHEN LOWER(TRIM(city)) = 'delhi' THEN 'Delhi'
    WHEN LOWER(TRIM(city)) = 'indore' THEN 'Indore'
    WHEN LOWER(TRIM(city)) = 'mumbai' THEN 'Mumbai'
    WHEN LOWER(TRIM(city)) = 'chennai' THEN 'Chennai'
    WHEN LOWER(TRIM(city)) = 'bangalore' THEN 'Bangalore'
    WHEN LOWER(TRIM(city)) = 'jaipur' THEN 'Jaipur'
    WHEN LOWER(TRIM(city)) = 'unknown' THEN 'Unknown'
    ELSE city
END;

-- Fix Age 
select   age from users_clean 
order by 1;

update users_clean
set age = abs(age);


update users_clean
set age = Null
where age < 18 or  age > 100;

select avg(age) from users_clean;
update users_clean
set age = 30
where age is null;

-- Fix Gender
select    distinct gender from users_clean ;
update users_clean
set gender = 
case 
when lower(trim(gender)) = 'f' then 'Female'
when lower(trim(gender)) = 'm' then 'Male'
when lower(trim(gender)) = 'male' then 'Male'
when lower(trim(gender)) = 'female' then 'Female'
when lower(trim(gender)) = 'other' then 'Others'

else gender end;
UPDATE users_clean
SET gender = CASE
    WHEN gender IN ('Male', 'Female', 'Others') THEN gender
    ELSE NULL
END;
update users_clean
set gender = 'Unknown'
where gender is null;

-- fix acquisition_channel
select  distinct acquisition_channel from users_clean ;
UPDATE users_clean
SET acquisition_channel = CASE
    WHEN LOWER(TRIM(acquisition_channel)) = 'organic search' THEN 'Organic Search'
    WHEN LOWER(TRIM(acquisition_channel)) = 'email campaign' THEN 'Email Campaign'
    WHEN LOWER(TRIM(acquisition_channel)) = 'social media' THEN 'Social Media'
    WHEN LOWER(TRIM(acquisition_channel)) = 'referral' THEN 'Referral'
    WHEN LOWER(TRIM(acquisition_channel)) = 'direct' THEN 'Direct'
    WHEN LOWER(TRIM(acquisition_channel)) = 'paid ads' THEN 'Paid Ads'
    ELSE acquisition_channel
END;


-- fix device_type
select   device_type from users_clean ;

UPDATE users_clean
SET device_type = CASE
    WHEN LOWER(TRIM(device_type)) = 'mobile ' THEN 'Mobile'
    WHEN LOWER(TRIM(device_type)) = 'tablet' THEN 'Tablet'
    WHEN LOWER(TRIM(device_type)) = 'desktop ' THEN 'Desktop'
    
    ELSE device_type
END;

-- fix plan_type
select   plan_type from users_clean ;
UPDATE users_clean
SET plan_type = CASE
    WHEN LOWER(TRIM(plan_type)) = 'free ' THEN 'Free'
    WHEN LOWER(TRIM(plan_type)) = 'premium' THEN 'Premium'
    ELSE plan_type
END;

select * from users_clean
 ;
delete from users_clean
where user_id = 68;
update users_clean
set acquisition_channel = null
where acquisition_channel = '';

ALTER TABLE users_clean
MODIFY signup_date DATE;



UPDATE users_clean
SET acquisition_channel = 'Unknown'
WHERE acquisition_channel IS NULL
   OR TRIM(acquisition_channel) = '';


UPDATE users_clean
SET city = 'Unknown'
WHERE city IS NULL
   OR TRIM(city) = '';

UPDATE users_clean
SET gender = 'Unknown'
WHERE gender IS NULL
   OR TRIM(gender) = '';


SELECT *
FROM users_clean
WHERE user_id IS NULL
   OR signup_date IS NULL
   OR country IS NULL
   OR city IS NULL
   OR age IS NULL
   OR gender IS NULL
   OR acquisition_channel IS NULL
   OR device_type IS NULL
   OR plan_type IS NULL;
   USE Cleaning;
SHOW TABLES;


SELECT DATABASE();
SELECT USER(), CURRENT_USER();




