
USE AdventureWorks2019;

--views: logical table predefined select statement to extract data 

GO
CREATE VIEW Top_sales AS 

SELECT TOP 10 * FROM Sales.SalesOrderHeader ORDER BY TotalDue;

GO
SELECT * FROM Top_sales;

GO
DROP VIEW Top_sales;

--also can apply joins to fect data from multiple tables


------------------------------------------------------

--triggers: type of procedure to (save log, send email or rollback transaction)
--which automatically call when create, insert, update or delete data from objects

-- table level: insert, update or delete data from table
-- database level: create or drop new table

SELECT * FROM [HumanResources].[Shift];

GO

--create a tirgger to describe the logic of auto calling
CREATE TRIGGER shift_entry_avoid ON [HumanResources].[Shift]
AFTER INSERT --update/delete
AS
BEGIN 
PRINT 'Insert is not allowed, you need approval'
ROLLBACK TRANSACTION
END
GO

--test the trigger

INSERT INTO HumanResources.Shift (Name, StartTime, EndTime, ModifiedDate) 
VALUES('Casual', '17:00:00.0000000', '01:00:00.0000000', GETDATE())

/*
output: Insert is not allowed, you need approval

The transaction ended in the trigger. The batch has been aborted.
*/

GO
	-- database level trigger --

CREATE TRIGGER new_table_creation_avoid ON DATABASE AFTER
CREATE_TABLE AS 
BEGIN 
PRINT 'table creation is not allowed, you need approval'
ROLLBACK TRANSACTION
END

GO

--test 

CREATE TABLE demo_table (var1 VARCHAR(10))

/*
output: table creation is not allowed, you need approval
The transaction ended in the trigger. The batch has been aborted.

*/

GO

DROP TRIGGER new_table_creation_avoid;

GO

----------------------------------------------

-- Stored Procedures: Set of saved sql statements to interact
--with database obejcts for inserting, updating, ,deleting, validating
-- and extracting data from database.

--provides security layer to database against direct acess of database to users

CREATE PROCEDURE check_total_customer AS 
SET NOCOUNT ON -- no count determine how many rows effected/selected.
SELECT * FROM [Sales].[Customer];

GO

CREATE PROCEDURE check_total_employees AS 
SET NOCOUNT OFF -- no count determine how many rows effected/selected.
SELECT * FROM [HumanResources].[Employee];

GO

--parameterized stored proc

-- input parameter
CREATE PROCEDURE get_employees 
@job_title nVARCHAR(50)
-- for default parameter
--@job_title nVARCHAR(50) = '@job_title nVARCHAR(50)'
AS 
SET NOCOUNT OFF -- no count determine how many rows effected/selected.
SELECT * FROM [HumanResources].[Employee] WHERE JobTitle = @job_title;

GO
-- output parameter to return scalr value
CREATE PROCEDURE get_employee_hire_date 
@hire_date DATE OUTPUT

AS 

SET @hire_date = (SELECT TOP 1 [HireDate]  FROM [HumanResources].[Employee]
WHERE JobTitle = 'Senior Tool Designer'  ORDER BY HireDate ASC)



--test/call

EXEC check_total_customer;

GO

EXEC check_total_employees

GO


EXEC get_employees @job_title = 'Design Engineer'
EXEC get_employees 'Senior Tool Designer'

--exec proc and get output
DECLARE @output DATE
EXEC get_employee_hire_date @output OUTPUT
SELECT @output
GO

--drop

DROP PROC check_total_customer;

GO

--------------------------------------------------

-- User defined function: set of rutines to perform temp calcualtion on given 
--data or implement some logical/comparison operation and return scalr or tabular results.

SELECT * FROM sales.SalesTerritory;
GO
CREATE FUNCTION get_sales_ytd()
RETURNS money
AS BEGIN
DECLARE @total_money MONEY
SELECT @total_money = SUM(SalesYTD) FROM sales.SalesTerritory;
RETURN @total_money;

END

GO

CREATE FUNCTION get_group_sales_ytd(@group VARCHAR(50))
RETURNS money
AS BEGIN
DECLARE @total_money MONEY
SELECT @total_money = SUM(SalesYTD) FROM sales.SalesTerritory
WHERE [Group] = @group;
RETURN @total_money;

END

go

DECLARE @total_money_output MONEY
SELECT @total_money_output = dbo.get_group_sales_ytd('North America')

PRINT @total_money_output


GO

SELECT * FROM Sales.SalesOrderHeader;

GO

CREATE FUNCTION get_sales_top_records(@topr INTEGER)
RETURNS TABLE
AS 
RETURN 
SELECT TOP(@topr) CustomerID, SubTotal, TaxAmt FROM Sales.SalesOrderHeader;

GO

SELECT customerid, SubTotal FROM get_sales_top_records(10);

GO

--test
DECLARE @total_money_output MONEY
SELECT @total_money_output = dbo.get_sales_ytd()

PRINT @total_money_output

-- drop function

DROP FUNCTION get_sales_top_records

------------------------------------------------------------

-- Error Handeling

--USING TRANSACTION COMMIT AND ROLLBACK
--@error number
--raise error for custom message
--transaction within a try catch 

SELECT * FROM [Sales].[SalesTerritory]

BEGIN TRANSACTION

UPDATE Sales.SalesTerritory 
SET CostYTD = 1 WHERE TerritoryID = 1;



DECLARE @result VARCHAR(50)
SET @result = @@error
IF(@result = 0)
BEGIN
	PRINT 'operation sucsessful'
	COMMIT TRANSACTION

END
ELSE
BEGIN
	PRINT 'operation sucsessful'
	ROLLBACK TRANSACTION
END

--for custom message
RAISERROR('custom message', 16, 1)

BEGIN TRY

BEGIN TRANSACTION

UPDATE Sales.SalesTerritory 
SET CostYTD = 1 WHERE TerritoryID = 1;
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	PRINT 'faield'
	ROLLBACK TRANsaction
END CATCH

GO
------------------------------

--Grouping, rollback and cube for aggeraged results against 
--different combinations of categorical cols


--Grouping sets: The GROUPING SETS defines multiple grouping sets in the same query.

--https://www.sqlservertutorial.net/sql-server-basics/sql-server-grouping-sets/

SELECT  Name, CountryRegionCode, [Group], SUM(SalesYTD)
FROM Sales.SalesTerritory 
GROUP BY GROUPING SETS (
	(Name), 
	(name, CountryRegionCode), 
	(Name, CountryRegionCode, [Group])
)

--ROLLUP (grouping sets: short method) generates a result set 
--that represents aggregates for a hierarchy of values in the selected columns.

--https://www.sqlservertutorial.net/sql-server-basics/sql-server-rollup/

SELECT  Name, CountryRegionCode, [Group], SUM(SalesYTD)
FROM Sales.SalesTerritory 
GROUP BY ROLLUP (

	Name, CountryRegionCode, [Group]
)


--CUBE generates a result set that represents aggregates for all combinations of values in the selected columns.


--https://www.sqlservertutorial.net/sql-server-basics/sql-server-cube/

SELECT Name, CountryRegionCode, [Group], SUM(SalesYTD)
FROM Sales.SalesTerritory 
GROUP BY CUBE (
	 
	Name, CountryRegionCode, [Group]
)

--------------------------------------------------------------
---------------------------------------------------------

--Ranking and bucketing:

--2nd last value using dense rank to avoid duplicate values
SELECT s.TotalDue FROM 

(SELECT TotalDue, dense_RANK() 
OVER(ORDER BY TotalDue DESC) AS 'drank'
FROM Sales.SalesOrderHeader) AS s
WHERE s.drank = 2

GO

--2nd last value using offset row
SELECT c.TotalDue 
FROM Sales.SalesOrderHeader AS c                    
ORDER BY c.TotalDue DESC
OFFSET 1 ROW
FETCH FIRST 1 ROW ONLY ; 

SELECT TOP 10 * FROM Sales.SalesOrderHeader ORDER BY TotalDue DESC;

--182018.6272

SELECT PostalCode,
ROW_NUMBER() OVER
(ORDER BY PostalCode) AS 'RowNumber',
RANK() OVER
(ORDER BY PostalCode) AS 'Rank',
DENSE_RANK() OVER
(ORDER BY PostalCode) AS 'DRank',
NTILE(4) OVER
(ORDER BY PostalCode) AS 'Ntile',
PERCENT_RANK() OVER
(ORDER BY PostalCode) AS 'Percent_Rank'
 FROM Person.Address 
WHERE PostalCode IN ('98011', '98019', '98251', '98256');


SELECT * FROM Person.Address;

-- Lead and Lag for next and previous rows values

SELECT OrderDate, TotalDue,
       LAG(TotalDue, 1) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS lag,
       LEAD(TotalDue, 1) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS lead
  FROM Sales.SalesOrderHeader
 WHERE DueDate < '2019-01-08'
 ORDER BY TotalDue


 -- partitioning aggeragtes

 SELECT OrderDate, TotalDue,
       sum(TotalDue) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS total,
       avg(TotalDue) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS mean,
	   min(TotalDue) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS lowest,
	   max(TotalDue) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS highest,
	   count(TotalDue) OVER
         (PARTITION BY OrderDate ORDER BY TotalDue) AS counts
  FROM Sales.SalesOrderHeader
 WHERE DueDate < '2019-01-08'
 ORDER BY OrderDate ASC, TotalDue


-----------------------------------------------------

--Partitions: To optimize the quering scanning process

--only support huge amount of data so sql enterprise support only

--first create a fucntion
CREATE PARTITION FUNCTION customer_part_funct(int) AS
RANGE RIGHT FOR VALUES (1000, 5000, 10000, 15000)

--then create partition sceme for that function

CREATE PARTITION SCHEME customer_part_scheme AS 
PARTITION customer_part_funct TO
(group1, group2, group3, group4, group5)

-- then add filegroups and files to relate filegroups in database properties

--test

--create table
CREATE TABLE partition (emid INT IDENTITY (1, 1) not null,
hdate DATE null) ON customer_part_scheme (emid)

--add data
DECLARE @i int;
WHILE(@i<10000)
BEGIN
INSERT INTO partition (hdate) VALUES (GETDATE())
SET @i=@i+1;

END

--check
SELECT $PARTITION.customer_part_funct(emid) AS 'partiton_number'
FROM partition;


-----------------------------------------------
--dynamic quries to select cols to get data

SELECT CountryRegionCode, [Group], SalesYTD FROM sales.SalesTerritory;

DECLARE @sqlstring VARCHAR(2000)
SET @sqlstring = 'select CountryRegionCode, [Group], '
SET @sqlstring = @sqlstring + 'SalesYTD FROM sales.SalesTerritory'

PRINT(@sqlstring)
exec (@sqlstring)

-------------------------------------------------

--Merge: combine data into one table  based on source and target (use for data staging)

--https://www.sqlservertutorial.net/sql-server-basics/sql-server-merge/

/*
MERGE target_table USING source_table
ON merge_condition
WHEN MATCHED
    THEN update_statement
WHEN NOT MATCHED by target
    THEN insert_statement
WHEN NOT MATCHED BY SOURCE
    THEN DELETE;
*/

MERGE sales.category t 
    USING sales.category_staging s
ON (s.category_id = t.category_id)
WHEN MATCHED
    THEN UPDATE SET 
        t.category_name = s.category_name,
        t.amount = s.amount
WHEN NOT MATCHED BY TARGET 
    THEN INSERT (category_id, category_name, amount)
         VALUES (s.category_id, s.category_name, s.amount)
WHEN NOT MATCHED BY SOURCE 
    THEN DELETE;


--Pivoting: aggregate values against categorical attributes in rows and cols

/*
SQL Server PIVOT operator rotates a table-valued expression. It turns the unique values in one column into multiple columns in the output and performs aggregations on any remaining column values.

You follow these steps to make a query a pivot table:

First, select a base dataset for pivoting.
Second, create a temporary result by using a derived table or common table expression (CTE)
Third, apply the PIVOT operator.
*/

SELECT * FROM   
(
    SELECT 
        c.Name, 
        p.ProductID
    FROM 
        Production.Product p
        INNER JOIN [Production].[ProductCategory] c 
            ON c.ProductCategoryID = p.ProductID
) t 
PIVOT(
    COUNT(ProductID) 
    FOR name IN (
        [Children Bicycles], 
        [Comfort Bicycles], 
        [Cruisers Bicycles], 
        [Cyclocross Bicycles], 
        [Electric Bikes], 
        [Mountain Bikes], 
        [Road Bikes])
) AS pivot_table;

-- sequence: set of numeric values

CREATE SEQUENCE item_counter
    AS INT
    START WITH 10
    INCREMENT BY 10;

--usecase to add data into table
CREATE SCHEMA procurement;
GO
--Code language: SQL (Structured Query Language) (sql)
--Next, create a new table named orders:

CREATE TABLE procurement.purchase_orders(
    order_id INT PRIMARY KEY,
    vendor_id int NOT NULL,
    order_date date NOT NULL
);
--Code language: SQL (Structured Query Language) (sql)
--Then, create a new sequence object named order_number that starts with 1 and is incremented by 1:

CREATE SEQUENCE procurement.order_number 
AS INT
START WITH 1
INCREMENT BY 1;

INSERT INTO procurement.purchase_orders
    (order_id,
    vendor_id,
    order_date)
VALUES
    (NEXT VALUE FOR procurement.order_number,1,'2019-04-30');

/* The application requires sharing a sequence of numbers across multiple tables or multiple columns within the same table.
The application requires to restart the number when a specified value is reached. 

*/

SELECT 
    * 
FROM 
    sys.sequences;

------------------------------------------------------------------

-- Self Join: Join on same table

-- Using SELF JOIN to query hierarchical data
SELECT
  e.FirstName + ' ' + e.LastName Employee
  ,m.FirstName + ' ' + m.LastName Manager
FROM Employee e
INNER JOIN Employee m
	ON m.EmployeeID = e.ManagerID
ORDER BY Manager;
                                    

--Using SELF JOIN to compare rows in the same table
SELECT
  e1.City
  ,e1.FirstName + ' ' + e1.LastName AS employee_1
  ,e2.LastName + ' ' + e2.FirstName AS employee_2
FROM Employee e1
INNER JOIN Employee e2
	ON e1.EmployeeID > e2.EmployeeID
	AND e1.City = e2.City
ORDER BY e1.City,
employee_1,
employee_2;
                
				