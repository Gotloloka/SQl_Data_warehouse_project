
/*
========================================================================================================
Product Report
========================================================================================================
Purpose:
	- This report consolidated key product metrics and behaviors 

	Highlights:
		1. Gathers essential fields as names, ages ,and transaction detials.
		2. Segments Product by revenue to identify high_Performers, Mid_Range, or Low_performaners.
		3.  Agggregates product -level metrics:
			- total orders 
			- total sales
			- total quantity sold 
			- total products 
			-lifespan (in months)
		4. Calculates valuable KPIs:
			- recency (months since last order)
			- average order revenue (AOR)
			- average monthly spend 
========================================================================================================
*/
/*
--------------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
-------------------------------------------------------------------------------------------------------- */
CREATE VIEW gold.report_products AS
WITH base_query_product AS (
SELECT
	s.order_number,
	s.customer_key,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	s.order_date,
	s.shipping_date,
	s.sales_amount,
	s.quantity,
	s.price,
	p.product_cost
FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL),
 product_aggregations as (
 /*
--------------------------------------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
-------------------------------------------------------------------------------------------------------- */
 SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan,
	MAX(order_date) AS last_order_date,
	COUNT( DISTINCT order_number) AS total_orders,
	SUM( sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT( DISTINCT customer_key) AS total_customers,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query_product
GROUP BY product_key,
	product_name,
	category,
	subcategory,
	product_cost)

/*
--------------------------------------------------------------------------------------------------------
3) Final Query: Combines all product results into output
-------------------------------------------------------------------------------------------------------- */
SELECT 
 product_key,
 product_name,
 category,
 subcategory,
 product_cost,
 last_order_date,
 DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_months,
 CASE 
	WHEN total_sales > 5000 THEN 'High_performer'
	WHEN total_sales > 5000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
END product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- AOR
CASE 
	WHEN total_orders = 0 THEN 0
	ELSE total_sales/ total_orders
END avg_order_revenue,
--- AMR
CASE
	WHEN lifespan= 0 THEN total_sales
	ELSE total_sales/lifespan
END avg_monthly_revenue
FROM product_aggregations
