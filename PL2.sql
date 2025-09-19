select * from pl.matches2;

alter table pl.matches2
add column d_n text;

update pl.matches2
	set d_n = case
				when time(date) >= "06:30" and time(date) < "19:30" then 'day'
                else 'night'
    end;
    
alter table pl.matches2
change column teamID team text;

select
	team,
    count as points
from pl.matches2
group by 1 order by 2;


select team, h_a , count(*) 
from pl.matches2
group by 1,2
order by 1; 

select team, sum(case when result='w' then 3 when result='l' then 0 when result='d' then 1 end)
from pl.matches2
group by 1 order by 2 desc;

select team, sum(case when result='w' then 1 end) w, sum(case when result='l' then 1 end) l, sum(case when result='d' then 1 end) d, count(*)
from pl.matches2 
where round<20
group by 1 order by 2 desc;
-- analyze

select * from pl.matches2;
 
 select 
	h_a,
    avg(scored) as avg_scored,
    avg(xG) as avg_xg
from
	pl.matches2
group by 1;

 select 
	team,
	h_a,
    avg(scored) as avg_scored,
    avg(xG) as avg_xg
from
	pl.matches2
    where round<20
group by 1,2
order by 1,2 desc;
    

select *
from
	(select 
		team,
		h_a,
		avg(scored) as avg_scored,
		avg(xG) as avg_xg
	from
		pl.matches2
		where round<20
	group by 1,2
	order by 1,2 desc) h
join  (select 
	team,
	h_a,
    avg(scored) as avg_scored,
    avg(xG) as avg_xg
from
	pl.matches2
    where round<20
group by 1,2
order by 1,2 desc) a 
on h.team = a.team and h.h_a != a.h_a
where h.h_a = 'h' and h.h_a<=a.h_a;


select 
	d_n,
    avg(scored+missed) as goals
from
	pl.matches2
where round<20
group by 1;

select * from pl.matches2;

select
	deep,
    avg(scored) avg_goals,
    sum(scored) goals,
    count(*) as matches
from pl.matches2
where round<20
group by 1
order by 2 desc;

select
	deep_allowed,
    avg(missed) avg_missed,
    sum(missed) missed,
    count(*) as matches
from pl.matches2
where round<20
group by 1
order by 2 desc;

select 
	team,
    deep,
    count(deep) as used
from pl.matches2
where round<20
group by 1,2
having count(deep) =(select max(cnt) from(select count(deep) cnt from pl.matches2 where round<20 group by team,deep) as sub)
;
select 
	ran.team,
    total_points,
    max(deep) as deep,
    used,
    row_number() over(order by total_points desc) as ranked
from
	(select
		team,
        deep,
        count(deep) as used,
        rank() over(partition by team order by count(deep) desc) as ranked
	from pl.matches2
    where round<20
    group by 1,2) ran
join
	(select
		team,
        sum(pts) as total_points
	from pl.matches2
    where round<20
    group by 1 ) pts
on ran.team = pts.team
    where ranked=1
    group by 1,2,4
    order by 2 desc;
    
    
    select 
	ran.team,
    total_points,
    max(deep_allowed) as deep_allowed,
    used,
    row_number() over(order by total_points desc) as ranked
from
	(select
		team,
        deep,
        deep_allowed,
        count(deep_allowed) as used,
        rank() over(partition by team order by count(deep_allowed) desc) as ranked
	from pl.matches2
    where round<20
    group by 1,2) ran
join
	(select
		team,
        sum(pts) as total_points
	from pl.matches2
    where round<20
    group by 1 ) pts
on ran.team = pts.team
    where ranked=1
    group by 1,2,4
    order by 2 desc;

    select * from pl.matches2;
	
    
    
SELECT 
    d.team,
    d.total_points,
    scored,
    missed,
    d.deep,
    al.deep_allowed,
    d.ranked
FROM (
    SELECT 
        ran.team,
        total_points,
        scored,
        missed,
        MAX(deep) AS deep,
        used,
        ROW_NUMBER() OVER (ORDER BY total_points DESC) AS ranked
    FROM (
        SELECT
            team,
            deep,
            COUNT(deep) AS used,
            RANK() OVER (PARTITION BY team ORDER BY COUNT(deep) DESC) AS ranked
        FROM pl.matches2
        WHERE round < 20
        GROUP BY team, deep
    ) ran
    JOIN (
        SELECT
            team,
            SUM(pts) AS total_points,
            sum(scored) scored,
            sum(missed) missed
        FROM pl.matches2
        WHERE round < 20
        GROUP BY team
    ) pts
    ON ran.team = pts.team
    WHERE ranked = 1
    GROUP BY ran.team, total_points, used
    ORDER BY total_points DESC
) d
JOIN (
    SELECT 
        ran.team,
        total_points,
        MAX(deep_allowed) AS deep_allowed,
        used,
        ROW_NUMBER() OVER (ORDER BY total_points DESC) AS ranked
    FROM (
        SELECT
            team,
            deep,
            deep_allowed,
            COUNT(deep_allowed) AS used,
            RANK() OVER (PARTITION BY team ORDER BY COUNT(deep_allowed) DESC) AS ranked
        FROM pl.matches2
        WHERE round < 20
        GROUP BY team, deep, deep_allowed
    ) ran
    JOIN (
        SELECT
            team,
            SUM(pts) AS total_points
        FROM pl.matches2
        WHERE round < 20
        GROUP BY team
    ) pts
    ON ran.team = pts.team
    WHERE ranked = 1
    GROUP BY ran.team, total_points, used
    ORDER BY total_points DESC
) al
ON d.team = al.team;

select count(*)/2 from pl.matches2 where round<20 ;

select 
	team,
    max(tot_points) poits,
    sum(xpts) as xpoints,
    max(tot_goal) goals,
    avg(scored) as avg_goals,
    sum(xG) as xg,
    avg(xg) as avg_xg,
    round((sum(scored)/sum(xG))*100) as pres,
    sum(missed) as missed,
    avg(missed) as avg_mised,
    sum(xGA) as xga,
    avg(xGA) as avg_axg
from
	pl.matches2
where round<20
group by 1
order by 2 desc;

select	
	team,
    max(scored-missed) as max_result,
    max(scored),
    max(missed)
from 
	pl.matches2
where
	round<20
group by 1
order by 2 desc;
  
select 
	least(h_team,a_team) as h_team,
    GREATEST(h_team,a_team) as a_team,
    scored,
    missed
from(    
	select 
		h.team h_team,
		a.team a_team,
        h.result,
        h.scored,
        h.missed
	from
		pl.matches2 h, pl.matches2 a
	where 
		h.id != a.id 
		and h.h_a != a.h_a
		and h.xG = a.xGA
		and h.npxG = a.npxGA
		and h.scored = a.missed
		and h.round<20) H_A
group by least(h_team,a_team), greatest(h_team,a_team),scored,missed
order by 4 desc;
    