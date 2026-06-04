--============================================================
-- PROJECT:     World Development Indicators 2019-2024
-- AUTHOR:      Andrea Galicia 
-- DATA SOURCE: Our World in Data (ourworldindata.org)
--              ILO Modelled Estimates, via World Bank
--              International Monetary Fund (IMF).
-- DESCRIPTION:  Analysis of key global economic indicators
--              (unemployment, inflation, GDP growth, GDP per capita)
--              during and after the COVID-19 pandemic (2019–2024).
--              Identifies which countries recovered fastest,
--              which have the lowest unemployment, and which
--              present the worst living conditions based on
--              high inflation and low economic growth.

-- TOOLS:       PostgreSQL 18 / pgAdmin 4 / Power BI
-- DATE:         May 2026
-- ============================================================

-- ============================================================
-- Table Creation
-- ============================================================

CREATE TABLE unemployment (
	      entity VARCHAR(100),
	      code VARCHAR(10),
	      year INTEGER, 
	      unemployment_rate NUMERIC(6,2) 
	);
	
	
	CREATE TABLE inflation (
	        entity VARCHAR(100),
	        code VARCHAR(10),
	        year INTEGER, 
	        inflation_rate NUMERIC(8,2)
	);
	
	CREATE TABLE gdp_growth (
	   entity VARCHAR(100),
	   code VARCHAR(10),
	   year INTEGER, 
	   gdp_growth_rate NUMERIC(8,2)
	);
	
	CREATE TABLE gdp_per_capita (
	    entity VARCHAR(100),
	    code   VARCHAR(10),
	    year   INTEGER,
	    gdp_per_capita NUMERIC(12,2)
	);
	
-- ============================================================
-- Data Recognition
-- ============================================================

SELECT COUNT(*) FROM unemployment;
SELECT COUNT(*) FROM inflation;
SELECT COUNT(*) FROM gdp_growth;
SELECT COUNT(*) FROM gdp_per_capita;

SELECT * FROM unemployment;

SELECT * FROM inflation;

SELECT* FROM gdp_growth;

SELECT * FROM gdp_per_capita;

-- ============================================================
-- Analysis 1: Which countries offer better and worse economic conditions?
-- ============================================================
-- Method: Misery Index = AVG(unemployment_rate) + AVG(inflation_rate)
-- Period: 2019-2024 | Higher index = worse conditions for citizens

-- FINDINGS - Best economic stability indicators:

SELECT 
u.entity,
ROUND(AVG(u.unemployment_rate),2) AS avg_unemployment, 
ROUND(AVG(i.inflation_rate),2) AS avg_inflation, 
ROUND(AVG(u.unemployment_rate) + AVG(i.inflation_rate),2) as Misery_Index
FROM unemployment u	
INNER JOIN inflation i
ON u.entity= i.entity
AND u.year = i.year
WHERE u.year BETWEEN 2019 AND 2024
GROUP BY u.entity
ORDER BY misery_index asc;


--These are the countries with the best economic stability indicators:
-- 1. Qatar (1.53):    Driven by its massive natural gas and oil reserves, combined with a small citizen population, 
--    Qatar maintains the lowest index in the dataset, supported by a near-zero unemployment rate of 0.13%.
-- 2. Bahrain (1.77):  Its economy is primarily built on hydrocarbons, positioning it as one of the wealthiest nations.
-- 3. Thailand (2.47): A success story of rapid transformation from an agricultural base to a modern, 
--    export-led industrial economy. It maintains a healthy balance between unemployment (0.92%) and inflation (1.56%).


-- FINDINGS - Worst economic stability indicators:

SELECT 
u.entity,
ROUND(AVG(u.unemployment_rate),2) AS avg_unemployment, 
ROUND(AVG(i.inflation_rate),2) AS avg_inflation, 
ROUND(AVG(u.unemployment_rate) + AVG(i.inflation_rate),2) as Misery_Index
FROM unemployment u	
INNER JOIN inflation i
ON u.entity= i.entity
AND u.year = i.year
WHERE u.year BETWEEN 2019 AND 2024
GROUP BY u.entity
ORDER BY misery_index asc;

--These are the countries with the worse economic stability indicators:
--1. Zimbabwe (262.85):Suffering from extreme poverty caused by devastating hyperinflation (253.94%) and poor economic management. 
--     Despite a relatively moderate unemployment rate of 8.91%, agricultural shocks and political instability
--     keep the index at the highest level in the dataset.
--2. Sudan (188.62): Sudan's poverty is primarily driven by decades of 
--    devastating civil wars, severe political instability, government corruption 
--    and heavy reliance on vulnerable, climate-sensitive agriculture.
--    Unemployment (10.58%) is moderate, but inflation (178.04%) is catastrophic.
--3. Lebanon (138.91):This country is experiencing a severe economic collapse that began in 2019, 
--    fueled by financial mismanagement and sectarian patronage. 
--    With an inflation rate of 127.04%, it represents one of the most drastic financial crises in recent history.

-- ============================================================
-- Analysis 2: Which countries recovered fastest from COVID?
-- ============================================================
-- Method: LAG() window function to compare GDP growth 2020 vs 2021
-- Recovery score = gdp_growth_rate(2021) - gdp_growth_rate(2020)
SELECT 
entity, 
gdp_growth_rate, 
year,
LAG (gdp_growth_rate) OVER (PARTITION BY entity ORDER BY year) as prev_year_growth,
gdp_growth_rate - LAG(gdp_growth_rate) OVER (PARTITION BY entity ORDER BY year) AS recovery
FROM   gdp_growth 
WHERE  year between 2019 and 2021;

--
WITH recovery_data AS (
SELECT 
        entity,
        year,
        gdp_growth_rate,
        LAG(gdp_growth_rate) OVER (PARTITION BY entity ORDER BY year) AS prev_year_growth,
        gdp_growth_rate - LAG(gdp_growth_rate) OVER (PARTITION BY entity ORDER BY year) AS recovery
    FROM gdp_growth
    WHERE year BETWEEN 2019 AND 2021
	)
SELECT *
FROM recovery_data
WHERE year = 2021 AND recovery IS NOT NULL
ORDER BY recovery desc
LIMIT 20;

-- FINDINGS:
--The data reveals that the top recovering countries are highly dependent on 
--international tourism, leisure, and logistics services.
--They show the highest recovery rates after severe 2020 contractions:

-- Macao       (Recovery: 76.86)
-- Maldives    (Recovery: 70.42)
-- Aruba       (Recovery: 38.63)
-- Bahamas     (Recovery: 37.68)

--This is very important to understand because if a new pandemic, 
--a natural disaster, or a global recession hits tomorrow, 
--these economies would collapse again just as fast.

-- In contrast, Taiwan (+3.42% in 2020) and China (+2.34%) never contracted,
-- reflecting more diversified and resilient economic structures.

-- ============================================================
-- Analysis 3: Which countries have the lowest unemployment?
-- ============================================================
-- Method: AVG unemployment rate per country, period 2019-2024

SELECT 
  entity,
  ROUND(AVG(unemployment_rate),2) AS avg_unemployment 
  FROM unemployment	
  WHERE year BETWEEN 2019 AND 2024
  GROUP BY entity
  ORDER BY avg_unemployment asc;

-- FINDINGS:
--The data reveals that the countries with the lowest official unemployment are 
--primarily driven by either highly specialized, wealthy economies heavily reliant on foreign labor
--or agricultural - based economies. 

-- Qatar       (0.13)  - oil wealth,
-- Cambodia    (0.24)  - agricultural economy, 
-- Niger       (0.52)  - agricultural economy
-- Thailand    (0.92)  - diversified export-led economy

 
-- ============================================================
-- END OF ANALYSIS -
-- ============================================================

