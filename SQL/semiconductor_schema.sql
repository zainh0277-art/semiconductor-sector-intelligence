--
-- PostgreSQL database dump
--

\restrict smNKEODTFOay1XNduqf0WiDcnpxS4UycjazHOS7ZhkNDOWNTyeMMvCdGEI0Qw2b

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    company_id integer NOT NULL,
    ticker character varying(10) NOT NULL,
    company_name character varying(100) NOT NULL
);


--
-- Name: companies_company_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.companies ALTER COLUMN company_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.companies_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: financials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financials (
    financial_id integer NOT NULL,
    company_id integer NOT NULL,
    fiscal_year integer NOT NULL,
    revenue numeric(15,2) NOT NULL,
    gross_profit numeric(15,2) NOT NULL,
    operating_income numeric(15,2) NOT NULL,
    net_income numeric(15,2) NOT NULL,
    total_assets numeric(15,2) NOT NULL,
    total_liabilities numeric(15,2) NOT NULL,
    cash_and_equivalents numeric(15,2) NOT NULL,
    total_debt numeric(15,2) NOT NULL,
    operating_cash_flow numeric(15,2) NOT NULL
);


--
-- Name: financials_financial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.financials ALTER COLUMN financial_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.financials_financial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: financials_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financials_staging (
    ticker character varying(10),
    company_name character varying(100),
    fiscal_year integer,
    revenue numeric(15,2),
    gross_profit numeric(15,2),
    operating_income numeric(15,2),
    net_income numeric(15,2),
    total_assets numeric(15,2),
    total_liabilities numeric(15,2),
    cash_and_equivalents numeric(15,2),
    total_debt numeric(15,2),
    operating_cash_flow numeric(15,2)
);


--
-- Name: market_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.market_prices (
    market_price_id integer NOT NULL,
    company_id integer NOT NULL,
    price_date date NOT NULL,
    open_price numeric(15,4),
    high_price numeric(15,4),
    low_price numeric(15,4),
    close_price numeric(15,4),
    adjusted_close numeric(15,4),
    volume bigint
);


--
-- Name: market_prices_market_price_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.market_prices ALTER COLUMN market_price_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.market_prices_market_price_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: market_prices_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.market_prices_staging (
    price_date date,
    adjusted_close numeric(15,4),
    close_price numeric(15,4),
    high_price numeric(15,4),
    low_price numeric(15,4),
    open_price numeric(15,4),
    volume bigint,
    ticker character varying(10)
);


--
-- Name: vw_annual_market_returns; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_annual_market_returns AS
 WITH ranked_prices AS (
         SELECT market_prices.company_id,
            (EXTRACT(year FROM market_prices.price_date))::integer AS market_year,
            market_prices.adjusted_close,
            row_number() OVER (PARTITION BY market_prices.company_id, (EXTRACT(year FROM market_prices.price_date)) ORDER BY market_prices.price_date) AS first_rank,
            row_number() OVER (PARTITION BY market_prices.company_id, (EXTRACT(year FROM market_prices.price_date)) ORDER BY market_prices.price_date DESC) AS last_rank
           FROM public.market_prices
        ), annual_prices AS (
         SELECT ranked_prices.company_id,
            ranked_prices.market_year,
            max(
                CASE
                    WHEN (ranked_prices.first_rank = 1) THEN ranked_prices.adjusted_close
                    ELSE NULL::numeric
                END) AS start_price,
            max(
                CASE
                    WHEN (ranked_prices.last_rank = 1) THEN ranked_prices.adjusted_close
                    ELSE NULL::numeric
                END) AS end_price
           FROM ranked_prices
          GROUP BY ranked_prices.company_id, ranked_prices.market_year
        )
 SELECT company_id,
    market_year,
    round((((end_price - start_price) / NULLIF(start_price, (0)::numeric)) * (100)::numeric), 2) AS annual_return_pct
   FROM annual_prices;


--
-- Name: vw_dashboard_financials; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_dashboard_financials AS
 SELECT c.company_id,
    c.ticker,
    c.company_name,
    f.fiscal_year,
    f.revenue,
    f.gross_profit,
    f.operating_income,
    f.net_income,
    f.total_assets,
    f.total_liabilities,
    f.cash_and_equivalents,
    f.total_debt,
    f.operating_cash_flow,
    round(((f.gross_profit / NULLIF(f.revenue, (0)::numeric)) * (100)::numeric), 2) AS gross_margin_pct,
    round(((f.net_income / NULLIF(f.revenue, (0)::numeric)) * (100)::numeric), 2) AS net_profit_margin_pct,
    round(((f.total_debt / NULLIF(f.total_assets, (0)::numeric)) * (100)::numeric), 2) AS debt_to_assets_pct,
    (f.cash_and_equivalents - f.total_debt) AS net_cash_position,
    round(((f.operating_cash_flow / NULLIF(f.revenue, (0)::numeric)) * (100)::numeric), 2) AS operating_cash_flow_margin_pct
   FROM (public.financials f
     JOIN public.companies c ON ((f.company_id = c.company_id)));


--
-- Name: vw_growth_vs_market; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_growth_vs_market AS
 WITH revenue_growth AS (
         SELECT f.company_id,
            f.fiscal_year,
            f.revenue,
            lag(f.revenue) OVER (PARTITION BY f.company_id ORDER BY f.fiscal_year) AS previous_revenue,
            f.net_income
           FROM public.financials f
        )
 SELECT c.ticker,
    c.company_name,
    rg.fiscal_year,
    rg.revenue,
    rg.previous_revenue,
    round((((rg.revenue - rg.previous_revenue) / NULLIF(rg.previous_revenue, (0)::numeric)) * (100)::numeric), 2) AS revenue_growth_pct,
    round(((rg.net_income / NULLIF(rg.revenue, (0)::numeric)) * (100)::numeric), 2) AS net_profit_margin_pct,
    m.annual_return_pct
   FROM ((revenue_growth rg
     JOIN public.companies c ON ((rg.company_id = c.company_id)))
     LEFT JOIN public.vw_annual_market_returns m ON (((rg.company_id = m.company_id) AND (rg.fiscal_year = m.market_year))));


--
-- Name: vw_dashboard_integrated; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_dashboard_integrated AS
 SELECT c.company_id,
    g.ticker,
    g.company_name,
    g.fiscal_year,
    g.revenue,
    g.revenue_growth_pct,
    g.net_profit_margin_pct,
    g.annual_return_pct,
    f.gross_margin_pct,
    f.operating_cash_flow_margin_pct,
    f.debt_to_assets_pct
   FROM ((public.vw_growth_vs_market g
     JOIN public.companies c ON (((g.ticker)::text = (c.ticker)::text)))
     JOIN public.vw_dashboard_financials f ON (((c.company_id = f.company_id) AND (g.fiscal_year = f.fiscal_year))));


--
-- Name: vw_dashboard_market_risk; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_dashboard_market_risk AS
 WITH price_history AS (
         SELECT market_prices.company_id,
            market_prices.price_date,
            market_prices.adjusted_close,
            lag(market_prices.adjusted_close) OVER (PARTITION BY market_prices.company_id ORDER BY market_prices.price_date) AS previous_close,
            max(market_prices.adjusted_close) OVER (PARTITION BY market_prices.company_id ORDER BY market_prices.price_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_peak,
            row_number() OVER (PARTITION BY market_prices.company_id ORDER BY market_prices.price_date) AS first_rank,
            row_number() OVER (PARTITION BY market_prices.company_id ORDER BY market_prices.price_date DESC) AS last_rank
           FROM public.market_prices
        ), metrics AS (
         SELECT price_history.company_id,
            min(price_history.price_date) AS first_date,
            max(price_history.price_date) AS last_date,
            max(
                CASE
                    WHEN (price_history.first_rank = 1) THEN price_history.adjusted_close
                    ELSE NULL::numeric
                END) AS first_price,
            max(
                CASE
                    WHEN (price_history.last_rank = 1) THEN price_history.adjusted_close
                    ELSE NULL::numeric
                END) AS last_price,
            ((stddev_samp(((price_history.adjusted_close - price_history.previous_close) / NULLIF(price_history.previous_close, (0)::numeric))))::double precision * sqrt((252)::double precision)) AS annualized_volatility,
            min(((price_history.adjusted_close - price_history.running_peak) / NULLIF(price_history.running_peak, (0)::numeric))) AS maximum_drawdown
           FROM price_history
          GROUP BY price_history.company_id
        ), returns AS (
         SELECT metrics.company_id,
            metrics.first_date,
            metrics.last_date,
            metrics.first_price,
            metrics.last_price,
            metrics.annualized_volatility,
            metrics.maximum_drawdown,
            (power((metrics.last_price / NULLIF(metrics.first_price, (0)::numeric)), (365.25 / (NULLIF((metrics.last_date - metrics.first_date), 0))::numeric)) - (1)::numeric) AS cagr
           FROM metrics
        )
 SELECT c.company_id,
    c.ticker,
    c.company_name,
    round((r.cagr * (100)::numeric), 2) AS cagr_pct,
    round(((r.annualized_volatility * (100)::double precision))::numeric, 2) AS annualized_volatility_pct,
    round((r.maximum_drawdown * (100)::numeric), 2) AS maximum_drawdown_pct,
    round((((r.cagr)::double precision / NULLIF(r.annualized_volatility, (0)::double precision)))::numeric, 3) AS return_to_risk_ratio
   FROM (returns r
     JOIN public.companies c ON ((r.company_id = c.company_id)));


--
-- Name: vw_financial_market_intelligence; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_financial_market_intelligence AS
 SELECT c.ticker,
    c.company_name,
    f.fiscal_year,
    f.revenue,
    f.net_income,
    f.operating_cash_flow,
    f.total_debt,
    round(((f.net_income / NULLIF(f.revenue, (0)::numeric)) * (100)::numeric), 2) AS net_profit_margin_pct,
    round(((f.operating_cash_flow / NULLIF(f.revenue, (0)::numeric)) * (100)::numeric), 2) AS cash_flow_margin_pct,
    m.annual_return_pct
   FROM ((public.companies c
     JOIN public.financials f ON ((c.company_id = f.company_id)))
     LEFT JOIN public.vw_annual_market_returns m ON (((c.company_id = m.company_id) AND (f.fiscal_year = m.market_year))));


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (company_id);


--
-- Name: companies companies_ticker_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_ticker_key UNIQUE (ticker);


--
-- Name: financials financials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financials
    ADD CONSTRAINT financials_pkey PRIMARY KEY (financial_id);


--
-- Name: market_prices market_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_prices
    ADD CONSTRAINT market_prices_pkey PRIMARY KEY (market_price_id);


--
-- Name: market_prices uq_company_price_date; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_prices
    ADD CONSTRAINT uq_company_price_date UNIQUE (company_id, price_date);


--
-- Name: financials uq_company_year; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financials
    ADD CONSTRAINT uq_company_year UNIQUE (company_id, fiscal_year);


--
-- Name: financials fk_financials_company; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financials
    ADD CONSTRAINT fk_financials_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id);


--
-- Name: market_prices fk_market_company; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_prices
    ADD CONSTRAINT fk_market_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id);



