# Supply Chain Stockout Prediction & Inventory Intelligence

**Power BI + Predictive Analytics Portfolio Project**

## Overview

This portfolio dashboard explores inventory availability, demand, inbound supply, stockout patterns, and model-predicted stockout risk. It connects predictive insights with replenishment recommendations across products and warehouses.

> **Data notice:** This project uses synthetic demonstration data. Predictions and replenishment recommendations are decision-support examples, not guarantees or production purchasing instructions.

## Dashboard Pages

| Page | Purpose |
|---|---|
| **1. Executive Overview** | Summarizes inventory, demand, inbound supply, and stockout performance. |
| **2. Stockout Driver Analysis** | Explores inventory conditions associated with stockout observations. |
| **3. Stockout Risk Monitor** | Monitors predicted risk across warehouses and products, including a high-risk worklist. |
| **4. Inventory Replenishment & Action Center** | Prioritizes reorder quantities and products needing review. |
| **5. Supply Chain Trends** | Tracks monthly inventory, demand, inbound supply, stockout days, supply-demand gaps, and lead time. |
| **6. Model & Prediction Insights** | Presents model metrics, predicted probability distributions, risk bands, and predicted risk by warehouse/category. |
| **7. Definitions & Help** | Planned documentation page for metric definitions, interpretation, and dashboard guidance. |

## Data Source

Workbook: `04_supply_chain_stockout_data.xlsx`

Observed workbook tables/sheets include:

- `Warehouses` — warehouse identifiers, names, and regions.
- `Suppliers` — supplier reference data.
- `Products` — product identifiers, SKU, category, supplier, and unit cost.
- `InventoryDaily` — daily inventory, demand, inbound supply, stockout outcomes, and lead times.
- `StockoutPredictions` — prediction date, product, warehouse, probability, risk band, and recommended reorder units.
- `ModelMetrics` — reported model performance values.
- `DimDate` and `DimRiskBand` — reporting dimensions created for date and risk-band filtering.

## Data Model

The report uses dimension-to-fact relationships where possible:

- `Products[ProductKey]` to product keys in inventory and prediction tables.
- `Warehouses[WarehouseKey]` to warehouse keys in inventory and prediction tables.
- `DimDate[Date]` to inventory snapshot dates; prediction-date filtering should be checked independently.
- `DimRiskBand[RiskBand]` to `StockoutPredictions[RiskBand]`.

Use one-to-many, single-direction relationships from dimensions to fact tables where appropriate. Validate date relationships and filter behavior in the actual `.pbix` model before publishing.

## Key Operational Measures

The report includes metrics such as:

- Current Inventory Units
- Total Demand Units
- Total Inbound Units
- Stockout Rate
- Stockout Days
- Average Lead Time Days
- Recommended Reorder Units
- Products Needing Review
- Warehouses Needing Review

**Interpretation note:** Monthly inbound supply exceeding monthly demand does not, by itself, rule out stockouts at individual product-warehouse locations or dates.

## Prediction Measures (DAX)

```dax
High-Risk Predictions =
CALCULATE(
    COUNTROWS(StockoutPredictions),
    StockoutPredictions[RiskBand] = "High"
)

Medium-Risk Predictions =
CALCULATE(
    COUNTROWS(StockoutPredictions),
    StockoutPredictions[RiskBand] = "Medium"
)

Average Predicted Stockout Risk =
AVERAGE(StockoutPredictions[StockoutProbability])

Predicted Inventory Records =
COUNTROWS(StockoutPredictions)
```

The `StockoutProbability` field is a decimal probability; format the average as a percentage in Power BI.

## Model Performance

The supplied `ModelMetrics` table reports:

| Metric | Reported value |
|---|---:|
| Accuracy | 98.95% |
| Recall | 96.47% |
| ROC AUC | 99.94% |

Example measures:

```dax
Model Accuracy =
CALCULATE(MAX(ModelMetrics[Value]), ModelMetrics[Metric] = "Accuracy")

Model Recall =
CALCULATE(MAX(ModelMetrics[Value]), ModelMetrics[Metric] = "Recall")

Model ROC AUC =
CALCULATE(MAX(ModelMetrics[Value]), ModelMetrics[Metric] = "ROC AUC")
```

**Evaluation caveat:** The available project context does not establish whether these scores were measured on training, validation, or held-out test data. They should not be described as verified out-of-sample performance without supporting documentation. Model metrics are stored values and may not change with report slicers.

## Model & Prediction Insights: Observed Results

From the completed report with slicers set to All:

- High-risk predictions: **4,962**.
- Medium-risk predictions: **192**.
- Average predicted stockout risk: **17.3%**.
- Predicted inventory records: approximately **29K**.
- Average predicted risk by band: **Low 0.7%**, **Medium 54.3%**, **High 96.2%**.
- Predicted risk mix by warehouse: approximately **82% Low** and **17% High**, with a small Medium segment.
- Average predicted risk by product category: **Home 18.4%**, **Office 17.8%**, **Electronics 16.5%**, **Industrial 16.4%**.

The probability distribution has a large concentration in the **0–10%** and **90–100%** bins. The exact risk-band cutoff rules have not been verified from the source generation logic, so avoid asserting numeric band thresholds.

## Using the Report

1. Open the Power BI report and begin with **Executive Overview**.
2. Filter by **Date**, **Product**, and **Warehouse** to inspect specific inventory slices.
3. Use **Stockout Driver Analysis** for descriptive patterns; associations do not establish causation.
4. Use **Stockout Risk Monitor** to inspect high-risk prediction records.
5. Use **Inventory Replenishment & Action Center** to compare recommended reorder quantities and review priorities.
6. Use **Supply Chain Trends** to review monthly changes.
7. Use **Model & Prediction Insights** to interpret prediction distributions and the reported model metrics.

Some pages use **Stockout Status** (historical outcome) while prediction-focused pages use **Predicted Risk Band**. These fields describe different concepts and should not be treated as interchangeable.

## Limitations and Responsible Use

- The dataset is synthetic and not representative of a real supply chain.
- Risk probabilities and risk-band definitions require validation before operational use.
- Very high reported model scores warrant scrutiny for leakage, class balance, and evaluation methodology.
- Reorder-unit totals across dates are sums of recommendation records, not necessarily a single current purchase order.
- Forecasts, probabilities, and reorder suggestions should be reviewed alongside inventory policy, lead time, costs, and operational constraints.

## Technology

**Power BI Desktop · Power Query · DAX · Dimensional Data Modeling · Predictive Analytics · Inventory Intelligence**

