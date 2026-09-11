# HR Attrition & Retention Intelligence Dashboard

## Project Overview

The **HR Attrition & Retention Intelligence Dashboard** is an end-to-end
Business Intelligence and applied machine learning portfolio project
designed to analyze workforce attrition, identify employee risk
patterns, prioritize retention actions, monitor workforce movement, and
evaluate model performance.

The solution combines:

-   **Power BI** for interactive analytics, visualization, DAX measures,
    and executive reporting
-   **CSV files** as the current data source used by the Power BI report
-   **SQL Server** tables and analytical views as the production-style
    relational data architecture and an alternative/future Power BI data
    source
-   **Python / Machine Learning** for employee attrition probability
    scoring and risk classification
-   **DAX** for workforce KPIs, retention measures, time intelligence,
    and model evaluation metrics

> **Current implementation:** The Power BI dashboard currently loads its
> data from CSV files. The SQL Server scripts included in this
> repository demonstrate how the same solution can be implemented using
> a relational database architecture for a production or enterprise
> environment.

------------------------------------------------------------------------

## Business Objective

Employee attrition can create significant operational and financial
costs. This project demonstrates how HR and leadership teams can use
analytics and predictive modeling to:

-   Monitor workforce health and employee turnover
-   Identify factors associated with attrition
-   Detect employees with elevated predicted attrition risk
-   Prioritize retention interventions
-   Analyze hiring and termination trends
-   Measure net workforce movement
-   Compare workforce patterns across departments and job roles
-   Evaluate the effectiveness and limitations of an attrition
    prediction model

The dashboard is intended as a decision-support solution. Predicted
attrition risk should support, not replace, appropriate HR and
management judgment.

------------------------------------------------------------------------

## Technology Stack

  -----------------------------------------------------------------------
  Technology                          Purpose
  ----------------------------------- -----------------------------------
  Power BI Desktop                    Data modeling, DAX, interactive
                                      dashboards, visualization

  Power Query                         Data preparation and transformation

  DAX                                 KPIs, workforce metrics, risk
                                      measures, and model evaluation

  CSV                                 Current Power BI project data
                                      source

  SQL Server / T-SQL                  Production-style relational tables
                                      and analytical views

  Python                              Data preparation and machine
                                      learning

  Machine Learning                    Employee attrition probability
                                      prediction and risk classification
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Current Data Source

The current Power BI report uses **CSV files**.

Typical project data files include:

``` text
data/
├── employees.csv
├── attrition_predictions.csv
└── model_metrics.csv
```

The CSV implementation makes the portfolio project portable and easy to
run without requiring a SQL Server instance.

### Employees

Contains employee and workforce attributes such as:

-   Employee Key
-   Age
-   Gender
-   Department
-   Job Role
-   Hire Date
-   Termination Date
-   Snapshot Date
-   Attrition Flag
-   Monthly Salary
-   Tenure Years
-   Job Satisfaction
-   Performance Rating
-   Overtime Flag
-   Commute Miles
-   Training Hours Monthly
-   Years Since Promotion

### Attrition Predictions

Contains machine-learning prediction results, including:

-   Employee Key
-   Attrition Probability
-   Risk Band
-   Recommended Action

### Model Metrics

Contains model evaluation information used by the Power BI model.

------------------------------------------------------------------------

## SQL Server Architecture

Although CSV files are currently used by Power BI, the repository also
includes a SQL Server implementation that represents how the project
could be deployed in a more production-oriented environment.

SQL script:

``` text
sql/
└── HR_Attrition_Retention_SQL_Tables_Views.sql
```

### SQL Tables

The SQL implementation includes:

-   `dbo.Employees`
-   `dbo.AttritionPredictions`
-   `dbo.ModelMetrics`
-   `dbo.DimDate`

### SQL Views

The following analytical views support reporting and downstream
analytics:

#### `dbo.vw_EmployeeAttritionAnalytics`

Combines employee attributes and model predictions into a
reporting-friendly employee-level dataset.

Includes derived attributes such as:

-   Attrition Status
-   Overtime Status
-   Elevated Risk Flag
-   Low Job Satisfaction Flag
-   Promotion Delay Flag
-   Long Commute Flag
-   Early Tenure Flag

#### `dbo.vw_DepartmentAttritionSummary`

Provides department-level metrics such as:

-   Headcount
-   Attrited Employees
-   Attrition Rate
-   Average Tenure
-   Average Monthly Salary
-   Average Attrition Probability
-   High-Risk Employees
-   Medium-Risk Employees
-   Elevated-Risk Employees

#### `dbo.vw_JobRoleAttritionSummary`

Provides attrition and predicted-risk analysis by department and job
role.

#### `dbo.vw_WorkforceMovement`

Provides monthly workforce movement metrics:

-   New Hires
-   Terminations
-   Net Workforce Change
-   Department
-   Year / Month

#### `dbo.vw_RetentionPriorities`

Supports the Retention Action Center by identifying actionable employee
factors such as:

-   Low Job Satisfaction
-   Working Overtime
-   Promotion Delay
-   Long Commute
-   Early Tenure

#### `dbo.vw_ElevatedRiskEmployees`

Returns employees classified as Medium or High predicted attrition risk
for targeted monitoring and retention analysis.

#### `dbo.vw_ModelOutcomeSummary`

Provides classification outcome metrics using the model probability
threshold:

-   True Positives
-   False Positives
-   False Negatives
-   True Negatives
-   Accuracy
-   Precision
-   Recall

------------------------------------------------------------------------

## Power BI Data Model

The primary model uses the following logical tables:

``` text
Employees
    |
    | EmployeeKey
    v
AttritionPredictions

DimDate
    |
    +---- SnapshotDate  (Active)
    +---- HireDate      (Inactive)
    +---- TerminationDate (Inactive)

ModelMetrics
    (Disconnected model-level metrics)
```

Recommended relationships:

-   `Employees[EmployeeKey]` -\> `AttritionPredictions[EmployeeKey]`
-   `DimDate[Date]` -\> `Employees[SnapshotDate]` - Active
-   `DimDate[Date]` -\> `Employees[HireDate]` - Inactive
-   `DimDate[Date]` -\> `Employees[TerminationDate]` - Inactive

Inactive date relationships are activated in DAX with
`USERELATIONSHIP()` when calculating hiring and termination measures.

------------------------------------------------------------------------

## Dashboard Pages

### 1. Executive Workforce Overview

Provides an executive-level view of workforce health and attrition.

Key content includes:

-   Headcount
-   Attrition Rate
-   High-Risk Employees
-   Average Tenure
-   Average Monthly Income
-   Attrition Rate by Department
-   Attrition Rate by Job Role
-   Employee Risk Distribution
-   Attrition Rate by Job Satisfaction
-   Workforce by Department
-   Employee Terminations Trend

------------------------------------------------------------------------

### 2. Attrition Driver Analysis

Explores workforce characteristics associated with employee turnover.

Key analysis includes:

-   Overtime Attrition Rate
-   Average Tenure of Leavers
-   Average Years Since Promotion for Leavers
-   Average Job Satisfaction for Leavers
-   Attrition Rate by Tenure
-   Attrition Rate by Years Since Promotion
-   Attrition Rate by Overtime
-   Attrition Rate by Job Satisfaction
-   Top Attrition Drivers

The custom driver analysis evaluates factors such as overtime, low job
satisfaction, early tenure, promotion delay, long commute, and lower
salary.

These factors represent observed associations and should not be
interpreted as proof of causation.

------------------------------------------------------------------------

### 3. High-Risk Employee Monitor

Provides an operational view of employees with elevated model-predicted
attrition risk.

Key content includes:

-   High-Risk Employee Worklist
-   Attrition Probability
-   Risk Band
-   Department
-   Job Role
-   Job Satisfaction
-   Tenure
-   High-Risk Employees by Department
-   Employee Risk Profile by Department

The worklist is designed to help users prioritize employee populations
for further review.

------------------------------------------------------------------------

### 4. Retention Action Center

Transforms workforce risk analysis into actionable retention priorities.

Key KPIs include:

-   High-Risk Employees
-   Medium-Risk Employees
-   Low Job Satisfaction Employees
-   Overtime Employees
-   Elevated-Risk Employees

Key visuals include:

-   Retention Priorities
-   Elevated-Risk Retention Priorities
-   Elevated-Risk Employees by Job Role
-   Retention Action Worklist

The page focuses on actionable factors such as overtime, low job
satisfaction, long commute, promotion delay, and early tenure.

------------------------------------------------------------------------

### 5. Workforce Trends

Monitors how the workforce changes over time.

Key KPIs include:

-   New Hires - 24M
-   Terminations - 24M
-   Net Workforce Change - 24M
-   Hiring to Termination Ratio - 24M
-   Average Tenure

Key visuals include:

-   New Hires vs Terminations
-   Net Workforce Change by Month
-   New Hires vs Terminations by Department
-   Net Workforce Change by Department
-   Average Employee Tenure by Department

Positive net workforce movement is displayed in green and negative
movement in red.

------------------------------------------------------------------------

### 6. Model & Probability Insights

Evaluates machine-learning predictions and explains model behavior.

Current model performance displayed in the dashboard:

  Metric              Result
  ----------------- --------
  Model Accuracy       81.0%
  Model Precision      42.1%
  Model Recall          5.8%
  Model F1 Score       10.2%

Prediction outcome summary:

  Outcome             Count
  ----------------- -------
  True Positives         16
  False Positives        22
  False Negatives       261
  True Negatives      1,201

Additional visuals include:

-   Average Predicted Attrition Risk by Department
-   Predicted Attrition Risk by Job Role
-   Attrition Probability Distribution
-   Actual Attrition Rate by Predicted Risk Band
-   Predicted Attrition Risk by Actual Outcome

### Model Interpretation

The model achieves **81.0% overall accuracy**, but recall is only
**5.8%**.

This occurs because the model correctly identifies many employees who
stay, while missing a large number of employees who actually leave. The
high number of False Negatives demonstrates that overall accuracy alone
is not sufficient for evaluating an attrition model.

For a retention use case, future model development should place greater
emphasis on improving recall while monitoring the precision/recall
tradeoff.

------------------------------------------------------------------------

### 7. Definitions & Help

Provides business and technical documentation directly inside the Power
BI report.

Sections include:

-   Workforce Metrics
-   Predicted Attrition Risk
-   Model Performance Metrics
-   Model Interpretation
-   Dashboard Usage Guidance

This page helps business stakeholders understand the meaning and
limitations of the dashboard metrics and predictive model.

------------------------------------------------------------------------

## Selected DAX Measures

### Headcount

``` dax
Headcount =
DISTINCTCOUNT(Employees[EmployeeKey])
```

### Attrited Employees

``` dax
Attrited Employees =
CALCULATE(
    [Headcount],
    Employees[AttritionFlag] = 1
)
```

### Attrition Rate

``` dax
Attrition Rate =
DIVIDE(
    [Attrited Employees],
    [Headcount],
    0
)
```

### High-Risk Employees

``` dax
High-Risk Employees =
CALCULATE(
    DISTINCTCOUNT(AttritionPredictions[EmployeeKey]),
    AttritionPredictions[AttritionProbability] >= 0.65
)
```

### Average Attrition Probability

``` dax
Average Attrition Probability =
AVERAGE(AttritionPredictions[AttritionProbability])
```

### New Hires

``` dax
New Hires =
CALCULATE(
    DISTINCTCOUNT(Employees[EmployeeKey]),
    USERELATIONSHIP(DimDate[Date], Employees[HireDate])
)
```

### Terminations

``` dax
Terminations =
CALCULATE(
    DISTINCTCOUNT(Employees[EmployeeKey]),
    USERELATIONSHIP(DimDate[Date], Employees[TerminationDate])
)
```

### Net Workforce Change

``` dax
Net Workforce Change =
[New Hires] - [Terminations]
```

------------------------------------------------------------------------

## Machine Learning Workflow

The machine-learning portion of the project follows a typical supervised
classification workflow:

``` text
CSV Employee Data
        |
        v
Data Preparation / Feature Engineering
        |
        v
Python ML Training
        |
        v
Attrition Probability
        |
        +---- Risk Band
        |
        +---- Recommended Action
        |
        v
CSV Prediction Output
        |
        v
Power BI
```

The prediction output is joined to employee data through `EmployeeKey`.

The model-generated probability is used throughout the Power BI
dashboard for risk monitoring, retention prioritization, and model
evaluation.

------------------------------------------------------------------------

## CSV-to-SQL Migration Path

The current CSV implementation can be migrated to SQL Server without
redesigning the business logic of the dashboard.

A production-oriented flow could be:

``` text
HR / Source Systems
        |
        v
ETL / Data Pipeline
        |
        v
SQL Server
  ├── Employees
  ├── AttritionPredictions
  ├── ModelMetrics
  └── DimDate
        |
        v
SQL Analytical Views
        |
        v
Power BI Semantic Model
        |
        v
Interactive HR Dashboard
```

Possible future enhancements include:

-   Replace CSV Power BI connections with SQL Server views
-   Add scheduled ETL processing
-   Add incremental refresh
-   Store historical employee snapshots
-   Automate Python model scoring
-   Write prediction results back to SQL Server
-   Add model versioning and evaluation history
-   Implement row-level security
-   Deploy the Power BI semantic model to Microsoft Fabric / Power BI
    Service

------------------------------------------------------------------------

## Running the Project with CSV Files

1.  Clone or download the repository.
2.  Open the Power BI `.pbix` file.
3.  In Power BI, update the CSV source paths if necessary.
4.  Confirm that the employee, prediction, and model metric CSV files
    load successfully.
5.  Refresh the Power BI model.
6.  Verify table relationships.
7.  Review the report pages and slicers.

------------------------------------------------------------------------

## Using the SQL Server Version

The included SQL script provides a database implementation for the
project.

1.  Create or select a SQL Server database.
2.  Run:

``` text
sql/HR_Attrition_Retention_SQL_Tables_Views.sql
```

3.  Load the employee and prediction data into the SQL tables.
4.  Validate the SQL analytical views.
5.  In Power BI, use **Get Data -\> SQL Server**.
6.  Connect Power BI to the required SQL tables or reporting views.
7.  Recreate or map the relationships used by the CSV model.
8.  Refresh and validate the report measures.

> The SQL implementation is included as an architectural and portfolio
> demonstration. The current Power BI report remains configured to use
> CSV files unless the data source is manually changed to SQL Server.

------------------------------------------------------------------------

## Key Portfolio Skills Demonstrated

This project demonstrates practical experience with:

-   Power BI dashboard architecture
-   Executive and operational BI reporting
-   Advanced DAX
-   Power Query
-   Dimensional data modeling
-   SQL Server
-   T-SQL tables and analytical views
-   Date dimensions and inactive relationships
-   Workforce and HR analytics
-   Python machine learning
-   Predictive attrition modeling
-   Classification metrics
-   Model interpretation
-   Retention analytics
-   Business-focused data storytelling
-   Data visualization and conditional formatting
-   CSV-to-database migration architecture

------------------------------------------------------------------------

## Important Notes

-   The dataset used in this portfolio project is synthetic/sample data
    and should not be interpreted as real employee information.
-   Model predictions indicate statistical risk, not certainty.
-   Risk factors should not be interpreted as causal relationships.
-   Predictive analytics should be used responsibly and with appropriate
    human review.
-   The current report uses CSV files; SQL Server objects are provided
    to demonstrate an enterprise-ready data architecture and future
    migration path.

------------------------------------------------------------------------

## Future Enhancements

Potential future versions of the project may include:

-   Microsoft Fabric Lakehouse / Warehouse integration
-   Azure Data Factory or Fabric Data Factory pipelines
-   Automated ML scoring pipelines
-   MLflow model tracking
-   Historical workforce snapshot fact tables
-   SHAP-based model explainability
-   Model drift monitoring
-   Improved recall and threshold optimization
-   Row-level security
-   Power BI Service deployment
-   Automated refresh
-   HR retention recommendation workflows
-   AI-generated narrative insights

------------------------------------------------------------------------

## Project Status

**Current:** Power BI dashboard implemented using CSV data sources.

**Included:** SQL Server tables and analytical views for a
production-style database architecture.

**Analytics:** Seven Power BI pages covering workforce overview,
attrition drivers, employee risk, retention actions, workforce trends,
model evaluation, and definitions/help.

**Machine Learning:** Attrition probability scoring and risk
classification integrated into Power BI.
