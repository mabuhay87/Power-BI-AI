-- Sales Forecasting Dashboard - SQL Data Model

CREATE TABLE DimDate (
    [Date] date PRIMARY KEY,
    [Year] int,
    [Month] int,
    [MonthName] varchar(3),
    [Quarter] varchar(2),
    [YearMonth] varchar(7),
    [YearMonthSort] int
);

CREATE TABLE DimProduct (
    Product varchar(100) PRIMARY KEY,
    Category varchar(100) NOT NULL
);

CREATE TABLE DimRegion (
    Region varchar(50) PRIMARY KEY
);

CREATE TABLE FactSales (
    SalesID int IDENTITY(1,1) PRIMARY KEY,
    [Date] date NOT NULL,
    Region varchar(50) NOT NULL,
    Category varchar(100) NOT NULL,
    Product varchar(100) NOT NULL,
    Units int NOT NULL,
    Price decimal(18,2) NOT NULL,
    DiscountPct decimal(9,4) NOT NULL,
    Revenue decimal(18,2) NOT NULL,
    CONSTRAINT FK_FactSales_DimDate FOREIGN KEY ([Date]) REFERENCES DimDate([Date]),
    CONSTRAINT FK_FactSales_DimRegion FOREIGN KEY (Region) REFERENCES DimRegion(Region),
    CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (Product) REFERENCES DimProduct(Product)
);
