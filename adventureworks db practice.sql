
use [AdventureWorks2019];
--Database: Collection of data Management objects (log, users, Schemas, 
--			tables, views, program logic, security etc)
--Schema: logical namespaces (contain related tables) in the database
--table: Data container having tabular structure

--SQL: Query language to play with data, its security and its structure

--					4 - types of SQL

--Data Manipulation Language (DML) is the set of SQL statements that 
--focuses on querying and modifying data. DML statements include, truncate
--the primary focus of this training, and modification statements
--such as INSERT, UPDATE, and DELETE.


--Data Definition Language (DDL) is the set of SQL statements that 
--handles the definition and life cycle of database objects, such as tables,
--views, and procedures.
--DDL includes statements such as CREATE, ALTER, and DROP.

--Data Query Language (DQL) is the set of SQL statements that 
--focuses on querying (extract) data from database objects.
-- select or exec , with lultiple clasues and operators and functions
-- like, in, between, where, having, group by, order by, over etc.

--Data Control Language (DCL) is the set of SQL statements used to manage 
--security permissions for users and objects. DCL includes statements such as 
--GRANT, REVOKE, and DENY.

--Transaction Control Language (TCL) is the set of SQL statements used to manage 
-- trnsaction exection results to permanently saved or undo. 
-- COMMIT, ROLLBACK, BREAKPOINT



--BAsic admin queries

-- all table info in given schema
SELECT 
    *
FROM
    information_schema.tables where TABLE_SCHEMA = 'Production';

-- single table info

SELECT 
    *
FROM
    information_schema.tables where TABLE_NAME = 'EmployeePayHistory';


SELECT 
    *
FROM
    information_schema.tables where TABLE_TYPE = 'BASE TABLE';

-- get info of table columns

SELECT TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 

	where TABLE_NAME = 'SalesReason'
go

--calling views

SELECT * FROM information_schema.views;

--Retrieving data from tables

--DQL: Selection of data from tables to view:

-- Select Query execution order: Which tables(from), which rows(where), 
			--group by (grouping), having(group condition),
			--select (which cols), order by (sorting)

select * from [HumanResources].[Department];

select * from Sales.SalesOrderHeader order by TotalDue
	OFFSET 0 ROWS --Skip zero rows
	FETCH NEXT 10 ROWS ONLY; --Get the next 10

go

-- CTE (Common table experessions): temp result set

with cte_temset as 
	(select * from [HumanResources].[JobCandidate])

select top 10 * from cte_temset where BusinessEntityID is not NULL;

select count(*) from [HumanResources].[JobCandidate];

go

select JobTitle, MaritalStatus from [HumanResources].[Employee] where Gender = 'M';

go

select * from [Person].[CountryRegion];
go

select * from [HumanResources].[Employee] where OrganizationLevel = 2
go

select JobTitle, BirthDate, Gender, HireDate from [HumanResources].[Employee] 
where JobTitle like '%Manager%' and HireDate > '2008-12-31'
go

select ProductNumber, Name, DaysToManufacture, ListPrice + 10 as cal_col from 
[Production].[Product]
go

select ProductNumber, Name, DaysToManufacture, ListPrice + 10 as cal_col into 
[Production].[Product_2] from [Production].[Product]
go

select ProductNumber, Name, DaysToManufacture, ListPrice + 10 as cal_col into #temp_product
from [Production].[Product]
go


-- DML to update data in tables

update [Production].[Product_2] set Name = 'Blade White' where name = 'Blade'
go 

delete from [Production].[Product_2] where name = 'Bearing Ball'
go

--DDL Statements

--change, add or drop table structure properties
ALTER TABLE [Production].[Product_2]
ALTER COLUMN productnumber nvarchar(26);

ALTER TABLE Customers
DROP COLUMN Email;

ALTER TABLE Persons
ADD DateOfBirth date;

--remove data alongwith table itself
DROP TABLE  [Production].[Product_2];

--remove table data only
Truncate TABLE [Production].[Product_2];

go

--Subqueries

--2nd highest value

SELECT TOP 1 ActualCost FROM ( SELECT distinct TOP 2 ActualCost FROM [Production].[TransactionHistory]

	ORDER BY ActualCost DESC) AS MyTable;


select top 3 LineTotal from [Sales].[SalesOrderDetail] order by LineTotal desc

-- 3rd lowest value
select top 1 LineTotal from (

	select top 3 LineTotal from [Sales].[SalesOrderDetail] order by LineTotal

	) as t

-- get 4th highest value
select Top 1 LineTotal from ( 
					select distinct top 4 LineTotal  from [Sales].[SalesOrderDetail] 
					order by LineTotal desc) as t

-- get nth value using dense_rank

WITH RESULT AS  
(  
    SELECT LineTotal,  
           DENSE_RANK() OVER (ORDER BY LineTotal DESC) AS DENSERANK  
    FROM [Sales].[SalesOrderDetail]  
)  
SELECT TOP 1 LineTotal  
FROM RESULT  
WHERE DENSERANK = 3

-- using row number get nth value

select LineTotal from   
					(select LineTotal,
					ROW_NUMBER() over (order by LineTotal desc) as r
					from [Sales].[SalesOrderDetail] ) as t  
where r = 3;

--Joins

--inner join
go
select pr.Name as ProductName, pr.Color, pr.size, pr.StandardCost,
	ps.Name as ProductCategory from [Production].[Product] as pr 
	inner join 
	[Production].[ProductSubcategory] as ps on 
	ps.ProductSubcategoryID = pr.ProductSubcategoryID;
	
go
select pr.Name as ProductName, pr.Color, pr.size, pr.StandardCost,
	ps.Name as ProductCategory from [Production].[Product] as pr 
	left join 
	[Production].[ProductSubcategory] as ps on 
	ps.ProductSubcategoryID = pr.ProductSubcategoryID;
go
select pr.Name as ProductName, pr.Color, pr.size, pr.StandardCost,
	ps.Name as ProductCategory from [Production].[Product] as pr 
	full join 
	[Production].[ProductSubcategory] as ps on 
	ps.ProductSubcategoryID = pr.ProductSubcategoryID;
go
select pr.Name as ProductName, pr.Color, pr.size, pr.StandardCost,
	ps.Name as ProductCategory from [Production].[Product] as pr 
	cross join 
	[Production].[ProductSubcategory] as ps; 
	
go

--aggreagtion

select 
	ps.Name as ProductCategory, count(pr.Name) 
	as ProductCount, sum(pr.StandardCost) as ProductTotalCost
	from 
	[Production].[Product] as pr 
	inner join 
	[Production].[ProductSubcategory] as ps on 
	ps.ProductSubcategoryID = pr.ProductSubcategoryID
	group by

	ps.Name;
go

--left outer Join
--All left rows, matched right rows and non matched (right) replaced with Null

select o.FirstName, o.EmailPromotion, p.PersonID, p.AccountNumber, p.TerritoryID  
	from 
	[Person].[Person] as o left join [Sales].Customer as p  
	on p.PersonID = o.BusinessEntityID 

go

--right outer Join
--All right rows, matched left rows and non matched (left) replaced with Null

select p.BusinessEntityID, p.JobTitle, p.LoginID,  o.FirstName, o.EmailPromotion
	from 
	[HumanResources].[Employee] as p right join [Person].[Person] as o
	on p.BusinessEntityID = o.BusinessEntityID 

--full outer Join
--All matched rows and non matched replaced (left or right) rows with Null


select o.FirstName, o.EmailPromotion, p.PersonID, p.AccountNumber, p.TerritoryID  
	from 
	[Person].[Person] as o full outer join [Sales].Customer as p  
	on p.PersonID = o.BusinessEntityID 

go

--cross join
--cross pairs of all left rows with right rows

select top 20 d.DepartmentID as dID, d.GroupName, d.Name,
		e.DepartmentID as edID, e.StartDate
		
		from
		
		[HumanResources].[Department] as d cross join
		[HumanResources].[EmployeeDepartmentHistory] as e; 
			
--..........................................

--Date functions

select GETDATE() - 1 --subtract days from current date

select DATEPART(DD, GETDATE())

select DATEPART(MM, GETDATE())

select DATEPART(YYYY, GETDATE())

select DATEPART(dd, '2021-4-11')

select DATEPART(QUARTER, GETDATE())

select DATEPART(WEEKDAY, GETDATE())

select DATEPART(WEEK, GETDATE())

select DATEPART(HOUR, GETDATE())

select DATEPART(MINUTE, GETDATE())

select DATEPART(DAYOFYEAR, GETDATE())

--dateadd (add any datetime parameter in datetime e.g days, hours, months)

select DATEADD(day, 4, getdate())

select DATEADD(MINUTE, 4, getdate())


--datediff (get difference between datetime)


select ProductID, orderqty, DATEdiff(day, StartDate, EndDate) 
		from
		[Production].[WorkOrder];

select ProductID, orderqty, DATEdiff(HOUR, StartDate, EndDate) as time_diff
		from
		[Production].[WorkOrder];

select DATEADD(day, -(DATEPART(day, GETDATE()) -1), GETDATE())



--string functions

print 'Hello World'

select '  My text  '

select len('  My text ') --auo trim right side spaces

select LTRIM('  My text ')

select CONCAT(ReviewerName, ' - ',  EmailAddress) from [Production].[ProductReview]


select left(Comments, 5) from [Production].[ProductReview]

select upper(ReviewerName) from [Production].[ProductReview]

select len(Comments) from [Production].[ProductReview]

select substring(Comments, 2, 5) from [Production].[ProductReview]

select trim(Comments) from [Production].[ProductReview]


--Aggregations

select sum(LineTotal) from [Sales].[SalesOrderDetail]

select max([LineTotal]) from [Sales].[SalesOrderDetail]

select count([LineTotal]) from [Sales].[SalesOrderDetail]

select distinct count(CustomerID) from Sales.Customer;



-- important sql queries to get data from databse

-- get duplicate value
--https://chartio.com/learn/databases/how-to-find-duplicate-values-in-a-sql-table/

--get duplicate colum values from table

select s.SalesOrderID, count(s.SalesOrderID) from Sales.SalesOrderDetail as s
group by SalesOrderID having count(SalesOrderID) > 1

--get duplicate rows from table

select s.SalesOrderID, s.ProductID, count(*) 
	from Sales.SalesOrderDetail as s
	group by SalesOrderID, ProductID 
	having count(*) > 1

-- self join on table
--https://www.devart.com/dbforge/sql/sqlcomplete/self-join-in-sql-server.html#:~:text=The%20SELF%20JOIN%20in%20SQL,SELF%20JOIN%20aliases%20are%20used.

--The SELF JOIN in SQL, as its name implies, is used to join a table to itself. 
--This means that each row in a
--table is joined to itself and every other row in that table.

-- query hierarchial data within a table
select top 10 e1.* 
	from HumanResources.Employee as e1 
	inner join 
	HumanResources.Employee as e2
	on e1.BusinessEntityID = e2.BusinessEntityID
	where e1.OrganizationLevel = 1;

--compare rows within a table
select top 10 e1.* 
	from HumanResources.Employee as e1 
	inner join 
	HumanResources.Employee as e2
	on e1.BusinessEntityID > e2.BusinessEntityID;

-- set operations: both tables should be same number of columns with same data type
-- union: unite all rows vertically within no duplication
-- union all: unite all rows vertically within duplication
-- except: get rows which are not present in other table
-- intersaction: common rows between two tables

--https://www.c-sharpcorner.com/UploadFile/3194c4/set-operators-in-sql-server/#:~:text=more%20SELECT%20statements.-,Set%20operators%20are%20used%20to%20combine%20results%20from%20two%20or,rows%20from%20multiple%20SELECT%20queries.

--union

select p.ProductID, p.OrderQty, p.UnitPrice from Purchasing.PurchaseOrderDetail as p
union
select s.ProductID, s.OrderQty, s.UnitPrice from Sales.SalesOrderDetail as s

--union all
select BusinessEntityID 
from Person.Person union all
select BusinessEntityID from HumanResources.Employee

-- intersect
select BusinessEntityID 
from Person.Person intersect
select BusinessEntityID from HumanResources.Employee

--except
select p.ProductID, p.OrderQty, p.UnitPrice from Purchasing.PurchaseOrderDetail as p
except
select s.ProductID, s.OrderQty, s.UnitPrice from Sales.SalesOrderDetail as s

