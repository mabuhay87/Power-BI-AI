# Executive AI Dashboard (Power BI + AI)

## Overview
The **Executive AI Dashboard** is an advanced Power BI analytics project designed to demonstrate modern **AI-assisted business intelligence**, anomaly detection, and executive-level storytelling.

This dashboard combines **financial KPIs, operational metrics, and AI-driven analytics** to help leaders quickly understand revenue performance, operational risks, and drivers of change.

The project demonstrates how Power BI can be used not just for reporting, but for **intelligent monitoring and decision support**.

---

# Key Features

### Executive Overview
High-level KPIs designed for leadership visibility.

Includes:
- Total Revenue
- Gross Margin %
- Revenue YoY %
- Revenue Health Score
- Best / Worst YoY Month indicators

These metrics provide a **quick financial health snapshot**.

---

### AI Driver Analysis
Uses Power BI's built-in AI visuals to identify factors driving business performance.

Includes:
- **Key Influencers Visual**
  - Explains drivers of:
    - Revenue
    - Gross Margin %

Example drivers analyzed:
- Region
- Product Category
- Customer Segment
- Discount %
- Units Sold

---

### AI Insights
A deeper analytical page combining:

- **Decomposition Tree**
- Dynamic executive insight summary
- Revenue vs support ticket analysis

This page answers questions such as:

- What factors drive revenue performance?
- Where are margins strongest?
- Which segments contribute the most revenue?

---

### Performance Explorer
Interactive exploration page allowing users to analyze performance trends.

Includes visuals such as:

- Revenue by Month
- Revenue by Region
- Revenue by Category
- Revenue by Customer Segment

This page helps analysts **slice and explore performance across business dimensions**.

---

### Daily Performance Monitoring
Operational monitoring page showing short-term trends and risks.

Includes:

- Daily Revenue Trend
- 7-Day Moving Average
- Support Ticket Spikes
- Revenue Anomaly Flag
- Revenue Health Score

This page helps detect:

- revenue volatility
- operational spikes
- potential service issues affecting customers

---

### Revenue Anomaly Detection
Statistical anomaly detection is implemented using a **28-day rolling Z-Score model**.

Formula:

Revenue Z-Score =  
(Current Revenue - Rolling 28-day Average) ÷ Rolling 28-day Standard Deviation

Interpretation:

| Z-Score | Meaning |
|------|------|
| ≥ 2.5 | Revenue spike |
| ≤ −2.5 | Revenue drop |
| -2.5 to 2.5 | Normal variation |

Anomalies are automatically flagged and highlighted in the dashboard.

---

### Revenue Health Score
A composite score (0-100) measuring overall revenue performance.

Factors included:

- Revenue YoY %
- Gross Margin %
- Ticket Rate per 1K Customers
- Revenue anomaly penalty

Financial metrics are weighted more heavily to align with executive priorities.

Score interpretation:

| Score | Health |
|------|------|
| 85-100 | Excellent |
| 70-84 | Good |
| 55-69 | Watch |
| <55 | At Risk |

---

# AI Techniques Used

This project demonstrates several AI-style analytical techniques available inside Power BI:

- Key Influencers
- Decomposition Tree
- Rolling statistical anomaly detection
- Moving average trend smoothing
- Composite scoring models
- Conditional anomaly highlighting

---

# Technologies Used

- Power BI Desktop
- DAX
- Statistical Anomaly Detection
- Business Intelligence Modeling

---

# Dashboard Pages

1. Executive Overview  
2. AI Driver Analysis  
3. AI Insights  
4. Performance Explorer  
5. Daily Performance  
6. Revenue Anomaly Audit  

---

# Example Business Questions Answered

- What factors are driving revenue performance?
- Which regions generate the most revenue?
- Are we experiencing abnormal revenue fluctuations?
- How does operational ticket volume impact revenue?
- What is the current overall revenue health?

---

# Project Purpose

This project demonstrates skills in:

- Business intelligence development
- AI-driven analytics
- advanced DAX modeling
- executive dashboard design
- anomaly detection

The goal is to show how **Power BI can be used as an intelligent decision platform rather than just a reporting tool.**

---

# Future Enhancements

Potential improvements include:

- Automated anomaly alerts
- Forecast models
- AI-generated insight summaries
- Real-time data integration
- Customer churn prediction models

---

# Author

Cristina L. Fontenot  
Senior Software Engineer / BI Developer  

Specializing in:
- Power BI
- Data analytics
- AI-driven reporting
- Enterprise dashboard development

---