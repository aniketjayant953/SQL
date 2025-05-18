-- VIEWS
  -- Stores a logical table(basically a query)
    
SELECT * FROM airways;

-- Simple Views
CREATE VIEW indigo AS
SELECT * FROM flights 
WHERE Airline = 'Indigo Airline';

 SHOW TABLES;
 
 -- Complex Views - where views are joined tables and subquery
 CREATE VIEW joined_order_data AS
 SELECT order_id, amount, r_name, name, date, delivery_time, delivery_rating, restaurant_rating
 FROM orders t1
 JOIN users t2
 ON t1.user_id = t2.user_id
 JOIN restaurants t3
 ON t1.r_id = t3.r_id;

SELECT r_name, SUM(amount) FROM joined_order_data
GROUP BY r_name; 

UPDATE flights
SET Source = 'Bangaluru'
WHERE Source = 'Banglore';

SELECT * FROM indigo;

UPDATE indigo
SET Source = 'New Delhi'
WHERE Source = 'Delhi';

DROP VIEW indigo;

-- Not Updateable Views if it contains
   -- Aggr Operations
   -- Group By
   -- Join Operation
   
DELETE FROM joined_order_data 
WHERE order_id = 1001;

-- Materialized Views 
	-- Stores actual Table rather than logical table(basically a query)
	-- Exists in Postgre, Oracle
    
