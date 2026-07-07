/*
	Create Database and Schemas

	Script Purpose:
		This script creates a new database, if the database exists, it is dropped and recreated.
		Additionally, the script creates three schemas within the database: 'bronze', 'silver', 'gold'.

	Warning:
		Script will drop the entire database if it exists and all data in the database will be 
		permanently deleted.
*/

use master;
go

if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end;
go

create database DataWarehouse;
go

use DataWarehouse;
go

create schema bronze;
go
create schema silver;
go
create schema gold;
go
