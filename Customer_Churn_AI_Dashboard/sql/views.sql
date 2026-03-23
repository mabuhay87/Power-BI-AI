CREATE VIEW vw_HighRiskCustomers AS
SELECT
    CustomerID,
    Region,
    CustomerSegment,
    ContractType,
    MonthlyCharges,
    ChurnProbability,
    RecommendedAction
FROM FactCustomerChurn
WHERE ChurnProbability >= 0.65;

CREATE VIEW vw_ChurnDrivers AS
SELECT
    ContractType,
    PaymentMethod,
    InternetService,
    CustomerSegment,
    COUNT(*) AS CustomerCount,
    AVG(ChurnProbability) AS AvgChurnProbability,
    SUM(CASE WHEN ChurnFlag = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers
FROM FactCustomerChurn
GROUP BY
    ContractType,
    PaymentMethod,
    InternetService,
    CustomerSegment;
