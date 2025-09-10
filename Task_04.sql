-- Úkol č. 4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH wage_changes AS (
    SELECT
        year,
        dim_name,
        ROUND(((AVG(value_czk) - LAG(AVG(value_czk)) OVER (PARTITION BY dim_name ORDER BY year))
              / LAG(AVG(value_czk)) OVER (PARTITION BY dim_name ORDER BY year)) * 100, 2) AS wage_percent_change
    FROM data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
    WHERE metric = 'wage'
    GROUP BY year, dim_name
),
price_changes AS (
    SELECT
        year,
        dim_name,
        ROUND(((AVG(value_czk) - LAG(AVG(value_czk)) OVER (PARTITION BY dim_name ORDER BY year))
              / LAG(AVG(value_czk)) OVER (PARTITION BY dim_name ORDER BY year)) * 100, 2) AS price_percent_change
    FROM data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
    WHERE metric = 'price'
    GROUP BY year, dim_name
),
avg_changes AS (
    SELECT
        w.year,
        AVG(w.wage_percent_change) AS wage_percent_change,
        AVG(p.price_percent_change) AS price_percent_change
    FROM wage_changes w
    JOIN price_changes p
      ON w.year = p.year
    GROUP BY w.year
)
SELECT
    year,
    price_percent_change,
    wage_percent_change,
    (price_percent_change - wage_percent_change) AS price_minus_wage_diff
FROM avg_changes
WHERE (price_percent_change - wage_percent_change) > 10
ORDER BY year;
