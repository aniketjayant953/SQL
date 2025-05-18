-- Case Study Airways
SELECT * FROM airways;

-- 1. Find the month with most number of flights
SELECT MONTHNAME(date),count(*) 
FROM airways
GROUP BY MONTHNAME(date)
ORDER BY COUNT(*) DESC;

-- 2. Which week day has most costly flights
SELECT DAY(Date), AVG(price) 
FROM airways
GROUP BY DAY(Date)
ORDER BY AVG(price) DESC LIMIT 1;

-- Find number of indigo flights every month
SELECT MONTHNAME(Date), COUNT(*) FROM airways
WHERE Airline = 'Indigo'
GROUP BY MONTHNAME(Date)
ORDER BY MONTHNAME(date);

-- 4. Find list of all flights that depart between 10AM and 2PM from Banglore to Delhi
SELECT * FROM flights
WHERE source = 'Banglore' AND
Destination = 'Delhi'AND
Dep_Time > '10:00:00' AND Dep_Time < '14:00:00';

-- Find the number of flights departing on weekends from Bangalore
SELECT COUNT(*)  FROM airways
WHERE source = 'Banglore' AND
DAYNAME(date) IN ('saturday','sunday');

-- Calculate the arrival time for all flights by adding the duration to the departure time.
ALTER TABLE airways
ADD COLUMN departure DATETIME;

UPDATE airways
SET departure = STR_TO_DATE(CONCAT(date,' ',dep_time),'%Y-%m-%d %H:%i');


ALTER TABLE airways
ADD COLUMN duration_mins INT,
ADD COLUMN arrival DATETIME;

SELECT duration,
REPLACE(REPLACE(SUBSTRING_INDEX(duration, ' ',1),'h',''),'m','')*60 + 
CASE
	WHEN SUBSTRING_INDEX(duration, ' ',-1) = SUBSTRING_INDEX(duration, ' ',1) THEN 0
    ELSE REPLACE(SUBSTRING_INDEX(duration, ' ',-1),'m','')
END AS 'mins'
FROM airways;

UPDATE airways
SET duration_mins = REPLACE(REPLACE(SUBSTRING_INDEX(duration, ' ',1),'h',''),'m','')*60 + 
CASE
	WHEN SUBSTRING_INDEX(duration, ' ',-1) = SUBSTRING_INDEX(duration, ' ',1) THEN 0
    ELSE REPLACE(SUBSTRING_INDEX(duration, ' ',-1),'m','')
END;

UPDATE airways
SET arrival =  DATE_ADD(departure,INTERVAL duration_mins MINUTE);

SELECT TIME(arrival) FROM airways;

-- 	7. Calculate the arrival date for all the flights
SELECT DATE(arrival) FROM airways;

-- Find the number of flights which travel on multiple dates.
SELECT COUNT(*) FROM airways
WHERE DATE(departure) != DATE(arrival);

-- Calculate the average duration of flights between all city pairs. The answer should In xh ym format
SELECT source,destination, 
TIME_FORMAT(SEC_TO_TIME(AVG(Duration_mins)*60),'%kh %im') 'avg_duration'
FROM airways
GROUP BY source,destination;

-- Find all flights which departed before midnight but arrived at their destination after midnight having only 0 stops.
SELECT * 
FROM airways
WHERE Total_Stops = 'non-stop' AND
DATE(departure) < DATE(arrival);

-- Find quarter wise number of flights for each airline
SELECT airline, QUARTER(departure), COUNT(*)
FROM airways
GROUP BY airline, QUARTER(departure);

-- Average time duration for flights that have 1 stop vs more than 1 stops
SELECT 
CASE 
	WHEN total_stops = '1 stop' THEN '1 stop'
    ELSE '> 1 stop'
END 'stops',
TIME_FORMAT(SEC_TO_TIME(AVG(Duration_mins)*60),'%kh %im') as 'avg_duration'
FROM airways
WHERE  total_stops != 'non_stop'
GROUP BY stops;

-- 14. Find all Air India flights in a given date range originating from Delhi
-- 1st Mar 2019 to 10th Mar 2019 

SELECT * FROM airways
WHERE source = 'Delhi' AND
DATE(departure) BETWEEN '2019-03-01' AND '2019-03-10';

-- Find the longest flight of each airline
SELECT airline,
TIME_FORMAT(SEC_TO_TIME(MAX(duration_mins)*60),'%kh %im') as 'max_duration' 
FROM airways
GROUP BY Airline
ORDER BY 'max_duration' DESC;

-- 16. Find all the pair of cities having average time duration > 3 hours
SELECT source, destination, 
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' 
FROM airways
GROUP BY source, destination
HAVING AVG(Duration_mins) > 180;

-- 	17. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi
SELECT DAYNAME(departure) as Weekday,
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM-6AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM-12PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM-6PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM-12AM'
FROM airways
WHERE Source = 'Banglore' AND Destination = 'Delhi'
GROUP BY DAYNAME(departure);

-- 18. Make a weekday vs time grid showing avg flight price from Banglore and Delhi
SELECT DAYNAME(departure) as Weekday,
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM-6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM-12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM-6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM-12AM'
FROM airways
WHERE Source = 'Banglore' AND Destination = 'Delhi'
GROUP BY DAYNAME(departure);

SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM - 6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM - 12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM - 6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM - 12PM'
FROM airways
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure)
ORDER BY DAYOFWEEK(departure) ASC;
