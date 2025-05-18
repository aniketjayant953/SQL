-- Stored Procedure

CALL hello_world();

SELECT * FROM users;

SET @message = '';
CALL add_user('Ankit', 'ankit@gmail.com',@message);

SELECT @message;

DELETE from users WHERE name = 'Ankit';

CALL users_details('vartika@gmail.com');

SET @total = 0;
CALL place_order(3, 3, '6,7', @total);

SELECT @total;
SELECT * FROM orders;
SELECT * FROM order_details;


-- ### hello_world stored procedure
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `hello_world`()
-- BEGIN
-- 	SELECT "Hello world";
-- END


-- ### add_user stored procedure
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `add_user`(IN input_name VARCHAR(255), IN input_email VARCHAR(255), OUT message VARCHAR(233))
-- BEGIN

-- 	-- chech if input_email exist in user table
--     DECLARE user_count INTEGER;
--     SELECT COUNT(*) INTO user_count FROM users WHERE email = input_email;
-- 	
--     -- insert the new user
--     IF user_count = 0 THEN
-- 		INSERT INTO users (name,email) VALUES (input_name, input_email);
-- 		SET message = 'user inserted';
-- 	ELSE
-- 		SET message = 'user already exist';
--     END IF;
-- 	

-- END

-- ### user_details stored procedure
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `users_details`(IN input_email VARCHAR(255))
-- BEGIN
-- 	DECLARE id INTEGER;
--     SELECT user_id INTO id FROM users WHERE email = input_email;
--     
--     SELECT * FROM orders WHERE user_id = id;
-- END


-- ### place_order stored procedure
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `place_order`(IN input_user_id INT, IN input_r_id INT, IN input_f_ids VARCHAR(20), OUT total_amount INT)
-- BEGIN
-- 	
--     -- insert into orders table
--     DECLARE new_order_id INT;
--     DECLARE f_id1 INT;
--     DECLARE f_id2 INT;
--     
--     SET f_id1 = SUBSTRING_INDEX(input_f_ids, ',', 1);
--     SET f_id2 = SUBSTRING_INDEX(input_f_ids, ',', -1);
--     
--     SELECT MAX(order_id) + 1 INTO new_order_id FROM orders;
--     
--     SELECT SUM(price) INTO total_amount FROM menu
--     WHERE r_id = input_r_id AND f_id IN (f_id1, f_id2);
--     
--     INSERT INTO orders (order_id, user_id, r_id, amount, date) VALUES
--     (new_order_id, input_user_id, input_r_id, total_amount, DATE(NOW()));

-- 	-- insert into orders_details table
--     INSERT INTO order_details (order_id, f_id) VALUES (new_order_id, f_id1), (new_order_id, f_id2);
--     

-- END

