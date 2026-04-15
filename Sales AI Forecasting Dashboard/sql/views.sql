-- Monthly trend for reporting
CREATE VIEW vw_MonthlySalesTrend AS
SELECT
    d.YearMonth,
    fs.Region,
    fs.Category,
    fs.Product,
    SUM(fs.Units) AS TotalUnits,
    AVG(fs.Price) AS AvgPrice,
    AVG(fs.DiscountPct) AS AvgDiscountPct,
    SUM(fs.Revenue) AS TotalRevenue
FROM FactSales fs
JOIN DimDate d
    ON fs.[Date] = d.[Date]
GROUP BY
    d.YearMonth,
    fs.Region,
    fs.Category,
    fs.Product;

-- Regional summary view
CREATE VIEW vw_SalesByRegion AS
SELECT
    fs.Region,
    SUM(fs.Revenue) AS TotalRevenue,
    SUM(fs.Units) AS TotalUnits,
    AVG(fs.Price) AS AvgPrice
FROM FactSales fs
GROUP BY fs.Region;

-- Product summary view
CREATE VIEW vw_SalesByProduct AS
SELECT
    fs.Category,
    fs.Product,
    SUM(fs.Revenue) AS TotalRevenue,
    SUM(fs.Units) AS TotalUnits,
    AVG(fs.Price) AS AvgPrice,
    AVG(fs.DiscountPct) AS AvgDiscountPct
FROM FactSales fs
GROUP BY
    fs.Category,
    fs.Product;
