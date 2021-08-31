--Template for Database Restore plus Additional Items to Run
--LastUpdated  03/18/2021 sb
/*
USE [master]
--ALTER DATABASE [<DatabaseName>] SET SINGLE_USER WITH ROLLBACK IMMEDIATE

RESTORE DATABASE [<DatabaseName>] FROM  DISK = N'E:\SQL_Backups_BAK\<DatabaseName>.bak' WITH  FILE = 1, 
	MOVE N'<DatabaseName>_log' TO N'F:\SQL_Log\<DatabaseName>.ldf',  
	NOUNLOAD,  REPLACE,  STATS = 5
	
--ALTER DATABASE [<DatabaseName>] SET MULTI_USER

GO
*/

/*
--THEN SET COMPATABILITY TO SQL 2019

ALTER DATABASE [<DatabaseName>]
SET COMPATIBILITY_LEVEL =  150

----------------------------------
--change owner of database to sa

USE [<DatabaseName>];
GO
EXEC sp_changedbowner 'sa';
GO
----------------------------------
--update usage for database

DBCC UPDATEUSAGE(<DatabaseName>);

----------------------------------
--update stats for database

USE [<DatabaseName>];
GO
EXEC sp_updatestats;
GO

*/