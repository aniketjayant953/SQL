SELECT DISTINCT Destination FROM flights
UNION 
SELECT DISTINCT Source FROM flights;

SELECT 
    Airline, Route, Dep_Time, Duration, Price
FROM
    flights
WHERE
    Source = 'Banglore'
        AND Destination = 'Delhi';

SELECT Airline, COUNT(*) FROM flights
GROUP BY Airline;

SELECT 
    Source, COUNT(*)
FROM
    (SELECT 
        source
    FROM
        flights UNION ALL SELECT 
        destination
    FROM
        flights) T
GROUP BY T.Source
ORDER BY count(*) desc;

select Date_of_Journey, COUNT(*) FROM flights
GROUP BY Date_of_Journey
