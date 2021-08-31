/*
Find Embedded SQL Server Logins in Jobs, Linked Servers or SSISDB
Updated: 2019-10-17 (Pablo Echeverria)
https://www.mssqltips.com/sqlservertip/6165/find-embedded-sql-server-logins-in-jobs-linked-servers-or-ssisdb/?utm_source=dailynewsletter&utm_medium=email&utm_content=headline&utm_campaign=20191017

Problem
A database login or user (SQL Login, Oracle User, etc.) is actively being used and embedded in code, but the password is about to change. How can you find all of the places where it exists with SQL Server such as Jobs, Linked Servers and SSIS information stored on the server?

Solution
The below script can be used to find where a particular login/user exists on a SQL Server instance.  This can be used to quickly identify where you may have configurations settings that may need to changed.


*/


DECLARE @Database VARCHAR(128), @Username VARCHAR(128)
SET @Database = 'YourDatabase' -- enter value here
SET @Username = 'YourUser' -- enter value here

-- find where user exists within linked server configurations
USE [master]
SELECT [s].[name] [LinkedServerName], [s].[data_source] [Database], [ll].[remote_name] [Username]
FROM [sys].[servers] [s]
INNER JOIN [sys].[linked_logins] [ll] ON [ll].[server_id] = [s].[server_id]
 WHERE [s].[data_source] = @Database
   AND [ll].[remote_name] = @Username

-- find where user exists with SQL Agent job steps
USE [msdb]
SELECT [j].[name] [JobName], [js].[step_id], [js].[step_name], [js].[command]
FROM [dbo].[sysjobs] [j]
INNER JOIN [dbo].[sysjobsteps] [js] ON [js].[job_id] = [j].[job_id]
WHERE [js].[command] LIKE '%'+@Database+'%'
  AND [js].[command] LIKE '%'+@Username+'%'

-- find where user exists for SSIS info stored in SSISDB database
IF DB_ID('SSISDB') IS NOT NULL
BEGIN
  SELECT [f].[name] [folder], [p].[name] [project], [op].[object_name] [package], [op].[parameter_name] [parameter],
         [op].[design_default_value], [op].[default_value], [j].[name] [JobName], [js].[step_id], [js].[step_name],
         [js].[command]
  FROM [SSISDB].[catalog].[folders] [f]
  INNER JOIN [SSISDB].[catalog].[projects] [p] ON [p].[folder_id] = [f].[folder_id]
  INNER JOIN [SSISDB].[catalog].[object_parameters] [op] ON [op].[project_id] = [p].[project_id]
   LEFT JOIN [msdb].[dbo].[sysjobsteps] [js] ON [js].[command] LIKE '%'+[op].[object_name]+'%'
   LEFT JOIN [msdb].[dbo].[sysjobs] [j] ON [j].[job_id] = [js].[job_id]
  WHERE [op].[design_default_value] = @Database
     OR [op].[design_default_value] = @Username
     OR [op].[default_value] = @Database
     OR [op].[default_value] = @Username

  SELECT [e].[name] [Environment], [ev].[name] [Variable], [ev].[value]
  FROM [SSISDB].[catalog].[environments] [e]
  INNER JOIN [SSISDB].[catalog].[environment_variables] [ev] ON [ev].[environment_id] = [e].[environment_id]
  WHERE [ev].[value] = @Database
     OR [ev].[value] = @Username
END