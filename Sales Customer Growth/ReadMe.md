# Sales & Customer Growth Intelligence

A Power BI portfolio project that combines sales, profitability, customer retention, churn-risk prediction, regional and channel analysis, and future revenue forecasting in one interactive executive dashboard.

> **Data note:** The project currently uses synthetic Excel data. It contains no real customer, financial, or confidential business information.

## Project overview

The report helps business leaders answer six questions:

1. How much revenue and gross profit is the business generating?
2. Are customers growing, returning, or becoming at risk of churn?
3. Which products generate the most revenue and margin?
4. Which regions and sales channels perform best?
5. What revenue is forecast for the next six months?
6. How should users interpret the KPIs, predictions, and forecast limitations?

## Dashboard pages

### 1. Revenue Overview

Executive summary of revenue, gross profit, gross margin, and year-over-year growth.

Key visuals:

- Total Revenue, Gross Profit, Gross Margin, and Revenue Growth KPI cards
- Monthly Revenue and Gross Profit trend
- Revenue by Product Category
- Revenue by Region
- Revenue by Customer Segment
- Product Profitability detail table

### 2. Customer Growth & Retention

Customer acquisition, returning-customer performance, lifetime value, and churn-risk analysis.

Key visuals:

- Active, New, Returning, and At-Risk Customer KPI cards
- Customer Retention Rate
- New and Active Customer trend
- New versus Returning Customers
- Customers by Churn Risk
- Customer Lifetime Revenue by Segment
- Customer Retention Worklist

### 3. Product & Sales Performance

Product-level revenue, profitability, discount impact, units, and order performance.

Key visuals:

- Revenue, Gross Profit, Gross Margin, Orders, Units Sold, and Average Order Value cards
- Revenue and Gross Profit by Product Category
- Top 10 Products by Revenue
- Gross Margin by Product
- Discount Impact on Product Margin
- Revenue and Gross Profit by Sales Channel
- Product Performance Detail table

### 4. Regional & Channel Performance

Regional contribution and channel-mix analysis across Direct Sales, Partner, and Web channels.

Key visuals:

- Revenue and Gross Profit by Region
- Channel Revenue Mix by Region
- Gross Margin by Region and Channel
- Regional Revenue Heatmap
- Monthly Revenue Trend by Sales Channel
- Regional and Channel Performance Detail

### 5. Sales Forecasting

Historical-versus-forecast revenue analysis for January through June 2026.

Key visuals:

- Last 12 Months Actual Revenue
- Next-period Forecast Revenue
- Forecast Growth and Average Monthly Forecast
- Actual versus Forecast Monthly Revenue
- Monthly Revenue Forecast
- Cumulative Forecast Revenue
- Monthly Forecast Schedule

The current source forecast is approximately $919K per month, producing a six-month cumulative forecast of approximately $5.51M.

### 6. Definitions & Help

User documentation covering:

- KPI definitions
- Customer, churn, product, region, channel, and forecast terminology
- Report navigation
- Filter behavior and limitations
- Responsible-AI guidance

## Current headline results

With the full January 2024–December 2025 historical period selected, the synthetic dataset produces approximately:

| Metric | Result |
|---|---:|
| Total Revenue | $20.7M |
| Gross Profit | $10.8M |
| Gross Margin | 52.0% |
| Total Orders | 7K |
| Units Sold | 46K |
| Active Customers | 998 |
| New Customers | 242 |
| Returning Customers | 756 |
| Retention Rate | 75.8% |
| High-Risk Customers | 17 |
| Six-Month Forecast | Approximately $5.51M |

Values change with report filters, except model-wide or forecast values that do not contain the selected business dimension.

## Data source
## Excel
The current report imports an Excel workbook. A recommended filename is:

```text
Sales_Customer_Growth_Data.xlsx
```

The workbook contains these logical tables:

| Table | Purpose | Example fields |
|---|---|---|
| `Orders` | Sales fact table | OrderKey, OrderDate, CustomerKey, ProductKey, Channel, Quantity, Revenue, Cost, GrossProfit, DiscountPct |
| `Customers` | Customer dimension | CustomerKey, CustomerName, JoinDate, Region, Segment |
| `Products` | Product dimension | ProductKey, ProductName, Category, ListPrice, UnitCost |
| `CustomerPredictions` | Customer-level ML output | CustomerKey, ChurnProbability, ChurnRisk, ActualChurnFlag, LifetimeRevenue, OrderCount, RecencyDays |
| `RevenueForecast` | Monthly forecast output | Month, ForecastRevenue, ForecastType |
| `ModelMetrics` | Overall model results | Metric, Value |

Excel requirements:

- One header row per worksheet
- No merged cells
- Unique keys in Customers and Products
- Numeric Revenue, Cost, GrossProfit, Quantity, DiscountPct, and probability columns
- Date-formatted OrderDate, JoinDate, and forecast Month fields
- Consistent Low, Medium, and High churn-risk labels

## Data source
## SQL Server

## Included Files

- `sql/schema.sql` - SQL Server star-schema tables for dates, products, regions, and sales transactions.
- `sql/views.sql` - Reporting views for monthly sales trends, regional performance, and product performance.
- `python_ml/train_sales_forecast_model.py` - Python ML training script for revenue prediction.

## Use Cases

- Load the sales dataset into SQL Server.
- Use SQL Server as the data source for Power BI.
- Create reusable reporting views for Power BI visuals.
- Train a Python machine-learning model using sales, pricing, product, region, and time features.
- Extend the project with forecast and scenario-analysis outputs.

---

# SQL Server Data Model

The SQL model uses a simple reporting structure consisting of:

- `DimDate` - calendar/date attributes used for time intelligence and monthly reporting.
- `DimProduct` - product and category information.
- `DimRegion` - sales region information.
- `FactSales` - transactional sales facts including units, price, discount percentage, and revenue.

## schema.sql

```sql
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
```

---

# SQL Reporting Views

The project includes three Power BI-friendly SQL views.

### vw_MonthlySalesTrend

Provides monthly revenue, units, average price, and average discount by region, category, and product. This view can support historical sales trend and forecasting visuals.

### vw_SalesByRegion

Summarizes total revenue, total units, and average price by region. This can be used for **Revenue by Region** and regional performance visuals.

### vw_SalesByProduct

Summarizes revenue, units, average price, and average discount by product and category. This can be used for the **Product Performance Matrix** and product-level analysis.

## views.sql

```sql
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
```

---

# Suggested SQL Server Setup

1. Create a SQL Server database, for example `SalesForecastingDB`.
2. Run `sql/schema.sql` to create the tables.
3. Load the sales CSV data into the corresponding SQL tables.
4. Populate the dimension tables before loading `FactSales` so the foreign-key values exist.
5. Run `sql/views.sql` after the tables contain data.
6. In Power BI Desktop, select **Get Data > SQL Server** and connect to the database.
7. Load either the base tables for a star-schema model or the reporting views for simplified report development.

## Suggested Power BI Relationships

```text
DimDate[Date]       1  ----  *  FactSales[Date]
DimProduct[Product] 1  ----  *  FactSales[Product]
DimRegion[Region]   1  ----  *  FactSales[Region]
```

Use single-direction filtering from the dimension tables to `FactSales`.

---

# Python ML

The `python_ml/train_sales_forecast_model.py` script reads `sales_sample.csv`, creates time-based features, encodes categorical fields, scales numeric fields, and trains a `RandomForestRegressor` to predict revenue.

The current model uses these features:

- Region
- Category
- Product
- Units
- Price
- DiscountPct
- Year
- Month
- Quarter
- DayOfWeek

The trained model is saved as:

```text
sales_forecast_model.joblib
```

## Data model

The model follows a star-schema design centered on `Orders`.

```text
Customers[CustomerKey]  1 ─── *  Orders[CustomerKey]
Products[ProductKey]    1 ─── *  Orders[ProductKey]
Date[Date]              1 ─── *  Orders[OrderDate]
Customers[CustomerKey]  1 ─── 1  CustomerPredictions[CustomerKey]
Date[Date]              1 ─── *  RevenueForecast[Month]
```

Recommended settings:

- Single-direction filters from dimension tables to fact tables
- Active Date-to-Orders relationship
- Active Date-to-RevenueForecast relationship when supported
- `ModelMetrics` disconnected because it represents model-wide results
- `Date[Month Year]` sorted by `Date[Month Year Sort]`

The forecast measure also uses `TREATAS` so the shared Date axis can filter monthly forecasts reliably.

## Date table

The Date table covers both historical orders and future forecast months.

```DAX
Date =
VAR FirstOrderDate =
    MINX('Orders', 'Orders'[OrderDate])
VAR LastOrderDate =
    MAXX('Orders', 'Orders'[OrderDate])
VAR LastForecastDate =
    MAXX('RevenueForecast', 'RevenueForecast'[Month])
RETURN
    ADDCOLUMNS(
        CALENDAR(
            FirstOrderDate,
            MAX(LastOrderDate, LastForecastDate)
        ),
        "Year", YEAR([Date]),
        "Month Number", MONTH([Date]),
        "Month", FORMAT([Date], "MMM"),
        "Month Year", FORMAT([Date], "MMM yyyy"),
        "Month Year Sort", YEAR([Date]) * 100 + MONTH([Date]),
        "Quarter", "Q" & FORMAT([Date], "Q")
    )
```

## Core DAX measures

### Revenue and profitability

```DAX
Total Revenue =
SUM('Orders'[Revenue])

Total Cost =
SUM('Orders'[Cost])

Gross Profit =
SUM('Orders'[GrossProfit])

Gross Margin % =
DIVIDE([Gross Profit], [Total Revenue], 0)

Total Orders =
DISTINCTCOUNT('Orders'[OrderKey])

Units Sold =
SUM('Orders'[Quantity])

Average Order Value =
DIVIDE([Total Revenue], [Total Orders], 0)

Average Discount =
AVERAGE('Orders'[DiscountPct])
```

### Customer growth and retention

```DAX
Active Customers =
DISTINCTCOUNT('Orders'[CustomerKey])

New Customers =
CALCULATE(
    DISTINCTCOUNT('Customers'[CustomerKey]),
    TREATAS(
        VALUES('Date'[Date]),
        'Customers'[JoinDate]
    )
)

Returning Customers =
MAX([Active Customers] - [New Customers], 0)

Customer Retention Rate =
DIVIDE([Returning Customers], [Active Customers], 0)

At-Risk Customers =
CALCULATE(
    DISTINCTCOUNT('CustomerPredictions'[CustomerKey]),
    'CustomerPredictions'[ChurnRisk] = "High"
)
```

### Product and channel analysis

```DAX
Product Revenue Rank =
RANKX(
    ALLSELECTED('Products'[ProductName]),
    [Total Revenue],
    ,
    DESC,
    DENSE
)

Revenue per Customer =
DIVIDE([Total Revenue], [Active Customers], 0)

Profit per Order =
DIVIDE([Gross Profit], [Total Orders], 0)

Channel Revenue Share =
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        REMOVEFILTERS('Orders'[Channel])
    ),
    0
)
```

### Sales forecasting

```DAX
Forecast Revenue by Date =
CALCULATE(
    SUM('RevenueForecast'[ForecastRevenue]),
    TREATAS(
        VALUES('Date'[Date]),
        'RevenueForecast'[Month]
    )
)

Cumulative Forecast Revenue =
VAR CurrentDate =
    MAX('Date'[Date])
RETURN
    CALCULATE(
        [Forecast Revenue by Date],
        FILTER(
            ALLSELECTED('Date'[Date]),
            'Date'[Date] <= CurrentDate
        )
    )
```

## Conditional formatting

The dashboard uses consistent business rules:

- Revenue data bars: `#1F6E8C`
- Positive Gross Profit: `#2E8B57`
- Negative Gross Profit: `#C0392B`
- Forecast: `#6043D5`
- Warning/medium performance: `#E3A008`
- Low margin or high risk: red
- Strong margin or low risk: green

Example margin-color measure:

```DAX
Gross Margin Color =
SWITCH(
    TRUE(),
    [Gross Margin %] < 0.30, "#C0392B",
    [Gross Margin %] < 0.50, "#E3A008",
    "#2E8B57"
)
```

## Slicer strategy

Historical pages use synchronized slicers for:

- Order Date
- Region
- Customer Segment
- Product Category
- Sales Channel

The forecasting table contains Month, ForecastRevenue, and ForecastType only. Therefore, Region, Segment, Category, and Channel slicers do not filter forecast values. The forecasting page uses the shared Date axis and forecast-specific logic instead.

## Navigation and interaction

- A page navigator connects all six report pages.
- In Power BI Desktop, use `Ctrl + click` to activate navigator buttons.
- In Power BI Service Reading view, use a normal click.
- Selecting a visual cross-filters other visuals on the page.
- Selecting blank canvas space clears the current visual selection.

## Validation checks

Before publishing, verify:

- Gross Profit equals Total Revenue minus Total Cost.
- Gross Margin equals Gross Profit divided by Total Revenue.
- New Customers plus Returning Customers equals Active Customers for the full selected period.
- Revenue by category, region, segment, and channel reconciles to Total Revenue.
- Product and regional ranks change correctly with slicers.
- The forecast appears only during January–June 2026.
- Monthly forecast values reconcile to cumulative forecast revenue.
- Forecast and model-wide metrics do not appear to respond to unsupported slicers.
- Month Year sorts chronologically rather than alphabetically.

## Forecast limitations

- The forecast source contains approximately equal monthly revenue values from January through June 2026.
- A flat forecast does not capture seasonality, promotions, macroeconomic shifts, or regional/product differences.
- The forecast table does not contain Region, Segment, Category, Channel, prediction intervals, or confidence bounds.
- Forecast values should be treated as decision support, not guaranteed revenue.

Recommended future improvements:

- Add lower and upper confidence intervals.
- Produce forecasts by region, channel, category, and product.
- Backtest predictions against withheld historical months.
- Add MAE, RMSE, MAPE, and forecast-bias monitoring.
- Retrain the model when actual performance materially diverges from forecast.

## Responsible AI

Churn predictions and revenue forecasts support human decision-making. They should not independently determine customer treatment, pricing, marketing eligibility, or financial commitments.

Users should:

- Review predictions alongside recent customer activity and business knowledge.
- Monitor false positives and false negatives in churn classifications.
- Evaluate potential bias across customer segments and regions.
- Monitor model drift and data-quality changes.
- Document model versions, thresholds, training periods, and evaluation results.
- Protect customer privacy when replacing synthetic data with production data.

## Skills demonstrated

- Power BI report development
- Star-schema data modeling
- DAX measures and time intelligence
- Customer acquisition and retention analytics
- Churn-risk integration
- Product profitability analysis
- Regional and channel performance analysis
- Revenue forecasting
- Conditional formatting and executive visualization design
- Slicer synchronization and page navigation
- Data reconciliation and model validation
- Responsible-AI documentation

## Future enhancements

- Customer cohort-retention analysis
- Repeat-purchase frequency and RFM segmentation
- Customer and product drill-through pages
- What-if parameters for price, cost, and discount scenarios
- Forecast confidence intervals
- Churn-model performance monitoring
- Automated Excel or SQL refresh
- Row-level security by region
- Power BI Service deployment pipeline
- SQL Server, Fabric Lakehouse, or warehouse-backed production model


