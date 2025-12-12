/*
====================================================================================================
EDA Script: Exploratory Data Analysis for Business Decisions
====================================================================================================
Script Purpose:
    This script performs exploratory data analysis (EDA) on the Gold layer of the data warehouse to
understand the structure, scope, and quality of the data. The analysis provides insights into sales performance,
customer behavior, product profitability, and revenue distribution to support data-driven
business decisions and downstream reporting.
====================================================================================================
*/

USE DataWarehouse;

-- Check to see if column is a measure or dimension
SELECT DISTINCT
  category
FROM gold.dim_products;
-- output resulted in string values so -> dimension


SELECT DISTINCT
  sales_amount
FROM gold.fact_sales;
-- output resulted in numeric values that make sense to aggregate so -> a measure

SELECT DISTINCT
  product_name
FROM gold.dim_products;
-- output resulted in string values so -> dimension

SELECT DISTINCT
  quantity
FROM gold.fact_sales;
-- output resulted in numeric values that make sense to aggregate so -> a measure

SELECT DISTINCT
  birthdate
FROM gold.dim_customers;
-- output resulted in date values so -> dimension
-- BUT... if you calculate the AGE from the birthdate, then the result is numeric and it makes sense to aggregate
-- that would make it a measure
SELECT DISTINCT
  DATEDIFF(YEAR, birthdate, GETDATE()) AS Age
FROM gold.dim_customers;

-- a tricky situation: the customer_id
SELECT DISTINCT
  customer_id
-- SUM(customer_id)
FROM gold.dim_customers;
-- the values are numeric, but it doesn't make sense to aggregate them so -> dimension


-- Explore all objects in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- Explore all counties our customers come from.
SELECT DISTINCT country
FROM gold.dim_customers;

-- Explore all categories ("the major divisions")
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY 1,2,3;

-- DATE exploration
-- identify the earliest and latest dates (boundaries)
-- understand the scope of data and the timespan
/* find the date of the first and last order */
SELECT
  MIN(order_date) first_order,
  MAX(order_date) latest_order,
  DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) order_range_months
FROM gold.fact_sales;

-- find the yougest and oldest customer
SELECT
  MIN(DATEDIFF(year, birthdate, GETDATE())) as youngest_customer,
  MAX(DATEDIFF(year, birthdate, GETDATE())) as oldest_customer
FROM gold.dim_customers;


-- Find the Total Sales
SELECT SUM(sales_amount) total_sales
FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) total_items_sold
FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) average_selling_price
FROM gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(order_number) number_of_orders
FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) number_of_orders
FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_id) number_of_products
FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_id) number_of_customers
FROM gold.dim_customers;

-- Find the total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key) number_of_orders
FROM gold.fact_sales;

-- generate a report that shows all key metrics of the business
  SELECT 'Total Sales' AS measure_name, SUM(sales_amount) measure_value
  FROM gold.fact_sales
UNION ALL
  SELECT
    'Total Quantity' AS measure_name, SUM(quantity)
  FROM gold.fact_sales
UNION ALL
  SELECT 'Average Price' AS measure_name, AVG(price)
  FROM gold.fact_sales
UNION ALL
  SELECT 'Total No. Orders' AS measure_name, COUNT(DISTINCT order_number)
  FROM gold.fact_sales
UNION ALL
  SELECT 'Total No. Products' AS measure_name, COUNT(product_id)
  FROM gold.dim_products
UNION ALL
  SELECT 'Total No. Customers' AS measure_name, COUNT(customer_id)
  FROM gold.dim_customers;


-- Find the total customers by countries
SELECT country, COUNT(customer_id) total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY COUNT(customer_id) DESC;

-- Find total customers by gender
SELECT gender, COUNT(customer_id) total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY COUNT(customer_id) DESC;

-- Find total products by category
SELECT category, COUNT(product_id) total_products
FROM gold.dim_products
GROUP BY category
ORDER BY COUNT(product_id) DESC;

-- What is the average costs in each category?
SELECT category, AVG(p.cost) average_cost
FROM gold.dim_products p
GROUP BY category
ORDER BY AVG(p.cost) DESC;

-- What is the total revenue genderated for each category?
SELECT p.category, SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY SUM(f.sales_amount) DESC;

-- Find how much total revenue is generated by each customer
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
  LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
  c.customer_id, 
  c.first_name,
  c.last_name
ORDER BY SUM(f.sales_amount) DESC;

-- What is the distribution of sold items across countries?
SELECT c.country, SUM(quantity) total_items_sold
FROM gold.fact_sales f
  LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY country
ORDER BY SUM(quantity) DESC;

-- Which 5 products generate the highest revenue?
SELECT top 5
  p.product_name,
  SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2 DESC;

-- with Window Function: Which 5 products generate the highest revenue?
WITH
  product_ranking
  AS
  (
    SELECT
      p.product_name,
      SUM(f.sales_amount) total_revenue,
      ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS ranked_products
    FROM gold.fact_sales f
      LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.product_name
  )
SELECT
  *
FROM product_ranking
WHERE ranked_products <= 5;


-- What are the 5 worst-performing products in terms of sales?
SELECT top 5
  p.product_name,
  SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2 ASC;

-- with Window Function: What are the 5 worst-performing products in terms of sales?
SELECT
  p.product_name,
  SUM(f.sales_amount) total_revenue,
  ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) ASC) AS ranked_products
FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name

-- Which 5 subcategories generate the highest revenue?
SELECT top 5
  p.subcategory,
  SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY 2 DESC;

-- What are the 5 worst-performing subcategories in terms of sales?
SELECT top 5
  p.subcategory,
  SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY 2;

-- Find the top 10 customers who have generated the highest revenue
SELECT *
FROM (SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS ranked_customers
  FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
  GROUP BY 
  c.customer_id,
  c.first_name,
  c.last_name) t
WHERE ranked_customers <= 10;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
  c.customer_key,
  c.first_name,
  c.last_name,
  COUNT(DISTINCT order_number) total_orders
FROM gold.fact_sales f
  LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
  c.customer_key,
  c.first_name,
  c.last_name
ORDER BY total_orders;

-- using CTEs
WITH
  count_of_customers_orders
  AS
  (
    SELECT
      c.customer_key customer_key,
      c.first_name first_name,
      c.last_name last_name,
      COUNT(DISTINCT f.order_number) count_of_orders
    FROM gold.fact_sales f
      LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
  c.customer_key,
  c.first_name,
  c.last_name
  ),
  ranked
  AS
  (
    SELECT
      customer_key,
      first_name,
      last_name,
      count_of_orders,
      ROW_NUMBER() OVER (ORDER BY count_of_orders ASC) AS ranked_customers
    FROM count_of_customers_orders
  )
SELECT
  customer_key,
  first_name,
  last_name,
  count_of_orders,
  ranked_customers
FROM ranked
WHERE ranked_customers <= 3;
