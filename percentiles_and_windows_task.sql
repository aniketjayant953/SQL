-- Rank Employee in terms of revenue generation. Show employee id, first name, revenue, and rank

SELECT EmployeeID, FirstName, employee_rev_gen,
DENSE_RANK() OVER (ORDER BY employee_rev_gen desc) as Ranking
FROM
(SELECT A.EmployeeID, A.FirstName, UnitPrice, Quantity, UnitPrice*Quantity as revenue,
SUM(UnitPrice*Quantity) OVER(PARTITION BY EmployeeID) as employee_rev_gen,
ROW_NUMBER() OVER(PARTITION BY EmployeeID) as 'rank'
FROM nw_Employees A
JOIN nw_Orders B
ON A.EmployeeID  = B.EmployeeID 
JOIN `nw_Order_Details` C
ON B.OrderID = C.OrderID) t
WHERE t.rank = 1;

select e.EmployeeID, e.FirstName , sum(od.UnitPrice * od.Quantity) as revenue, 
rank() over(order by sum(od.UnitPrice * od.Quantity) desc) as EmpRank
from nw_Orders o 
join `nw_Order_Details` od 
on od.OrderID = o.OrderID
join nw_Employees e 
on e.EmployeeID = o.EmployeeID
group by e.EmployeeID, e.FirstName
order by EmpRank;

-- Show All products cumulative sum of units sold each month.
SELECT 
YEAR(C.OrderDATE),MONTHNAME(C.OrderDate), 
SUM(SUM(Quantity)) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_sum_of_quantity_sold
FROM nw_Products A
JOIN `nw_order_details` B
ON A.ProductID = B.ProductID
JOIN nw_Orders C
ON B.OrderID = C.OrderID
GROUP BY YEAR(C.OrderDATE),MONTHNAME(C.OrderDate);


-- Show Percentage of total revenue by each suppliers

SELECT SupplierID,CompanyName, total_revenue, (total_revenue/combined_revenue)*100 as percentage
FROM
(SELECT A.SupplierID,A.CompanyName, C.UnitPrice, C.Quantity, C.UnitPrice*C.Quantity as revenue, 
SUM(C.UnitPrice*C.Quantity) OVER(PARTITION BY A.SupplierID) as total_revenue,
SUM(C.UnitPrice*C.Quantity) OVER() as combined_revenue,
ROW_NUMBER() OVER(PARTITION BY A.SupplierID) as row_id
FROM nw_Suppliers A
JOIN nw_Products B
ON A.SupplierID = B.SupplierID
JOIN `nw_Order_Details` C
ON B.ProductID = C.ProductID) t
WHERE row_id = 1
ORDER BY percentage DESC;

select s.SupplierId, sum(od.UnitPrice*od.Quantity) as Revenue, sum(od.UnitPrice*od.Quantity) /
sum(sum(od.UnitPrice*od.Quantity)) over() * 100 as PercentTotalRevenue
from nw_suppliers s 
join nw_Products p 
on p.SupplierId=s.SupplierID
join `nw_Order_Details` od 
on p.ProductID=od.ProductID 
group by s.SupplierId
order by Revenue desc;

-- Show Percentage of total orders by each suppliers

SELECT s.SupplierId, COUNT(DISTINCT od.OrderID) as NumberOfOrder, COUNT(DISTINCT od.OrderID) /
sum(count(distinct od.OrderID)) over() * 100 as PercentTotalOrder
from nw_suppliers s 
join nw_products p 
on p.SupplierId=s.SupplierID
join `nw_order_details` od 
on p.ProductID=od.ProductID 
group by s.SupplierId
order by NumberOfOrder desc; 

-- Show All Products Year Wise report of totalQuantity sold, percentage change from last year.

SELECT  YEAR(C.OrderDate) as `Year`, SUM(B.Quantity) as quan,
((SUM(B.Quantity) - LAG(SUM(B.Quantity)) OVER())/LAG(SUM(B.Quantity)) OVER())*100 as percent
FROM nw_products A
JOIN `nw_order_details` B
ON A.ProductID = B.ProductID
JOIN nw_orders C
ON C.OrderID = B.OrderID
GROUP BY `Year`;

select *, 
100 *(Quantity - lag(Quantity) over(partition  by ProductId order by ProductId, Year))/lag(Quantity) over(partition  by ProductId order by ProductId, Year) PercentageChange
from (select p.ProductID, year(o.OrderDate) Year, sum(od.Quantity)  as 'Quantity'
from nw_Orders o 
join `nw_order_details` od 
on od.OrderID = o.OrderID
join nw_Products p 
on p.ProductID = od.ProductID
group by p.ProductID,year(o.OrderDate)
order by p.ProductID,year(o.OrderDate)) t;


-- For each condition, what is the average satisfaction level of drugs that are "On Label" vs "Off Label"?
SELECT Conditions, Indication, avg_sat FROM
(SELECT *,
AVG(Satisfaction) OVER(PARTITION BY `Conditions`, Indication) as 'avg_sat',
ROW_NUMBER() OVER(PARTITION BY `Conditions`, Indication) as'rank'
FROM drug
WHERE Indication IS NOT NULL) t
WHERE t.rank = 1;

WITH temp_df AS (
        SELECT
            drug.Conditions,
            drug.Indication,
            drug.Satisfaction,
            ROUND(
                AVG(drug.Satisfaction) OVER(
                    PARTITION BY drug.Conditions,
                    drug.Indication
                    ORDER BY drug.Satisfaction 
                    ROWS BETWEEN UNBOUNDED PRECEDING
                        AND UNBOUNDED FOLLOWING
                ),
                2
            ) AS avg_satisfaction,
            DENSE_RANK() OVER(
                PARTITION BY drug.Conditions,
                drug.Indication
                ORDER BY
                    drug.Satisfaction
            ) AS rank_num
        FROM drug
    )
SELECT
    temp_df.Conditions,
    temp_df.Indication,
    temp_df.avg_satisfaction
FROM temp_df
where rank_num = 1;

-- For each drug type (RX, OTC, RX/OTC), what is the average ease of use and satisfaction level of drugs with a price above
-- the median for their type?
SELECT *
(SELECT Type,price,
AVG(EaseOfUse) OVER(PARTITION BY TYPE) avg_ease_of_use, 
AVG(Satisfaction) OVER(PARTITION BY TYPE) avg_satisfaction,
PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY price) OVER(PARTITION BY TYPE) as 'median_price'
FROM drug) t
WHERE t.price > t.median_price;

WITH temp_df as (
    SELECT Type, 
        AVG(EaseOfUse) OVER(PARTITION BY Type) AS avg_ease_of_use,
        AVG(Satisfaction) OVER(PARTITION BY Type) AS avg_satisfaction
    FROM (
        SELECT
            Type, Price,
            PERCENTILE_CONT(0.5) WITHIN GROUP (
                ORDER BY Price
            ) OVER (PARTITION BY Type) AS median_price,
            EaseOfUse,
            Satisfaction
        FROM drug WHERE Type IN ('RX', 'OTC', 'RX/OTC')
    ) AS subquery
    WHERE Price >= median_price
)

SELECT Type, avg_ease_of_use, avg_satisfaction FROM temp_df GROUP BY Type;


-- What is the cumulative distribution of EaseOfUse ratings for each drug type (RX, OTC, RX/OTC)? Show the results in descending 
-- order by drug type and cumulative distribution. Use the built-in method and the manual method by calculating on your own.
-- For the manual method, use the "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW" and see if you get the same results as
-- the built-in method.


SELECT Type, EaseOfUse, 
       COUNT(*) OVER (
            PARTITION BY Type 
            ORDER BY EaseOfUse 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 1.0 / COUNT(*) OVER (PARTITION BY Type) AS cumulative_dist,
        cume_dist() over(
            partition by Type
            order by EaseOfUse
        ) as 'percentile_score'
FROM drug
WHERE Type IN ('RX', 'OTC', 'RX/OTC')
ORDER BY Type, cumulative_dist DESC;

-- What is the median satisfaction level for each medical condition? Show the results in descending order by median 
-- satisfaction level. Don't repeat the same rows of your result.

WITH temp_df AS (
    SELECT drugs.Condition, 
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY drugs.Satisfaction) OVER (PARTITION BY drugs.Condition) AS median_satisfaction
    FROM drugs
)

SELECT temp_df.Condition, temp_df.median_satisfaction 
FROM temp_df 
GROUP BY temp_df.Condition
ORDER BY temp_df.median_satisfaction DESC;

-- What is the running average of the price of drugs for each medical condition? Show the results in ascending order by 
-- medical condition and drug name.
SELECT Conditions, Drug, 
AVG(SUM(price)) OVER(ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as run_avg_price
FROM drug
GROUP BY Conditions, Drug
ORDER BY Conditions, Drug;

SELECT drug.Conditions, drug.Drug, ROUND(drug.Price, 2), 
    ROUND(AVG(drug.Price) OVER (
        PARTITION BY drug.Conditions 
        ORDER BY drug.Drug 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS running_avg_price
FROM drug
ORDER BY drug.Conditions ASC, drug.Drug ASC;

-- What is the percentage change in the number of reviews for each drug between the previous row and the current row? 
-- Show the results in descending order by percentage change. 

SELECT drug.Conditions, drug.Drug, drug.Reviews,
    (drug.Reviews - LAG(drug.Reviews) OVER (
        PARTITION BY drug.Conditions, drug.Drug 
        ORDER BY drug.Reviews DESC)
    ) * 100.0 / LAG(drug.Reviews) OVER (
        PARTITION BY drug.Conditions, drug.Drug 
        ORDER BY drug.Reviews DESC
    ) AS pct_change
FROM drug
ORDER BY pct_change DESC;

-- What is the percentage of total satisfaction level for each drug type (RX, OTC, RX/OTC)? Show the results in descending
--  order by drug type and percentage of total satisfaction.
SELECT type, 
(tot_sat/ SUM(tot_sat) OVER())*100 as percent
FROM
(SELECT type,
SUM(Satisfaction) OVER(PARTITION BY type) as tot_sat,
ROW_NUMBER() OVER(PARTITION BY type) rank_no
FROM drug) t
WHERE t.rank_no = 1
ORDER BY percent DESC;


WITH temp_df AS (
    SELECT Type, Satisfaction,
        ROUND(SUM(Satisfaction) OVER (PARTITION BY Type) * 100.0 / SUM(Satisfaction) OVER (),2) AS pct_total_satisfaction
    FROM drug
    WHERE Type IN ('RX', 'OTC', 'RX/OTC')
    ORDER BY Type ASC, pct_total_satisfaction DESC
)

SELECT 'Type', pct_total_satisfaction FROM temp_df
GROUP BY 'Type';

-- What is the cumulative sum of effective ratings for each medical condition and drug form combination? Show the results 
-- in ascending order by medical condition, drug form and the name of the drug.

SELECT Conditions,
SUM(SUM(Effective)) OVER(PARTITION BY drug.Conditions, drug.Form 
						ORDER BY drug.Drug
						ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_R
FROM drug
WHERE drug = 'Amoxicillin'
GROUP BY Conditions;

SELECT drug.Condition, drug.Form, drug.Drug, 
    drug.Effective, 
    SUM(drugs.Effective) OVER (
        PARTITION BY drug.Conditions, drug.Form 
        ORDER BY drug.Drug 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum_effective
FROM drug
ORDER BY 
    drug.Condition ASC, 
    drug.Form ASC, 
    drug.Drug ASC;

-- What is the rank of the average ease of use for each drug type (RX, OTC, RX/OTC)? Show the results in descending order by
-- rank and drug type.
SELECT DISTINCT type, avg_rat, rank_no FROM
(SELECT *,
DENSE_RANK() OVER(ORDER BY avg_rat) as 'rank_no'
FROM
(SELECT type, 
AVG(EaseOfUse) OVER(PARTITION BY type) as avg_rat
FROM drug) t) t2
ORDER BY rank_no DESC, type DESC;

SELECT Type, EaseOfUse,
    RANK() OVER (
        PARTITION BY Type 
        ORDER BY AVG(EaseOfUse) DESC
    ) AS ease_of_use_rank
FROM drug
WHERE Type IN ('RX', 'OTC', 'RX/OTC')
GROUP BY Type, EaseOfUse
ORDER BY ease_of_use_rank ASC, Type ASC;

-- For each condition, what is the average effectiveness of the top 3 most reviewed drugs?

SELECT Type, EaseOfUse,
    RANK() OVER (
        PARTITION BY Type 
        ORDER BY AVG(EaseOfUse) DESC
    ) AS ease_of_use_rank
FROM drug
WHERE Type IN ('RX', 'OTC', 'RX/OTC')
GROUP BY Type, EaseOfUse
ORDER BY ease_of_use_rank ASC, Type ASC;