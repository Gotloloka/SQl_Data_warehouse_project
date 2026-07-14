# Data Dictionary for Gold Layer 

## Overview

The Gold layer is hte business_level data representation, structured to support analytical and reporting use cases. It consissts of dimension tables and fact tables for spefic business metrics.

### 1. gold.dim_customers
- __purpose__: Stores customer detail enriched with demographic and geographic data.
- __Columns__:



|Column Name  | Data Type|Description|
| --- | --- | --- |
|customer_key|INT | Surrogate key uniquely identifying each customer reocrd in the dimension table. |
| customer_id |INT | Unique numerical identifier assigned to each customer|
| customer_number |NVARCHAR(50) |  Alphanumric identfier representing the customer, used for tracking and refeencing.|
| first_name |NVARCHAR(50)  | The customer's first name,as recorded in the system|
| last_name |NVARCHAR(50)  | The customer's last_name or family name.|
| country |NVARCHAR(50)  | The country of residence for the customer (e.g. 'Australia')|
| marital_status |NVARCHAR(50)  | The material status of the customer (e.g. "Married','Single')|
| gender |NVARCHAR(50)  | The gender of the customer (e.g. 'Male', 'Female','n/a')|



