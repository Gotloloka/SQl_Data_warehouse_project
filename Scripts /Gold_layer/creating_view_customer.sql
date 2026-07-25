/*
========================================================================================================
Customer Report
========================================================================================================
Purpose:
	- This report consolidated key customer metrics and behaviors 

	Highlights:
		1. Gathers essential fields as names, ages ,and transaction detials.
		2. Segments customer into categoties (VIP, Regular, New) and age groups.
		3.  Agggregates customer -level metrics:
			- total orders 
			- total sales
			- total quantity purchased 
			- total products 
			-lifespan (in months)
		4. Calculates valuable KPIs:
			- recency (months since last order)
			- average order value
			- average monthly spend 
========================================================================================================
*/
/*
--------------------------------------------------------------------------------------------------------
1) Base Quaery: Retrieves core columns from tables 
-------------------------------------------------------------------------------------------------------- */
CREATE VIEW gold.report_customer AS
WITH base_query AS (
SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	s.quantity,
CONCAT( c.first_name,' ',c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customer c
ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL),
/*
--------------------------------------------------------------------------------------------------------
3) Customer_aggregation: Summarizes key  metrics at the customer level
-------------------------------------------------------------------------------------------------------- */
customer_aggregation AS (
SELECT
	customer_key,
	customer_number, 
	customer_name, 
	age,
	COUNT( DISTINCT order_number) AS total_orders,
	SUM( sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT( DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price
	
FROM base_query
GROUP BY customer_key, customer_number, customer_name,age ) 

SELECT 
customer_key, 
customer_number, 
customer_name,
age,
CASE WHEN  age <20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN ' 20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and  above'
END age_group
,
CASE WHEN  lifespan >= 12 and total_sales >5000 THEN 'VIP'
	 WHEN lifespan >= 12 and  total_sales <= 5000 THEN 'Regular'
	ELSE  'New'
END customer_segment
,
total_orders,
total_sales,
total_quantity,	
total_products,
last_order_date,
DATEDIFF(MONTH, last_order_date , GETDATE()) AS RECENCY, -- months since  last order be placed 
lifespan,
-- Compute average order value (AVO)
CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales/total_orders
END avg_order_value,
-- compuate average monthly spend 
CASE WHEN lifespan = 0 THEN total_sales
	else total_sales/lifespan
END  avg_monthly_spend
FROM customer_aggregation
