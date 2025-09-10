DROP TABLE IF EXISTS data_academy_content.t_kristyna_pospisilova_project_sql_secondary_final;

CREATE TABLE data_academy_content.t_kristyna_pospisilova_project_sql_secondary_final AS
SELECT
    c.country             AS country_name,
    e.country             AS country_code,
    e."year"::int         AS year,
    ROUND(AVG(e.gdp)::numeric,2)        AS gdp_current_usd,
    ROUND(AVG(e.gini)::numeric,2)       AS gini_index,
    ROUND(AVG(e.population)::numeric,0) AS population
FROM data_academy_content.economies e
JOIN data_academy_content.countries c
  ON c.country = e.country
WHERE e."year" BETWEEN 2006 AND 2018
GROUP BY c.country, e.country, e."year";
