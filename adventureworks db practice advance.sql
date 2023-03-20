
use [AdventureWorks2019];

--views (To secure the data, Repeated needed data info stored in views)
--views are logical data view (not contain physical data)
--views can contain single table query or more than one table 

go
create view Sales.salesteritory_view_us as 
select * from [AdventureWorks2019].[Sales].[SalesTerritory] where 
CountryRegionCode like 'US'
go
--check a view
SELECT * FROM information_schema.views where TABLE_NAME = 'salesteritory_view_us';

--call a view

select * from sales.salesteritory_view_us;

go
create view [HumanResources].employee_department_view as

	select top 10 
	e.LastName, e.JobTitle, d.Department, d.Shift
	from
	[HumanResources].[vEmployee] as e inner join
	[HumanResources].[vEmployeeDepartmentHistory] as d 
	on e.BusinessEntityID = d.BusinessEntityID;
go
select * from [HumanResources].employee_department_view;

--To apply some security rules or checks against database interaction
-- both levels database or table level
--Triggers (set of automated scripts called against event occure)
--Triggers apply on table or views against (before or after) events occure
--Triggers auto executed insert, update, delete, create, drop or login etc

--DB level
go
create trigger create_table_trigger on
	database
	after --before (one at a time)
	create_table --update/delete/drop/create (one at a time)
	as
	begin

	 print 'Creation of Table is not allowed, You need admin approval'
	rollback transaction

	end
go
--test the trigger
create table mytable (col1 varchar(10))

--trigger on table first check table data
select * from [HumanResources].[Shift];

go
--create a trigger on table level
create trigger insert_shift_trigger on
	[HumanResources].[Shift]
	after --before (one at a time)
	insert --update/delete/drop (one at a time)
	as
	begin

	 print 'Insert is not allowed, You need admin approval'
	rollback transaction

	end

--test the trigger exection

insert into [HumanResources].[Shift] 
	(Name, StartTime, EndTime, ModifiedDate)
	values
	('Overnight', '01:00:00.0000000', '06:00:00.0000000',
	'2021-10-12 23:17:00.000')



--Stored Procedures (Intermediate interface between application and database)
--It is subrutine that contain sql scripts that is used multiple times against
--user actions so ultimately it enhance the database security
--can accept inputs and return multiple outputs if any
--encapsulated callable sql script 

go
--create a procedure
create procedure hr_shift_procedure as

set nocount on

select * from [HumanResources].[Shift] 

--only execute each time
execute hr_shift_procedure

go
create procedure hr_shift_procedure_2 as

set nocount off

select * from [HumanResources].[Shift] 

--only execute
execute hr_shift_procedure_2

--drop a procedure

drop proc hr_shift_procedure_2

--parameterized procedure


--input parameters
go
create procedure hr_shift_procedure_bydefault_name
--default value
@shift_name nvarchar(50) = 'Evening'
as select * from [HumanResources].[Shift] where
name = @shift_name

go
execute hr_shift_procedure_byname @shift_name = 'Day'
--execute hr_shift_procedure_byname 'Day'
go
create procedure hr_shift_procedure_bydefault_name
--default value
@shift_name nvarchar(50) = 'Evening'
as select * from [HumanResources].[Shift] where
name = @shift_name

execute hr_shift_procedure_bydefault_name


--output parameters
go
create proc hr_shift_procedure_get_id_byname
@shift_name nvarchar(50),
@shift_id tinyint output
as
set @shift_id = (select ShiftID from[HumanResources].[Shift] 
				 where Name = @shift_name)

declare @outputid tinyint
exec hr_shift_procedure_get_id_byname @shift_name = 'Evening', @shift_id = @outputid output
select @outputid

go
create proc hr_shift_procedure_get_id_number as
begin
return 3
end

declare @output int
exec @output = hr_shift_procedure_get_id_number 
select @output



--Functions (to perform some sort of calculation or conversion)
-- scalar : return data value
-- table  : return table itself
-- system built-in

select * from Sales.SalesTerritory;

--scalar functions (for singular value return)
go
create function YTDSales()

returns money as

begin

declare @YTDsales money
select @YTDsales = sum(SalesYTD) from sales.SalesTerritory
return @YTDsales
end
go


declare @ytdresults money
select @ytdresults = dbo.YTDSales()
print @ytdresults

go
--parameterized scalar functions

create function YTDGroup(@group varchar(50))

returns money as

begin

declare @YTDsales money
select @YTDsales = sum(SalesYTD) from sales.SalesTerritory
where [group] = @group
return @YTDsales
end

go

declare @results money
select @results = dbo.YTDGroup('Europe')
print @results



--table functions series of values (matrix)

select top 10 * from [Sales].[SalesTerritory]

go

create function sales_teritorry_table(@tid int)
returns table
as
return select name, CountryRegionCode, [group], salesytd, saleslastyear

from [Sales].[SalesTerritory] where
territoryID = @tid

go

select name, saleslastyear from sales_teritorry_table(5)

--Transaction Error Handeling 

select * from [Sales].[SalesTerritory];

declare @error_results varchar
declare @CB varchar = 'United Kingdom'

begin transaction
	update [Sales].[SalesTerritory]
	set CountryRegionCode = 'UK'
	where name = @CB


set @error_results = @@ERROR
if (@error_results = 0)
begin
	print 'Success!'
	commit transaction
end
else
begin
	print 'Failure'
	--raiserror('Custom Error Message', 10, 1)
	rollback transaction
end

--Try Catch

--begin try
--begin transaction

	--commit transaction

--end try

--begin catch
	--rollback transaction
--end catch

-- Grouping sets: at one time grouping multiple cols and chunks of data

select Name, CountryRegionCode, [GROUP], sum(SalesYTD) as SumYTD from [Sales].[SalesTerritory]
	group by grouping sets
	(
	(name),
	(Name, CountryRegionCode),
	(Name, CountryRegionCode, [GROUP])
	)

-- Roll UP: subdomain to domain grouping
select Name, CountryRegionCode, [GROUP], sum(SalesYTD) as SumYTD from [Sales].[SalesTerritory]
	group by rollup(
	(Name, CountryRegionCode, [GROUP])
	)

-- cube: cross pairing in grouping cols
select Name, CountryRegionCode, [GROUP], sum(SalesYTD) as SumYTD from [Sales].[SalesTerritory]
	group by cube(
	(Name, CountryRegionCode, [GROUP])
	)


							--Window Functions:
--Analytical functions operate on row or set of rows to aggregate and compare values.
--To enquire, apply and analayze the patterns within partitions of data.
--https://learnsql.com/blog/mysql-window-functions/

--Aggregated Functions:

--In aggregate functions, input table rows are summarized, so several (or many) rows are
--collapsed into one summary row. like max, sum, avg, count etc
--Results into one grouped value based on summarized value.

--A window function performs calculations over a set of rows, and uses
--information within the individual rows when required.

--Over: The OVER clause determines how the rows are arranged and then processed 
--by the window function.

--partition: The optional PARTITION BY clause divides window columns 
--into groups (partitions), 


select OrderDate, SalesOrderID,  CustomerID, TotalDue,
	sum(TotalDue) over (partition by OrderDate) as sums,
	avg(TotalDue) over (partition by OrderDate) as avgs,
	count(TotalDue) over (partition by OrderDate) as counts
	
from 
	[Sales].[SalesOrderHeader] order by TotalDue;

-- Rank: Assign the degree number(rank) in each partition based 
--			on specific col numeric values
--Returns the rank of the current row within a defined partition. 
--If one or more rows share the same ranking value, some rank numbers will 
--be omitted from the sequence (e.g. if there
--are two rows tied for second rank, the rank sequence will be 1, 2, 2, 4…).

--Dense Rank: Does not Skip a value: if there are two rows tied for second rank, the rank sequence
--will be 1, 2, 2, 3, 4…).

--Row Number: Returns the number of the current row within a defined partition.
--It assigns a row number to each record within the partition; it reinitializes
--row numbers to start from 1 when the partition is switched.


--Ntile: Divides rows within the current partition into buckets.
--The number of buckets is specified by the user.
--The NTILE() function then assigns the number of the bucket to each row.

select * from [Person].[Address];

select AddressLine1, city,  PostalCode,
	row_number() over (order by postalcode ) as Row_Number,
	Rank() over (partition by city order by postalcode) as Rank,
	dense_Rank() over (partition by city order by postalcode ) as Dense_Rank,
	NTILE(4) over (partition by city order by postalcode ) as Ntile4
from 
	[Person].[Address] order by PostalCode;

--Lead: Looks up a subsequent row value for the specified 
--column within the current partition.

--Lag: Looks up a previous row value for a specified column
--within the current partition.

--First value: Returns the value of a specified column for the first row 
--within the current partition.

--Last value: Returns the value of a specified column for the last row within
--the current partition.

--Nth Value: Returns the value of a specified column for the nth row within the current
--partition, where n is defined by the user.

select top 20 * from [Sales].[SalesOrderHeader];

go
select OrderDate, SalesOrderID,  CustomerID, TotalDue,
	Lead(TotalDue, 1, 0) over (partition by OrderDate order by TotalDue) as Lead_value,
	Lag(TotalDue, 1, 0) over (partition by OrderDate order by TotalDue ) as Lag_value,
	First_value(TotalDue) over (partition by OrderDate order by TotalDue ) as First_value,
	Last_value(TotalDue) over (partition by OrderDate order by TotalDue ) as Last_value
	
from 
	[Sales].[SalesOrderHeader];

