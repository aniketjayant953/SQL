-- Autocommit
SELECT * FROM person;

SET autocommit = 1; -- won't save the quert executions

UPDATE person SET name = 'rishabh' WHERE ID = 2;

SELECT * FROM person;

-- Transcation
SELECT * FROM person;

START TRANSACTION;

UPDATE person SET balance = 30000 WHERE ID = 1;

UPDATE person SET balance = 25000 WHERE ID = 4;

COMMIT;

START TRANSACTION;

SAVEPOINT A;
UPDATE person SET balance = 30000 WHERE ID = 1;
SAVEPOINT B;
UPDATE person SET balance = 25000 WHERE ID = 4;

ROLLBACK TO B;


START TRANSACTION;

UPDATE person SET balance = 30000 WHERE ID = 1;
COMMIT;
UPDATE person SET balance = 25000 WHERE ID = 4;

ROLLBACK ;
