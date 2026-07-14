# Data Dictionary for Gold Layer 

## Overview

The Gold layer is hte business_level data representation, structured to support analytical and reporting use cases. It consissts of dimension tables and fact tables for spefic business metrics.

### 1. gold.dim_customers
- __purpose__: Stores customer detail enriched with demographic and geographic data.
- __Columns__:



|Column Name  | Data Type|Description|
| --- | --- | --- |
| customer_key|INT | Surrogate key uniquely identifying each customer record in the cust dimension table. |
| customer_id |INT | Unique numerical identifier assigned to each customer|
| customer_number |NVARCHAR(50) |  Alphanumric identfier representing the customer, used for tracking and refeencing.|
| first_name |NVARCHAR(50)  | The customer's first name,as recorded in the system|
| last_name |NVARCHAR(50)  | The customer's last_name or family name.|
| country |NVARCHAR(50)  | The country of residence for the customer (e.g. 'Australia')|
| marital_status |NVARCHAR(50)  | The material status of the customer (e.g. "Married','Single')|
| gender |NVARCHAR(50)  | The gender of the customer (e.g. 'Male', 'Female','n/a')|

### 2. gold.dims_products
- __purpose__: Provides information about the products and their attributes
- Columns

|Column Name  | Data Type|Description|
| --- | --- | --- |
| product_key|INT | Surrogate key uniquely identifying each product record in the product  dimension table. |
| product_id|INT |An unique identifier assigned to the product for internal tracking and referencing. |
| product_number |NVARCHAR(50)  | A structured alphanumeric code representing the product, often used for categorization or inventory|
 |product_name |NVARCHAR(50)  | Descriptive name of the product, including key details such as type,color,size. |
 |category_id |NVARCHAR(50)  | An unique identifier for the product's category, linking to its high-level classification.|
 |category |NVARCHAR(50)  | The broader classification of the product(e.g. Bikes, Components) to group related items.|
 |Subcategory|NVARCHAR(50)  | A more detailed classification of the product within the category, such as product type. |
 |maintenance _required |NVARCHAR(50)  | Indicated whether the product requires maintenance (e.g. 'Yes', 'No'). |
 |cost |INT| The cost or base price of the product, measured in monetary units. |
 |product_line |NVARCHAR(50)  | The specific product line or series to  which the product belongs (e.g. Road, Mountain).|
 |start_date |DATE| The date when the product became availible for sale or use, stored in |

### 3. gold.dim_customer
|Column Name  | Data Type|Description|
| --- | --- | --- |
|order_number|NVARCHAR(50)  | An unique alphanumeric identifier for each sales order (e.g. 'SO54496'). |
|product_key|INT | Surrogate key uniquely identifying each product record in the product  dimension table. |
|customer_key|INT | Surrogate key uniquely identifying each customer record in the cust dimension table. |
|order_date |DATE| The date when the order was places. |
|shipping_date |DATE| The date when the orderwas shipped to the customer |
|due_date |DATE| The date when the order payment was due. |
|sales_amount|INT | The total monetary value of the sale for the line item, in whole cuurency units (e.g. 25). |
|quantity|INT | The number of units of the product ordered for the line item (e.g. 1). |
|price |INT | The price per unit of the product for the line item, in whole currency units (e.g. 25). |





