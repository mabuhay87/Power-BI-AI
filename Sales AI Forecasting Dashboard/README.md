
# Sales Forecasting Dashboard (Power BI + AI)

## Overview
This project demonstrates a Power BI dashboard for forecasting sales using historical data, machine learning forecasting, and scenario simulation.

## Dataset
Located in /data/sales_sample.csv

Columns:
Date, Region, Category, Product, Units, Price, DiscountPct, Revenue

## Dashboard Pages
1. Executive Forecast Overview
2. Historical Sales Analysis
3. AI Forecast
4. Scenario Simulator

## Forecast
Use Power BI Analytics pane to create 12‑month forecast on revenue.

## Scenario Simulation
Create What‑If parameters:
Price Adjustment %
Marketing Impact %

## Example DAX
Scenario Revenue =
SUMX(
    FactSales,
    FactSales[Units] *
    FactSales[Price] *
    (1 + 'Price Adjustment %'[Price Adjustment % Value]/100) *
    (1 + 'Marketing Impact %'[Marketing Impact % Value]/100)
)

## This package adds SQL and Python ML starter files for the Sales Forecasting Dashboard.
Included:
- sql/schema.sql
- sql/views.sql
- python_ml/train_sales_forecast_model.py

Author: Cristina L. Fontenot
