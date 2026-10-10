-- Semiconductor Sector Financial & Market Intelligence
-- PostgreSQL database: semiconductor_analytics_db
-- READ-ONLY documentation and validation queries.
-- Run in pgAdmin Query Tool connected to semiconductor_analytics_db.
-- This script does not modify tables, views, or data.

-- 1. List all user tables and views.
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_type, table_name;

-- 2. Inspect columns and data types for the three main tables.
SELECT table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('companies', 'financials', 'market_prices')
ORDER BY table_name, ordinal_position;

-- 3. Retrieve the exact definitions of the six existing analytical views.
-- Save this output separately if you need to recreate the views.
SELECT viewname,
       pg_get_viewdef(format('%I.%I', schemaname, viewname)::regclass, true) AS view_definition
FROM pg_catalog.pg_views
WHERE schemaname = 'public'
  AND viewname IN (
    'vw_annual_market_returns',
    'vw_financial_market_intelligence',
    'vw_growth_vs_market',
    'vw_dashboard_financials',
    'vw_dashboard_market_risk',
    'vw_dashboard_integrated'
  )
ORDER BY viewname;

-- 4. Verify row counts of main tables.
SELECT 'companies' AS dataset, COUNT(*) AS row_count FROM companies
UNION ALL
SELECT 'financials', COUNT(*) FROM financials
UNION ALL
SELECT 'market_prices', COUNT(*) FROM market_prices;

-- 5. Confirm companies in the dataset.
SELECT company_id, ticker, company_name
FROM companies
ORDER BY ticker;

-- 6. Verify FY2025 financial metrics (values in USD millions).
SELECT c.ticker, f.fiscal_year, f.revenue, f.net_income,
       f.cash_and_equivalents, f.total_debt, f.operating_cash_flow
FROM financials f
JOIN companies c ON c.company_id = f.company_id
WHERE f.fiscal_year = 2025
ORDER BY c.ticker;

-- 7. Verify annual stock returns for market year 2025.
SELECT c.ticker, a.market_year,
       ROUND(a.annual_return_pct::numeric, 2) AS annual_return_pct
FROM vw_annual_market_returns a
JOIN companies c ON a.company_id = c.company_id
WHERE a.market_year = 2025
ORDER BY c.ticker;

-- 8. Confirm available market years and company coverage.
SELECT a.market_year, COUNT(DISTINCT a.company_id) AS companies_covered
FROM vw_annual_market_returns a
GROUP BY a.market_year
ORDER BY a.market_year;

-- NOTE: To save executable CREATE TABLE and CREATE VIEW statements,
-- export the actual database schema using pg_dump (schema-only):
-- pg_dump -U postgres -d semiconductor_analytics_db --schema-only --no-owner --no-privileges -f "SQL/semiconductor_schema.sql"
-- Run that command in PowerShell (not inside pgAdmin SQL editor).
