
use AdventureWorks2019;


-- Merge Statement: Source and Traget table syncronize
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-merge/
/*
MERGE target_table USING source_table
ON merge_condition
WHEN MATCHED
    THEN update_statement
WHEN NOT MATCHED
    THEN insert_statement
WHEN NOT MATCHED BY SOURCE
    THEN DELETE;
*/
go
CREATE TABLE sales.category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);

INSERT INTO sales.category(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (2,'Comfort Bicycles',25000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',10000);


CREATE TABLE sales.category_staging (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);


INSERT INTO sales.category_staging(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',20000),
    (5,'Electric Bikes',10000),
    (6,'Mountain Bikes',10000);


select * from sales.category
select * from sales.category_staging
--
truncate table sales.category
truncate table sales.category_staging


-- merge play into action

MERGE sales.category t -- target
    USING sales.category_staging s -- source
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



-- Transactions
--Complete set of statement to perform a database task

/*
A transaction is a single unit of work that typically contains multiple T-SQL statements.

If a transaction is successful, the changes are committed to the database. However, if a transaction has an error, the changes have to be rolled back.

When executing a single statement such as INSERT, UPDATE, and DELETE, SQL Server uses the autocommit transaction. In this case, each statement is a transaction.
*/

CREATE TABLE invoices (
  id int IDENTITY PRIMARY KEY,
  customer_id int NOT NULL,
  total decimal(10, 2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE invoice_items (
  id int,
  invoice_id int NOT NULL,
  item_name varchar(100) NOT NULL,
  amount decimal(10, 2) NOT NULL CHECK (amount >= 0),
  tax decimal(4, 2) NOT NULL CHECK (tax >= 0),
  PRIMARY KEY (id, invoice_id),
  FOREIGN KEY (invoice_id) REFERENCES invoices (id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

BEGIN TRANSACTION;

	INSERT INTO invoices (customer_id, total)
	VALUES (100, 0);

	INSERT INTO invoice_items (id, invoice_id, item_name, amount, tax)
	VALUES (10, 1, 'Keyboard', 70, 0.08),
		   (20, 1, 'Mouse', 50, 0.08);

	UPDATE invoices
	SET total = (SELECT
	  SUM(amount * (1 + tax))
	FROM invoice_items
	WHERE invoice_id = 1);

COMMIT;

-- database snapshot: Current copy of database

CREATE DATABASE advworks_Snapshots 
ON ( NAME = AdventureWorks2019, FILENAME = 'D:\snapshots\advworks2019.ss')  
AS SNAPSHOT OF AdventureWorks2019; 

-- bulk insert: from file to db table data insertion

BULK INSERT Employees
FROM 'D:\data\employees.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
);

-- creating sequence: A list of numbers

CREATE SEQUENCE item_counter
    AS INT
    START WITH 10
    INCREMENT BY 10;

SELECT NEXT VALUE FOR item_counter;


INSERT INTO invoices
    (order_id,
    vendor_id,
    order_date)
VALUES
    (NEXT VALUE FOR item_counter, 1,'2019-04-30');


-- select into: create a brand new table and insert a data from existing table
go
SELECT    
    customer_id, 
    first_name, 
    last_name, 
    email
INTO 
    purchasing.customers
FROM    
    sales.customers
WHERE 
    state = 'CA';


-- database cursor: A database cursor is an object that enables traversal 
--over the rows of a result set. It allows you to process individual row returned by a query.

-- declare, open, fetch, close, dealocate

DECLARE 
    @product_name VARCHAR(MAX), 
    @list_price   DECIMAL;

DECLARE cursor_product CURSOR -- declare
FOR SELECT 
        product_name, 
        list_price
    FROM 
        production.products;

OPEN cursor_product;

-- main execution of curosr
FETCH NEXT FROM cursor_product INTO 
    @product_name, 
    @list_price;

WHILE @@FETCH_STATUS = 0 -- untill all rows are travsersed
    BEGIN
        PRINT @product_name + CAST(@list_price AS varchar);
        FETCH NEXT FROM cursor_product INTO 
            @product_name, 
            @list_price;
    END;

CLOSE cursor_product;

DEALLOCATE cursor_product;


-- Try Catch blocks to handel excptions:
--https://www.sqlservertutorial.net/sql-server-stored-procedures/sql-server-try-catch/

/*
Inside the CATCH block, you can use the following functions to get the detailed information on the error that occurred:

ERROR_LINE() returns the line number on which the exception occurred.
ERROR_MESSAGE() returns the complete text of the generated error message.
ERROR_PROCEDURE() returns the name of the stored procedure or trigger where the error occurred.
ERROR_NUMBER() returns the number of the error that occurred.
ERROR_SEVERITY() returns the severity level of the error that occurred.
ERROR_STATE() returns the state number of the error that occurred.
*/
go
CREATE PROC usp_divide(
    @a decimal,
    @b decimal,
    @c decimal output
) AS
BEGIN
    BEGIN TRY
        SET @c = @a / @b;
    END TRY
    BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END;
GO

DECLARE @r decimal;
EXEC usp_divide 10, 2, @r output;
PRINT @r;

	