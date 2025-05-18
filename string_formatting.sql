-- LIKE Wildcard
SELECT name FROM movies
WHERE name LIKE 'A____';

SELECT name FROM movies 
WHERE name LIKE '%man';

-- Upper
SELECT upper(name), lower(name) FROM movies;

-- CONCAT
SELECT concat(name, '', director, 10) FROM movies;

SELECT concat_ws('-',name, director) FROM movies;

-- SUBSTRING ,SUBSTR
SELECT name, substr(name,2,5) FROM movies;

SELECT name, substr(name,-5,2) FROM movies;

-- Replace (case sensitive)
SELECT REPLACE('Hello World','world','india');

SELECT name, replace(name,'Man','woman')
FROM movies
WHERE name LIKE '%man%';

-- REVERSE
SELECT reverse("hello");

SELECT  name , reverse(name) FROM movies
WHERE name = reverse(name);

-- length char_length()
SELECT name, length(name), char_length(name) FROM Movies
WHERE length(name) != char_length(name);

-- INSERT
SELECT insert('hello world',7,5,'INDIA');

-- LEFT and RIGHT
SELECT name, LEFT(name,3) FROM movies;

-- REPEAT
SELECT REPEAT(name,3) FROM movies;

-- TRIM
SELECT TRIM('    nitish    ');
SELECT TRIM(BOTH '.' FROM '..........nitish........');
SELECT TRIM(LEADING'.' FROM '..........nitish........');
SELECT TRIM(TRAILING '.' FROM '..........nit.ish........');

-- LTRIM, RTRIM
SELECT LTRIM('      nitish      ');
SELECT RTRIM('      nitish      ');

-- SUBSTRING INDEX (split)
SELECT substring_index("www.campus.in",'.',2);
SELECT substring_index("www.campus.in",'.',-1);

-- STRCMP
SELECT strcmp('delhi','mumbai');
SELECT strcmp('mumbai','delhi');
SELECT strcmp('delhi','delhi');

-- LOCATE -> last parameter mean searching start from that charachter for optimaztion techniques faster query
SELECT LOCATE('w','Hello World',5);

-- LPAD RPAD -> middle parameter indicates total no.of char will show after the query has run
SELECT LPAD('8888888','10','+91');
SELECT RPAD('8888888','10','+91');