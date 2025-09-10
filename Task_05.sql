-- Úkol č. 5 - Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH wage_changes AS (
    SELECT
        year,
        ROUND(((AVG(value_czk) - LAG(AVG(value_czk)) OVER (ORDER BY year)) 
               / LAG(AVG(value_czk)) OVER (ORDER BY year)) * 100, 2) AS salary_percent_change,
        CASE 
            WHEN AVG(value_czk) > LAG(AVG(value_czk)) OVER (ORDER BY year) THEN 'Roste'
            WHEN AVG(value_czk) < LAG(AVG(value_czk)) OVER (ORDER BY year) THEN 'Klesá'
        END AS trend_salary
    FROM data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
    WHERE metric = 'wage'
    GROUP BY year
),
price_changes AS (
    SELECT
        year,
        ROUND(((AVG(value_czk) - LAG(AVG(value_czk)) OVER (ORDER BY year)) 
               / LAG(AVG(value_czk)) OVER (ORDER BY year)) * 100, 2) AS price_percent_change,
        CASE 
            WHEN AVG(value_czk) > LAG(AVG(value_czk)) OVER (ORDER BY year) THEN 'Zdražení'
            WHEN AVG(value_czk) < LAG(AVG(value_czk)) OVER (ORDER BY year) THEN 'Zlevnění'
        END AS trend_value
    FROM data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
    WHERE metric = 'price'
    GROUP BY year
),
gdp_world AS (
    SELECT
        year,
        ROUND(((AVG(gdp_current_usd) - LAG(AVG(gdp_current_usd)) OVER (ORDER BY year)) 
               / LAG(AVG(gdp_current_usd)) OVER (ORDER BY year)) * 100, 2) AS gdp_world_percent_change,
        CASE 
            WHEN AVG(gdp_current_usd) > LAG(AVG(gdp_current_usd)) OVER (ORDER BY year) THEN 'Roste'
            WHEN AVG(gdp_current_usd) < LAG(AVG(gdp_current_usd)) OVER (ORDER BY year) THEN 'Klesá'
        END AS gdp_world_trend
    FROM data_academy_content.t_kristyna_pospisilova_project_sql_secondary_final
    GROUP BY year
),
gdp_cz AS (
    SELECT
        year,
        ROUND(((AVG(gdp_current_usd) - LAG(AVG(gdp_current_usd)) OVER (ORDER BY year)) 
               / LAG(AVG(gdp_current_usd)) OVER (ORDER BY year)) * 100, 2) AS gdp_cz_percent_change,
        CASE 
            WHEN AVG(gdp_current_usd) > LAG(AVG(gdp_current_usd)) OVER (ORDER BY year) THEN 'Roste'
            WHEN AVG(gdp_current_usd) < LAG(AVG(gdp_current_usd)) OVER (ORDER BY year) THEN 'Klesá'
        END AS gdp_cz_trend
    FROM data_academy_content.t_kristyna_pospisilova_project_sql_secondary_final
    WHERE country_name = 'Czech Republic'
    GROUP BY year
)
SELECT 
    w.year,
    gw.gdp_world_percent_change, gw.gdp_world_trend,
    gc.gdp_cz_percent_change, gc.gdp_cz_trend,
    p.price_percent_change, p.trend_value,
    w.salary_percent_change, w.trend_salary
FROM wage_changes w
JOIN price_changes p USING (year)
JOIN gdp_world gw USING (year)
JOIN gdp_cz gc USING (year)
ORDER BY w.year;
