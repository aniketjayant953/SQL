-- Window Function Part 2
SELECT * FROM
(SELECT  BattingTeam, batter, sum(batsman_run) as total_runs,
DENSE_RANK() OVER (PARTITION BY BattingTeam ORDER BY sum(batsman_run) DESC) as rank_within_team
FROM ipl
GROUP BY BattingTeam, batter) t
WHERE T.rank_within_team < 6
ORDER BY t.BattingTeam, t.rank_within_team;

-- Cumulative SUM

SELECT * FROM
(SELECT 
CONCAT('Match-',CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) as 'match_no',
SUM(batsman_run) AS 'runs_scored' ,
SUM(SUM(batsman_run)) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_runs,
AVG(SUM(batsman_run)) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Average_runs,
AVG(SUM(batsman_run)) OVER (ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS running_average
from ipl 
WHERE batter = 'V Kohli'
GROUP BY ID)  t;

-- Percent total
SELECT f_name, 
(total_value/SUM(total_value) OVER())*100 as percent_total
FROM
(SELECT f_id, SUM(amount) as 'total_value' FROM orders t1
JOIN order_details t2
on t1.order_id = t2.order_id
where r_id = 3
GROUP BY f_id) t
JOIN food t3
ON t.f_id = t3.f_id
ORDER BY percent_total desc;

-- Percent Change MoM
SELECT YEAR(Date), MONTHNAME(Date), SUM(amount) as revenue,
((SUM(amount) - LAG(SUM(amount)) OVER())/LAG(SUM(amount)) OVER())*100 as percent_diff
FROM orders
GROUP BY YEAR(Date), MONTHNAME(Date);

-- Percentile
SELECT
PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY marks) OVER(PARTITION BY branch) as 'median_marks',
PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY marks) OVER(PARTITION BY branch) as 'median_marks'
FROM marks;

-- Outlier Detection
SELECT * FROM
(SELECT *,
PERCENTILE_DISC (0.25) WITHIN GROUP (ORDER BY marks) OVER() as 'Q1',
PERCENTILE_DISC (0.75) WITHIN GROUP (ORDER BY marks) OVER() as 'Q3'
FROM marks) t
WHERE t.marks > t.Q1 - (1.5 * (t.Q3 - t.Q1)) AND
t.marks < t.Q3 - (1.5 * (t.Q3 - t.Q1))
ORDER BY t.student_id;

-- Buckets, NTILE
SELECT *,
NTILE(3) OVER(ORDER BY marks desc) AS 'buckets'
FROM marks;

SELECT brand, model, price,
CASE
	WHEN bucket = 1 THEN 'budget'
    WHEN bucket = 2 THEN 'mid-range'
    WHEN bucket = 3 THEN 'premium'
END AS 'phone_type'
FROM
(SELECT brand, model, price,
NTILE(3) OVER(ORDER BY price) as bucket
FROM smartphones) t;

-- Cumulative distribution
SELECT *,
CUME_DIST() over(ORDER BY marks) as 'Percentile_score'
FROM marks;

-- Partition by on multiple columns
-- cheapest flights
SELECT * FROM
(SELECT Source, Destination, Airline, AVG(price) as avg_fare,
DENSE_RANK() OVER(PARTITION BY Source, Destination ORDER BY AVG(Price)) as 'rank'
FROM flights
GROUP BY Source, Destination, Airline ) t
WHERE t.rank = 1


