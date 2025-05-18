-- LAPTOP DATASET CLEANING

SELECT * FROM laptop;

SELECT COUNT(*) FROM laptop;

-- Cloning data
CREATE TABLE laptops_backup LIKE laptop;

-- Inserting values
INSERT INTO laptops_backup

-- Check Memory Conspumption
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'zomato'
AND TABLE_NAME = 'laptop';

-- Drop column
ALTER TABLE laptop DROP COLUMN `Unnamed: 0`;

-- Drop Null

-- Drop Duplicates
DELETE FROM laptop
WHERE `index` NOT IN
(SELECT MIN(`index`)
FROM laptop
GROUP BY Company, TypeName, Inches, ScreenResolution);

-- Modify column inches
ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1);

-- Clean RAM from GB
UPDATE laptop  t1
SET Ram = (SELECT Ram FROM (SELECT `index`, REPLACE(Ram,'GB','') AS Ram FROM laptop) AS t2 WHERE t1.index = t2.index);

ALTER TABLE laptop MODIFY COLUMN Ram INT;

-- Weight Column
UPDATE laptop  t1
SET Weight  = (SELECT Weight FROM (SELECT `index`, REPLACE(Weight,'kg','') AS Weight  FROM laptop) AS t2 WHERE t1.index = t2.index);

ALTER TABLE laptop MODIFY COLUMN Weight DECIMAL(10,2);

-- Price 
UPDATE laptop  t1
SET Price  = (SELECT Price FROM (SELECT `index`, ROUND(Price) AS Price FROM laptop) AS t2 WHERE t1.index = t2.index);

ALTER TABLE laptop MODIFY COLUMN Price INT;

-- OS
SELECT DISTINCT OPSys FROM laptop;

-- mac
-- windows
-- linux
-- no os
-- Android chrome (others)

UPDATE laptop
SET OpSys = 
CASE 
	WHEN Opsys LIKE '%mac%' THEN 'macos'
    WHEN Opsys LIKE '%Windows%' THEN 'windows'
    WHEN Opsys LIKE '%linux%' THEN 'linux'
    WHEN Opsys LIKE '%No OS%' THEN 'N/A'
    ELSE 'other'
END;
 
-- GPU
ALTER TABLE laptop ADD COLUMN gpu_brand VARCHAR(255) AFTER GPU;
ALTER TABLE laptop ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

UPDATE laptop t1
SET gpu_brand= (SELECT gpu_brand FROM(SELECT `index`, SUBSTRING_INDEX(GPU,' ',1) AS gpu_brand 
				FROM laptop) t2
                WHERE t1.index = t2.index);

UPDATE laptop t1
SET gpu_name = (SELECT gpu_name  FROM(SELECT `index`, REPLACE(GPU,gpu_brand,'') AS gpu_name 
				FROM laptop) t2
                WHERE t1.index = t2.index);
                
ALTER TABLE laptop DROP COLUMN Gpu;

-- CPU

ALTER TABLE laptop 
ADD COLUMN cpu_brand VARCHAR(255) AFTER `Cpu`,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,2) AFTER cpu_name;

UPDATE laptop t1
SET cpu_brand= (SELECT cpu_brand FROM(SELECT `index`,SUBSTRING_INDEX(`Cpu`,' ',1) AS cpu_brand 
				FROM laptop) t2
                WHERE t1.index = t2.index);
                
UPDATE laptop t1
SET cpu_speed= (SELECT cpu_speed FROM(SELECT `index`,CAST(REPLACE(SUBSTRING_INDEX(`Cpu`,' ',-1),'GHz','') AS DECIMAL(10,2)) AS cpu_speed
				FROM laptop) t2
                WHERE t1.index = t2.index);
                
UPDATE laptop t1
SET cpu_name= (SELECT cpu_name FROM(SELECT `index`, REPLACE(REPLACE(cpu,cpu_brand,''), SUBSTRING_INDEX(cpu,' ',-1),'') AS cpu_name
				FROM laptop) t2
                WHERE t1.index = t2.index);

ALTER TABLE laptop DROP COLUMN `cpu`;	

-- Resolution
ALTER TABLE laptop 
ADD COLUMN res_width INT AFTER Screenresolution,
ADD COLUMN res_height INT AFTER res_width;

UPDATE laptop t2
SET res_width = (SELECT res_width FROM(SELECT `index`, SUBSTRING_INDEX(SUBSTRING_INDEX(screenresolution,' ',-1),'x',1) as res_width FROM laptop) t1 WHERE t1.index = t2.index),
res_height = (SELECT res_height FROM (SELECT `index`,SUBSTRING_INDEX(SUBSTRING_INDEX(screenresolution,' ',-1),'x',-1) as res_height FROM laptop) t1 WHERE t1.index = t2.index);

-- Touchscreen
ALTER TABLE laptop 
ADD COLUMN touchscreen INT AFTER res_height;

UPDATE laptop
SET touchscreen = Screenresolution LIKE '%Touch%';

ALTER TABLE laptop 
DROP COLUMN screenresolution;

-- Cpu_Name Less Complex
UPDATE laptop
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

-- Memory SSD HDD
ALTER TABLE laptop 
ADD COLUMN mem_type VARCHAR(255) AFTER memory,
ADD COLUMN primary_storage INT AFTER mem_type,
ADD COLUMN secondary_storage INT AFTER primary_storage;

UPDATE laptop
SET mem_type = 
CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%'  THEN 'SSD'
    WHEN Memory LIKE '%HDD%'  THEN 'HDD'
    WHEN Memory LIKE '%Flash%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END;

SELECT memory, 
REGEXP_SUBSTR(SUBSTRING_INDEX(memory,'+',1),'[0-9]+'),
CASE 
	WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') 
    ELSE 0 
END 
    FROM laptop;
    
UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(memory,'+',1),'[0-9]+'),
secondary_storage = 
CASE 
	WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') 
    ELSE 0 
END; 
 
UPDATE laptop
SET primary_storage =
CASE 
	WHEN primary_storage <= 2 THEN primary_storage*1024
    ELSE primary_storage
END,

secondary_storage =
CASE 
	WHEN secondary_storage <= 2 THEN secondary_storage*1024
    ELSE secondary_storage
END;

ALTER TABLE laptop DROP COLUMN memory;

ALTER TABLE laptop DROP COLUMN gpu_name;

SELECT *  FROM laptop;