use [AdventureWorksDW2020]

go
select top 10 c.FirstName, c.YearlyIncome, c.TotalChildren, g.City from DimCustomer c inner join DimGeography g on c.GeographyKey = g.GeographyKey
where c.Gender = 'M' and c.MaritalStatus = 'S' order by c.BirthDate 

go

select top 10 dp.EnglishProductName, st.SalesTerritoryCountry, fs.TotalProductCost, fs.SalesAmount ,

case when SalesAmount > 3399 then 'Trending' else 'Normal' end as Sales_category

from DimProduct as dp inner join FactInternetSales fs on dp.ProductKey = fs.ProductKey

inner join DimSalesTerritory st on st.SalesTerritoryKey = fs.SalesTerritoryKey and st.SalesTerritoryRegion = 'Northwest'

group by dp.EnglishProductName, st.SalesTerritoryCountry, fs.TotalProductCost, fs.SalesAmount order by fs.SalesAmount desc;

go

select top 5 * from DimSalesTerritory;

