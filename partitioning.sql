CREATE DATABASE part_demo;

USE part_demo;
GO

ALTER DATABASE part_demo
ADD FILEGROUP g1;

ALTER DATABASE part_demo
ADD FILEGROUP g2;

ALTER DATABASE part_demo
ADD FILEGROUP g3;

-- добавление файлов в каждую группу
ALTER DATABASE part_demo
ADD FILE
(
	NAME = f1,
	FILENAME = '/home/db_files/f1.ndf'
) TO FILEGROUP g1;

ALTER DATABASE part_demo
ADD FILE
(
	NAME = f2,
	FILENAME = '/home/db_files/f2.ndf'
) TO FILEGROUP g2;

ALTER DATABASE part_demo
ADD FILE
(
	NAME = f3,
	FILENAME = '/home/db_files/f3.ndf'
) TO FILEGROUP g3;

-- Partition Function
CREATE PARTITION FUNCTION my_pf(int) -- функция для трех разделов
AS
RANGE LEFT
FOR VALUES (10, 20)

CREATE PARTITION SCHEME my_ps
AS PARTITION my_pf -- схема основана на функции разделения my_pf
TO (g1, g2, g3) -- и связана с тремя группами файлов (g1, g2, g3)

CREATE TABLE t1 (c1 int, c2 int)
ON my_ps(c1);

-- create table to split
CREATE TABLE t_to_split(c1p int, c2p int);
DECLARE @i INT
SET @i=0;
WHILE (@i<30)
BEGIN
	INSERT INTO t_to_split(c1p, c2p)
	VALUES (@i, @i*2);

	SET @i = @i + 1;
END;

INSERT INTO t1(c1, c2)
SELECT c1p, c2p FROM t_to_split;