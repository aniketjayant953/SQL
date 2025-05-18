-- Display the names of athletes who won a gold medal in the 2008 Olympics and whose height is greater than the average 
-- height of all athletes in the 2008 Olympics.

SELECT * FROM olympics
where year = 2008 and medal = 'Gold' and Height > (select avg(Height) 
													from olympics where Year = 2008);

-- Display the names of athletes who won a medal in the sport of basketball in the 2016 Olympics and whose weight is less 
-- than the average weight of all athletes who won a medal in the 2016 Olympics.

select name from olympics
where Sport = 'basketball' and 
Year = 2016 and 
Medal is not null and 
Weight < (select avg(Weight) 
		  from olympics 
          where Year = 2016 and
          Medal is not null);
          
-- Display the names of all athletes who have won a medal in the sport of swimming in both the 2008 and 2016 Olympics.

select Name, Year, count(*) from olympics A
where Sport = 'Swimming' and Medal is not null and year in (2016,2018)
group by Name, Year
having count(*) > 1;

-- Display the names of all countries that have won more than 50 medals in a single year.
with country_won as (select country from olympics
				where medal is not null and country is not null
				group by country, Year
				having count(*) > 50)

select * from country_won;

-- Display the names of all athletes who have won medals in more than one sport in the same year.

with name_players as 
(select Name from olympics
where Medal is not null
group by Name, Year, Sport
having count(*) > 1
order by count(medal) desc)

select distinct name from name_players ;

-- What is the average weight difference between male and female athletes in the Olympics who have won a medal in the same event?
with result as (select * from olympics where medal is not null)
select B.Event, avg(A.Weight - B.Weight) from  result A
join result B
on A.Event = B.Event 
and A.Sex != B.Sex
group by B.Event;

-- How many patients have claimed more than the average claim amount for patients who are smokers and have at least one child,
-- and belong to the southeast region?

select count(*) from insurance 
where claim >
(select avg(claim) from insurance 
where smoker = 'Yes' and children > 0 and region = 'southeast');

-- How many patients have claimed more than the average claim amount for patients who are not smokers and have a BMI 
-- greater than the average BMI for patients who have at least one child?

select count(*) from insurance where claim >
(select avg(claim) from insurance where smoker = 'No' and bmi >
(select avg(bmi) from insurance
where children > 0));

-- How many patients have claimed more than the average claim amount for patients who have a BMI greater than the 
-- average BMI for patients who are diabetic, have at least one child, and are from the southwest region?

select count(*) from insurance where claim > 
(select avg(claim) from insurance where bmi>
(select avg(bmi) from insurance
where diabetic = 'Yes' and children > 0 and region = 'southwest'));

-- What is the difference in the average claim amount between patients who are smokers and patients who are non-smokers, 
-- and have the same BMI and number of children?

select avg(A.claim - B.claim) from insurance A
join insurance B
on A.bmi = B.bmi and A.smoker != B.smoker and A.children = B.children