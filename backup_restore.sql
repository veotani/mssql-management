-- USE some_db;
CREATE PROCEDURE FullBackup
AS
BEGIN
	BACKUP DATABASE some_db
	TO
	DISK = '/home/db_backup/full/somedb.bak'
	WITH INIT;
END

CREATE PROCEDURE DifferentialBackup
AS
BEGIN
	DECLARE @backupTime DATETIME;
	DECLARE @backupTimeText VARCHAR(50);
	DECLARE @backupFolder VARCHAR(50);
	DECLARE @backupExt VARCHAR(50);
	DECLARE @backupFilePath VARCHAR(100);
	SET @backupTime = CAST(GETDATE() AS DATETIME);
	SET @backupTimeText = LEFT(CONVERT(VARCHAR, @backupTime, 120), 50);
	SET @backupExt = '.bak'
	SET @backupFolder = '/home/db_backup/differential/'
	SET @backupFilePath = CONCAT(@backupFolder, @backupTimeText, @backupExt)
	BACKUP DATABASE some_db
	TO
	DISK = @backupFilePath
	WITH DIFFERENTIAL, INIT;
END

-- USE master;
ALTER PROCEDURE RestoreFromDifferentialBackupByDate
(@dateToRestoreFrom VARCHAR(100))
AS
BEGIN	
	DECLARE @backupFilePath VARCHAR(100);
	SET @backupFilePath = CONCAT('/home/db_backup/differential/', @dateToRestoreFrom, '.bak');

	BACKUP LOG some_db 
	TO DISK = '/home/db_backup/log/somedb_log.TRN'
	WITH NORECOVERY;

	RESTORE DATABASE some_db FROM DISK = '/home/db_backup/full/somedb.bak'
	WITH NORECOVERY;

	RESTORE DATABASE some_db FROM DISK = @backupFilePath
	WITH RECOVERY;
END