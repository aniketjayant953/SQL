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