SELECT * FROM `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide` LIMIT 1000;

-- Percentage cases by population
SELECT countries_and_territories,date, daily_confirmed_cases, pop_data_2019, 
  (daily_confirmed_cases/pop_data_2019) as Percentage
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`;

-- Percentage death by cases
SELECT countries_and_territories,date, daily_confirmed_cases, daily_deaths, 
  (daily_deaths/(case when daily_confirmed_cases=0 then 1 else daily_confirmed_cases end))*100 as Percentage
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
ORDER BY 1,2;

-- for Egypt Percentage cases by population
SELECT countries_and_territories,date, daily_confirmed_cases, pop_data_2019, 
  (daily_confirmed_cases/pop_data_2019)
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt'
ORDER BY 2;

-- Percentage death by cases
SELECT countries_and_territories,date, daily_confirmed_cases, daily_deaths, 
  (daily_deaths/(case when daily_confirmed_cases=0 then 1 else daily_confirmed_cases end))*100 as Percentage
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt'
ORDER BY 1,2;

-- total death and cases by months for Egypt
SELECT countries_and_territories,year, month, sum(daily_confirmed_cases) as total_cases, 
  sum(daily_deaths) as total_deaths, 
  (sum(daily_deaths)/(case when sum(daily_confirmed_cases)=0 then 1 else sum(daily_confirmed_cases)end))*100 Percentage
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt'
GROUP BY 
  1,2,3
ORDER BY 1,2,3;

-- total death and cases  for Egypt
SELECT countries_and_territories, sum(daily_confirmed_cases) as total_cases, 
  sum(daily_deaths) as total_deaths, 
  (sum(daily_deaths)/(case when sum(daily_confirmed_cases)=0 then 1 else sum(daily_confirmed_cases)end))*100 Percentage
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt'
GROUP BY 
  1
ORDER BY 1;

-- find highest 5 days for cases in Egypt
SELECT countries_and_territories,date, daily_confirmed_cases,
sum(daily_confirmed_cases) over (partition by month, year) as cases_month
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt'
ORDER BY 3 desc
LIMIT 5;

-- find highest 5 days for deaths in Egypt
SELECT countries_and_territories,date, daily_deaths,
sum(daily_deaths) over (partition by month, year) as deaths_month
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt'
ORDER BY 3 desc
LIMIT 5;

-- find highest day for death rate by case in Egypt
SELECT countries_and_territories,date, daily_confirmed_cases, daily_deaths,
  daily_deaths/(case when daily_confirmed_cases=0 then 1 else daily_confirmed_cases end) as rate_death
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
WHERE
  countries_and_territories = 'Egypt' 
ORDER BY 5 desc
LIMIT 5;

-- global 
-- find highst day for cases in the world 
SELECT date, sum(daily_confirmed_cases) as total_cases
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;

-- find highst day for deaths in the world 
SELECT date, sum(daily_deaths) as total_deaths
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;

-- find highst death rate in the world 
SELECT date, sum(daily_deaths) as total_deaths, sum(daily_confirmed_cases) as total_cases,
  (sum(daily_deaths)/(case when sum(daily_confirmed_cases)=0 then 1 else sum(daily_confirmed_cases)end)) rate_death
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
GROUP BY 1
ORDER BY 3 desc
LIMIT 5;

-- find top 5 country in cases
SELECT countries_and_territories , sum(daily_confirmed_cases) as total_cases
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;

-- find top 5 country in deaths
SELECT countries_and_territories , sum(daily_deaths) as total_deaths
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;

-- find top 5 country in rate deaths
SELECT countries_and_territories, sum(daily_deaths) as total_deaths, sum(daily_confirmed_cases) as total_cases,
  (sum(daily_deaths)/(case when sum(daily_confirmed_cases)=0 then 1 else sum(daily_confirmed_cases)end)) as rate_deat 
FROM
  `bigquery-public-data.covid19_ecdc_eu.covid_19_geographic_distribution_worldwide`
GROUP BY 1
ORDER BY 4 desc
LIMIT 5;