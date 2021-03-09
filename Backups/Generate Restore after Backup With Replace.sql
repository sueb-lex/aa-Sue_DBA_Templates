/*
Auto generate SQL Server restore scripts after each backup completes
https://www.mssqltips.com/sqlservertip/1611/auto-generate-sql-server-restore-scripts-after-each-backup-completes/
can be run after backups to create a script to restore database from last backup in msdb
see article if you want to schedule this to be run on a regular basis

Use this to do a replace
*/


SET NOCOUNT ON 
DECLARE @databaseName sysname 

CREATE TABLE #TmpCommands 
(ID INT IDENTITY(1,1), 
Cmd VARCHAR(8000) ) 

DECLARE dbnames_cursor CURSOR 
FOR 
   SELECT name  
   FROM master..sysdatabases 
   WHERE name NOT IN ( 'model','tempdb', 'master','msdb') 
   AND (status & 32) =0         -- Do not include loading 
   AND (status & 64) =0         -- Do not include loading 
   AND (status & 128) =0        -- Do not include recovering 
   AND (status & 256) =0        -- Do not include not recovered 
   AND (status & 512) =0        -- Do not include offline 
   AND (status & 32768) =0      -- Do not include emergency 
   AND (status & 1073741824) =0 -- Do not include cleanly shutdown 
  
OPEN dbnames_cursor 
  
FETCH NEXT FROM dbnames_cursor INTO @databaseName 
WHILE (@@FETCH_STATUS <> -1) 
   BEGIN 
   IF (@@FETCH_STATUS <> -2) 
   BEGIN 
      INSERT INTO #TmpCommands(Cmd) 
      VALUES ('----------------Script to Restore the ' + @databaseName + ' Database--------------') 

      DECLARE @backupStartDate datetime  
      DECLARE @backup_set_id_start INT  
      DECLARE @backup_set_id_end INT 

      SELECT @backup_set_id_start = MAX(backup_set_id)  
      FROM msdb.dbo.backupset  
      WHERE database_name = @databaseName AND type = 'D' 

      SELECT @backup_set_id_end = MIN(backup_set_id)  
      FROM msdb.dbo.backupset  
      WHERE database_name = @databaseName AND type = 'D'  
      AND backup_set_id > @backup_set_id_start 

      IF @backup_set_id_end IS NULL SET @backup_set_id_end = 999999999 

      INSERT INTO #TmpCommands(Cmd) 
      SELECT Cmd FROM( 
      SELECT backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' FROM DISK = '''  
      + mf.physical_device_name + ''' WITH REPLACE, STATS = 5 --' Cmd 
      FROM msdb.dbo.backupset b,  
      msdb.dbo.backupmediafamily mf  
      WHERE b.media_set_id = mf.media_set_id  
      AND b.database_name = @databaseName  
      AND b.backup_set_id = @backup_set_id_start  
     /*
	 UNION  
      SELECT backup_set_id, 'RESTORE LOG ' + @databaseName + ' FROM DISK = '''  
      + mf.physical_device_name + ''' WITH FILE = ' + CAST(position AS VARCHAR(10)) + ', NORECOVERY --' Cmd 
      FROM msdb.dbo.backupset b,  
      msdb.dbo.backupmediafamily mf  
      WHERE b.media_set_id = mf.media_set_id  
      AND b.database_name = @databaseName  
      AND b.backup_set_id >= @backup_set_id_start AND b.backup_set_id < @backup_set_id_end  
      AND b.type = 'L'  
      UNION  
      SELECT 999999999 AS backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' WITH RECOVERY --' Cmd
	 */ 
      ) A 
      ORDER BY backup_set_id 
   END 

   FETCH NEXT FROM dbnames_cursor INTO @DatabaseName  

END 

CLOSE dbnames_cursor 
DEALLOCATE dbnames_cursor 

DECLARE @PrintCommand VARCHAR(8000) 

DECLARE Print_cursor CURSOR 
FOR  
   SELECT Cmd FROM #TmpCommands 
   ORDER BY ID 
  
OPEN Print_cursor 
  
FETCH NEXT FROM Print_cursor INTO @PrintCommand 
WHILE (@@FETCH_STATUS <> -1) 
   BEGIN 
   IF (@@FETCH_STATUS <> -2) 
      BEGIN  
         PRINT @PrintCommand 
   END  

   FETCH NEXT FROM Print_cursor INTO @PrintCommand  
END 

CLOSE Print_cursor 
DEALLOCATE Print_cursor 
  
DROP TABLE #TmpCommands 