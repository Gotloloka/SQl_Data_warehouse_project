/* 
===========================================================================================
Quality Checks
===========================================================================================

Script Purpose:
	This script performs quality checks to validate the integrity, consistency,and accurancy of the Gold layer. These checks ensure:
	- Uniqueness of suurogate keys in dimension tables.
	- Referential of surrogate keys in dimension tables.
	- Validation of relationships in the dat model for analytical purposes.

Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolver any discrepancies found during the checks.
===========================================================================================
*/

-- ===========================================================================================
-- Checking 'gold.dim_customers'
-- ===========================================================================================
-- Check for Uniquemess of Customer Key in gold.dim_customers
-- Expectation: No results

Select 
	customer_key,
	count(*) as duplicate_count
from gold.dim_customer
group by customer_key
having count(*) >1;
Go ;

-- ===========================================================================================
-- Checking 'gold.product_key'
-- ===========================================================================================
-- Check for Uniquemess of Product Key in gold.dim_products
-- Expectation: No result
select 
	product_key,
	count(*) as duplicate_count 
from gold.dim_products
group by product_key
having count(*) >1;

go 
-- ===========================================================================================
-- Checking 'gold.product_key'
-- ===========================================================================================
-- Check the data model connectivity between fact and dimensions

select *
from gold.fact_sales s
left join gold.dim_customer c
on c.customer_key = s.customer_key
left join gold.dim_products p
on  p.product_key = s.customer_key
where p.product_key is null or c.customer_key is null
