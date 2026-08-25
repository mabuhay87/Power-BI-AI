# Healthcare Claims Denial Intelligence

An end-to-end Power BI and machine-learning portfolio project for identifying healthcare claims that are likely to be denied, explaining the operational drivers behind denials, and prioritizing high-value claims for review.

The solution combines a SQL Server reporting layer, a star-schema Power BI semantic model, DAX measures, interactive drill-through, and claim-level ML predictions.

> **Portfolio disclaimer:** The project uses synthetic demonstration data. It contains no protected health information (PHI) and is not intended for clinical or production claim-adjudication decisions.

## Business Problem

Healthcare claim denials delay reimbursement, increase administrative effort, and create preventable revenue leakage. Operations teams need to know:

- How many claims and billed dollars are being denied?
- Which denial reasons, procedures, specialties, and workflow failures drive denials?
- Which providers have unusually high denial rates or denied dollars?
- Which open claims have the highest predicted denial risk?
- Is the prediction model accurate, well calibrated, and useful for operational triage?

## Solution Overview

This report gives executives, revenue-cycle analysts, provider-relations teams, and claim-review staff a shared view of denial performance.

| Capability | Implementation |
|---|---|
| Executive monitoring | KPI cards, monthly claims trend, denial dollars and plan matrix |
| Root-cause analysis | Denial reason, procedure, specialty, authorization and filing visuals |
| Provider analysis | Provider scorecard, rankings and drill-through details |
| AI-assisted prioritization | Claim-level probability, risk band and high-risk dollar queue |
| Model governance | Accuracy, precision, recall, F1, ROC AUC and confusion matrix |
| Data preparation | SQL Server tables, reporting views and date dimension |
| Interactivity | Synchronized slicers, dynamic titles, conditional formatting and navigation |

## Dashboard Pages

### 1. Executive Overview

Provides a high-level summary of claim volume, financial performance and predicted risk.

Key elements:

- Total Claims
- Total Billed
- Total Paid
- Denial Rate
- Predicted High-Risk Dollars
- Claims Volume by Month
- Denied Dollars by Denial Reason
- Claims by AI Risk Band
- Plan Performance Matrix

### 2. Denial Drivers

Explains where denials originate and highlights preventable operational failures.

Key elements:

- Denied Claims
- Denied Dollars
- Preventable Denials
- Preventable Denial Rate
- Denied Claims by Reason
- Denied Claims by Procedure
- Denial Rate by Provider Specialty
- Authorization and Filing Pattern Matrix

### 3. Provider Performance

Compares denial outcomes across providers and supports provider-level investigation.

Key elements:

- Total Providers
- Providers with Denials
- Denied Dollars
- Denial Rate
- Provider Performance Details
- Providers with Highest Denial Rates
- Top Providers by Denied Dollars
- Provider Detail drill-through page

### 4. AI Work Queue

Prioritizes individual claims for review using predicted denial probability and financial exposure.

Key elements:

- Predicted High-Risk Claims
- Predicted High-Risk Dollars
- Predicted Denial Rate
- Average Denial Probability
- Claims by AI Risk Band
- High-Risk Dollars by Procedure
- Claim-level review queue sorted by denial probability

### 5. Model Monitoring

Evaluates classification performance and compares predicted risk with actual outcomes.

Key elements:

- Accuracy
- Precision
- Recall
- F1 Score
- ROC AUC
- False Positives and False Negatives
- Model Metrics Comparison
- Actual vs. Predicted Outcomes
- Confusion Matrix
- Predicted Probability vs. Actual Denial Rate

### Definitions & Help

Documents KPI definitions, AI terminology, navigation instructions, report limitations and responsible-AI guidance.

### Provider Detail

A hidden drill-through page that displays the selected provider's identity, specialty, network status, state and claim outcomes. Users access it by right-clicking a provider on the Provider Performance page.

## Current Demonstration Results

The current synthetic dataset contains approximately 5,000 claims for January 2025 through August 2026.

| Metric | Result |
|---|---:|
| Total billed | $23.0M |
| Total paid | $14.6M |
| Denied claims | 387 |
| Denial rate | 7.7% |
| Predicted high-risk claims | 21 |
| Predicted high-risk dollars | $355K |
| Model accuracy | 92.5% |
| Precision | 60.0% |
| Recall | 9.3% |
| F1 score | 16.1% |
| ROC AUC | 65.7% |

### Model interpretation

Although overall accuracy is high, denial recall is only 9.3%. The model correctly identifies a relatively small portion of actual denials and produces many false negatives. Accuracy is therefore not sufficient by itself because the dataset is imbalanced and most claims are paid.

Before production use, the next modeling iteration should prioritize recall and the financial cost of missed denials. Recommended experiments include class weighting, threshold tuning, resampling, additional authorization and coding features, and cost-sensitive evaluation.

## Current Data Source: Excel

The current Power BI report is built from an Excel workbook. Excel provides a portable data source that allows the complete dashboard to be opened and refreshed without requiring access to a SQL Server instance.

The workbook contains the following Excel tables or worksheets:

| Excel table/worksheet | Purpose | Primary key |
|---|---|---|
| `Claims` | Claim dates, procedures, billed and paid amounts, actual outcomes and operational flags | `ClaimKey` |
| `Members` | Member demographics, plan type, state and risk attributes | `MemberKey` |
| `Providers` | Provider name, specialty, network status and state | `ProviderKey` |
| `Predictions` | Claim-level denial probability, predicted outcome and risk band | `ClaimKey` |
| `ModelMetrics` | Accuracy, precision, recall, F1 score, ROC AUC and error counts | `Metric` |

The `Date` table is created inside Power BI and related to `Claims[ServiceDate]`. The included SQL Server script is an optional database implementation for a future production-style version of the project.

### Excel data preparation

- Format each worksheet range as an official Excel table using **Home → Format as Table**.
- Give each Excel table the exact name shown above.
- Keep column names unchanged so Power Query steps and DAX measures continue to work.
- Store dates as Excel dates, not text.
- Store `DeniedFlag`, `PredictedDenial`, authorization and filing indicators consistently as `0/1`, `TRUE/FALSE`, or `Yes/No` according to the current Power Query transformations.
- Store `DenialProbability` as a decimal between `0` and `1`.
- Do not add merged cells, blank header rows, subtotals or manually calculated totals inside the source tables.

## Data Model for SQL Server Use

The Power BI model follows a star-schema design.

| Table | Purpose | Key |
|---|---|---|
| `Date` | Calendar attributes and chronological sorting | `Date` |
| `Members` | Member demographics, plan and risk attributes | `MemberKey` |
| `Providers` | Provider identity, specialty, network and state | `ProviderKey` |
| `Claims` | Claim-level financial and denial outcomes | `ClaimKey` |
| `Predictions` | ML score, predicted class and risk band | `ClaimKey` |
| `ModelMetrics` | Stored evaluation results by model version | `ModelMetricKey` |

### Relationships

- `Date[Date]` **1 → many** `Claims[ServiceDate]`
- `Members[MemberKey]` **1 → many** `Claims[MemberKey]`
- `Providers[ProviderKey]` **1 → many** `Claims[ProviderKey]`
- `Claims[ClaimKey]` **1 → 1** `Predictions[ClaimKey]`
- `ModelMetrics` remains disconnected because it stores model-level evaluation results rather than claim-level events.

Use single-direction filtering from each dimension toward `Claims`. Sort `Date[MonthYear]` by `Date[MonthYearSort]`.

## Important Fields

| Field | Description |
|---|---|
| `DeniedFlag` | Actual claim outcome: 1 = denied, 0 = paid |
| `DenialReason` | Actual reason assigned to a denied claim |
| `AuthorizationObtained` | Whether authorization was obtained before service |
| `FiledTimely` | Whether the claim was filed within the required period |
| `CodingErrorFlag` | Whether the claim contains a detected coding issue |
| `DenialProbability` | ML probability that the claim will be denied |
| `PredictedDenial` | Predicted outcome after applying the model threshold |
| `RiskBand` | Low, Medium or High operational risk category |

## Core DAX Measures

```DAX
Total Claims =
COUNTROWS ( Claims )

Total Billed =
SUM ( Claims[BilledAmount] )

Total Paid =
SUM ( Claims[PaidAmount] )

Denied Claims =
CALCULATE ( [Total Claims], Claims[DeniedFlag] = 1 )

Denied Dollars =
CALCULATE ( [Total Billed], Claims[DeniedFlag] = 1 )

Denial Rate =
DIVIDE ( [Denied Claims], [Total Claims], 0 )

Predicted High-Risk Claims =
CALCULATE ( [Total Claims], Predictions[RiskBand] = "High" )

Predicted High-Risk Dollars =
CALCULATE ( [Total Billed], Predictions[RiskBand] = "High" )

Average Denial Probability =
AVERAGE ( Predictions[DenialProbability] )
```

Format dollar measures as currency and rate/probability measures as percentages.

## SQL Server Objects

Run `Healthcare_Claims_Denial_Intelligence_SQL_Server.sql` to create the database layer.

### Tables

- `dbo.Date`
- `dbo.Members`
- `dbo.Providers`
- `dbo.Claims`
- `dbo.Predictions`
- `dbo.ModelMetrics`

### Reporting views

| View | Primary use |
|---|---|
| `pbi.vw_ClaimDetail` | Claim-level reporting and validation |
| `pbi.vw_ExecutiveOverview` | Executive KPIs and trends |
| `pbi.vw_DenialDrivers` | Root-cause analysis |
| `pbi.vw_ProviderPerformance` | Provider scorecard and ranking |
| `pbi.vw_AIWorkQueue` | Prioritized claim-review queue |
| `pbi.vw_ModelMetricsLatest` | Latest model evaluation results |
| `pbi.vw_ConfusionMatrix` | Actual versus predicted outcome counts |
| `pbi.vw_RiskBandCalibration` | Predicted probability versus actual denial rate |

## AI/ML Workflow

1. Extract claim, member and provider features from SQL Server.
2. Clean missing values and encode categorical variables.
3. Split the dataset into training and test sets using stratification.
4. Train a binary-classification model where `DeniedFlag` is the target.
5. Generate `DenialProbability` and `PredictedDenial` for each claim.
6. Assign operational risk bands using documented thresholds.
7. Write claim-level scores to `dbo.Predictions`.
8. Write evaluation results to `dbo.ModelMetrics`.
9. Refresh the Power BI semantic model.
10. Monitor recall, precision, calibration and financial exposure.

Example risk-band logic:

```text
High:   DenialProbability >= 0.70
Medium: DenialProbability >= 0.30 and < 0.70
Low:    DenialProbability < 0.30
```

Thresholds should be validated against business capacity and the cost of false negatives rather than treated as universal values.

## Report Filters and Navigation

The following slicers are synchronized across the five primary report pages:

- Service Date
- Plan Type
- Provider State

AI Risk Band and Predicted Denial are synchronized between AI Work Queue and Model Monitoring. Provider Specialty and Provider Name remain page-specific.

Model-level KPI cards sourced from the disconnected `ModelMetrics` table do not change with claim-level slicers. This is intentional and should be explained on the Definitions & Help page.

## Visual Design

- 16:9 report canvas
- Dark navy page header
- Consistent KPI card layout
- Accessible color contrast
- Green for favorable outcomes
- Amber for warnings
- Red for denials and high risk
- Dynamic titles reflecting date and plan selections
- Conditional formatting for denial rate and probability
- Page navigation and hidden drill-through page

Suggested palette:

| Use | Hex |
|---|---|
| Header navy | `#123044` |
| Primary teal | `#1F6E8C` |
| Favorable green | `#2E8B57` |
| Warning amber | `#E3A008` |
| Denial red | `#C0392B` |
| Page background | `#F3F6F9` |

## Installation and Setup

### Prerequisites

- Power BI Desktop
- SQL Server or SQL Server Express
- SQL Server Management Studio
- Python 3.10 or later for model training
- Python packages such as `pandas`, `numpy`, `scikit-learn`, `joblib` and a SQL Server connector

### Database setup

1. Create an empty SQL Server database.
2. Open `Healthcare_Claims_Denial_Intelligence_SQL_Server.sql` in SQL Server Management Studio.
3. Select the new database.
4. Execute the script.
5. Load the dimension tables before loading claims.
6. Load predictions only after the corresponding claims exist.

Recommended load order:

1. `Members`
2. `Providers`
3. `Claims`
4. `Predictions`
5. `ModelMetrics`

## Validation Queries

```SQL
-- Claim and financial totals
SELECT
    COUNT(*) AS TotalClaims,
    SUM(BilledAmount) AS TotalBilled,
    SUM(PaidAmount) AS TotalPaid,
    SUM(CONVERT(int, DeniedFlag)) AS DeniedClaims
FROM dbo.Claims;

-- Prediction coverage
SELECT
    COUNT(*) AS TotalClaims,
    COUNT(p.ClaimKey) AS ScoredClaims
FROM dbo.Claims AS c
LEFT JOIN dbo.Predictions AS p
    ON p.ClaimKey = c.ClaimKey;

-- Confusion matrix source
SELECT *
FROM pbi.vw_ConfusionMatrix;
```

## Responsible AI Considerations

- Use predictions to prioritize human review, not to automatically deny claims.
- Monitor performance across plan type, geography, specialty, age band and other relevant groups.
- Document the model version, scoring date, threshold and training period.
- Investigate data drift and changes in claim-adjudication policy.
- Protect member and provider information using least-privilege access.
- Use row-level security and an approved data-retention policy for real healthcare data.
- Never publish PHI, member identifiers or confidential claim data in a public repository.

## Future Enhancements

- Tune the classification threshold to improve denial recall.
- Add SHAP-based claim-level reason explanations.
- Add model-version and scoring-period comparisons.
- Add revenue-recovery tracking after claim intervention.
- Add claim-status aging and appeal outcomes.
- Add incremental refresh for large claim histories.
- Add row-level security by market, provider group or operations team.
- Deploy the model and reporting pipeline through Microsoft Fabric or Azure.

## Portfolio Skills Demonstrated

- Power BI report design and storytelling
- Dimensional modeling and semantic-model development
- DAX measures and filter context
- SQL Server DDL, views, constraints and indexing
- Python machine learning and classification metrics
- Model monitoring and responsible-AI communication
- Drill-through, synchronized slicers and conditional formatting
- Healthcare revenue-cycle and claims-denial analytics
