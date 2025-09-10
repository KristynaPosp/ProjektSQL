Průvodní listina k projektu z SQL

Autor Kristýna Pospíšilová

Zdroj dat Databáze data_academy_content

# Zadání projektu

Cílem projektu je pomocí SQL analyzovat data o mzdách, cenách vybraných potravin a makroekonomických ukazatelích a odpovědět na pět výzkumných otázek

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd
3. Která kategorie potravin zdražuje nejpomaleji (má nejnižší průměrný meziroční nárůst)
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (o více než 10 %)
5. Má výška HDP vliv na změny ve mzdách a cenách potravin Tedy, pokud HDP vzroste výrazněji, projeví se to ve stejném nebo následujícím roce na cenách potravin či mzdách výraznějším růstem

# Popis tvorby finálních tabulek

Primární tabulka

t_kristyna_pospisilova_project_sql_primary_final

- Obsahuje průměrné roční hodnoty mezd a cen potravin v ČR.
- Dimenze
  - metric,
  - year, quarter,
  - dim_code, dim_name – kód a název odvětvípotraviny,
  - value_czk – hodnota v Kč,
  - unit – jednotka (Kč).
- Zdrojem dat byly tabulky czechia_payroll, czechia_payroll_industry_branch, czechia_price, czechia_price_category.

Sekundární tabulka

t_kristyna_pospisilova_project_sql_secondary_final

- Obsahuje makroekonomická data ze zdrojové tabulky economies spojená s countries.
- Dimenze
  - Country_code, country_name,
  - year,
  - gdp_current_usd, gini_index, population.
- Tabulka byla omezena na roky, které se překrývají s primární tabulkou.

# Výzkumné otázky a odpovědi

Otázka 1 Rostou mzdy ve všech odvětvích

Odpověď Ve většině případů mzdy pravidelně rostou. Identifikováno bylo 30 případů, kdy v některém odvětví meziročně poklesly.

Otázka 2 Kolik si lze koupit chleba a mléka

Odpověď

- V 1. kvartálu 2006 cca 1 326 kg chleba a 1 372 litrů mléka.
- Ve 4. kvartálu 2018 cca 1 443 kg chleba a 1 769 litrů mléka.

Otázka 3 Která kategorie potravin zdražuje nejpomaleji

Odpověď Nejpomaleji zdražuje cukr krystalový, jeho průměrný meziroční růst činil −1,92 %.

Otázka 4 Existuje rok, kdy ceny rostly výrazně rychleji než mzdy (10 %)

Odpověď V žádném roce nebyl meziroční růst cen potravin výrazně vyšší než růst mezd (tedy vyšší než 10 %).

Otázka 5 Má HDP vliv na vývoj mezd a cen potravin

Odpověď

- Celosvětově ve stejném roce se projevilo snížením HDP jen zlevnění (2009), ale platy stále rostly (i když se růst zpomaloval ještě i další rok)
- V ČR vezmeme-li jen HDP ČR, v roce 2009 došlo k velkému propadu cen (nejspíše i kvůli celosvětovému HDP), dále se pokles cen mění spíše rokdva roky s odstupem po snížení HDP. U cen dochází k postupnému snižovánízvyšování podle HDP s odstupem roku