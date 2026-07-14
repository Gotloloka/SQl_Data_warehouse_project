/* 
===========================================================================================
DDL Script: Create Gold Views
===========================================================================================

Script Purpose:
	This script creates view for the layer in the data warehouse.
	The Gold layer  represents the final dimension and fact  tables (Star schema)



	Each view performs transformations and combines data from the Silver layer
	to produce a clean, enriched, and business- rady dataset 

	usage:
		-These views can be queried directly for analytics and reporting.
===========================================================================================
*/


-- ===========================================================================================
--Create Dimension: gold.dim_customer
-- ===========================================================================================
IF OBJECT_ID ('gold.dim_customer','U') IS NOT NULL
	DROP VIEW gold.dim_customer;
GO
CREATE VIEW gold.dim_customer AS
SELECT
ROW_NUMBER() OVER (ORDER BY ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	ci.cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.cst_gndr,'N/A')
	END AS gender,
	la.cntry as country,
	ca.bdate as birthdate,
	ci.cst_create_date

FROM silver.crm_cust_info AS  ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON  ci.cst_key = ca.cst_id
JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cst_id;
GO
IF OBJECT_ID ('gold.dim_products','U') IS NOT NULL
	DROP VIEW gold.dim_products;

-- ===========================================================================================
--Create Dimension: gold.dim_products
-- ===========================================================================================
GO
CREATE VIEW gold.dim_product  AS
	SELECT
	ROW_NUMBER() OVER ( ORDER BY pr.prd_start_dt,pr.prd_line) AS product_key,
		pr.prd_id as product_id,
		pr.prd_key product_number,
		pr.prd_nm as product_name,
		pr.cat_id as category_id,
		ct.cat as category,
		ct.sub_cat as subcategory,
		ct.maintenance,
		pr.prd_line as product_line,
		pr.prd_cost as product_cost,
		pr.prd_start_dt as start_date
	
	FROM silver.crm_prd_info  as pr
	LEFT JOIN silver.erp_px_cat_g1v2 ct
	ON pr.cat_id = ct.cst_id
	WHERE pr.prd_end_dt is null;--filter out all the historical data
	GO
	IF OBJECT_ID ('gold.fact_sales','U') IS NOT NULL
	DROP VIEW gold.fact_sales;
	GO

-- ===========================================================================================
--Create Fact: gold.fact_sales
-- ===========================================================================================
CREATE VIEW gold.fact_sales AS
	SELECT 
	 sl.sls_ord_num as order_number,
	 pr.product_key,
	 cu.customer_key,
	 sl.sls_order_dt as order_date,

	 sl.sls_due_dt as due_date,
	 sl.sls_ship_dt as shipping_date,
	 sl.sls_sales as sales_amount,
	 sl.sls_quantity as quantity,
	 sl.sls_price as price
 
	FROM silver.crm_sales_details AS sl
	LEFT JOIN gold.dim_products pr
	on sl.sls_prd_key =  pr.product_number
	LEFT JOIN gold.dim_customer cu
	ON sl.sls_cust_id = cu.customer_id;
