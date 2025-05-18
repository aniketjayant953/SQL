-- DATETIME/TEMPORAL Datatypes

CREATE TABLE Uber_rides(
	ride_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    cab_id INT,
    start_time DATETIME,
    end_time DATETIME
);

SELECT *, CURRENT_DATE(), NOW(), CURRENT_TIME() FROM uber_rides;

INSERT INTO uber_rides (user_id, cab_id, start_time, end_time) VALUES
(22,1,'2023-03-11 10:00:00',NOW());

SELECT *,
DATE(start_time),
TIME(start_time),
YEAR(start_time),
MONTH(start_time),
DAY(start_time),
DAYOFWEEK(start_time),
DAYNAME(start_time),
QUARTER(start_time),
HOUR(start_time),
SECOND(start_time),
MINUTE(start_time),
DAYOFYEAR(start_time),
WEEKOFYEAR(start_time),
LAST_DAY(start_time)
FROM uber_rides;

SELECT start_time, DATE_FORMAT(start_time,'%d-%b-%y'), DATE_FORMAT(start_time,'%l:%i% %p') FROM uber_rides;

-- Implicit/Explicit Data Conversion
SELECT '2023-03-11' > '2023-03-10'; -- string but recognized as date

SELECT '2023-03-11' > '9 Mar 2023'; -- failed to recognize as date so we need to do explicit date conversion

SELECT '2023-03-11'> STR_TO_DATE('9-Mar/2023', '%e-%b/%Y');

-- Date Time Arthmetics
SELECT DATEDIFF(CURRENT_DATE(), '2023-07-21');

SELECT DATEDIFF(end_time,start_time) FROM uber_rides;

SELECT TIMEDIFF(CURRENT_TIME(),'20:00:00');

SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 10 YEAR), 
DATE_SUB(CURRENT_DATE(), INTERVAL 10 YEAR) ; 

-- AUTO_UPDATE -> will auto update time on update query
CREATE TABLE posts(
	post_id INT PRIMARY KEY AUTO_INCREMENT,
	user_id INT,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP
);

SELECT * FROM  posts;

INSERT INTO posts (user_id, content) VALUES (1, 'Hello World');

UPDATE posts
SET content = 'NO more hello world'
WHERE post_id = 1;