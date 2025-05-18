-- Scalar Subquery

select * from movies 
where (gross - budget) = (select Max(gross - budget)
						  from movies);
                          
select count(*) from movies 
where score > (select avg(score)
			   from movies);
               
select * from movies
where year = 2000 and score = (select max(score)
							   from movies 
                               where year = 2000);

select * from movies 
where score =  (select max(score) from movies 
				where votes >(select avg(votes) 
				from movies));


-- Vector subquery
select * from users
where user_id not in (select distinct user_id from orders);


with top_dir as (select director  from movies
					group by director
					order by sum(gross) desc limit 3)
select * from movies
where director in (select * from top_dir);

with stars as (	select star from movies
				where votes > 25000
				group by star
				having avg(score)> 8.5)
select * from movies where star in (select * from stars);

-- Table Subquery
select * from movies where (year, (gross-budget)) in 
(select year, max(gross - budget)
from movies
group by year);

with top_movies as (select genre, max(score) 
					from movies
					where votes > 25000
					group by genre)

select * from movies where (genre, score) in 
(select * from top_movies)
and votes > 25000;


with duo as (select star, director, max(gross) 
			from movies
			group by star, director
			order by max(gross) desc limit 5)
            
select * from movies where (star, director, gross) in 
(select * from duo);


-- -- Correlated Query --- ---


SELECT *
FROM movies m1
WHERE score > (SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre);



with fav_food as (	select name, f_name, count(*) as freq from users A
					join orders B
					on A.user_id = B.user_id
					join order_details C
					on B.order_id = C.order_id
					join food D
					on D.f_id = C.f_id
					group by name, f_name )
                    
select * from fav_food f1
where freq = (select max(freq) 
			  from fav_food f2
			  where f1.name = f2.name );
              
-- Select Subquery

select name, 
(votes/(select sum(votes) from movies))*100 
from movies;

select name, genre, score, 
(select avg(score) from movies m1 
where m1.genre = m2.genre) as avg_score_genre 
from movies m2;

-- From

select r_name, avg_ratings from	(select r_id, avg(restaurant_rating) as avg_ratings 
								from orders 
								group by r_id) A
                                join restaurants B
                                on A.r_id = B.r_id;
                                
-- Having

select genre, avg(score) from movies
group by genre
having avg(score) > (select avg(score) from movies);


-- Insert

SELECT * FROM zomato.loyal_users;
insert into loyal_users
(user_id, name)
select A.user_id, B.name 
from orders A
join users B
on A.user_id = B.user_id
group by user_id, B.name
having count(*) > 3;

update loyal_users
set money = (Select sum(amount)*0.1
			 from orders
             where orders.user_id = loyal_users.user_id);
             


-- Delete
delete from users 
where user_id IN (select user_id from (select user_id from users
where user_id Not in (select distinct user_id  from orders)))