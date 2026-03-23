-- Customer Churn AI Dashboard - SQL Data Model

CREATE TABLE DimDate (
    [Date] date PRIMARY KEY,
    [Year] int,
    [Month] int,
    [MonthName] varchar(3),
    [Quarter] varchar(2),
    [YearMonth] varchar(7),
    [YearMonthSort] int
);

CREATE TABLE FactCustomerChurn (
    CustomerID int PRIMARY KEY,
    SignupDate date NOT NULL,
    Region varchar(50) NOT NULL,
    CustomerSegment varchar(50) NOT NULL,
    ContractType varchar(50) NOT NULL,
    InternetService varchar(50) NOT NULL,
    PaymentMethod varchar(50) NOT NULL,
    TenureMonths int NOT NULL,
    MonthlyCharges decimal(10,2) NOT NULL,
    SupportTickets90D int NOT NULL,
    LatePayments12M int NOT NULL,
    PaperlessBilling bit NOT NULL,
    StreamingService bit NOT NULL,
    TechSupport bit NOT NULL,
    SeniorCitizen bit NOT NULL,
    Dependents bit NOT NULL,
    Partner bit NOT NULL,
    ChurnProbability decimal(9,4) NOT NULL,
    ChurnFlag bit NOT NULL,
    RecommendedAction varchar(200) NOT NULL
);
