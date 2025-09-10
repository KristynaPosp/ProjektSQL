-- Úkol č. 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH salary AS (
  SELECT year, quarter, ROUND(AVG(value_czk),2) AS avg_salary
  FROM data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
  WHERE metric='wage'
    AND ((year=2006 AND quarter=1) OR (year=2018 AND quarter=4))
  GROUP BY year, quarter
),
prices AS (
  SELECT year, quarter, dim_code, MAX(dim_name) AS dim_name, ROUND(AVG(value_czk),2) AS avg_price
  FROM data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
  WHERE metric='price'
    AND dim_code IN ('111301','114201')  -- chléb, mléko
    AND ((year=2006 AND quarter=1) OR (year=2018 AND quarter=4))
  GROUP BY year, quarter, dim_code
)
SELECT 
  p.dim_code,
  p.dim_name,
  p.year,
  p.quarter,
  s.avg_salary,
  p.avg_price,
  FLOOR(s.avg_salary / p.avg_price) AS units_purchasable
FROM prices p
JOIN salary s USING (year, quarter)
ORDER BY p.dim_code, p.year, p.quarter;
