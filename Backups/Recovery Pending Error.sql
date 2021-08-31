/*
First Thing to Try 
Last updated:  05/13/2021 sb

https://www.mssqltips.com/sqlservertip/5460/sql-server-database-stuck-in-restoring-state/
--If you have this problem, try this first:
RESTORE DATABASE [databasename] WITH RECOVERY

--If you receive an error that the database is in use, try to set the user to single user mode:
USE master;
GO

ALTER DATABASE Database_name
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

--Then try the restore with recovery command again. 
RESTORE DATABASE [databasename] WITH RECOVERY
--Once restored, you can set to multiple user mode using the following T-SQL command:

USE master;
GO

ALTER DATABASE Database_name
SET MULTI_USER;
GO

*/

--https://stackoverflow.com/questions/44081205/mssql-2016-server-all-databases-marked-recovery-pending-state
--answered 2/3/2021
Alter Database TestDB Set Emergency;
Go

Alter Database TestDB Rebuild Log On 
    (Name = N'TestDB_log',
    FileName = N'L:\Path\To\LogFile\TestDB_log.ldf')
Go

Alter Database TestDB Set Online, Multi_user;
Go

--------------------------------------------------------------
/*
https://stackoverflow.com/questions/57893472/database-keeps-going-into-recovery-pending-state
--answered 2/4/2021
Use the sp_who or sp_who2 stored procedures. You can also use the kill command to kill the processes that are active in the database.

*/

--best advice seems to be to restore backups and log files

-------------------------------------------------------------------------------
