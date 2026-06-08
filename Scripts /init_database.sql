/*
Creating Database and Schemas 
*/
USE MASTER;
GO
--Drop and creatte new "DataWarehouse" database

IF EXISTS ( SELECt 1 FROM sys.databases  WHERE name='Datawarehouse')
BEGIN
	ALTER DATABASE Datawarehouse set SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Datawarehouse;

END;
GO
-- Creating data warehouse database 
CREATE DATABASE Datawarehouse;
GO
USE Datawarehouse;
GO

-- Creating Schema 
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
