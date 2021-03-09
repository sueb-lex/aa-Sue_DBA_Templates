/*
T-SQL to generate script for attaching and detaching all user database in SQL Server
http://www.thesqlpost.com/2013/11/t-sql-to-generate-script-for-attaching.html
Uses the Create Database with Attach
Thursday, November 7, 2013
Must set query to display results in text so you can copy them to run in another window

-----------------------------------------
USE [master]
GO
ALTER DATABASE [DBA] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'DBA'
GO
-----------------------------------------
*/

/*
Run below query to generate T-SQL  for Detach, copy results and paste in another query window and run once you generated T-SQL for attach with second script.
*/
SELECT 'EXEC master.dbo.sp_detach_db @dbname = [' + name + ']' FROM SYSDATABASES WHERE DBID > 4



/*
Run below query to generate T-SQL  for Attach, save the result of this query to use as T-SQL for attaching databases on new SQL Server. 
You may modify your folder location for MDF and LDF, if those are different on new location. 
*/ 
SELECT  'CREATE DATABASE [' + DB_NAME(S1.database_id) + '] ON ( FILENAME = N''' + S1.physical_name + '''), ( FILENAME = N''' + S2.physical_name + ''') FOR ATTACH;'
FROM SYS.MASTER_FILES S1
JOIN SYS.MASTER_FILES S2 ON S1.database_id =S2.database_id AND s2.[type] = 1
WHERE S1.database_id > 4 AND S1.[type] = 0