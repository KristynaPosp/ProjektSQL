-- Projekt


-- Úkol č. 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

/* 
 * 1) z tabulky s value_type_code zjistíme, který kód náleží mzdám a vyfiltrujeme
 * 2) spojíme tabulky
 * 3) DO klauzule WHERE přidáme name IS NULL, zjistíme, jestli máme nějaké chyby (vyjde 172), dám klauzuli case na případ, kde mi vyjde null (později se mi vyfiltrují a už tam nemám žádné)
 * 4) uděláme průměr mezd (+zaokrouhlení na 2 des.m.) a GROUP BY  jméno a rok
 * 5) potřebujeme tam mít 2 sloupce na roky a platy, takže přidáme ještě jednou tabulku czechia payroll (bude 1 a 2) a přejmenujeme sloupce
 * 6) přidáme sloupec difference (nakonec asi není úplně nezbytný, jen pro info, o kolik)
 * 7) trend roste/klesá/stagnuje pomocí case
 * 8) když chci vědět, kde všude a kdy to klesalo, tak dám to klauzule (where ale nebere nově vzniklé názvy, takže nelze použít trend), takže přes HAVING - 30 výsledných údajů, kdy průměrná mzda klesla
 * 
 * odpověď: Ve většině případů průměrné mzdy pravidelně během roků rostou. Jsou však některá období v průřezu jednotlivými odvětvími, kde došlo i k jejímu poklesu.
 */

SELECT 
	cpib."name",
	cp2.payroll_year AS year_from,
	cp1.payroll_year AS year_to,
	ROUND(AVG(cp2.value), 2) AS avg_salary_from,
	ROUND(AVG(cp1.value), 2) AS avg_salary_to,
	ROUND(AVG(cp1.value), 2) - ROUND(AVG(cp2.value), 2) AS difference,
	CASE 
		WHEN ROUND(AVG(cp1.value), 2) > ROUND(AVG(cp2.value), 2) THEN 'Roste'
		WHEN ROUND(AVG(cp1.value), 2) < ROUND(AVG(cp2.value), 2) THEN 'Klesá'
		WHEN ROUND(AVG(cp1.value), 2) = ROUND(AVG(cp2.value), 2) THEN 'Stagnuje'
		ELSE 'CHYBA'
	END AS trend 
FROM czechia_payroll cp1
JOIN czechia_payroll cp2
	ON cp1.payroll_year = cp2.payroll_year + 1
	AND cp1.industry_branch_code = cp2.industry_branch_code 
JOIN czechia_payroll_industry_branch cpib
	ON cp1.industry_branch_code = cpib.code  
WHERE cp1.value_type_code = '5958'
	AND cp2.value_type_code = '5958'
GROUP BY cpib."name", cp1.payroll_year, cp2.payroll_year 
HAVING ROUND(AVG(cp1.value), 2) < ROUND(AVG(cp2.value), 2)
	OR ROUND(AVG(cp1.value), 2) = ROUND(AVG(cp2.value), 2)
ORDER BY cp1.payroll_year 
	



-- Úkol č. 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

/*
 * 1) najdu si v czechia_price_category code chléb (111301) a mléko (114201)
 * 2) vyfiltruju si info jen pro chléb a mléko
 * 3) filtr czechia price průměrné mzdy, 1. zmínka leden 2006 - tedy czechia payroll beru od 1. kvartálu 2006 + 4. kvartál 2018 pomocí case a přejmenovat
 * 4) spojit ty dvě tabulky dohromady přes join a do společného selectu vybrat vše potřebné + dodělat výsledný počet položek (zaokrouhlujeme dolů, chceme plný počet položek, který si můžeme dovolit)
 * 
 * Odpověď: v 1. kvartálu roku 2006 bylo možné koupit průměrně 1 326 kg chleba a 2 419 litrů mléka a ve 4. kvartálu roku 2018 už jen 819 kg chleba a 1 769 litrů mléka.
 */

SELECT 
	round(avg(
		CASE
			WHEN cp.date_from >= '2006-01-01' AND cp.date_from < '2006-04-01' THEN cp.value 
		END
	)::numeric, 2) AS avg_value_2006_q1,
	round(avg(
		CASE
			WHEN cp.date_from BETWEEN '2018-10-01' AND '2018-12-31' THEN cp.value
		END
	)::numeric, 2) AS avg_value_2018_q4,
	cp.category_code 
FROM czechia_price cp 
WHERE cp.category_code IN ('111301', '114201')
GROUP BY cp.category_code

	




SELECT
	cp.payroll_year,
	round(avg(cp.value), 2) AS avg_value_2006
FROM czechia_payroll cp 
WHERE cp.value_type_code = '5958'
	AND (
		(cp.payroll_year = '2006' AND cp.payroll_quarter = '1')
		OR (cp.payroll_year = '2018' AND cp.payroll_quarter = '4')
	)
GROUP BY cp.payroll_year 




SELECT 
	avg_price.category_code,
    avg_price.avg_value_2006_q1,
    avg_price.avg_value_2018_q4,
    avg_salary.avg_value_2006,
    floor(avg_salary.avg_value_2006 / avg_price.avg_value_2006_q1) AS units_purchasable_2006_q1,
    floor(avg_salary.avg_value_2006 / avg_price.avg_value_2018_q4) AS units_purchasable_2018_q4
FROM 
	(
		SELECT 
			round(avg(
				CASE
					WHEN cp.date_from >= '2006-01-01' AND cp.date_from < '2006-04-01' THEN cp.value 
				END
			)::numeric, 2) AS avg_value_2006_q1,
			round(avg(
				CASE
					WHEN cp.date_from BETWEEN '2018-10-01' AND '2018-12-31' THEN cp.value
				END
			)::numeric, 2) AS avg_value_2018_q4,
			cp.category_code 
		FROM czechia_price cp 
		WHERE cp.category_code IN ('111301', '114201')
		GROUP BY cp.category_code
	) AS avg_price
JOIN 
	(
		SELECT
			cp.payroll_year,
			round(avg(cp.value), 2) AS avg_value_2006
		FROM czechia_payroll cp 
		WHERE cp.value_type_code = '5958'
			AND (
				(cp.payroll_year = '2006' AND cp.payroll_quarter = '1')
				OR (cp.payroll_year = '2018' AND cp.payroll_quarter = '4')
			)
		GROUP BY cp.payroll_year 
	) AS avg_salary
ON (avg_salary.payroll_year = '2006' AND avg_price.category_code  = '111301')
	OR (avg_salary.payroll_year = '2018' AND avg_price.category_code  = '114201')
	
	
	
-- Úkol č. 3 - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
	
/* 
 * 1) spojím si tabulky a vyfiltruji si, co chci vidět
 * 2) převedu si datum jen na rok + přidám k year_to 1 rok a avg value před a po + group by vše, co je nutné
 * 3) přidám si procentuelní nárůst/úbytek
 * 4) uděláme vnořený dotaz with, abychom zjistili průměr pro každou kategorii
 * 
 * Odpověď: Nejpomaleji zdražuje cukr krystalový, jehož procentuelní nárůst je -1,92 %.
 */
	
	
WITH yearly_changes AS (
	SELECT 
		cpc.code,	
		cpc."name",
		round(avg(cp.value)::numeric, 2) AS avg_value_from,
		round(avg(cp2.value)::numeric, 2) AS avg_value_to,
		EXTRACT(YEAR FROM cp.date_from) AS year_from,
		EXTRACT(YEAR FROM cp2.date_from) AS year_to,
		round(((avg(cp2.value) - avg(cp.value)) / avg(cp.value))::numeric * 100, 2) AS percent_change
	FROM czechia_price_category cpc
	LEFT JOIN czechia_price cp
	ON cpc.code = cp.category_code 
	JOIN czechia_price cp2 
		ON cp.category_code = cp2.category_code 
		AND EXTRACT(YEAR FROM cp.date_from) = EXTRACT(YEAR FROM cp2.date_from) - 1
	GROUP BY cpc.code, cpc.name, year_from, year_to
)
SELECT 
	code,
	name,
	ROUND(AVG(percent_change)::numeric, 2) AS avg_yearly_percent_change
FROM yearly_changes
GROUP BY code, name
ORDER BY avg_yearly_percent_change ASC;
	
	
	
	
	

-- Úkol č. 4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
	
/* 
 * 1) vezmu si část tabulky z předchozího úkolu před vnořeným dotazem with
 * 2) přidám klauzuli having percent_change > 10, ale ukáže se mi jen jednotlivé potraviny, já potřebuju za celý rok vše..
 * 3) vyndáme vše nepotřebné (cpc)
 * 
 * Odpověď: V roce 2016 byl meziroční růst cen potravin výrazně vyšší než růst mezd (tedy vyšší než 10 %).
 */	
	
	
	
SELECT 
	EXTRACT(YEAR FROM cp.date_from) AS year_from,
	round(((avg(cp2.value) - avg(cp.value)) / avg(cp.value))::numeric * 100, 2) AS percent_change
FROM czechia_price cp
JOIN czechia_price cp2 
	ON cp.category_code = cp2.category_code 
	AND EXTRACT(YEAR FROM cp.date_from) = EXTRACT(YEAR FROM cp2.date_from) - 1
GROUP BY year_from
HAVING round(((avg(cp2.value) - avg(cp.value)) / avg(cp.value))::numeric * 100, 2) > 10
	
	
	
	
/* Úkol č. 5 - Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * 				projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
 * 1) Vezmu si dotaz z předchozího úkolu, kde vidím nárůst/pokles cen v jednotlivých rokách (bez having)
 * 2) z tabulky economies si připravíme tabulku pro jednotlivé roky 2006 - 2018 hdp pro celý svět?? + uděláme dvakrát, jednou jen pro čr)
 * 3) stejně připravíme další 2 tabulky a budeme mít 3 tabulky s roky 2006 - 2018 a hdp, platy a ceny potravin
 * 4) všechny tabulky spojíme přes rok 
 * 5) pro přehled si můžeme ke každé tabulce přidat klauzuli case a jestli roste/klesá
 * 6) totéž tabulku jen pro čr
 * 
 */


-- CELOSVĚTOVÉ HDP


SELECT 
	value.year_from,
	gdp.gdp_percent_change,
	gdp.trend_gdp,
	value.value_percent_change,
	value.trend_value,
	salary.salary_percent_change,
	salary.trend_salary
FROM 
	(
		SELECT 
			e."year"::integer AS year_from,
			round(((avg(e2.gdp) - avg(e.gdp)) / avg(e.gdp))::NUMERIC * 100, 2) AS gdp_percent_change,
			CASE 
				WHEN avg(e2.gdp) > avg(e.gdp) THEN 'Roste'
				WHEN avg(e.gdp) > avg(e2.gdp) THEN 'Klesá'
			END AS trend_gdp 
		FROM economies e 
		JOIN economies e2 
		ON e.country = e2.country 
		AND e."year" = e2."year" - 1
		GROUP BY e."year", e2."year"
		HAVING e."year" BETWEEN '2006' and '2017'
	) AS gdp		
JOIN 
	(
		SELECT 
			EXTRACT(YEAR FROM cp.date_from)::integer AS year_from,
			round(((avg(cp2.value) - avg(cp.value)) / avg(cp.value))::numeric * 100, 2) AS value_percent_change,
			CASE 
				WHEN avg(cp2.value) > avg(cp.value) THEN 'Zdražení'
				WHEN avg(cp.value) > avg(cp2.value) THEN 'Zlevnění'
			END AS trend_value
		FROM czechia_price cp
		JOIN czechia_price cp2 
			ON cp.category_code = cp2.category_code 
			AND EXTRACT(YEAR FROM cp.date_from) = EXTRACT(YEAR FROM cp2.date_from) - 1
		GROUP BY year_from	
	) AS value 		
ON 	value.year_from = gdp.year_from			
JOIN 
	(
		SELECT 
			cp2.payroll_year::integer AS year_from,
			round(((avg(cp1.value) - avg(cp2.value)) / avg(cp2.value))::NUMERIC * 100, 2) AS salary_percent_change,
			CASE 
				WHEN avg(cp1.value) > avg(cp2.value) THEN 'Roste'
				WHEN avg(cp2.value) > avg(cp1.value) THEN 'Klesá'
			END AS trend_salary
		FROM czechia_payroll cp1
		JOIN czechia_payroll cp2
			ON cp1.payroll_year = cp2.payroll_year + 1
			AND cp1.industry_branch_code = cp2.industry_branch_code 
		WHERE cp1.value_type_code = '5958'
			AND cp2.value_type_code = '5958'
		GROUP BY cp1.payroll_year, cp2.payroll_year 
		HAVING cp2.payroll_year BETWEEN '2006' and '2017' 	
	) AS salary
ON value.year_from = salary.year_from
ORDER BY value.year_from asc
	

-- HDP jen pro ČR
	
SELECT 
	value.year_from,
	gdp.gdp_percent_change,
	gdp.trend_gdp,
	value.value_percent_change,
	value.trend_value,
	salary.salary_percent_change,
	salary.trend_salary
FROM 
	(
		SELECT 
			e."year"::integer AS year_from,
			round(((avg(e2.gdp) - avg(e.gdp)) / avg(e.gdp))::NUMERIC * 100, 2) AS gdp_percent_change,
			CASE 
				WHEN avg(e2.gdp) > avg(e.gdp) THEN 'Roste'
				WHEN avg(e.gdp) > avg(e2.gdp) THEN 'Klesá'
			END AS trend_gdp 
		FROM economies e 
		JOIN economies e2 
		ON e.country = e2.country 
		AND e."year" = e2."year" - 1
		WHERE e.country = 'Czech Republic' AND e2.country = 'Czech Republic'
		GROUP BY e."year", e2."year"
		HAVING e."year" BETWEEN '2006' and '2017'
	) AS gdp		
JOIN 
	(
		SELECT 
			EXTRACT(YEAR FROM cp.date_from)::integer AS year_from,
			round(((avg(cp2.value) - avg(cp.value)) / avg(cp.value))::numeric * 100, 2) AS value_percent_change,
			CASE 
				WHEN avg(cp2.value) > avg(cp.value) THEN 'Zdražení'
				WHEN avg(cp.value) > avg(cp2.value) THEN 'Zlevnění'
			END AS trend_value
		FROM czechia_price cp
		JOIN czechia_price cp2 
			ON cp.category_code = cp2.category_code 
			AND EXTRACT(YEAR FROM cp.date_from) = EXTRACT(YEAR FROM cp2.date_from) - 1
		GROUP BY year_from	
	) AS value 		
ON 	value.year_from = gdp.year_from			
JOIN 
	(
		SELECT 
			cp2.payroll_year::integer AS year_from,
			round(((avg(cp1.value) - avg(cp2.value)) / avg(cp2.value))::NUMERIC * 100, 2) AS salary_percent_change,
			CASE 
				WHEN avg(cp1.value) > avg(cp2.value) THEN 'Roste'
				WHEN avg(cp2.value) > avg(cp1.value) THEN 'Klesá'
			END AS trend_salary
		FROM czechia_payroll cp1
		JOIN czechia_payroll cp2
			ON cp1.payroll_year = cp2.payroll_year + 1
			AND cp1.industry_branch_code = cp2.industry_branch_code 
		WHERE cp1.value_type_code = '5958'
			AND cp2.value_type_code = '5958'
		GROUP BY cp1.payroll_year, cp2.payroll_year 
		HAVING cp2.payroll_year BETWEEN '2006' and '2017' 	
	) AS salary
ON value.year_from = salary.year_from
ORDER BY value.year_from asc	
	
	
	
	
	
	
	
	

		
