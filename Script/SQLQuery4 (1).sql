/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold.

WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

-- Switch to the new database
USE DataWarehouseAnalytics;
GO

-- Create schema
CREATE SCHEMA gold;
GO

-- Create dim_customers table
CREATE TABLE gold.dim_customers (
    customer_key int,
    customer_id int,
    customer_number nvarchar(50),
    first_name nvarchar(50),
    last_name nvarchar(50),
    country nvarchar(50),
    marital_status nvarchar(50),
    gender nvarchar(50),
    birthdate date,
    create_date date
);
GO

-- Create dim_products table
CREATE TABLE gold.dim_products (
    product_key int,
    product_id int,
    product_number nvarchar(50),
    product_name nvarchar(50),
    category_id nvarchar(50),
    category nvarchar(50),
    subcategory nvarchar(50),
    maintenance nvarchar(50),
    cost int,
    product_line nvarchar(50),
    start_date date
);
GO

-- Create fact_sales table
CREATE TABLE gold.fact_sales (
    order_number nvarchar(50),
    product_key int,
    customer_key int,
    order_date date,
    shipping_date date,
    due_date date,
    sales_amount int,
    quantity tinyint,
    price int
);
GO

-- Bulk Insert into dim_customers
BULK INSERT gold.dim_customers
FROM 'C:\Users\mervi\OneDrive\Desktop\SQL course\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Bulk Insert into dim_products
BULK INSERT gold.dim_products
FROM 'C:\Users\mervi\OneDrive\Desktop\SQL course\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Bulk Insert into fact_sales
BULK INSERT gold.fact_sales
FROM 'C:\Users\mervi\OneDrive\Desktop\SQL course\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- CHANGE OVER TIME
-- Analyze sales performance over time
SELECT
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_Sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Analyze sales performance over time by month
SELECT
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) as total_Sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Analyze sales performance over time as per year
SELECT
    DATETRUNC(year, order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
ORDER BY order_year;

--CUMULATIVE ANALYSIS
--Calculate the total sales per month and the running total of sales over time by month
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) AS t
ORDER BY order_date;

-- Calculate the total sales per year and the running total of sales over time
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) AS t
ORDER BY order_date;


-- Calculate the total sales per year, running total, and moving average of sales

-- Calculate the total sales per year and the moving average of sales over time
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(total_sales) OVER (ORDER BY order_date) AS moving_avg_sales
FROM
(
    SELECT
        CAST(YEAR(order_date) AS INT) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY CAST(YEAR(order_date) AS INT)
) AS t
ORDER BY order_date;

-- PERFORMANCE ANALYSIS
/* Analyze the yearly performance of products by comparing their sales
   to both the average sales performance of the product and the previous year's sales  */
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year over year analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_of_prev_year,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increased'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreased'
        ELSE 'No Change'
    END AS prev_yr_change
FROM yearly_product_sales
ORDER BY product_name;

-- Part-to-Whole analysis
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)

SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- DATA SEGMENTATION
/* Segment products into cost ranges and 
count how many products fall into each segment*/

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100 - 500'
            WHEN cost >= 500 AND cost < 1000 THEN '500 - 1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)

SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/* Group customers into three segments based on their spending behavior:
   - VIP: Customers with at least 12 months of history and spending more than €5,000.
   - Regular: Customers with at least 12 months of history but spending €5,000 or less. 
   - New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS customer_count
FROM (
    SELECT
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY customer_count DESC;


/* Customer Report
Purpose:  This report consolidates key customer metrics and behaviors
Highlights: 
1. Gather essential fields such as names, ages and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregate customer-level metrics:
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - lifespan (in months)
4. Calculates valuable KPIs
   - recency (months since last order)
   - average order value
   - average monthly spend */ 
   WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'NEW'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity, 
    total_products, 
    lifespan,
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;

/* Build project report

Purpose: This report consolidates key product metrics and behaviors. 

Highlights:
  1. Gathers essential fields such as product name, category, subcategory and cost. 
  2. Segments products by revenue to identify High-Performers, Mid-Range or Low-Performers. 
  3. Aggregates product-level metrics:
     - total orders
     - total sales
     - total quantity sold
     - total customers (unique)
     - lifespan (in months)
  4. Calculates valuable KPIs:
     - recency (months since last sale)
     - average order revenue (AOR)
     - average monthly revenue */

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount, 
        f.quantity, 
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
)
SELECT 
    product_key,
    product_name,
    category,
    subcategory, 
    cost, 
    
    MIN(order_date) AS first_sale_date,
    MAX(order_date) AS last_sale_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    DATEDIFF(MONTH, MAX(order_date), GETDATE()) AS recency_in_months,

    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,

    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,

    -- Force 2-decimal average selling price
    CAST(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)) AS DECIMAL(18,2)) AS avg_selling_price,

    CASE 
        WHEN SUM(sales_amount) >= 10000 THEN 'High-Performer'
        WHEN SUM(sales_amount) >= 5000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    -- Force 2-decimal avg order revenue
    CAST(
        CASE 
            WHEN COUNT(DISTINCT order_number) = 0 THEN 0
            ELSE SUM(sales_amount) * 1.0 / COUNT(DISTINCT order_number)
        END
    AS DECIMAL(18,2)) AS avg_order_revenue,

    -- Force 2-decimal avg monthly revenue
    CAST(
        CASE 
            WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) = 0 THEN SUM(sales_amount)
            ELSE SUM(sales_amount) * 1.0 / DATEDIFF(MONTH, MIN(order_date), MAX(order_date))
        END
    AS DECIMAL(18,2)) AS avg_monthly_revenue

FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost;




SELECT * FROM gold.report_products;

