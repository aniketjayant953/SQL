-- Window Functions

SELECT * , AVG(marks) OVER (PARTITION BY branch) FROM marks;

SELECT *, 
MIN(marks) Over(), 
MAX(marks) OVER(),
MIN(marks) OVER (PARTITION BY branch),
MAX(marks) OVER (PARTITION BY branch)
FROM marks;

SELECT * FROM   (SELECT *,
				Avg(marks) OVER(PARTITION BY branch) as 'branch_avg'
				FROM marks) t
WHERE t.marks < t.branch_avg;

-- Rank

SELECT *,
CONCAT(branch, '-', ROW_NUMBER() OVER(PARTITION BY branch ORDER BY marks DESC)) as 'row_number',
RANK() OVER(PARTITION BY branch ORDER BY marks DESC) as 'rank',
DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) as 'dense_rank'
FROM marks;

-- Top 2 Customer per month

SELECT * FROM
(SELECT MONTHNAME(date) as 'month', B.name, SUM(amount) as 'total', 
RANK() OVER(PARTITION BY MONTHNAME(date) ORDER BY SUM(amount) desc) as 'month_rank'
FROM orders A
JOIN users B
on A.user_id = B.user_id
GROUP BY  MONTHNAME(date), B.name
ORDER BY MONTHNAME(date)) t
WHERE T.month_rank < 3
ORDER BY `month` desc, month_rank asc;

-- First Value/ Last Value/ Nth Value


-- Topper in every branch
SELECT *,
FIRST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC) as 'first_value(Topper)',
LAST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC
					  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as 'last_value(Loser)'
FROM marks;
 
-- 2nd topper
SELECT *,
NTH_VALUE(name,5) OVER(PARTITION BY branch ORDER BY marks DESC
					  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as 'last_value(2nd topper)'
FROM marks;

-- topper name, branch, marks
SELECT name,loser, branch, topper_marks from
(SELECT *,
FIRST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC) as 'topper',
FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC) as 'topper_marks',
LAST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC
					  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as 'Loser'
FROM marks) t
where t.name = t.topper and t.marks = t.topper_marks;

-- Lag and Lead
SELECT *,
LAG(marks,4) OVER(ORDER BY student_id) as 'lag-4', 
LEAD(marks,2) OVER(ORDER BY student_id) as 'lead-2' 
from marks;

-- Month on month reveue increase
SELECT monthname(date), SUM(amount),
((SUM(amount) - LAG(SUM(amount),1) OVER())/LAG(SUM(amount),1) OVER())*100
from orders
GROUP BY monthname(date)