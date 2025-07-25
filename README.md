# SQL-Sales-and-Product-Performance-Analysis


![Picture1](https://github.com/user-attachments/assets/812e5fc6-d697-4b46-9362-f4695ec0c033)


1) Create the 'DataWarehouseAnalytics' database

2) Create Gold Schema
   
3) Create dimensions of customers table, product table and sales table.

4) Bulk insert into above tables

5) Change over time

-- Analyze sales performance over time

<img width="476" height="335" alt="imaGE DE" src="https://github.com/user-attachments/assets/b70d4b45-54b4-47c4-a3cc-41fc3023e8fc" />


-- Analyze sales performance over time by month

<img width="410" height="328" alt="imaGE DE" src="https://github.com/user-attachments/assets/6bc397fc-b626-49a9-904c-db096dcfe7d4" />


-- Analyze sales performance over time as per year

<img width="401" height="147" alt="imaGE DE" src="https://github.com/user-attachments/assets/3df38693-cd19-422c-99db-7e6d64cdab01" />

6) Cumulative Analysis
   
--Calculate the total sales per month and the running total of sales over time by month

<img width="322" height="338" alt="image" src="https://github.com/user-attachments/assets/fdf8b62c-7db0-45bf-976b-704f64a145e1" />


-- Calculate the total sales per year and the running total of sales over time

<img width="325" height="137" alt="image" src="https://github.com/user-attachments/assets/a0836176-9e27-4f3d-ac88-b25578a8dd34" />


-- Calculate the total sales per year, running total, and moving average of sales
-- Calculate the total sales per year and the moving average of sales over time

<img width="440" height="135" alt="image" src="https://github.com/user-attachments/assets/e3124741-449d-48d9-9c89-d9798b032034" />


7) Performance Analysis

-- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales

<img width="887" height="332" alt="image" src="https://github.com/user-attachments/assets/a01a5c63-3203-40fe-b9a0-53addd21299c" />


8) Part-to-Whole analysis

<img width="416" height="93" alt="image" src="https://github.com/user-attachments/assets/19ab714f-c325-453a-9029-fc0cb2dbf4fc" />


9) Data Segmentation

-- Segment products into cost ranges and count how many products fall into each segment

<img width="221" height="112" alt="image" src="https://github.com/user-attachments/assets/ead8fd1b-fc83-4884-92c9-040ea250c900" />


-- Group customers into three segments based on their spending behavior:
   - VIP: Customers with at least 12 months of history and spending more than €5,000.
   - Regular: Customers with at least 12 months of history but spending €5,000 or less. 
   - New: Customers with a lifespan less than 12 months.
   And find the total number of customers by each group.

<img width="271" height="92" alt="image" src="https://github.com/user-attachments/assets/b163b2ed-4d3a-4351-9a9d-6e5ff59aa6f0" />


REPORTS: 

1: Customer Report
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
   - average monthly spend

<img width="1406" height="328" alt="image" src="https://github.com/user-attachments/assets/2a560f3f-bb3e-4228-8885-f9094e7aa76a" />


2: Product Report

Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:

    1. Gathers essential fields such as product name, category, subcategory, and cost.

    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    
    3. Aggregates product-level metrics:
    
       - total orders
       
       - total sales
       
       - total quantity sold
       
       - total customers (unique)
       
       - lifespan (in months)
    
    4. Calculates valuable KPIs:
    
       - recency (months since last sale)
       
       - average order revenue (AOR)
       
       - average monthly revenue


<img width="1587" height="313" alt="imaGE DE" src="https://github.com/user-attachments/assets/edab7be5-6b79-42ee-a0a8-64ad51024380" />












