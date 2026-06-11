USE Datawarehouse;
-- Creating table for Datawarehouse Database 

IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_first_name NVARCHAR(50), 
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO 
IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nam NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(10),
prd_start DATE,
prd_end DATE
);

GO
IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(20),
sls_prd_key NVARCHAR(20),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

GO
IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12 (
	cust_ID NVARCHAR(25),
	bith_date DATE,
	cust_gender NVARCHAR(10)

);

GO 
IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
GO
CREATE TABLE bronze.erp_loc_a101(
	cust_ID NVARCHAR(25),
	country NVARCHAR(50)
);
GO
IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2(
	ID NVARCHAR(50),
	category NVARCHAR(50),
	sub_category NVARCHAR(50),
	maintenance NVARCHAR(10)
);

