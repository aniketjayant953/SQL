-- What are the top 5 patients who claimed the highest insurance amounts?
SELECT * FROM (SELECT *,
RANK() OVER(ORDER BY claim DESC) as 'rank'
from insurance) t
WHERE t.rank < 6;

-- What is the average insurance claimed by patients based on the number of children they have?
SELECT children, avg_claim FROM 
(SELECT *,
AVG(claim) OVER(PARTITION BY children) as avg_claim,
ROW_NUMBER() OVER(PARTITION BY children) as 'rank_no'
FROM insurance) t
WHERE t.rank_no = 1;

-- What is the highest and lowest claimed amount by patients in each region?
SELECT region,highest_claim, lowest_claim FROM
(SELECT *,
MAX(claim) OVER(PARTITION BY region) as highest_claim,
MIN(claim) OVER(PARTITION BY region ) as lowest_claim,
ROW_NUMBER() OVER(PARTITION BY region) as 'rank_no'
FROM insurance
WHERE region is NOT NULL) t
WHERE rank_no = 1;


-- What is the percentage of smokers in each age group?


-- What is the difference between the claimed amount of each patient and the first claimed amount of that data?

SELECT *,
(claim - first_claim) as difference FROM
(SELECT *,
FIRST_VALUE(claim) OVER() as first_claim
FROM insurance) t;

-- For each patient, calculate the difference between their claimed amount and the average claimed amount of patients 
-- with the same number of children.
SELECT *, (claim-avg_claim) as difference FROM
(SELECT *,
AVG(claim) OVER(PARTITION BY children) as avg_claim
FROM insurance) t;

-- Show the patient with the highest BMI in each region and their respective rank.
SELECT * FROM
(SELECT *,
DENSE_RANK() OVER(PARTITION BY region ORDER BY bmi desc) as 'group_rank',
DENSE_RANK() OVER(ORDER BY bmi desc) as 'overall_rank'
FROM insurance
WHERE region IS NOT NULL) t
WHERE t.group_rank < 2;

-- Calculate the difference between the claimed amount of each patient and the claimed amount of the patient who has the 
-- highest BMI in their region.

SELECT *, (claim-max_bmi_claim) as difference FROM
(SELECT *,
FIRST_VALUE(claim) OVER(PARTITION BY region ORDER BY bmi desc) as max_bmi_claim
FROM insurance
WHERE region is NOT NULL) t;

-- For each patient, calculate the difference in claim amount between the patient and the patient with the highest claim amount among patients
-- with the same bmi and smoker status, within the same region. Return the result in descending order difference.

SELECT *, (max_claim -claim) as difference FROM
(SELECT *,
MAX(claim) OVER(PARTITION BY region,smoker ) as max_claim
FROM insurance
WHERE region is NOT NULL) t
ORDER BY difference desc;

--  For each patient, find the maximum BMI value among their next three records (ordered by age).
SELECT *,
MAX(bmi) OVER(ORDER BY age
					  ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING) as 'max_bmi_between(1,3 records)'
FROM insurance;

-- For each patient, find the rolling average of the last 2 claims.
SELECT *,
AVG(claim) OVER(ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) as 'roll_avg(over 2 rec)'
FROM insurance;

-- Find the first claimed insurance value for male and female patients, within each region order the data by patient age in ascending order, 
-- and only include patients who are non-diabetic and have a bmi value between 25 and 30.

SELECT region, gender, first_claim FROM 
(SELECT *, 
FIRST_VALUE(claim) OVER (PARTITION BY region, gender ORDER BY age) as first_claim,
ROW_NUMBER() OVER (PARTITION BY region, gender ORDER BY age) as rank_
FROM insurance
WHERE diabetic = 'No' AND bmi BETWEEN 25 and 30 and region IS NOT NULL)t
WHERE t.rank_ = 1;