/*
Backup all databases to Directory 
backup location MUST be already created
https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/

-- if you want to include the time in the filename then substitute this line
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')
*/

DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @SQL VARCHAR(2048) -- used for SQL statement

 
-- specify database backup directory
SET @path = 'C:\Backups\'  
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
--WHERE name IN ('WebRW')  -- include these databases

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
   --if you uncomment below it will run the backup immediately  
   --BACKUP DATABASE @name TO DISK = @fileName  
   SET @SQL = 'BACKUP DATABASE '+@name+ ' TO DISK = '''+@fileName+''' WITH COMPRESSION, STATS = 5 ' 
   PRINT @SQL
    
   FETCH NEXT FROM db_cursor INTO @name  
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor