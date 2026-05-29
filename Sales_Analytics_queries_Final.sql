use sales_analytics;
select * from raw_sales_data; 

LOAD DATA LOCAL INFILE 'E:/Projects/Sales Analysis/Sales_data.csv'
INTO TABLE raw_sales_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

describe raw_sales_data;
select count(*) from raw_sales_data;
Select * from raw_sales_data limit 10;

select * from raw_sales_data 
where sales not regexp '^-?[0-9]+(\\.[0-9]+)?$'
or  quantity NOT REGEXP '^[0-9]+$'
or profit NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
or discount not regexp '^-?[0-9]+(\\.[0-9]+)?$'; 

SELECT COUNT(*) AS null_sales FROM raw_sales_data WHERE sales IS NULL;
SELECT COUNT(*) AS null_profit FROM raw_sales_data WHERE profit IS NULL;
SELECT COUNT(*) AS null_quantity FROM raw_sales_data WHERE quantity IS NULL;

SELECT COUNT(*) AS negative_qty FROM raw_sales_data WHERE quantity < 0;

SELECT MIN(order_date), MAX(order_date) FROM raw_sales_data;

Create table Sales_data (
Row_id int,			
Order_id varchar(50),	
Order_date date,		
Ship_date date,		
Ship_mode varchar(50),			
Customer_id	varchar(50),			
Customer_name varchar(100),			
Segment	varchar(50),			
Country	varchar(50),			
City varchar(50),			
State varchar(50),			
Postal_code	varchar(20),			
Region varchar(50),			
Product_id varchar(50),			
Category varchar(50),			
Sub_category varchar(50),			
Product_name varchar(255),			
Sales decimal(10,2),		
Quantity Int,		
Discount decimal(5,2),	
Profit	decimal(10,2)
);		

INSERT INTO sales_data (
    row_id, order_id, order_date, ship_date, ship_mode, customer_id,
    customer_name, segment, country, city, state, postal_code,
    region, product_id, category, sub_category, product_name,
    sales, quantity, discount, profit
)
SELECT 
    CAST(row_id AS SIGNED),
    TRIM(order_id),
    STR_TO_DATE(order_date, '%d-%m-%Y'),  
    STR_TO_DATE(ship_date, '%d-%m-%Y'),
    TRIM(ship_mode),
    TRIM(customer_id),
    TRIM(customer_name),
    TRIM(segment),
    TRIM(country),
    TRIM(city),
    TRIM(state),
    TRIM(postal_code),
    TRIM(region),
    TRIM(product_id),
    TRIM(category),
    TRIM(sub_category),
    TRIM(product_name),
    CAST(sales AS DECIMAL(10,2)),
    CAST(quantity AS SIGNED),
    CAST(discount AS DECIMAL(5,2)),
    CAST(profit AS DECIMAL(10,2))
FROM raw_sales_data
WHERE order_date IS NOT NULL
  AND ship_date IS NOT NULL
  AND sales REGEXP '^-?[0-9]+(\.[0-9]+)?$'
  AND quantity REGEXP '^[0-9]+$'
  AND discount REGEXP '^-?[0-9]+(\.[0-9]+)?$'
  AND profit REGEXP '^-?[0-9]+(\.[0-9]+)?$';
  
 Select count(*) as Incorrect_date from sales_data where order_date > ship_date or sales <0; 
 
 select * from sales_data where discount > 1 or discount <0;
 
SELECT 
    Order_ID, Product_ID, Order_Date, Ship_Date, Customer_ID, Sales, Quantity, Discount, Profit,
    COUNT(*) AS duplicate_count
FROM sales_data
GROUP BY
    Order_ID, Product_ID, Order_Date, Ship_Date, Customer_ID, Sales, Quantity, Discount, Profit
HAVING COUNT(*) > 1;

SELECT * FROM (
    SELECT *,
	  COUNT(*) OVER (
               PARTITION BY
                   Order_ID, Product_ID, Order_Date, Ship_Date, Customer_ID, Sales, Quantity, Discount,Profit
           ) AS dup_count
    FROM Sales_data
) t
WHERE dup_count > 1
ORDER BY
    Order_ID,
    Product_ID;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT Row_ID) AS unique_rows
FROM sales_data;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT Row_ID) AS unique_rows
FROM raw_sales_data;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM sales_data
WHERE Row_ID IN (
    SELECT Row_ID FROM (
        SELECT Row_ID,
               ROW_NUMBER() OVER (
                   PARTITION BY Order_ID, Product_ID, Order_Date, Ship_Date, Customer_ID, Sales, Quantity, Discount,Profit
							ORDER BY Row_ID
                                 ) AS rn
                    FROM sales_data
                  ) t
       WHERE rn > 1
);

  SET SQL_SAFE_UPDATES = 1;
  
-- Drop if exists
DROP TABLE IF EXISTS product_dim;

-- Create product_dim
CREATE TABLE Product_dim (
    Product_key INT AUTO_INCREMENT PRIMARY KEY,
    Product_id VARCHAR(50) NOT NULL,
    Category VARCHAR(50),
    Sub_category VARCHAR(50)
);

-- Insert cleaned product dimension (one row per product_id)
INSERT INTO product_dim (product_id, category, sub_category)
SELECT product_id, category, sub_category
FROM sales_data
GROUP BY product_id, category, sub_category;

-- Check
SELECT product_id, COUNT(*) AS cnt
FROM product_dim
GROUP BY product_id
HAVING cnt > 1;   -- should return 0

CREATE TABLE customer_dim (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

INSERT INTO customer_dim (customer_id, customer_name, segment)
SELECT customer_id, customer_name, segment
FROM sales_data
GROUP BY customer_id, customer_name, segment;

-- Check duplicates
SELECT customer_id, COUNT(*) AS cnt
FROM customer_dim
GROUP BY customer_id
HAVING cnt > 1;  -- should return 0

CREATE TABLE date_dim (
    date_key DATE PRIMARY KEY,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    weekday INT
);

-- Insert all distinct order & ship dates
INSERT INTO date_dim (date_key, day, month, month_name, quarter, year, weekday)
SELECT DISTINCT 
	d.date_key, 
    DAY(d.date_key), 
    MONTH(d.date_key), 
    MONTHNAME(d.date_key),
	QUARTER(d.date_key), 
    YEAR(d.date_key), 
    WEEKDAY(d.date_key)+1
FROM (
    SELECT order_date AS date_key FROM sales_data
    UNION
    SELECT ship_date AS date_key FROM sales_data
) d;

-- Check
SELECT COUNT(*) AS total_dates FROM date_dim;

DROP TABLE IF EXISTS region_dim;

CREATE TABLE region_dim (
    region_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    region VARCHAR(50)
);

INSERT INTO region_dim (country, state, city, region)
SELECT DISTINCT TRIM(country), TRIM(state), TRIM(city), TRIM(region)
FROM sales_data;

-- Check duplicates
SELECT country, state, city, region, COUNT(*) AS cnt
FROM region_dim
GROUP BY country, state, city, region
HAVING cnt > 1;  -- should return 0

CREATE TABLE sales_fact (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    product_key INT,
    customer_key INT,
    region_key INT,
    order_date_key DATE,
    ship_date_key DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),
    -- Derived metrics
    shipping_days INT,
    sales_per_unit DECIMAL(10,2),
    FOREIGN KEY (product_key) REFERENCES product_dim(product_key),
    FOREIGN KEY (customer_key) REFERENCES customer_dim(customer_key),
    FOREIGN KEY (region_key) REFERENCES region_dim(region_key),
    FOREIGN KEY (order_date_key) REFERENCES date_dim(date_key),
    FOREIGN KEY (ship_date_key) REFERENCES date_dim(date_key)
);

Alter table sales_fact add column Ship_mode_key int;

UPDATE sales_fact f
JOIN sales_data s
    ON f.Order_ID = s.Order_ID
JOIN ship_mode_dim d
    ON s.Ship_Mode = d.Ship_Mode
SET f.Ship_Mode_Key = d.Ship_Mode_Key;

ALTER TABLE sales_fact
ADD CONSTRAINT fk_ship_mode
FOREIGN KEY (Ship_Mode_Key)
REFERENCES ship_mode_dim(Ship_Mode_Key);

SELECT COUNT(*)
FROM sales_fact
WHERE Ship_Mode_Key IS NULL;

SELECT
    Ship_Mode_Key,
    COUNT(*)
FROM sales_fact
GROUP BY Ship_Mode_Key;

UPDATE sales_fact f
JOIN sales_data s
    ON f.Order_ID = s.Order_ID
JOIN ship_mode_dim d
    ON TRIM(s.Ship_Mode) = TRIM(d.Ship_Mode)
SET f.Ship_Mode_Key = d.Ship_Mode_Key;

SELECT
    Ship_Mode_Key, 
    COUNT(*)
FROM sales_fact
GROUP BY Ship_Mode_Key;

CREATE INDEX idx_ship_mode_key
ON sales_fact(Ship_Mode_Key);

describe sales_fact;
describe ship_mode_dim;

CREATE TABLE ship_mode_dim (
    Ship_Mode_Key INT AUTO_INCREMENT PRIMARY KEY,
    Ship_Mode VARCHAR(50)
);

Insert into ship_mode_dim (Ship_mode)
select distinct Ship_mode from sales_data;

select * from ship_mode_dim;


-- Insert into fact table
INSERT INTO sales_fact (
    order_id, product_key, customer_key, region_key, order_date_key, ship_date_key,
    sales, quantity, discount, profit, shipping_days, sales_per_unit
)
SELECT
    s.order_id,
    p.product_key,
    c.customer_key,
    r.region_key,
    s.order_date,
    s.ship_date,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    DATEDIFF(s.ship_date, s.order_date) AS shipping_days,
    round(s.sales / NULLIF(s.quantity,0),2) AS sales_per_unit
FROM sales_data s
JOIN product_dim p ON s.product_id = p.product_id
JOIN customer_dim c ON s.customer_id = c.customer_id
JOIN region_dim r
    ON s.country = r.country
   AND s.state   = r.state
   AND s.city    = r.city
   AND s.region  = r.region;

-- Check
SELECT COUNT(*) AS fact_rows FROM sales_fact; 
SELECT * FROM sales_fact limit 10; 



Create Index Idx_product_key on sales_fact(Product_key);
Create Index Idx_Customer_key on sales_fact(Customer_key);
Create Index Idx_Region_key on sales_fact(Region_key);
Create Index Idx_order_date_key on sales_fact(order_date_key);
Create Index Idx_ship_date_key on sales_fact(ship_date_key);


CREATE OR REPLACE VIEW sales_fact_view AS
SELECT f.*,
       p.category, p.sub_category,
       c.segment,
       r.region, r.country, r.state, r.city
FROM sales_fact f
JOIN product_dim p ON f.product_key = p.product_key
JOIN customer_dim c ON f.customer_key = c.customer_key
JOIN region_dim r ON f.region_key = r.region_key;

-- Total rows in fact table
SELECT COUNT(*) AS total_rows FROM sales_fact;

-- Check for nulls in critical columns
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customer,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales
FROM sales_fact;

-- Check derived metrics
SELECT MIN(shipping_days) AS min_shipping_days, MAX(shipping_days) AS max_shipping_days,
       MIN(sales_per_unit) AS min_sales_per_unit, MAX(sales_per_unit) AS max_sales_per_unit
FROM sales_fact;

-- Example: Product keys
SELECT DISTINCT product_key 
FROM sales_fact
WHERE product_key NOT IN (SELECT product_key FROM product_dim);

-- Shipping days should not be negative
SELECT * FROM sales_fact WHERE shipping_days < 0;

-- Sales per unit should not be zero or null
SELECT * FROM sales_fact WHERE sales_per_unit <= 0 OR sales_per_unit IS NULL;

select min(order_date_key) from sales_fact;

Create table sales_fact_backup as select * from sales_fact;
Create table sales_data_backup as select * from sales_data;

Update sales_data 
set 
	Order_date = date_add(Order_date, interval 11 year), 
	Ship_date = date_add(Ship_date, interval 11 year);
    
    Truncate table sales_fact;
    Truncate table date_dim;
    SET FOREIGN_KEY_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 1;

select * from sales_fact limit 10;
