-- Úkol č. 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH wages_year AS (
  SELECT
    year,
    dim_code,
    MAX(dim_name)                  AS dim_name,
    AVG(value_czk)                 AS avg_salary_year
  FROM t_kristyna_pospisilova_project_sql_primary_final
  WHERE metric = 'wage'
  GROUP BY year, dim_code
)
SELECT 
  w0.dim_name,
  w0.year       AS year_from,
  w1.year       AS year_to,
  ROUND(w0.avg_salary_year, 2) AS avg_salary_from,
  ROUND(w1.avg_salary_year, 2) AS avg_salary_to,
  ROUND(w1.avg_salary_year - w0.avg_salary_year, 2) AS difference,
  'Klesá' AS trend
FROM wages_year w0
JOIN wages_year w1
  ON w1.dim_code = w0.dim_code
 AND w1.year = w0.year + 1
WHERE w1.avg_salary_year < w0.avg_salary_year
ORDER BY w0.year;
