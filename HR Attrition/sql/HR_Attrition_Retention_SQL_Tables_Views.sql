/*
===============================================================================
 HR Attrition & Retention Intelligence Dashboard
 SQL Server Database Objects
===============================================================================
 Tables:
   dbo.Employees
   dbo.AttritionPredictions
   dbo.ModelMetrics
   dbo.DimDate

 Views:
   dbo.vw_EmployeeAttritionAnalytics
   dbo.vw_DepartmentAttritionSummary
   dbo.vw_JobRoleAttritionSummary
   dbo.vw_WorkforceMovement
   dbo.vw_RetentionPriorities
   dbo.vw_ElevatedRiskEmployees
   dbo.vw_ModelOutcomeSummary
===============================================================================
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID('dbo.AttritionPredictions', 'U') IS NOT NULL DROP TABLE dbo.AttritionPredictions;
IF OBJECT_ID('dbo.ModelMetrics', 'U') IS NOT NULL DROP TABLE dbo.ModelMetrics;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.Employees
(
    EmployeeKey             INT             NOT NULL PRIMARY KEY,
    Age                     INT             NULL,
    Gender                  VARCHAR(20)     NULL,
    Department              VARCHAR(100)    NULL,
    JobRole                 VARCHAR(150)    NULL,
    HireDate                DATE            NULL,
    TerminationDate         DATE            NULL,
    SnapshotDate            DATE            NULL,
    AttritionFlag           BIT             NOT NULL DEFAULT (0),
    MonthlySalary           DECIMAL(12,2)   NULL,
    TenureYears             DECIMAL(6,2)    NULL,
    JobSatisfaction         INT             NULL,
    PerformanceRating       DECIMAL(5,2)    NULL,
    OvertimeFlag            BIT             NULL,
    CommuteMiles            DECIMAL(8,2)    NULL,
    TrainingHoursMonthly    DECIMAL(8,2)    NULL,
    YearsSincePromotion     DECIMAL(6,2)    NULL,
    CONSTRAINT CK_Employees_JobSatisfaction CHECK (JobSatisfaction IS NULL OR JobSatisfaction BETWEEN 1 AND 5),
    CONSTRAINT CK_Employees_Age CHECK (Age IS NULL OR Age BETWEEN 16 AND 100)
);
GO

CREATE TABLE dbo.AttritionPredictions
(
    EmployeeKey             INT             NOT NULL PRIMARY KEY,
    AttritionProbability    DECIMAL(9,6)    NULL,
    RiskBand                VARCHAR(20)     NULL,
    RecommendedAction       VARCHAR(250)    NULL,
    PredictionDate          DATE            NULL,
    CONSTRAINT FK_AttritionPredictions_Employees FOREIGN KEY (EmployeeKey) REFERENCES dbo.Employees(EmployeeKey),
    CONSTRAINT CK_AttritionPredictions_Probability CHECK (AttritionProbability IS NULL OR AttritionProbability BETWEEN 0 AND 1),
    CONSTRAINT CK_AttritionPredictions_RiskBand CHECK (RiskBand IS NULL OR RiskBand IN ('Low','Medium','High'))
);
GO

CREATE TABLE dbo.ModelMetrics
(
    MetricId                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Metric                  VARCHAR(100)       NOT NULL,
    Value                   DECIMAL(12,6)      NULL,
    EvaluationDate          DATE               NULL,
    ModelVersion            VARCHAR(50)        NULL
);
GO

CREATE TABLE dbo.DimDate
(
    [Date]                  DATE            NOT NULL PRIMARY KEY,
    [Year]                  INT             NOT NULL,
    QuarterNumber           INT             NOT NULL,
    QuarterName             VARCHAR(2)      NOT NULL,
    MonthNumber             INT             NOT NULL,
    MonthName               VARCHAR(20)     NOT NULL,
    MonthShortName          VARCHAR(3)      NOT NULL,
    YearMonth               CHAR(7)         NOT NULL,
    YearMonthSort           INT             NOT NULL,
    DayOfMonth              INT             NOT NULL,
    DayName                 VARCHAR(20)     NOT NULL,
    IsWeekend               BIT             NOT NULL
);
GO

DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate   DATE = '2030-12-31';

;WITH n AS
(
    SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
d AS
(
    SELECT DATEADD(DAY, n, @StartDate) AS [Date]
    FROM n
)
INSERT INTO dbo.DimDate
(
    [Date], [Year], QuarterNumber, QuarterName,
    MonthNumber, MonthName, MonthShortName,
    YearMonth, YearMonthSort, DayOfMonth, DayName, IsWeekend
)
SELECT
    [Date],
    YEAR([Date]),
    DATEPART(QUARTER, [Date]),
    CONCAT('Q', DATEPART(QUARTER, [Date])),
    MONTH([Date]),
    DATENAME(MONTH, [Date]),
    LEFT(DATENAME(MONTH, [Date]), 3),
    CONVERT(CHAR(7), [Date], 126),
    YEAR([Date]) * 100 + MONTH([Date]),
    DAY([Date]),
    DATENAME(WEEKDAY, [Date]),
    CASE WHEN DATENAME(WEEKDAY, [Date]) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
FROM d;
GO

CREATE INDEX IX_Employees_Department ON dbo.Employees(Department);
CREATE INDEX IX_Employees_JobRole ON dbo.Employees(JobRole);
CREATE INDEX IX_Employees_HireDate ON dbo.Employees(HireDate);
CREATE INDEX IX_Employees_TerminationDate ON dbo.Employees(TerminationDate);
CREATE INDEX IX_Employees_SnapshotDate ON dbo.Employees(SnapshotDate);
CREATE INDEX IX_Employees_AttritionFlag ON dbo.Employees(AttritionFlag);
CREATE INDEX IX_AttritionPredictions_RiskBand ON dbo.AttritionPredictions(RiskBand);
CREATE INDEX IX_AttritionPredictions_Probability ON dbo.AttritionPredictions(AttritionProbability);
GO

CREATE OR ALTER VIEW dbo.vw_EmployeeAttritionAnalytics
AS
SELECT
    e.EmployeeKey,
    e.Age,
    e.Gender,
    e.Department,
    e.JobRole,
    e.HireDate,
    e.TerminationDate,
    e.SnapshotDate,
    e.AttritionFlag,
    CASE WHEN e.AttritionFlag = 1 THEN 'Left' ELSE 'Stayed' END AS AttritionStatus,
    e.MonthlySalary,
    e.TenureYears,
    e.JobSatisfaction,
    e.PerformanceRating,
    e.OvertimeFlag,
    CASE WHEN e.OvertimeFlag = 1 THEN 'Overtime' ELSE 'No Overtime' END AS OvertimeStatus,
    e.CommuteMiles,
    e.TrainingHoursMonthly,
    e.YearsSincePromotion,
    p.AttritionProbability,
    p.RiskBand,
    p.RecommendedAction,
    p.PredictionDate,
    CASE WHEN p.RiskBand IN ('Medium','High') THEN 1 ELSE 0 END AS ElevatedRiskFlag,
    CASE WHEN e.JobSatisfaction <= 2 THEN 1 ELSE 0 END AS LowJobSatisfactionFlag,
    CASE WHEN e.YearsSincePromotion >= 5 THEN 1 ELSE 0 END AS PromotionDelayFlag,
    CASE WHEN e.CommuteMiles >= 20 THEN 1 ELSE 0 END AS LongCommuteFlag,
    CASE WHEN e.TenureYears <= 2 THEN 1 ELSE 0 END AS EarlyTenureFlag
FROM dbo.Employees e
LEFT JOIN dbo.AttritionPredictions p
    ON e.EmployeeKey = p.EmployeeKey;
GO

CREATE OR ALTER VIEW dbo.vw_DepartmentAttritionSummary
AS
SELECT
    e.Department,
    COUNT(DISTINCT e.EmployeeKey) AS Headcount,
    SUM(CASE WHEN e.AttritionFlag = 1 THEN 1 ELSE 0 END) AS AttritedEmployees,
    CAST(1.0 * SUM(CASE WHEN e.AttritionFlag = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT e.EmployeeKey), 0) AS DECIMAL(9,4)) AS AttritionRate,
    AVG(CAST(e.TenureYears AS DECIMAL(12,4))) AS AvgTenureYears,
    AVG(CAST(e.MonthlySalary AS DECIMAL(18,2))) AS AvgMonthlySalary,
    AVG(CAST(p.AttritionProbability AS DECIMAL(12,6))) AS AvgAttritionProbability,
    SUM(CASE WHEN p.RiskBand = 'High' THEN 1 ELSE 0 END) AS HighRiskEmployees,
    SUM(CASE WHEN p.RiskBand = 'Medium' THEN 1 ELSE 0 END) AS MediumRiskEmployees,
    SUM(CASE WHEN p.RiskBand IN ('Medium','High') THEN 1 ELSE 0 END) AS ElevatedRiskEmployees
FROM dbo.Employees e
LEFT JOIN dbo.AttritionPredictions p
    ON e.EmployeeKey = p.EmployeeKey
GROUP BY e.Department;
GO

CREATE OR ALTER VIEW dbo.vw_JobRoleAttritionSummary
AS
SELECT
    e.Department,
    e.JobRole,
    COUNT(DISTINCT e.EmployeeKey) AS Headcount,
    SUM(CASE WHEN e.AttritionFlag = 1 THEN 1 ELSE 0 END) AS AttritedEmployees,
    CAST(1.0 * SUM(CASE WHEN e.AttritionFlag = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT e.EmployeeKey), 0) AS DECIMAL(9,4)) AS AttritionRate,
    AVG(CAST(p.AttritionProbability AS DECIMAL(12,6))) AS AvgAttritionProbability,
    SUM(CASE WHEN p.RiskBand = 'High' THEN 1 ELSE 0 END) AS HighRiskEmployees,
    SUM(CASE WHEN p.RiskBand = 'Medium' THEN 1 ELSE 0 END) AS MediumRiskEmployees,
    SUM(CASE WHEN p.RiskBand IN ('Medium','High') THEN 1 ELSE 0 END) AS ElevatedRiskEmployees
FROM dbo.Employees e
LEFT JOIN dbo.AttritionPredictions p
    ON e.EmployeeKey = p.EmployeeKey
GROUP BY e.Department, e.JobRole;
GO

CREATE OR ALTER VIEW dbo.vw_WorkforceMovement
AS
WITH Hires AS
(
    SELECT DATEFROMPARTS(YEAR(HireDate), MONTH(HireDate), 1) AS MonthStart, Department, COUNT(*) AS NewHires
    FROM dbo.Employees
    WHERE HireDate IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(HireDate), MONTH(HireDate), 1), Department
),
Terms AS
(
    SELECT DATEFROMPARTS(YEAR(TerminationDate), MONTH(TerminationDate), 1) AS MonthStart, Department, COUNT(*) AS Terminations
    FROM dbo.Employees
    WHERE TerminationDate IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(TerminationDate), MONTH(TerminationDate), 1), Department
),
Keys AS
(
    SELECT MonthStart, Department FROM Hires
    UNION
    SELECT MonthStart, Department FROM Terms
)
SELECT
    k.MonthStart,
    YEAR(k.MonthStart) AS [Year],
    MONTH(k.MonthStart) AS MonthNumber,
    CONVERT(CHAR(7), k.MonthStart, 126) AS YearMonth,
    k.Department,
    ISNULL(h.NewHires, 0) AS NewHires,
    ISNULL(t.Terminations, 0) AS Terminations,
    ISNULL(h.NewHires, 0) - ISNULL(t.Terminations, 0) AS NetWorkforceChange
FROM Keys k
LEFT JOIN Hires h ON k.MonthStart = h.MonthStart AND k.Department = h.Department
LEFT JOIN Terms t ON k.MonthStart = t.MonthStart AND k.Department = t.Department;
GO

CREATE OR ALTER VIEW dbo.vw_RetentionPriorities
AS
SELECT
    e.EmployeeKey,
    e.Department,
    e.JobRole,
    p.RiskBand,
    p.AttritionProbability,
    e.JobSatisfaction,
    e.OvertimeFlag,
    e.YearsSincePromotion,
    e.CommuteMiles,
    e.TenureYears,
    CASE
        WHEN e.JobSatisfaction <= 2 THEN 'Low Job Satisfaction'
        WHEN e.OvertimeFlag = 1 THEN 'Working Overtime'
        WHEN e.YearsSincePromotion >= 5 THEN 'Promotion Delay'
        WHEN e.CommuteMiles >= 20 THEN 'Long Commute'
        WHEN e.TenureYears <= 2 THEN 'Early Tenure'
        ELSE 'Monitor'
    END AS PrimaryRetentionPriority,
    p.RecommendedAction
FROM dbo.Employees e
INNER JOIN dbo.AttritionPredictions p ON e.EmployeeKey = p.EmployeeKey;
GO

CREATE OR ALTER VIEW dbo.vw_ElevatedRiskEmployees
AS
SELECT
    e.EmployeeKey,
    e.Department,
    e.JobRole,
    e.Age,
    e.Gender,
    e.MonthlySalary,
    e.TenureYears,
    e.JobSatisfaction,
    e.OvertimeFlag,
    CASE WHEN e.OvertimeFlag = 1 THEN 'Overtime' ELSE 'No Overtime' END AS OvertimeStatus,
    e.CommuteMiles,
    e.YearsSincePromotion,
    p.AttritionProbability,
    p.RiskBand,
    p.RecommendedAction
FROM dbo.Employees e
INNER JOIN dbo.AttritionPredictions p ON e.EmployeeKey = p.EmployeeKey
WHERE p.RiskBand IN ('Medium','High');
GO

CREATE OR ALTER VIEW dbo.vw_ModelOutcomeSummary
AS
WITH Outcomes AS
(
    SELECT
        e.EmployeeKey,
        e.AttritionFlag,
        p.AttritionProbability,
        CASE WHEN p.AttritionProbability >= 0.50 THEN 1 ELSE 0 END AS PredictedAttritionFlag
    FROM dbo.Employees e
    INNER JOIN dbo.AttritionPredictions p ON e.EmployeeKey = p.EmployeeKey
    WHERE p.AttritionProbability IS NOT NULL
)
SELECT
    SUM(CASE WHEN AttritionFlag = 1 AND PredictedAttritionFlag = 1 THEN 1 ELSE 0 END) AS TruePositives,
    SUM(CASE WHEN AttritionFlag = 0 AND PredictedAttritionFlag = 1 THEN 1 ELSE 0 END) AS FalsePositives,
    SUM(CASE WHEN AttritionFlag = 1 AND PredictedAttritionFlag = 0 THEN 1 ELSE 0 END) AS FalseNegatives,
    SUM(CASE WHEN AttritionFlag = 0 AND PredictedAttritionFlag = 0 THEN 1 ELSE 0 END) AS TrueNegatives,
    CAST(1.0 * SUM(CASE WHEN AttritionFlag = PredictedAttritionFlag THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(9,4)) AS Accuracy,
    CAST(1.0 * SUM(CASE WHEN AttritionFlag = 1 AND PredictedAttritionFlag = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN PredictedAttritionFlag = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL(9,4)) AS Precision,
    CAST(1.0 * SUM(CASE WHEN AttritionFlag = 1 AND PredictedAttritionFlag = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN AttritionFlag = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL(9,4)) AS Recall
FROM Outcomes;
GO

SELECT TOP (100) * FROM dbo.vw_EmployeeAttritionAnalytics;
SELECT * FROM dbo.vw_DepartmentAttritionSummary ORDER BY AttritionRate DESC;
SELECT * FROM dbo.vw_JobRoleAttritionSummary ORDER BY AvgAttritionProbability DESC;
SELECT * FROM dbo.vw_WorkforceMovement ORDER BY MonthStart, Department;
SELECT * FROM dbo.vw_ElevatedRiskEmployees ORDER BY AttritionProbability DESC;
SELECT * FROM dbo.vw_ModelOutcomeSummary;
GO
