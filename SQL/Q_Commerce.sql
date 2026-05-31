Create Database quick_commerce;
use quick_commerce;
CREATE TABLE orders (
    Order_ID VARCHAR(50),
    Company VARCHAR(100),
    City VARCHAR(100),
    Customer_Age INT NULL,
    Order_Value DECIMAL(10,2) NULL,
    Delivery_Time_Min INT NULL,
    Distance_KM DECIMAL(10,2) NULL,
    Items_Count INT NULL,
    Product_Category VARCHAR(100),
    Payment_Method VARCHAR(50),
    Customer_Rating DECIMAL(2,1) NULL,
    Discount_Applied TINYINT NULL,
    Delivery_Partner_Rating DECIMAL(2,1) NULL
);

##Importing Data
-- 1. Force the server to turn on file loading
SET GLOBAL local_infile = 1;

-- 2. Load the file using clean forward slashes (/)
LOAD DATA LOCAL INFILE "C:/Users/SAHITHI VITTAL/Documents/Projects/Q_Commerce_Project/quick_commerce_data_raw.csv"  
INTO TABLE orders  
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

-- ============================
-- Data Cleaning
-- ============================
select count(*) as total_orders from  orders;
-- Total Orders : '1000000'
select * from orders;

SELECT
    SUM(CASE WHEN TRIM(Order_ID) = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN TRIM(Company) = '' THEN 1 ELSE 0 END) AS missing_company,
    SUM(CASE WHEN TRIM(City) = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN TRIM(Customer_Age) = '' THEN 1 ELSE 0 END) AS missing_customer_age,
    SUM(CASE WHEN TRIM(Order_Value) = '' THEN 1 ELSE 0 END) AS missing_order_value,
    SUM(CASE WHEN TRIM(Delivery_Time_Min) = '' THEN 1 ELSE 0 END) AS missing_delivery_time,
    SUM(CASE WHEN TRIM(Distance_KM) = '' THEN 1 ELSE 0 END) AS missing_distance_km,
    SUM(CASE WHEN TRIM(Items_Count) = '' THEN 1 ELSE 0 END) AS missing_items_count,
    SUM(CASE WHEN TRIM(Product_Category) = '' THEN 1 ELSE 0 END) AS missing_product_category,
    SUM(CASE WHEN TRIM(Payment_Method) = '' THEN 1 ELSE 0 END) AS missing_payment_method,
    SUM(CASE WHEN TRIM(Customer_Rating) = '' THEN 1 ELSE 0 END) AS missing_customer_rating,
    SUM(CASE WHEN TRIM(Discount_Applied) = '' THEN 1 ELSE 0 END) AS missing_discount_applied,
    SUM(CASE WHEN TRIM(Delivery_Partner_Rating) = '' THEN 1 ELSE 0 END) AS missing_delivery_partner_rating
FROM orders;
-- Checked whether empty values present or not then noticesd that city column has 52000 empty values

select round((count(*) * 100 )/(select count(*) from orders),2) as missing_city_percentage 
from orders where trim(city)="";
-- we have 5.2% of missing city data so we convert it to null
update orders set city = null where trim(city) = '';

-- TRIM TEXT DATA : To ignore extra spaces
UPDATE orders SET company= trim(company),
	city = trim(city),
    product_category = trim(product_category),
    payment_method = trim(payment_method);

Describe orders; #It gives information about data type,null present or not and about key
-- All datatypes are assigned correctly , data exsts null values, there is no primary key 
-- so first we check is there any duplicate orderif if no duplicates exist we convert it to primary key
select order_id,count(*) from orders group by order_id having count(*) > 1;
-- No duplicate order_id is there .So now will convert order_id to primary key

alter table orders add primary key(order_id);

SELECT  #checking null count
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN Company IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Customer_Age IS NULL THEN 1 ELSE 0 END) AS null_customer_age,
    SUM(CASE WHEN Order_Value IS NULL THEN 1 ELSE 0 END) AS null_order_value,
    SUM(CASE WHEN Delivery_Time_Min IS NULL THEN 1 ELSE 0 END) AS null_delivery_time,
    SUM(CASE WHEN Distance_KM IS NULL THEN 1 ELSE 0 END) AS null_distance_km,
    SUM(CASE WHEN Items_Count IS NULL THEN 1 ELSE 0 END) AS null_items_count,
    SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS null_product_category,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS null_payment_method,
    SUM(CASE WHEN Customer_Rating IS NULL THEN 1 ELSE 0 END) AS null_customer_rating,
    SUM(CASE WHEN Discount_Applied IS NULL THEN 1 ELSE 0 END) AS null_discount_applied,
    SUM(CASE WHEN Delivery_Partner_Rating IS NULL THEN 1 ELSE 0 END) AS null_delivery_partner_rating
FROM orders;
-- identified that only the City column contained missing values (5.2% of records), which were retained as NULL to preserve transactional integrity while maintaining analytical transparency

SELECT  Company,COUNT(*) AS missing_city_orders FROM orders 
WHERE City IS NULL GROUP BY Company ORDER BY missing_city_orders DESC;
-- “Further investigation revealed that missing city values were uniformly distributed across all platforms, 
-- indicating a dataset-wide logging or generation issue rather than a company-specific operational problem.”

 SELECT CASE 
        WHEN City IS NULL THEN 'Missing City'
        ELSE 'Available City'
    END AS city_status,COUNT(*) AS total_orders,
    ROUND(AVG(Order_Value),2) AS avg_order_value,
    ROUND(SUM(Order_Value),2) AS total_revenue FROM orders GROUP BY city_status;
-- The missing city records behave very similarly to normal records.
--  Missing city values are likely random/system-generated missingness rather than business-biased missingness.

## Standardization Checks
select distinct company from orders order by company;
 -- 'Amazon Now','Big Basket','Blinkit','Dunzo','Flipkart Minutes','Jio Mart','Swiggy Instamart','Zepto'
select distinct city from orders order by city;
-- 'Amritsar','Bengluru','Chennai','Delhi','Gurgaon','Haridwar','Hyderabad','Jaipur','Kolkata','Mumbai','Noida','Pune'
select distinct Product_Category from orders order by Product_Category;
-- 'Beverages','Dairy','Fruits & Vegetables','Groceries','Household','Personal Care','Snacks'
select distinct Payment_Method from orders order by Payment_Method;
-- 'Cash on Delivery','Credit Card','Debit Card','UPI','Wallet'
select distinct discount_applied from orders ; -- 0-"NO", 1-"Yes"

-- Now checking min and max range 
SELECT 'customer_age' as metric,min(customer_age) as min_value ,max(customer_age) as max_value FROM orders
union all
SELECT 'Order_Value',min(Order_Value),max(Order_Value) FROM orders
union all
SELECT 'Delivery_Time_Min',min(Delivery_Time_Min),max(Delivery_Time_Min) FROM orders
union all
SELECT 'Distance_KM',min(Distance_KM),max(Distance_KM) FROM orders
union all
SELECT 'items_Count',min(items_Count),max(items_Count) FROM orders
union all
SELECT 'Customer_Rating',min(Customer_Rating),max(Customer_Rating) FROM orders
union all
SELECT 'Delivery_Partner_Rating',min(Delivery_Partner_Rating),max(Delivery_Partner_Rating) FROM orders;
-- Validating numeric ranges to identify anomalies and business inconsistencies

select count(*) from orders where items_count = 0; #35000 rows
select count(*) from orders where customer_rating = 0; #47000 rows
select count(*) from orders where delivery_partner_rating = 0; # 104137 rows
select count(*) from orders where customer_rating = 0 and delivery_partner_rating = 0; # 4961 rows

select count(*) as inconsistent_orders from orders
where items_count=0 and order_value>0; #35000

alter table orders add column anomaly_flag varchar(50);
update orders set anomaly_flag = 'Zero_Items_With_Revenue' where items_count=0 and order_value>0;
 -- I identified 35,000 transactions where order value existed despite zero item counts. Instead of deleting them directly, 
 -- I flagged them as potential anomalies to preserve data lineage and maintain analytical transparency.
 
 SELECT ROUND((COUNT(*) * 100.0) /(SELECT COUNT(*) FROM orders),2) AS anomaly_percentage
FROM orders WHERE anomaly_flag = 'Zero_Items_With_Revenue';
-- Identified that 3.5% of transactions contained revenue despite zero item counts, indicating potential transactional anomalies.
 select * from orders;
 
 -- Delivery Time vs Distance
 SELECT * FROM orders WHERE Delivery_Time_Min < 5 AND Distance_KM > 10; ## no rows returned
 
 -- ===========================
-- PERFORMANCE OPTIMIZATION : Create indexes to improve query performance on frequently used columns
-- ===========================
CREATE INDEX idx_city ON orders(city);

CREATE INDEX idx_company ON order_details(company);

CREATE INDEX idx_product_category ON orders(product_category);

CREATE INDEX idx_payment_method ON orders(payment_method);

 -- =========================================================================================================
-- KPI SUMMARY : KPI = Key Performance Indicator , a metric that measures how well a business is performing.
-- ===========================================================================================================
select 
count(*) as total_orders,
round(sum(Order_Value),2) as total_revenue,
round(avg(Order_Value),2) as avg_order_value,
round(avg(Delivery_Time_Min),2) as avg_delivery_time ,
round(avg
       (case when Customer_Rating>0 then Customer_Rating end),2) as avg_customer_rating,
round(avg
       (case when Delivery_Partner_Rating>0 then Delivery_Partner_Rating end),2) as avg_delivery_partner_rating 
 from orders;             

## KPI Analysis:
-- The dataset contains 1 million total orders, indicating large-scale operational activity.
-- Total revenue exceeded 571 million, showing strong transaction volume across quick commerce platforms.
-- The average order value (AOV) is 571.64, suggesting customers are placing medium-to-high value orders.
-- The average delivery time is 16.46 minutes, reflecting efficient quick-commerce delivery operations.
-- Average customer rating is 3.04/5, indicating moderate customer satisfaction levels.
-- Average delivery partner rating is 3.75/5, which is higher than customer ratings.
-- Delivery operations appear to perform better than the overall customer experience.
-- The gap between customer ratings and delivery partner ratings may indicate issues related to:
-- product quality,
-- pricing,
-- stock availability,
-- packaging,
-- or app experience rather than delivery performance.
-- The business demonstrates strong scalability due to high order volume and relatively fast delivery times.
-- Unrated orders were excluded from average rating calculations to ensure accurate KPI representation.
-- These KPIs provide an executive-level overview of operational efficiency,
-- customer experience, and revenue performance.
 
-- ===========================
-- Business Analysis Phase:
-- ==========================
 # 1. Platform Performance Analysis
#- Q1. Which platform has highest total revenue?
select Company,sum(Order_Value) as total_revenue from orders 
group by company order by total_revenue desc;
-- Business Insights:
-- Swiggy Instamart generated the highest total revenue among all platforms.

-- Blinkit and Zepto also demonstrated strong revenue performance,
-- indicating high customer demand and strong operational scale.

-- Jio Mart generated the lowest revenue among the analyzed platforms,
-- suggesting relatively lower market penetration or customer activity.

-- Revenue distribution across platforms appears relatively competitive,
-- with no single company dominating the market completely.

-- The quick commerce market appears highly competitive,
-- with multiple platforms contributing significant revenue volumes.

-- Higher revenue may indicate:
-- stronger customer acquisition,
-- larger order volumes,
-- better delivery operations,
-- or wider market reach.

-- Revenue insights can help identify:
-- market leaders,
-- competitive positioning,
-- and potential growth opportunities across platforms.

#- Q2)Which platform has Highest Average Order Value (AOV)
select company,round(avg(Order_Value),0) as AOV from orders
group by company order by AOV desc;

-- Swiggy Instamart recorded the highest Average Order Value (AOV) at 646,
-- indicating customers tend to place higher-value orders on this platform.

-- Zepto and Blinkit also demonstrated strong AOV performance,
-- suggesting effective customer spending behavior and larger basket sizes.

-- Jio Mart recorded the lowest AOV at 483,
-- which may indicate smaller basket sizes or lower-priced product purchases.

-- Platforms with higher AOV generally generate more revenue per transaction,
-- improving operational profitability and delivery efficiency.

-- Higher AOV may result from:
-- premium product offerings,
-- larger basket sizes,
-- aggressive cross-selling,
-- or stronger customer purchasing power.

-- Lower AOV platforms may need strategies such as:
-- bundle offers,
-- product recommendations,
-- or upselling techniques to increase basket value.

-- AOV is an important business KPI because it directly impacts:
-- revenue growth,
-- profit margins,
-- and operational efficiency.

# 2. Customer Rating Analysis
#- Find customer ratings across each company
select company, round(avg(
                           case when Customer_Rating>0 then Customer_Rating end),2) as avg_customer_rating
from orders group by company order by avg_customer_rating desc;

-- Blinkit achieved the highest average customer rating (3.55),
-- indicating comparatively stronger customer satisfaction levels.

-- Swiggy Instamart and Zepto also maintained strong customer ratings,
-- reflecting relatively positive customer experiences.

-- Dunzo recorded the lowest customer rating (2.45),
-- suggesting potential challenges related to customer experience.

-- Lower customer ratings may be associated with:
-- product quality issues,
-- delayed deliveries,
-- stock availability problems,
-- pricing concerns,
-- packaging quality,
-- or app experience limitations.

-- Platforms with higher customer ratings are more likely to achieve:
-- stronger customer retention,
-- positive brand perception,
-- and higher repeat purchase behavior.

-- The variation in customer ratings across platforms highlights
-- differences in overall service quality and customer satisfaction.

-- Improving customer satisfaction can directly impact:
-- platform loyalty,
-- customer engagement,
-- and long-term revenue growth.

# 3. Delivery Efficiency Analysis
select company,round(avg(Delivery_Time_Min),2) as avg_delivery_time,
 round(avg(
           case when Delivery_Partner_Rating>0 then Delivery_Partner_Rating end),2) as avg_delivery_partner_rating
from orders group by company order by   avg_delivery_time desc;

-- ============================
-- Delivery Efficiency Analysis
-- ============================

-- Zepto achieved the fastest average delivery time at 9.57 minutes,
-- indicating highly efficient quick-commerce operations.

-- Dunzo and Blinkit also demonstrated relatively fast delivery performance,
-- suggesting strong operational efficiency and delivery optimization.

-- Jio Mart recorded the highest average delivery time at 22.97 minutes,
-- which may impact customer experience and delivery satisfaction.

-- Despite differences in delivery time across platforms,
-- delivery partner ratings remained consistently stable around 3.75.

-- This suggests that customers may evaluate delivery partners positively
-- even when delivery times vary between platforms.

-- Faster delivery times are generally associated with:
-- better operational efficiency,
-- optimized logistics,
-- stronger warehouse distribution,
-- and improved last-mile delivery performance.

-- Platforms with longer delivery times may need improvements in:
-- route optimization,
-- delivery partner allocation,
-- inventory placement,
-- or operational scalability.

-- Zepto appears to have a strong competitive advantage in delivery speed,
-- which is a critical factor in the quick-commerce industry.

-- Delivery efficiency plays an important role in:
-- customer satisfaction,
-- repeat purchases,
-- and platform competitiveness.

#4. Discount Impact Analysis
select Discount_Applied , count(*) as total_orders,
round(SUM(Order_Value),2) as total_revenue,
round(avg(Order_Value),2) as AOV
from orders group by discount_applied;

-- Orders with discounts generated significantly higher Average Order Value (AOV).

-- Discounted orders achieved an AOV of 713.19,
-- compared to 476.93 for non-discounted orders.

-- Although discounted orders accounted for fewer total orders,
-- total revenue generated by discounted and non-discounted orders remained nearly equal.

-- This suggests that discounts are encouraging customers
-- to place higher-value orders and increase basket sizes.

-- Discount strategies appear effective in driving customer spending behavior.

-- Non-discounted orders contributed higher order volume,
-- but lower average transaction value.

-- Discounts may be successfully supporting:
-- upselling,
-- bulk purchases,
-- and larger cart values.

-- The business may benefit from optimizing discount strategies
-- to balance profitability and customer acquisition.

-- Discount analysis is important for understanding:
-- customer purchase behavior,
-- revenue optimization,
-- and promotional effectiveness.

#5. City Performance Analysis
select city, count(*) as total_orders,
round(sum(Order_Value),2) as total_revenue from orders
where city is not null group by city order by total_revenue desc;

-- Gurgaon generated the highest total revenue among all cities,
-- indicating strong customer demand and purchasing activity.

-- Noida and Delhi also demonstrated strong revenue performance,
-- highlighting the importance of NCR-region markets in quick commerce operations.

-- Mumbai and Bengaluru maintained high order volumes and strong revenue contribution,
-- reflecting large urban customer bases and high quick-commerce adoption.

-- Haridwar and Jaipur recorded comparatively lower revenue,
-- suggesting smaller market size or lower customer spending behavior.

-- Order volume across cities appears relatively balanced,
-- indicating broad market penetration across multiple regions.

-- Revenue variation across cities may be influenced by:
-- customer purchasing power,
-- population density,
-- delivery network efficiency,
-- and platform adoption levels.

-- Cities with higher revenue and order volume may represent:
-- high-priority operational markets,
-- stronger customer retention,
-- and better expansion opportunities.

-- Lower-performing cities may require:
-- targeted marketing,
-- promotional campaigns,
-- or operational improvements to increase engagement.

-- City-level analysis helps businesses identify:
-- high-growth markets,
-- expansion opportunities,
-- and regional customer behavior patterns.

#6. Product Category Analysis
select Product_Category, count(*) as total_orders,
round(sum(Order_Value),2) as total_revenue from orders
group by Product_Category order by total_revenue desc;

-- Dairy generated the highest total revenue and order volume among all product categories.

-- Groceries and Household products also contributed significantly to overall revenue,
-- indicating strong demand for daily essential items.

-- Revenue and order distribution across categories appear highly balanced,
-- suggesting diversified customer purchasing behavior.

-- No single product category dominates the market completely,
-- which reduces dependency on a specific product segment.

-- Essential and frequently purchased categories such as:
-- Dairy,
-- Groceries,
-- Snacks,
-- and Household items
-- continue to drive consistent transaction activity.

-- Fruits & Vegetables generated comparatively lower revenue,
-- though performance remained close to other categories.

-- The balanced category distribution suggests that customers use quick-commerce platforms
-- for a wide variety of daily needs rather than a single purchase category.

-- Product category insights can help businesses optimize:
-- inventory planning,
-- warehouse stocking,
-- promotional campaigns,
-- and category-level marketing strategies.

-- Categories with consistently high demand may require:
-- stronger inventory availability,
-- faster replenishment,
-- and priority operational focus.

#7. Platform Ranking
select company,round(sum(Order_Value),2) as total_revenue,
rank() over( order by sum(Order_Value) desc) as revenue_ranking
from orders group by company;

-- Swiggy Instamart ranked as the top revenue-generating platform,
-- indicating the strongest overall market performance among all platforms.

-- Blinkit and Zepto secured the second and third positions respectively,
-- demonstrating strong competitive presence in the quick-commerce market.

-- Revenue rankings help identify:
-- market leaders,
-- competitive positioning,
-- and platform-level business performance.

-- The revenue gap between top-performing and lower-performing platforms
-- suggests differences in:
-- customer demand,
-- operational scale,
-- market penetration,
-- and customer engagement.

-- Jio Mart ranked lowest in total revenue,
-- indicating comparatively lower transaction volume or customer activity.

-- Revenue ranking analysis can help businesses:
-- benchmark competitors,
-- prioritize expansion strategies,
-- and identify performance improvement opportunities.

-- Window functions such as RANK() improve analytical capabilities
-- by enabling comparative business performance analysis.


#8. Customer segementation
select case
           when Customer_Age between 18 and 25 then '18-25'
           when Customer_Age between 26 and 35 then '26-35'
           when Customer_Age between 36 and 45 then '36-45'
           else '46+'
end as age_group,
count(*) as total_orders,
round(avg(Order_Value),2) as AOV
from orders group by age_group order by total_orders desc;
           
-- Customers aged 46+ contributed the highest total order volume,
-- indicating strong engagement from older customer segments.

-- The 26–35 and 36–45 age groups also generated significant order volumes,
-- showing balanced customer participation across working-age demographics.

-- The 18–25 age group recorded the lowest order volume,
-- though Average Order Value (AOV) remained competitive.

-- Average Order Value remained highly consistent across all age groups,
-- suggesting that customer spending behavior does not vary significantly by age.

-- The similarity in AOV across age groups indicates stable purchasing patterns
-- and relatively uniform customer basket sizes.

-- Older customer segments may represent:
-- loyal repeat customers,
-- higher convenience dependency,
-- or stronger adoption of quick-commerce services.

-- Younger customer groups may offer future growth opportunities
-- through targeted marketing and engagement strategies.

-- Age-group analysis helps businesses understand:
-- customer demographics,
-- purchasing behavior,
-- and customer segmentation patterns.


-- ============================
-- Final Project Summary
-- ============================

-- Swiggy Instamart emerged as the highest revenue-generating platform.

-- Zepto demonstrated the fastest delivery performance,
-- indicating strong operational efficiency.

-- Blinkit achieved the highest customer satisfaction ratings.

-- Discounted orders generated significantly higher Average Order Value (AOV),
-- suggesting discounts effectively increase customer spending.

-- Revenue contribution across product categories remained highly balanced,
-- indicating diversified customer purchasing behavior.

-- Missing city values were identified as system-generated missingness
-- with minimal impact on business metrics.

-- Approximately 3.5% of orders contained transactional anomalies
-- where revenue existed despite zero item counts.

-- Overall, the quick-commerce ecosystem demonstrated:
-- strong operational scalability,
-- efficient delivery performance,
-- and highly competitive platform dynamics.