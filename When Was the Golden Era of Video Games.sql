-- best_selling_games
SELECT * 
FROM public.game_sales
ORDER BY games_sold DESC
LIMIT 10 ;

-- critics_top_ten_years
SELECT s.year,
	COUNT(*) AS num_games,
	ROUND(AVG(r.critic_score),2) AS avg_critic_score
FROM public.game_sales s
JOIN public.reviews r
ON s.name = r.name
GROUP BY s.year
HAVING Count(*) > 3
ORDER BY avg_critic_score DESC
LIMIT 10;


-- golden_years
SELECT c.year,
	c.num_games,
	c.avg_critic_score,
	u.avg_user_score,
	c.avg_critic_score - u.avg_user_score AS diff
FROM public.users_avg_year_rating u
JOIN public.critics_avg_year_rating c
ON c.year = u.year
WHERE c.avg_critic_score > 9
OR u.avg_user_score > 9
ORDER BY c.year