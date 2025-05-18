-- USER DEFINED FUNCTIONS
	-- Right click on Functions on the left under Schemas section

SET GLOBAL log_bin_trust_function_creators = 1;

SELECT * FROM person;

SELECT hello_world() FROM person;

SELECT *, age(dob) FROM person;

SELECT proper_name('Nitish','F','Y');

SELECT *,proper_name(name,gender,married) FROM person;

SELECT *,format_date(dob) FROM person;

SELECT flights_between('Bangaluru','New Delhi') as num_flights FROM flights;

SELECT COUNT(*) FROM flights
	WHERE source = 'Bangaluru' AND destination = 'New Delhi';
    
    
    
-- ### Make these Functions to run the above queries

-- ### hello_world function
-- CREATE DEFINER=`root`@`localhost` FUNCTION `hello_world`() RETURNS varchar(255) CHARSET utf8mb4
-- BEGIN

-- RETURN 'Hello World';
-- END

-- ### age function
-- CREATE DEFINER=`root`@`localhost` FUNCTION `age`(dob VARCHAR(255)) RETURNS int
-- BEGIN
--     SET dob = STR_TO_DATE(dob, '%d-%m-%Y');
-- RETURN (DATEDIFF(DATE(NOW()),dob))/365;
-- END

-- ### proper_name function
-- CREATE DEFINER=`root`@`localhost` FUNCTION `proper_name`(name VARCHAR(255), gender VARCHAR(233), married VARCHAR(255) ) RETURNS varchar(255) CHARSET utf8mb4
-- BEGIN
-- 	DECLARE title VARCHAR(244);
--     SET name = CONCAT(UPPER(LEFT(name,1)),LOWER(SUBSTRING(name,2)));
--     IF gender = 'M' THEN
-- 		SET title = CONCAT('MR',' ',name);
-- 	ELSE
-- 		IF married = 'Y' THEN
-- 			SET title = CONCAT('Mrs',' ',name);
-- 		ELSE 
-- 			SET title = CONCAT('Ms',' ',name);
-- 		END IF;
-- 	END IF;
-- RETURN title;
-- END

-- ### format_date function
-- CREATE DEFINER=`root`@`localhost` FUNCTION `format_date`(doj VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4
-- BEGIN
-- 	SET doj = STR_TO_DATE(doj, '%d-%m-%Y');
-- RETURN DATE_FORMAT(doj,'%D %b %y');
-- END

-- ### flights_between function
-- CREATE DEFINER=`root`@`localhost` FUNCTION `flights_between`(city1 VARCHAR(233), city2 VARCHAR(233)) RETURNS int
-- BEGIN
-- 	
-- RETURN (
-- 	SELECT COUNT(*) FROM flights
-- 	WHERE source = city1 AND destination = city2
-- );
-- END