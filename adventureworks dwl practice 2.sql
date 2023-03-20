
-- Datawarehouse Analysis 

use AdventureWorksDW2020;

-- How many active employees did we have on November 13th, 2013?
SELECT Count(1)
FROM [dbo].DimEmployee as emp
WHERE emp.HireDate <= '2013-11-13'
AND (
		emp.HireDate > '2013-11-13'
		OR
		HireDate IS NULL)

-- Join Sales and Product tables to retrieve product details;
SELECT Top 1000 *
FROM FactInternetSales s
INNER JOIN DimProduct p ON s.ProductKey = p.ProductKey --Returns results only where join conditions is true 


-- Select all sales from products that existed since January 1st, 2013;
SELECT *
FROM FactInternetSales s
INNER JOIN DimProduct p 
	ON s.ProductKey = p.ProductKey and p.StartDate > '2013-01-01'


-- Select Sales of specific product only; 
-- Get the sales of English Product Name ='Road-650 Black, 62'
SELECT * 
FROM FactInternetSales s
INNER JOIN DimProduct p ON s.ProductKey = p.ProductKey
WHERE p.EnglishProductName = 'Road-650 Black, 62'

--Get all orders from 2013 (Filter by year)
SELECT * 
FROM FactInternetSales s
INNER JOIN DimProduct p ON s.ProductKey = p.ProductKey
WHERE	s.OrderDate >= '2018-01-01'
AND		s.OrderDate <= '2020-12-31'

-- Select multiples values of English Product Names (filtering data using IN)
SELECT * 
FROM FactInternetSales s
INNER JOIN DimProduct p ON s.ProductKey = p.ProductKey
WHERE p.EnglishProductName IN(
		'Mountain-400-W Silver, 38',
		'Mountain-400-W Silver, 40',
		'Mountain-400-W Silver, 42',
		'Mountain-400-W Silver, 46')


-- Select all English Product Name starting with the word 'Mountain';
SELECT * 
FROM FactInternetSales s
INNER JOIN DimProduct p ON s.ProductKey = p.ProductKey
WHERE p.EnglishProductName LIKE 'Mountain%'


-- Aggregating data to undesratand more about product sales;
-- Select Total Sales for 2013
SELECT Sum(SalesAmount)
FROM FactInternetSales
WHERE OrderDate BETWEEN '2018-01-01' AND '2020-12-31' 



-- Select sales by category and Subcategory to understand sales distribuition
SELECT	cat.EnglishProductCategoryName 'Category'
	,	sub.EnglishProductSubcategoryName 'SubCategory'
	,	count(1) 'Count' -- returns the number of sales are there
	,	sum(s.SalesAmount) 'Sales' -- returns the total amount of sales
	,	avg(s.SalesAmount) 'Avg_SalesAmount' -- returns the average sales amount
	,	min(s.SalesAmount) 'Min_SalesAmount' -- returns the minimal sales amount
	,	max(s.SalesAmount) 'Max_SalesAmount' -- returns the maximum sales amount
FROM FactInternetSales s
LEFT JOIN DimProduct p ON s.ProductKey = p.ProductKey
LEFT JOIN DimProductSubcategory sub ON p.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN DimProductCategory cat ON sub.ProductCategoryKey = cat.ProductCategoryKey
GROUP BY	cat.EnglishProductCategoryName
		,	sub.EnglishProductSubcategoryName
ORDER BY	cat.EnglishProductCategoryName
		,	sub.EnglishProductSubcategoryName

-- Select only Sales for 2019 (Filter query)
SELECT	YEAR(s.OrderDate) 'Year'
	,	cat.EnglishProductCategoryName 'Category'
	,	sub.EnglishProductSubcategoryName 'SubCategory'
	,	count(1) 'Count' -- returns the number of sales are there
	,	sum(s.SalesAmount) 'Sales' -- returns the total amount of sales
	,	avg(s.SalesAmount) 'Avg_SalesAmount' -- returns the average sales amount
	,	min(s.SalesAmount) 'Min_SalesAmount' -- returns the minimal sales amount
	,	max(s.SalesAmount) 'Max_SalesAmount' -- returns the maximum sales amount
FROM FactInternetSales s
LEFT JOIN DimProduct p ON s.ProductKey = p.ProductKey
LEFT JOIN DimProductSubcategory sub ON p.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN DimProductCategory cat ON sub.ProductCategoryKey = cat.ProductCategoryKey
WHERE	YEAR(s.OrderDate) = 2019 -- used date function to parse year
GROUP BY	YEAR(s.OrderDate)
		,	cat.EnglishProductCategoryName
		,	sub.EnglishProductSubcategoryName
ORDER BY	cat.EnglishProductCategoryName
		,	sub.EnglishProductSubcategoryName

-- Select products sold in 2013, that were more than one million dollars in Total sales;
SELECT	YEAR(s.OrderDate) 'Year'
	,	cat.EnglishProductCategoryName 'Category'
	,	sub.EnglishProductSubcategoryName 'SubCategory'
	,	count(1) 'Count' -- returns the number of sales are there
	,	sum(s.SalesAmount) 'Sales' -- returns the total amount of sales
	,	avg(s.SalesAmount) 'Avg_SalesAmount' -- returns the average sales amount
	,	min(s.SalesAmount) 'Min_SalesAmount' -- returns the minimal sales amount
	,	max(s.SalesAmount) 'Max_SalesAmount' -- returns the maximum sales amount
FROM FactInternetSales s
LEFT JOIN DimProduct p ON s.ProductKey = p.ProductKey
LEFT JOIN DimProductSubcategory sub ON p.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN DimProductCategory cat ON sub.ProductCategoryKey = cat.ProductCategoryKey
WHERE	YEAR(s.OrderDate) = 2019 -- used date function to parse year
GROUP BY	YEAR(s.OrderDate)
		,	cat.EnglishProductCategoryName
		,	sub.EnglishProductSubcategoryName
HAVING		Sum(s.SalesAmount) > 1000000
ORDER BY	cat.EnglishProductCategoryName
		,	sub.EnglishProductSubcategoryName

-- Select each sales average for Group, Country and Region;
SELECT DISTINCT		t.SalesTerritoryGroup
				,	t.SalesTerritoryCountry
				,	t.SalesTerritoryRegion
				,	AVG(s.SalesAmount) OVER(PARTITION BY t.SalesTerritoryGroup) as 'GroupAvgSales'
				,	AVG(s.SalesAmount) OVER(PARTITION BY t.SalesTerritoryCountry) as 'CountryAvgSales'
				,	AVG(s.SalesAmount) OVER(PARTITION BY t.SalesTerritoryRegion) as 'RegionAvgSales'
FROM	FactInternetSales s
JOIN DimSalesTerritory t ON
	s.SalesTerritoryKey = t.SalesTerritoryAlternateKey
WHERE	YEAR(s.OrderDate) = 2019
ORDER BY 1, 2, 3

-- Select Sales Amount by Year (Using Sub-query to aggregate);
SELECT *
FROM (
		SELECT sum(SalesAmount) as 'Sales', YEAR(OrderDate) as 'Year'
		FROM FactInternetSales
		GROUP BY YEAR(OrderDate)
) YrSales

-- Select the Average Sales Amount across the years;
SELECT AVG(Sales) as 'AvgSales'
FROM (
		SELECT sum(SalesAmount) as 'Sales', YEAR(OrderDate) as 'Year'
		FROM FactInternetSales
		GROUP BY YEAR(OrderDate)
) YrSales

-- Check the existence of EnglishProductName = 'Wheels' in another table;
SELECT	EnglishProductName 'Product'
FROM	DimProduct p
WHERE	p.ProductSubcategoryKey IN
		(SELECT sc.ProductSubcategoryKey
		FROM DimProductSubcategory sc
		WHERE sc.EnglishProductSubcategoryName = 'Wheels')

-- Show 6 weeks rolling average of Weekly Sales for 2019;

-- First I created weekly sales totals
SELECT	Sum(s.SalesAmount) 'WeeklySales'
	,	DATEPART(ww, s.OrderDate) as 'WeekNum'
FROM	FactInternetSales s 
WHERE	YEAR(s.OrderDate) = 2019
GROUP BY	
		DATEPART(ww, s.OrderDate)
ORDER BY
		DATEPART(ww, s.OrderDate) ASC

-- Use previous sub-query as a source and calculate the moving average
SELECT		AVG(WeeklySales) OVER (ORDER BY WeekNum ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as AvgSales
		,	WeeklySales as 'Total Sales'
		,	WeekNum
FROM	( 
		SELECT	Sum(s.SalesAmount) 'WeeklySales'
	,	DATEPART(ww, s.OrderDate) as 'WeekNum'
FROM	FactInternetSales s 
WHERE	YEAR(s.OrderDate) = 2019
GROUP BY	
		DATEPART(ww, s.OrderDate)
		) AS s
GROUP BY WeekNum, WeeklySales
ORDER BY
		WeekNum

-- Show Year-to-date total sales;
SELECT		Sum(MonthlySales) OVER (ORDER BY SalesMonth ROWS UNBOUNDED PRECEDING) as YTDSales
		,	MonthlySales as 'MonthlySales'
		,	SalesMonth
FROM	( 
		SELECT	Sum(s.SalesAmount) 'MonthlySales'
	,	MONTH(s.OrderDate) as 'SalesMonth'
FROM	FactInternetSales s 
WHERE	YEAR(s.OrderDate) = 2019
GROUP BY	
		MONTH(s.OrderDate)
		) AS s
GROUP BY SalesMonth, MonthlySales
ORDER BY
		SalesMonth ASC

-- Show running total and year-to-date Sales partition by each years;
SELECT		Sum(MonthlySales) OVER (PARTITION BY SalesYear ORDER BY SalesMonth ROWS UNBOUNDED PRECEDING) as YTDSales
		,	MonthlySales as 'MonthlySales'
		,	SalesYear
		,	SalesMonth
FROM	( 
		SELECT	Sum(s.SalesAmount) 'MonthlySales'
	,	MONTH(s.OrderDate) as 'SalesMonth'
	,	YEAR(s.OrderDate) as 'SalesYear'
FROM	FactInternetSales s 
GROUP BY	
		MONTH(s.OrderDate)
	,	YEAR(s.OrderDate)
		) AS s
GROUP BY SalesMonth, SalesYear, MonthlySales
ORDER BY
		SalesYear, SalesMonth ASC

-- Show total sales monthly and the last day of the month
SELECT		EOMONTH(OrderDate) as 'Month'
		,	SUM(SalesAmount) as 'Sales'
FROM	FactInternetSales
GROUP BY	EOMONTH(OrderDate)
ORDER BY 1

-- Calculating the difference between two dates
-- Calculate the customer acquisition funnel 
-- How Long was it ago that each customer became a customer?, When was the day of their first purchase and how many days ago?)
SELECT		c.FirstName
		,	c.LastName
		,	c.DateFirstPurchase
		,	DATEDIFF(d,c.DateFirstPurchase,getdate()) as 'DaysSinceirstPurchase' 
FROM	DimCustomer c
ORDER BY 3 DESC

-- Aggregate the previous results to create a histogram;
-- Calculate the monthly average of customer tenure
SELECT		EOMONTH(c.DateFirstPurchase) as 'MonthOfFirstPurchase' -- What month did they become a customer?
		,	DATEDIFF(d,EOMONTH(c.DateFirstPurchase), getdate()) as 'DaysSinceFirstPurchase' -- How long have they been a customer?
		,	COUNT(1) as 'CustomerCount' -- How many customers are there for this month?
FROM DimCustomer c
GROUp BY EOMONTH(c.DateFirstPurchase)
ORDER BY 2 DESC

-- Check if the data is updated, find the latest monthly sales amount;
-- Get the most recent month
SELECT		d.CalendarYear
		,	d.MonthNumberOfYear
		,	mdt.IsMaxDate
		,	SUM(s.SalesAmount) as 'TotalSales'
FROM	DimDate d
JOIN FactInternetSales s ON d.DateKey = s.OrderDate
LEFT JOIN (
		SELECT		1 as 'IsMaxDate',
					MAX(OrderDate) as 'MaxDate'
		FROM	FactInternetSales
		) mdt
		ON		d.CalendarYear = YEAR(mdt.MaxDate) AND
				d.MonthNumberOfYear = MONTH(mdt.MaxDate)
GROUP BY	d.CalendarYear,
			d.MonthNumberOfYear,
			mdt.IsMaxDate
ORDER BY	1 DESC, 2 DESC

-- Using CTE to get an aggregate of an aggregate;
-- Show number of profitable weeks 
WITH Sales_CTE (Yr, WeekNum, WeeklySales)
AS 
(
	SELECT YEAR(OrderDate) as Yr, DATEPART(wk,OrderDate) as WeekNum, SUM(SalesAmount) as WeeklySales
	FROM FactInternetSales
	GROUP BY YEAR(OrderDate), DATEPART(wk,OrderDate)
)
SELECT *, CASE WHEN WeeklySales > 140000 THEN 1 ELSE 0 END as 'Profitable'
FROM Sales_CTE
ORDER BY 1,2
GO

-- Show the number of profitable weeks within a year
WITH Sales_CTE (Yr, WeekNum, WeeklySales)
AS 
(
	SELECT YEAR(OrderDate) as Yr, DATEPART(wk,OrderDate) as WeekNum, SUM(SalesAmount) as WeeklySales
	FROM FactInternetSales
	GROUP BY YEAR(OrderDate), DATEPART(wk,OrderDate)
)
SELECT Yr, SUM(CASE WHEN WeeklySales > 140000 THEN 1 ELSE 0 END) as 'Profitable'
FROM Sales_CTE
GROUP BY Yr
ORDER BY 1
GO

-- Year over Year Analysis
-- Show previous Year Sales 
WITH MonthlySales (YearNum, MonthNum, Sales)
AS
(	SELECT d.CalendarYear, d. MonthNumberOfYear, SUM(s.SalesAmount)
	FROM DimDate d
	JOIN FactInternetSales s ON DateKey = s.OrderDateKey
	GROUP BY d.CalendarYear, d.MonthNumberOfYear
)
-- Get current Year and join to CTE for previous year
SELECT		d.CalendarYear
		,	d.MonthNumberOFYear
		,	ms.Sales PrevSales
		,	SUM(s.SalesAmount) CurremtSales
FROM DimDate d
JOIN FactInternetSales s ON d.DateKey = s.OrderDateKey
JOIN MonthlySales ms ON
	d.CalendarYear-1 = ms.YearNum AND
	d.MonthNumberOfYear = ms.MonthNum
GROUP BY
		d.CalendarYear
	,	d.MonthNumberOfYear
	,	ms.Sales
ORDER BY
		1 DESC, 2 DESC

-- Calculate the % change Year over Year
WITH MonthlySales (YearNum, MonthNum, Sales)
AS
(	SELECT d.CalendarYear, d. MonthNumberOfYear, SUM(s.SalesAmount)
	FROM DimDate d
	JOIN FactInternetSales s ON DateKey = s.OrderDateKey
	GROUP BY d.CalendarYear, d.MonthNumberOfYear
)
-- Get current Year and join to CTE for previous year
SELECT		d.CalendarYear
		,	d.MonthNumberOFYear
		,	ms.Sales PrevSales
		,	SUM(s.SalesAmount) CurremtSales
		,	(SUM(s.SalesAmount) - ms.Sales) / SUM(s.SalesAmount) 'PctGrouth'
FROM DimDate d
JOIN FactInternetSales s ON d.DateKey = s.OrderDateKey
JOIN MonthlySales ms ON
	d.CalendarYear-1 = ms.YearNum AND
	d.MonthNumberOfYear = ms.MonthNum
GROUP BY
		d.CalendarYear
	,	d.MonthNumberOfYear
	,	ms.Sales
ORDER BY
		1 DESC, 2 DESC


--------------------------------------------------------------------


