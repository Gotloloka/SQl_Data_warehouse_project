/* 
==================================================================
Stored Procedure: Load Silver Layer (Source ->Silver)
==================================================================
Script Purpose: 
	This stored procedure performs the ETL (Extract,Transform, Load) process to populate the 'Silver' scheam tables from the 'Bronze' schema
	It performs the following actions:
	- Truncates the silver tables .
	-  Insert transformed and cleaned data from bronze into silver tables.

Parameters:
	None.
 This stored procedure does not accpet any parameters or return any values.

Usage Example:
	EXEC silver.load_load_silver 
==================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	DECLARE @start_time DATETIME,@end_time DATETIME ;
	DECLARE @batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE();
		PRINT '===============================================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '===============================================================';

		PRINT '---------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------------------------';
	SET @start_time = GETDATE();
	PRINT'>> Truncating Table: silver.crm_cust.info';
	TRUNCATE TABLE silver.crm_cust_info;
	Print '>> Inserting Data Into: silver.crm_cust_info';
	INSERT INTO SILVER.crm_cust_info(cst_id,cst_key,cst_first_name,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
	SELECT 
		cst_id,
		cst_key,
		TRIM(cst_first_name) AS cst_first_name ,
		TRIM(cst_lastname) AS cst_lastname,
		CASE when UPPER(TRIM(cst_marital_status)) ='s' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'N/A'
		END cst_marital_status,
		CASE when UPPER(TRIM(cst_gndr)) ='F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'N/A'
		END cst_gender,
		cst_create_date

	FROM ( SELECT * 
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id order by cst_create_date DESC) as flag_last 
			FROM bronze.crm_cust_info) AS flag_tab
		WHERE flag_last = 1 and cst_id is not null) t;
		
	SET @end_time = GETDATE();
	PRINT '>>Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR) + 'seconds';
	PRINT '--------------------';
	
	SET @start_time = GETDATE()
	PRINT'>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> Inserting Data Into: silver.crm_prd_info';
	/* Build Silver Layer 
	Clean and Load 
	crm_prd_info*/
	INSERT INTO silver.crm_prd_info ( prd_id,cat_id, prd_key, prd_nm,prd_cost,prd_line,prd_start_dt, prd_end_dt)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id, --Extract category ID
		SUBSTRING(prd_key,7,len(prd_key)) as prd_key, --EXtract Product Key
		prd_nam,
		Isnull(prd_cost,0) as prd_cost,-- Identify NULLS VALUES
		CASE  UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN  'S' THEN 'Other sale'
			WHEN  'T' THEN 'Touring'
			ELSE 'N/A'
		END as prd_line, -- Map product line codes to descriptive values 
		CAST ( prd_start as DATE ) AS prd_start_dt,
		CAST(CAST(LEAD(prd_start) OVER( Partition by prd_key order by prd_start asc) as DATEtime)-1 as DATE) as prd_end_dt	-- Calculate end date as one day before the next start date
	FROM Bronze.crm_prd_info;
	SET @end_time = GETDATE();
	PRINT '>>Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR) + 'seconds';
	PRINT '--------------------';
	SET @start_time = GETDATE();
	PRINT'>> Truncating Table: silver.crm_sales_details'
	TRUNCATE TABLE silver.crm_sales_details
	PRINT '>> Insesrting Data Into: silver.crm_sales_details'
	/*  Build Silver Layer 
	Clean and Load 
	crm_prd_info*/
	INSERT INTO silver.crm_sales_details( 
		sls_ord_num
		,sls_prd_key
		,sls_cust_id,
		sls_order_dt,
		sls_ship_dt
		,sls_due_dt
		,sls_sales
		,sls_quantity
		,sls_price)
	SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt=0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt as VARCHAR) as DATE) 
		END sls_order_dt,
		CASE WHEN sls_ship_dt=0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE) 
		END sls_ship_dt,
		CASE WHEN sls_due_dt=0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE) 
		END sls_due_dt,
		CASE  WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity*abs(sls_price) THEN sls_quantity*sls_price 
			ELSE sls_sales
		END sls_sales,-- Recalculate sales if original value is missing or incorrect 
		CASE  WHEN sls_quantity IS NULL OR sls_quantity <=0  THEN sls_sales/NULLIF(sls_price,0)
			ELSE sls_quantity
		END	sls_quantity,
		CASE  WHEN sls_price IS NULL OR sls_price <=0  THEN sls_sales/NULLIF(sls_quantity,0)
			ELSE sls_price
		END	sls_price -- Derive price original value is invalid 
	FROM bronze.crm_sales_details;
	SET @end_time = GETDATE();
	PRINT '>>Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR) + 'seconds';
	PRINT '---------------------------------------------------------------';
	PRINT 'Loading ERP Tables';
	PRINT '---------------------------------------------------------------';

	SET @start_time = GETDATE();
	PRINT'>> Truncating Table: silver.erp_cust_az12'
	TRUNCATE TABLE silver.erp_cust_az12
	PRINT '>> Insesrting Data Into: silver.erp_cust_az12'
	 /* LOAD and CLEAN silver.erp_cust_az12 */
	INSERT INTO silver.erp_cust_az12( cust_ID,bith_date,cust_gender)
	SELECT 
		CASE WHEN cust_ID  like  'NAS%' THEN SUBSTRING(cust_ID ,4,len(cust_ID )) 
		else cust_ID
		END cid,
		CASE WHEN bith_date>getdate() then NULL
			ELSE bith_date
		END AS birth_date,
		CASE WHEN UPPER(TRIM(cust_gender)) in ('F','FEMALE') THEN 'FEMALE'
			when UPPER(TRIM(cust_gender)) in ('M','MALE') THEN 'MALE'
			ELSE 'N/A'
		END cust_gender 
	FROM bronze.erp_cust_az12;
	SET @end_time = GETDATE();
	PRINT '>>Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR) + 'seconds';
	PRINT '--------------------';
	SET @start_time = GETDATE();
	PRINT'>> Truncating Table: silver.erp_loc_a101'
	TRUNCATE TABLE silver.erp_loc_a101
	Print '>> Insesrting Data Into: silver.erp_loc_a101'
	/* load and clean erp_loc_a101 */
	INSERT INTO silver.erp_loc_a101( cust_id, country)
	SELECT 
		replace(cust_ID,'-','') cid,
		CASE WHEN UPPER(TRIM(country)) in ('US','USA') THEN 'United State'
			when UPPER(TRIM(country)) in ('DE','Germany') THEN 'GERMANY'
			when UPPER(TRIM(country))  = '' or country IS NULL THEN 'N/A'
		ELSE TRIM(country)
		END countries -- Normalize and Handel missing or blank country codes 
	FROM bronze.erp_loc_a101;
	SET @end_time = GETDATE();
	PRINT '>>Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR) + 'seconds';
	PRINT '--------------------';
	SET @start_time = GETDATE();
	PRINT'>> Truncating Table: silver.erp_px_cat_g1v2'
	TRUNCATE TABLE silver.erp_px_cat_g1v2
	Print '>> Insesrting Data Into: silver.erp_px_cat_g1v2'
	 /* LOAD and CLEAN silver.erp_px_cat_g1v2 */
	 INSERT INTO silver.erp_px_cat_g1v2( ID,category,sub_category,maintenance)
	 SELECT 
		id, 
		TRIM(category),
		TRIM(sub_category),
		maintenance
	 FROM bronze.erp_px_cat_g1v2;
	 SET @end_time = GETDATE();
	PRINT '>>Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR) + 'seconds';
	PRINT '--------------------'
	
		SET @batch_end_time = GETDATE();
		PRINT '===============================================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '	- Total Load Duration: ' + CAST( DATEDIFF(SECOND,@batch_start_time,@batch_end_time) as NVARCHAR)+'seconds';
		PRINT '===============================================================================';

END TRY
	BEGIN CATCH
			PRINT '==============================================================================='
			PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
			PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
			PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);

			PRINT '==============================================================================='
	END CATCH;
END ;
GO
exec silver.load_silver
