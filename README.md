# Semiconductor Sector Financial & Market Intelligence

### End-to-End Financial Analytics & Business Intelligence Project

**Tech Stack:** Python | Pandas | PostgreSQL | SQL | Power BI | DAX | Excel

## Project Overview

This project explores the financial performance and stock-market behavior of five major semiconductor companies over the 2021–2025 period.

The objective is to combine financial statement analysis, historical market data, risk metrics, and interactive dashboards to support comparative sector research.

## Research Question

**Which semiconductor company demonstrates the strongest combination of revenue growth, profitability, stock-market performance, and financial strength?**

## Companies Analyzed

| Ticker | Company 
| NVDA | NVIDIA |
| AMD | Advanced Micro Devices |
| INTC | Intel |
| AVGO | Broadcom |
| QCOM | Qualcomm |

## Project Architecture

Financial Statements + Historical Market Prices  
↓  
Python Data Collection & Cleaning  
↓  
PostgreSQL Database  
↓  
SQL Analytical Views  
↓  
Power BI Data Model + DAX  
↓  
Interactive Dashboards & Sector Insights

## Dashboard Pages

### 01 — Financial Overview

Analyzes revenue, net income, profit margins, operating cash flow, and year-over-year growth.

### 02 — Market Risk & Return

Explores historical stock prices, normalized performance, annualized volatility, compound annual growth rate, maximum drawdown, and return-to-risk ratios.

### 03 — Sector Intelligence

Combines financial and market metrics to compare growth, profitability, financial strength, and market performance across companies.

## Dashboard Preview

### Financial Overview
![Financial Overview](Images/01_Financial_Overview.png)

### Market Risk & Return
![Market Risk and Return](Images/02_Market_Risk_Return.png)

### Sector Intelligence
![Sector Intelligence](Images/03_Sector_Intelligence.png)

## Key Findings

- NVIDIA demonstrated strong FY2025 revenue growth and profitability in the project dataset.
- Semiconductor companies exhibited different combinations of stock returns and volatility.
- Financial growth and stock-market returns should be evaluated separately rather than assumed to move together.
- Interactive company and year filters support comparative analysis.

## Repository Structure

```text
Data/
├── Cleaned/
└── Raw/

Python/
├── 01_market_data_collection.py
├── 02_market_data_cleaning.py
└── 03_load_market_to_postgresql.py

SQL/
├── semiconductor_database.sql
└── semiconductor_schema.sql

Power BI/
└── Semiconductor_Sector_Intelligence.pbix

Images/
Reports/
README.md
```

## Data Methodology

Financial statement data and historical market-price data were prepared for analysis using Python and PostgreSQL.

Financial figures are reported in USD millions where applicable.

Market returns use historical stock-price observations. Fiscal-year financial metrics and calendar-year stock returns may cover different reporting periods and should not be interpreted as perfectly aligned observations.

## Limitations

- The analysis covers five selected semiconductor companies, not the entire industry.
- Historical returns do not predict future investment performance.
- Financial and market metrics have different reporting frequencies and periods.
- The dashboard is intended for exploratory sector analysis, not investment advice.

## Project Status

Dashboard development and initial SQL-to-Power BI validation completed. Repository documentation and reproducibility review in progress.

## Author

BS Business Data Analytics  
University of Engineering and Technology, Lahore

**Focus Areas**: Data Analytics | Business Intelligence | Financial Analytics