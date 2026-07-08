/*
===========================================================
Project: E-Commerce Product Analytics
File: Data Cleaning.sql
Author: Amit Kumar
Description:
This script cleans the raw Events dataset by:
1. Removing duplicate records
2. Standardizing text values
3. Separating date and time
4. Cleaning Product IDs
5. Performing data quality validation
===========================================================
*/

-- =========================================================
-- STEP 1 : Create Working Copy
-- =========================================================

SELECT *
FROM events;

CREATE TABLE events_clean AS
SELECT *
FROM events;

SELECT *
FROM events_clean;


-- =========================================================
-- STEP 2 : Remove Duplicate Records
-- =========================================================

WITH duplicate_rows AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY
                   user_id,
                   session_id,
                   event_name,
                   event_timestamp,
                   product_id,
                   platform
               ORDER BY event_id
           ) AS ranks
    FROM events_clean
)

SELECT *
FROM duplicate_rows
WHERE ranks > 1;


CREATE TABLE events_clean_new AS

SELECT *
FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY
                   user_id,
                   session_id,
                   event_name,
                   event_timestamp,
                   product_id,
                   platform
               ORDER BY event_id
           ) AS ranks
    FROM events_clean
) AS cleaned

WHERE ranks = 1;

DROP TABLE events_clean;

RENAME TABLE events_clean_new TO events_clean;


-- =========================================================
-- STEP 3 : Standardize Event Names
-- =========================================================

SELECT DISTINCT event_name
FROM events_clean;

UPDATE events_clean
SET event_name =
CASE
    WHEN LOWER(TRIM(event_name)) = 'homepage_view'
        THEN 'Homepage_View'

    WHEN LOWER(TRIM(event_name)) = 'product_view'
        THEN 'Product_View'

    WHEN LOWER(TRIM(event_name)) = 'add_to_cart'
        THEN 'Add_To_Cart'

    WHEN LOWER(TRIM(event_name)) = 'checkout_start'
        THEN 'Checkout_Start'

    WHEN LOWER(TRIM(event_name)) = 'purchase_complete'
        THEN 'Purchase_Complete'

    ELSE event_name
END;


-- =========================================================
-- STEP 4 : Standardize Platform Names
-- =========================================================

SELECT DISTINCT platform
FROM events_clean;

UPDATE events_clean
SET platform =
CASE
    WHEN LOWER(TRIM(platform)) = 'ios app'
        THEN 'iOS App'

    WHEN LOWER(TRIM(platform)) = 'android app'
        THEN 'Android App'

    WHEN LOWER(TRIM(platform)) = 'web'
        THEN 'Web'

    ELSE platform
END;


-- =========================================================
-- STEP 5 : Create Date and Time Columns
-- =========================================================

ALTER TABLE events_clean
ADD COLUMN event_date DATE,
ADD COLUMN event_time TIME;


UPDATE events_clean
SET

event_date =
CASE

    WHEN event_timestamp LIKE '____-__-__%'
        THEN DATE
        (
            STR_TO_DATE
            (
                event_timestamp,
                '%Y-%m-%d %H:%i:%s'
            )
        )

    WHEN event_timestamp LIKE '__-__-____%'
        THEN DATE
        (
            STR_TO_DATE
            (
                event_timestamp,
                '%d-%m-%Y %H:%i'
            )
        )

END,

event_time =
CASE

    WHEN event_timestamp LIKE '____-__-__%'
        THEN TIME
        (
            STR_TO_DATE
            (
                event_timestamp,
                '%Y-%m-%d %H:%i:%s'
            )
        )

    WHEN event_timestamp LIKE '__-__-____%'
        THEN TIME
        (
            STR_TO_DATE
            (
                event_timestamp,
                '%d-%m-%Y %H:%i'
            )
        )

END;


ALTER TABLE events_clean
DROP COLUMN event_timestamp;


-- =========================================================
-- STEP 6 : Clean Product ID
-- =========================================================

UPDATE events_clean
SET product_id = REPLACE(product_id,'.0','');

UPDATE events_clean
SET product_id = NULL
WHERE product_id = '';


-- =========================================================
-- STEP 7 : Remove Temporary Column
-- =========================================================

ALTER TABLE events_clean
DROP COLUMN ranks;


-- =========================================================
-- STEP 8 : Data Quality Checks
-- =========================================================

-- Duplicate Event IDs

SELECT
    event_id,
    COUNT(*) AS duplicate_count
FROM events_clean
GROUP BY event_id
HAVING COUNT(*) > 1;


-- Check Missing Mandatory Fields

SELECT *
FROM events_clean
WHERE
      event_id IS NULL
   OR user_id IS NULL
   OR session_id IS NULL
   OR event_name IS NULL
   OR platform IS NULL
   OR event_date IS NULL
   OR event_time IS NULL;


-- Product Events Without Product ID

SELECT *
FROM events_clean
WHERE event_name IN
(
'Product_View',
'Add_To_Cart',
'Checkout_Start',
'Purchase_Complete'
)
AND product_id IS NULL;


-- =========================================================
-- STEP 9 : Final Validation
-- =========================================================

-- Total Unique Users

SELECT COUNT(DISTINCT user_id) AS total_users
FROM events_clean;

-- Dataset Preview

SELECT *
FROM events_clean
LIMIT 10;