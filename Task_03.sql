-- Úkol č. 3 - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
	
WITH price_year AS (
  SELECT
    year,
    dim_code,
    MAX(dim_name)              AS dim_name,
    AVG(value_czk)             AS avg_price_year
  FROM t_kristyna_pospisilova_project_sql_primary_final
  WHERE metric = 'price'
  GROUP BY year, dim_code
),
yearly_changes AS (
  SELECT
    p0.dim_code,
    MAX(p0.dim_name) AS name,
    p0.year          AS year_from,
    p1.year          AS year_to,
    ROUND(((p1.avg_price_year - p0.avg_price_year)
          / NULLIF(p0.avg_price_year,0)) * 100, 2) AS percent_change
  FROM price_year p0
  JOIN price_year p1
    ON p1.dim_code = p0.dim_code
   AND p1.year = p0.year + 1
  GROUP BY p0.dim_code, p0.year, p1.year, p0.avg_price_year, p1.avg_price_year
)
SELECT
  dim_code AS code,
  MAX(name) AS name,
  ROUND(AVG(percent_change)::numeric, 2) AS avg_yearly_percent_change
FROM yearly_changes
GROUP BY dim_code
ORDER BY avg_yearly_percent_change ASC;
