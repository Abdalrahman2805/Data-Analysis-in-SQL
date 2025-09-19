SELECt *
FROM babynames.baby_names;

ALTER TABLE babynames.baby_names
CHANGE Name name text,
CHANGE YearOFBirth year int,
CHANGE Sex sex text,
CHANGE Number number int;

SELECT name, sum(number) AS sum,
	CASE WHEN count(year) >= 50 THEN "Classic"
		ELSE "Trendy" END AS popularity_type
FROM babynames.baby_names
GROUP BY name
ORDER BY name
LIMIT 5;

SELECT rank() OVER(ORDER BY sum(number) DESC) AS rankn,
	name, 
	sum(number) AS sum
FROM  babynames.baby_names
WHERE sex = "M"
GROUP BY name
ORDER BY rankn;


SELECT name,
	COUNT(year) AS total_occurrences
FROM babynames.baby_names
WHERE year IN (1920, 2020)
AND sex = "F"
GROUP BY name;


