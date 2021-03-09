--Move tempdb databases
--https://docs.microsoft.com/en-us/sql/relational-databases/databases/move-system-databases


--determine name and location of files
SELECT name, physical_name AS CurrentLocation  
FROM sys.master_files  
WHERE database_id = DB_ID(N'tempdb');  
GO 

--change the filename path to new location
USE master;  
GO  
ALTER DATABASE tempdb   
MODIFY FILE (NAME = tempdev, FILENAME = 'F:\SPT2010SQL.SQL_Data\tempdb.mdf');  
GO  
ALTER DATABASE tempdb   
MODIFY FILE (NAME = templog, FILENAME = 'G:\SPT2010SQL.SQL_Log\templog.ldf');  
GO  

--stop and restart the SQL Server

--verify the change
SELECT name, physical_name AS CurrentLocation, state_desc  
FROM sys.master_files  
WHERE database_id = DB_ID(N'tempdb');

--delete the tempdb.mdf and templog.ldf from the old location