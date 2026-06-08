/*
Creating Database and Schemas 

SCript purpose:
	This script is a new database named 'Datawarehouse' after checking if it already  exists.
	If the database exists, it is dropped and recreated. Additionaly, the script sets up three schemas 
	within the database:'Bronze',;Silver','Gold'

Warning:
	1. Reading this script will permantly drop entire "Datawarehouse' database if ti exists.
	2. Ensure you have proper backups before runnings this script
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
