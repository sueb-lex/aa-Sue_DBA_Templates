/*
Generates a Script to Backup Databases to Directory
PATH FOR BACKUP MUST BE CREATED FIRST
https://dba.stackexchange.com/questions/118482/script-to-backup-all-databases
*/
DECLARE @PathForBackUp VARCHAR(255)
SET @PathForBackUp = 'C:\Backups\'

SELECT 'BACKUP DATABASE [' + name + '] TO  DISK = N''' + @PathForBackUp + '' + name + '.bak''
WITH NOFORMAT, NOINIT,  NAME = N''' + name + '_FullBackUp'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 5'
FROM sys.databases
WHERE database_id > 4

-------OR you can do the script below

DECLARE @DBName VARCHAR(255)  
DECLARE @PathForBackUp VARCHAR(255) 
DECLARE @FileName VARCHAR(255)  
DECLARE @DateFile VARCHAR(255)
DECLARE @SQL NVARCHAR(2048) 
SET @PathForBackUp = 'E:\TEMP\SharePoint2010\'  
SET @DateFile = REPLACE(REPLACE(CONVERT(VARCHAR(20),GETDATE(),120) ,' ','T'), ':','') 

DECLARE BACKUPING CURSOR FOR   
SELECT name  
FROM master.dbo.sysdatabases WHERE dbid > 4 

OPEN BACKUPING    
FETCH NEXT FROM BACKUPING INTO @DBName    
WHILE @@FETCH_STATUS = 0    

BEGIN    
        SET @FileName = @PathForBackUp + @DBName + '_' + @DateFile + '.BAK'  
    SET @SQL = 'BACKUP DATABASE '+@DBName+ ' TO DISK = '''+@FileName+''' WITH COMPRESSION, STATS=5 ' 
    PRINT @SQL 
    --EXECUTE sp_executesql @sql   
    FETCH NEXT FROM BACKUPING INTO @DBName  

END    

CLOSE BACKUPING    
DEALLOCATE BACKUPING 