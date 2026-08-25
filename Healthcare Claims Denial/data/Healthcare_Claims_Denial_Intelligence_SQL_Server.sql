/*=============================================================================
  Healthcare Claims Denial Intelligence
  SQL Server database objects for Power BI

  Execution order:
    1. Create or select your database.
    2. Run this entire script in SQL Server Management Studio.
    3. Load source data into dbo.Members, dbo.Providers, dbo.Claims,
       dbo.Predictions, and dbo.ModelMetrics.
    4. Connect Power BI to the pbi views at the end of this script.
=============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'pbi')
    EXEC(N'CREATE SCHEMA pbi AUTHORIZATION dbo;');
GO

/*=============================================================================
  TABLES
=============================================================================*/

IF OBJECT_ID(N'dbo.Members', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Members
    (
        MemberKey       int           NOT NULL,
        Age             tinyint       NOT NULL,
        AgeBand         varchar(20)   NOT NULL,
        Gender          varchar(20)   NOT NULL,
        PlanType        varchar(50)   NOT NULL,
        RiskScore       decimal(6,3)  NULL,
        State           char(2)       NOT NULL,
        CreatedDateTime datetime2(0)  NOT NULL
            CONSTRAINT DF_Members_CreatedDateTime DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Members PRIMARY KEY CLUSTERED (MemberKey),
        CONSTRAINT CK_Members_Age CHECK (Age BETWEEN 0 AND 120),
        CONSTRAINT CK_Members_RiskScore CHECK
            (RiskScore IS NULL OR RiskScore BETWEEN 0 AND 100)
    );
END;
GO

IF OBJECT_ID(N'dbo.Providers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Providers
    (
        ProviderKey     int           NOT NULL,
        ProviderName    varchar(150)  NOT NULL,
        Specialty       varchar(100)  NOT NULL,
        NetworkStatus   varchar(30)   NOT NULL,
        ProviderState   char(2)       NOT NULL,
        CreatedDateTime datetime2(0)  NOT NULL
            CONSTRAINT DF_Providers_CreatedDateTime DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Providers PRIMARY KEY CLUSTERED (ProviderKey),
        CONSTRAINT UQ_Providers_Name UNIQUE (ProviderName),
        CONSTRAINT CK_Providers_NetworkStatus CHECK
            (NetworkStatus IN ('In Network', 'Out of Network'))
    );
END;
GO

IF OBJECT_ID(N'dbo.Claims', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Claims
    (
        ClaimKey              int            NOT NULL,
        MemberKey             int            NOT NULL,
        ProviderKey           int            NOT NULL,
        ServiceDate           date           NOT NULL,
        ProcedureCode         varchar(20)    NULL,
        ProcedureDescription  varchar(150)   NOT NULL,
        BilledAmount          decimal(19,2)  NOT NULL,
        PaidAmount            decimal(19,2)  NOT NULL,
        DeniedFlag            bit            NOT NULL,
        DenialReason          varchar(100)   NULL,
        AuthorizationObtained bit            NOT NULL,
        FiledTimely           bit            NOT NULL,
        CodingErrorFlag       bit            NOT NULL
            CONSTRAINT DF_Claims_CodingErrorFlag DEFAULT (0),
        CreatedDateTime       datetime2(0)   NOT NULL
            CONSTRAINT DF_Claims_CreatedDateTime DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Claims PRIMARY KEY CLUSTERED (ClaimKey),
        CONSTRAINT FK_Claims_Members FOREIGN KEY (MemberKey)
            REFERENCES dbo.Members(MemberKey),
        CONSTRAINT FK_Claims_Providers FOREIGN KEY (ProviderKey)
            REFERENCES dbo.Providers(ProviderKey),
        CONSTRAINT CK_Claims_BilledAmount CHECK (BilledAmount >= 0),
        CONSTRAINT CK_Claims_PaidAmount CHECK
            (PaidAmount >= 0 AND PaidAmount <= BilledAmount),
        CONSTRAINT CK_Claims_DenialReason CHECK
            ((DeniedFlag = 1 AND DenialReason IS NOT NULL)
             OR (DeniedFlag = 0 AND DenialReason IS NULL))
    );
END;
GO

IF OBJECT_ID(N'dbo.Predictions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Predictions
    (
        ClaimKey             int           NOT NULL,
        DenialProbability    decimal(7,6)  NOT NULL,
        PredictedDenial      bit           NOT NULL,
        RiskBand             varchar(10)   NOT NULL,
        ModelVersion         varchar(50)   NULL,
        ScoredDateTime       datetime2(0)  NOT NULL
            CONSTRAINT DF_Predictions_ScoredDateTime DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Predictions PRIMARY KEY CLUSTERED (ClaimKey),
        CONSTRAINT FK_Predictions_Claims FOREIGN KEY (ClaimKey)
            REFERENCES dbo.Claims(ClaimKey),
        CONSTRAINT CK_Predictions_Probability CHECK
            (DenialProbability BETWEEN 0 AND 1),
        CONSTRAINT CK_Predictions_RiskBand CHECK
            (RiskBand IN ('Low', 'Medium', 'High'))
    );
END;
GO

/* Keep this table disconnected from Claims in the Power BI model. */
IF OBJECT_ID(N'dbo.ModelMetrics', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ModelMetrics
    (
        ModelMetricKey  int IDENTITY(1,1) NOT NULL,
        ModelVersion    varchar(50)        NOT NULL,
        EvaluationDate  date               NOT NULL,
        Metric          varchar(50)        NOT NULL,
        Value           decimal(12,6)      NOT NULL,
        CONSTRAINT PK_ModelMetrics PRIMARY KEY CLUSTERED (ModelMetricKey),
        CONSTRAINT UQ_ModelMetrics UNIQUE
            (ModelVersion, EvaluationDate, Metric),
        CONSTRAINT CK_ModelMetrics_Metric CHECK
            (Metric IN
                ('Accuracy', 'Precision', 'Recall', 'F1 Score', 'ROC AUC',
                 'True Positives', 'True Negatives',
                 'False Positives', 'False Negatives')),
        CONSTRAINT CK_ModelMetrics_Value CHECK (Value >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.[Date]', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Date]
    (
        [Date]        date         NOT NULL,
        DateKey       int          NOT NULL,
        [Year]        smallint     NOT NULL,
        QuarterNumber tinyint      NOT NULL,
        Quarter       char(2)      NOT NULL,
        MonthNumber   tinyint      NOT NULL,
        MonthName     varchar(9)   NOT NULL,
        MonthYear     char(8)      NOT NULL,
        MonthYearSort int          NOT NULL,
        WeekNumber    tinyint      NOT NULL,
        DayOfMonth    tinyint      NOT NULL,
        DayName       varchar(9)   NOT NULL,
        IsWeekend     bit          NOT NULL,
        CONSTRAINT PK_Date PRIMARY KEY CLUSTERED ([Date]),
        CONSTRAINT UQ_Date_DateKey UNIQUE (DateKey)
    );
END;
GO

/*=============================================================================
  DATE-DIMENSION LOADER
=============================================================================*/

CREATE OR ALTER PROCEDURE dbo.usp_LoadDateDimension
    @StartDate date,
    @EndDate   date
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        THROW 50001, 'Provide a valid date range.', 1;

    ;WITH DateSeries AS
    (
        SELECT @StartDate AS CalendarDate
        UNION ALL
        SELECT DATEADD(day, 1, CalendarDate)
        FROM DateSeries
        WHERE CalendarDate < @EndDate
    )
    INSERT dbo.[Date]
    (
        [Date], DateKey, [Year], QuarterNumber, Quarter, MonthNumber,
        MonthName, MonthYear, MonthYearSort, WeekNumber, DayOfMonth,
        DayName, IsWeekend
    )
    SELECT
        d.CalendarDate,
        CONVERT(int, CONVERT(char(8), d.CalendarDate, 112)),
        YEAR(d.CalendarDate),
        DATEPART(quarter, d.CalendarDate),
        CONCAT('Q', DATEPART(quarter, d.CalendarDate)),
        MONTH(d.CalendarDate),
        DATENAME(month, d.CalendarDate),
        LEFT(DATENAME(month, d.CalendarDate), 3)
            + ' ' + CONVERT(char(4), YEAR(d.CalendarDate)),
        YEAR(d.CalendarDate) * 100 + MONTH(d.CalendarDate),
        DATEPART(iso_week, d.CalendarDate),
        DAY(d.CalendarDate),
        DATENAME(weekday, d.CalendarDate),
        CASE WHEN DATEDIFF(day, '19000101', d.CalendarDate) % 7 IN (5, 6)
             THEN 1 ELSE 0 END
    FROM DateSeries AS d
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Date] AS existing
        WHERE existing.[Date] = d.CalendarDate
    )
    OPTION (MAXRECURSION 0);
END;
GO

/* Change the dates if your claims extend outside this range. */
EXEC dbo.usp_LoadDateDimension
    @StartDate = '2025-01-01',
    @EndDate   = '2026-12-31';
GO

/*=============================================================================
  PERFORMANCE INDEXES
=============================================================================*/

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE object_id = OBJECT_ID(N'dbo.Claims')
                 AND name = N'IX_Claims_ServiceDate')
    CREATE INDEX IX_Claims_ServiceDate
        ON dbo.Claims(ServiceDate)
        INCLUDE (ProviderKey, MemberKey, DeniedFlag, BilledAmount, PaidAmount);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE object_id = OBJECT_ID(N'dbo.Claims')
                 AND name = N'IX_Claims_Provider_Denied')
    CREATE INDEX IX_Claims_Provider_Denied
        ON dbo.Claims(ProviderKey, DeniedFlag)
        INCLUDE (BilledAmount, PaidAmount, ServiceDate, DenialReason,
                 ProcedureDescription);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE object_id = OBJECT_ID(N'dbo.Claims')
                 AND name = N'IX_Claims_DenialDrivers')
    CREATE INDEX IX_Claims_DenialDrivers
        ON dbo.Claims(DeniedFlag, DenialReason, ProcedureDescription)
        INCLUDE (ProviderKey, AuthorizationObtained, FiledTimely,
                 CodingErrorFlag, BilledAmount);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE object_id = OBJECT_ID(N'dbo.Predictions')
                 AND name = N'IX_Predictions_Risk')
    CREATE INDEX IX_Predictions_Risk
        ON dbo.Predictions(RiskBand, PredictedDenial)
        INCLUDE (ClaimKey, DenialProbability, ModelVersion);
GO

/*=============================================================================
  POWER BI VIEWS
=============================================================================*/

/* Base view: use for claim-level analysis and most DAX measures. */
CREATE OR ALTER VIEW pbi.vw_ClaimDetail
AS
SELECT
    c.ClaimKey,
    c.ServiceDate,
    d.DateKey,
    d.[Year],
    d.Quarter,
    d.MonthNumber,
    d.MonthName,
    d.MonthYear,
    d.MonthYearSort,
    c.MemberKey,
    m.Age,
    m.AgeBand,
    m.Gender,
    m.PlanType,
    m.RiskScore AS MemberRiskScore,
    m.State AS MemberState,
    c.ProviderKey,
    pr.ProviderName,
    pr.Specialty,
    pr.NetworkStatus,
    pr.ProviderState,
    c.ProcedureCode,
    c.ProcedureDescription,
    c.BilledAmount,
    c.PaidAmount,
    c.BilledAmount - c.PaidAmount AS UnpaidAmount,
    c.DeniedFlag,
    CASE WHEN c.DeniedFlag = 1 THEN 'Denied' ELSE 'Paid' END AS ActualOutcome,
    COALESCE(c.DenialReason, 'Paid') AS ActualOutcomeReason,
    c.DenialReason,
    c.AuthorizationObtained,
    CASE WHEN c.AuthorizationObtained = 1 THEN 'Yes' ELSE 'No' END
        AS AuthorizationStatus,
    c.FiledTimely,
    CASE WHEN c.FiledTimely = 1 THEN 'Yes' ELSE 'No' END AS FiledTimelyStatus,
    c.CodingErrorFlag,
    p.DenialProbability,
    p.PredictedDenial,
    CASE WHEN p.PredictedDenial = 1 THEN 'Predicted Denial'
         WHEN p.PredictedDenial = 0 THEN 'Predicted Paid'
         ELSE 'Not Scored' END AS PredictedOutcome,
    p.RiskBand,
    p.ModelVersion,
    p.ScoredDateTime,
    CASE WHEN p.PredictedDenial = 1 THEN c.BilledAmount ELSE 0 END
        AS PredictedHighRiskDollars,
    CASE
        WHEN c.DeniedFlag = 1
         AND (c.AuthorizationObtained = 0
              OR c.FiledTimely = 0
              OR c.CodingErrorFlag = 1
              OR c.DenialReason IN
                 ('Missing Authorization', 'Timely Filing', 'Coding Error'))
        THEN 1 ELSE 0
    END AS PreventableDenialFlag
FROM dbo.Claims AS c
INNER JOIN dbo.Members AS m
    ON m.MemberKey = c.MemberKey
INNER JOIN dbo.Providers AS pr
    ON pr.ProviderKey = c.ProviderKey
LEFT JOIN dbo.[Date] AS d
    ON d.[Date] = c.ServiceDate
LEFT JOIN dbo.Predictions AS p
    ON p.ClaimKey = c.ClaimKey;
GO

/* Page 1: Executive Overview. */
CREATE OR ALTER VIEW pbi.vw_ExecutiveOverview
AS
SELECT
    ServiceDate,
    COUNT_BIG(*) AS TotalClaims,
    SUM(BilledAmount) AS TotalBilled,
    SUM(PaidAmount) AS TotalPaid,
    SUM(CONVERT(bigint, DeniedFlag)) AS DeniedClaims,
    CAST(1.0 * SUM(CONVERT(bigint, DeniedFlag)) / NULLIF(COUNT_BIG(*), 0)
         AS decimal(12,6)) AS DenialRate,
    SUM(PredictedHighRiskDollars) AS PredictedHighRiskDollars
FROM pbi.vw_ClaimDetail
GROUP BY ServiceDate;
GO

/* Page 2: denial reason, procedure, specialty, authorization, and filing. */
CREATE OR ALTER VIEW pbi.vw_DenialDrivers
AS
SELECT
    ServiceDate,
    PlanType,
    ProviderState,
    Specialty,
    ProcedureDescription,
    DenialReason,
    AuthorizationStatus,
    FiledTimelyStatus,
    COUNT_BIG(*) AS TotalClaims,
    SUM(CONVERT(bigint, DeniedFlag)) AS DeniedClaims,
    SUM(CASE WHEN DeniedFlag = 1 THEN BilledAmount ELSE 0 END) AS DeniedDollars,
    SUM(CONVERT(bigint, PreventableDenialFlag)) AS PreventableDenials,
    CAST(1.0 * SUM(CONVERT(bigint, DeniedFlag)) / NULLIF(COUNT_BIG(*), 0)
         AS decimal(12,6)) AS DenialRate
FROM pbi.vw_ClaimDetail
GROUP BY
    ServiceDate, PlanType, ProviderState, Specialty, ProcedureDescription,
    DenialReason, AuthorizationStatus, FiledTimelyStatus;
GO

/* Page 3: Provider Performance and Provider Detail drill-through. */
CREATE OR ALTER VIEW pbi.vw_ProviderPerformance
AS
SELECT
    ProviderKey,
    ProviderName,
    Specialty,
    NetworkStatus,
    ProviderState,
    COUNT_BIG(*) AS TotalClaims,
    SUM(CONVERT(bigint, DeniedFlag)) AS DeniedClaims,
    SUM(CASE WHEN DeniedFlag = 1 THEN BilledAmount ELSE 0 END) AS DeniedDollars,
    CAST(1.0 * SUM(CONVERT(bigint, DeniedFlag)) / NULLIF(COUNT_BIG(*), 0)
         AS decimal(12,6)) AS DenialRate,
    CAST(AVG(CONVERT(decimal(12,6), DenialProbability)) AS decimal(12,6))
        AS AverageDenialProbability,
    DENSE_RANK() OVER
    (
        ORDER BY 1.0 * SUM(CONVERT(bigint, DeniedFlag))
                 / NULLIF(COUNT_BIG(*), 0) DESC
    ) AS ProviderDenialRateRank,
    DENSE_RANK() OVER
    (
        ORDER BY SUM(CASE WHEN DeniedFlag = 1 THEN BilledAmount ELSE 0 END) DESC
    ) AS ProviderDeniedDollarsRank
FROM pbi.vw_ClaimDetail
GROUP BY ProviderKey, ProviderName, Specialty, NetworkStatus, ProviderState;
GO

/* Page 4: AI Work Queue. */
CREATE OR ALTER VIEW pbi.vw_AIWorkQueue
AS
SELECT
    ClaimKey,
    ServiceDate,
    ProviderKey,
    ProviderName,
    ProviderState,
    Specialty,
    PlanType,
    ProcedureCode,
    ProcedureDescription,
    BilledAmount,
    AuthorizationStatus,
    FiledTimelyStatus,
    ActualOutcomeReason,
    DenialProbability,
    RiskBand,
    PredictedDenial,
    PredictedHighRiskDollars,
    ROW_NUMBER() OVER
    (
        ORDER BY DenialProbability DESC, BilledAmount DESC, ClaimKey
    ) AS ReviewPriority
FROM pbi.vw_ClaimDetail
WHERE DenialProbability IS NOT NULL;
GO

/* Page 5: latest stored model metrics. */
CREATE OR ALTER VIEW pbi.vw_ModelMetricsLatest
AS
WITH RankedMetrics AS
(
    SELECT
        ModelVersion,
        EvaluationDate,
        Metric,
        Value,
        ROW_NUMBER() OVER
        (
            PARTITION BY Metric
            ORDER BY EvaluationDate DESC, ModelMetricKey DESC
        ) AS RowNumber
    FROM dbo.ModelMetrics
)
SELECT ModelVersion, EvaluationDate, Metric, Value
FROM RankedMetrics
WHERE RowNumber = 1;
GO

/* Page 5: live confusion matrix based on Claims and Predictions. */
CREATE OR ALTER VIEW pbi.vw_ConfusionMatrix
AS
SELECT
    CASE WHEN DeniedFlag = 1 THEN 'Actual Denial' ELSE 'Actual Paid' END
        AS ActualOutcome,
    CASE WHEN PredictedDenial = 1 THEN 'Predicted Denial' ELSE 'Predicted Paid' END
        AS PredictedOutcome,
    COUNT_BIG(*) AS ClaimCount
FROM pbi.vw_ClaimDetail
WHERE PredictedDenial IS NOT NULL
GROUP BY DeniedFlag, PredictedDenial;
GO

/* Page 5: probability calibration by AI risk band. */
CREATE OR ALTER VIEW pbi.vw_RiskBandCalibration
AS
SELECT
    RiskBand,
    CASE RiskBand WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END
        AS RiskBandSort,
    COUNT_BIG(*) AS TotalClaims,
    CAST(AVG(CONVERT(decimal(12,6), DenialProbability)) AS decimal(12,6))
        AS AverageDenialProbability,
    CAST(1.0 * SUM(CONVERT(bigint, DeniedFlag)) / NULLIF(COUNT_BIG(*), 0)
         AS decimal(12,6)) AS ActualDenialRate
FROM pbi.vw_ClaimDetail
WHERE RiskBand IS NOT NULL
GROUP BY RiskBand;
GO

/*=============================================================================
  OPTIONAL MODEL-METRIC LOAD EXAMPLE
  Uncomment and change the values after evaluating a model.
=============================================================================*/
/*
INSERT dbo.ModelMetrics (ModelVersion, EvaluationDate, Metric, Value)
VALUES
('v1.0', '2026-08-01', 'Accuracy',        0.925),
('v1.0', '2026-08-01', 'Precision',       0.600),
('v1.0', '2026-08-01', 'Recall',          0.093),
('v1.0', '2026-08-01', 'F1 Score',        0.161),
('v1.0', '2026-08-01', 'ROC AUC',         0.657),
('v1.0', '2026-08-01', 'False Positives', 8),
('v1.0', '2026-08-01', 'False Negatives', 333);
*/

/*=============================================================================
  RECOMMENDED POWER BI IMPORTS

  Star-schema tables:
    dbo.Date          1 -> * dbo.Claims[ServiceDate]
    dbo.Members       1 -> * dbo.Claims[MemberKey]
    dbo.Providers     1 -> * dbo.Claims[ProviderKey]
    dbo.Claims        1 -> 1 dbo.Predictions[ClaimKey]
    dbo.ModelMetrics  disconnected

  Alternatively, import these report-ready views:
    pbi.vw_ClaimDetail
    pbi.vw_ExecutiveOverview
    pbi.vw_DenialDrivers
    pbi.vw_ProviderPerformance
    pbi.vw_AIWorkQueue
    pbi.vw_ModelMetricsLatest
    pbi.vw_ConfusionMatrix
    pbi.vw_RiskBandCalibration

  In Power BI, sort MonthYear by MonthYearSort and RiskBand by RiskBandSort.
=============================================================================*/
