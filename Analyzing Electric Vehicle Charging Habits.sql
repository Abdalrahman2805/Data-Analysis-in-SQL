SELECT *
FROM charging_sessions
LIMIT 5;

-- unique_users_per_garag
SELECT
	garage_id,
	COUNT(DISTINCT user_id) AS num_unique_users
FROM charging_sessions
WHERE user_type = 'Shared'
GROUP BY 1
ORDER BY 2 DESC;

-- most_popular_shared_start_times
SELECT 
	weekdays_plugin,
	start_plugin_hour,
	COUNT(*) AS num_charging_sessions
FROM charging_sessions
WHERE user_type = 'Shared'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

-- long_duration_shared_users
SELECT
	user_id,
	AVG(duration_hours) AS avg_charging_duration
FROM charging_sessions
WHERE user_type = 'Shared'
GROUP BY 1
HAVING AVG(duration_hours) > 10
ORDER BY 2 DESC;

-- total number of charging sessions
SELECT COUNT(*) AS number_of_sessions
FROM charging_sessions;


-- number of unique users and garages
SELECT 
	COUNT(DISTINCT user_id) AS num_users,
	COUNT(DISTINCT garage_id) AS num_garages
FROM charging_sessions;


-- distribution of sessions by user type (Shared vs Private)
SELECT
	user_type,
	COUNT(*) AS num_sessions
FROM charging_sessions
GROUP BY 1;

-- number of sessions per month
SELECT 
	month_plugin,
	COUNT(*) AS num_sessions
FROM charging_sessions
GROUP BY 1
ORDER BY 2 DESC;


-- the peak charging hours
SELECT 
	start_plugin_hour,
	COUNT(*) AS total_sessions
FROM charging_sessions
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Average, Longest and shortest session duration
SELECT AVG(duration_hours) AS avg_duration,
	MAX(duration_hours) AS longest_session,
	MIN(duration_hours) AS shortest_session
FROM charging_sessions;

