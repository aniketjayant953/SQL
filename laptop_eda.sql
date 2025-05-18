-- Laptop Data EDA
SELECT * FROM laptop;

-- Head Tail Sample
SELECT * FROM laptop ORDER BY `index` DESC limit 5;
SELECT * FROM laptop ORDER BY `index` limit 5;
SELECT * FROM laptop 
ORDER BY rand() DESC limit 5;

-- Univariate Analysis
SELECT COUNT(price),
MAX(price) OVER(),
AVG(price) OVER(),
STD(price) OVER(),
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1' 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Price) OVER() AS 'median' 
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3' 
FROM laptop
ORDER BY `index` LIMIT 1;

SELECT COUNT(price)
FROM laptop
WHERE price IS NULL;

-- Outliers
SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1', 
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM laptop) t
WHERE t.price < t.Q1 - (1.5 *(t.Q3 -t.Q1)) OR
t.price < t.Q3 + (1.5 *(t.Q3 -t.Q1));

-- Histogram in SQL!!!!
SELECT t.buckets, REPEAT('=',COUNT(*)/10) FROM
(SELECT price, 
CASE 
	WHEN PRICE BETWEEN 0 AND 25000 THEN '0-250K'
    WHEN PRICE BETWEEN 25000 AND 50000 THEN '25K-50K'
    WHEN PRICE BETWEEN 50000 AND 75000 THEN '50K-75K'
    WHEN PRICE BETWEEN 75000 AND 100000 THEN '75K-100K'
    ELSE '>100K'
END AS 'buckets'
FROM laptop) t
GROUP BY t.buckets;

SELECT Company, COUNT(*) 
FROM laptop
GROUP BY Company;

-- Bivariate Analysis

-- Numerical-Numerical
-- Scatter Plot
SELECT cpu_speed, Price FROM laptop;

SELECT CORR(cpu_speed, Price) FROM laptop;

-- Categorical-Categorical
-- Contengency Table -> Cross Table
SELECT Company, 
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'TS Yes', 
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'TS No' 
FROM laptop
GROUP BY Company;

SELECT Company, 
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) as intel,
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) as amd,
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) as samsung
FROM laptop
GROUP BY Company ;

-- Numerical Categorical
SELECT Company, MIN(Price),
MAX(Price),
AVG(Price) 
FROM laptop
GROUP BY Company;

-- Missing VALUES
UPDATE laptop
SET price = NULL
WHERE `index` IN (1,12,14,22,34);

SELECT * FROM laptop
WHERE price IS NULL;

UPDATE laptop
SET Price = (SELECT AVG(price) FROM laptop)
WHERE Price IS NULL;

-- On the basis of Company
UPDATE laptop l1
SET Price = (SELECT AVG(price) FROM laptop l1 WHERE l2.Company = l1.Company)
WHERE Price IS NULL;

-- On the basis of Company + processor
UPDATE laptop l1
SET Price = (SELECT avg_price FROM (SELECT AVG(price) as avg_price FROM laptop l2 WHERE l2.Company = l1.Company AND l2.cpu_brand = l1.brand_name)t)
WHERE Price IS NULL;


-- Feature Enginnering
ALTER TABLE laptop 
ADD COLUMN ppi INT;

UPDATE laptop
SET ppi = ROUND(SQRT(res_width*res_width + res_height*res_height)/Inches);

ALTER TABLE laptop 
ADD COLUMN screen_size VARCHAR(100) AFTER inches;

UPDATE laptop
SET screen_size = 
CASE 
	WHEN INCHES < 14.0 THEN 'small'
    WHEN INCHES > 14.0 AND inches < 17.0 THEN 'medium'
    ELSE 'large'
END;

SELECT gpu_brand,
CASE When gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE When gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'AMD',
CASE When gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE When gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptop;

SELECT * FROM laptop;