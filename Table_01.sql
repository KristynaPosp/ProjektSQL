DROP TABLE IF EXISTS data_academy_content.t_kristyna_pospisilova_project_sql_primary_final;

CREATE TABLE data_academy_content.t_kristyna_pospisilova_project_sql_primary_final (
  metric    text,
  year      int,
  quarter   int,
  dim_code  text,
  dim_name  text,
  value_czk numeric(12,2),
  unit      text
);

INSERT INTO data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
(metric, year, quarter, dim_code, dim_name, value_czk, unit)
SELECT
  'wage'                          AS metric,
  cp.payroll_year::int            AS year,
  cp.payroll_quarter::int         AS quarter,
  cp.industry_branch_code::text   AS dim_code,
  ib.name                         AS dim_name,
  AVG(cp.value)::numeric(12,2)    AS value_czk,
  'Kč'                            AS unit
FROM data_academy_content.czechia_payroll cp
LEFT JOIN data_academy_content.czechia_payroll_industry_branch ib
       ON ib.code = cp.industry_branch_code
WHERE cp.value_type_code = '5958'
GROUP BY cp.payroll_year, cp.payroll_quarter, cp.industry_branch_code, ib.name;

INSERT INTO data_academy_content.t_kristyna_pospisilova_project_sql_primary_final
(metric, year, quarter, dim_code, dim_name, value_czk, unit)
SELECT
  'price'                                       AS metric,
  EXTRACT(YEAR FROM p.date_from)::int           AS year,
  EXTRACT(QUARTER FROM p.date_from)::int        AS quarter,
  p.category_code::text                         AS dim_code,
  pc.name                                       AS dim_name,
  AVG(p.value)::numeric(12,2)                   AS value_czk,
  'Kč'                                          AS unit
FROM data_academy_content.czechia_price p
LEFT JOIN data_academy_content.czechia_price_category pc
       ON pc.code = p.category_code
GROUP BY EXTRACT(YEAR FROM p.date_from)::int,
         EXTRACT(QUARTER FROM p.date_from)::int,
         p.category_code, pc.name;
