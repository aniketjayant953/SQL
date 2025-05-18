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