-- Check version of Ola Hallengren's SQL Server Maintenance Solution
--https://glennsqlperformance.com/2021/01/27/updating-your-ola-hallengren-scripts/
-- MUST POINT TO DBA DATABASE IF THAT IS WHERE STORED PROCEDURES ARE INSTALLED

DECLARE @VersionKeyword nvarchar(max);
SET @VersionKeyword = N'--// Version: ';

SELECT sch.[name] AS [Schema Name], obj.[name] AS [Object Name],
       CASE WHEN CHARINDEX(@VersionKeyword, OBJECT_DEFINITION(obj.[object_id])) > 0 
	   THEN SUBSTRING(OBJECT_DEFINITION(obj.[object_id]),CHARINDEX(@VersionKeyword,OBJECT_DEFINITION(obj.[object_id])) + LEN(@VersionKeyword) + 1, 19) END AS [Version],
       CAST(CHECKSUM(CAST(OBJECT_DEFINITION(obj.[object_id]) AS nvarchar(max)) COLLATE SQL_Latin1_General_CP1_CI_AS) AS bigint) AS [Checksum]
FROM sys.objects AS obj
INNER JOIN sys.schemas AS sch 
ON obj.[schema_id] = sch.[schema_id]
WHERE sch.[name] = N'dbo'
AND obj.[name] IN (N'CommandExecute', N'DatabaseBackup', N'DatabaseIntegrityCheck', N'IndexOptimize')
ORDER BY sch.[name] ASC, obj.[name] ASC;

-- Version History
-- https://ola.hallengren.com/versions.html

-- If you don't have the latest version, you can download and install the latest version
-- https://ola.hallengren.com/scripts/MaintenanceSolution.sql

-- Make sure to change this line in the script so it doesn't create new Agent jobs: SET @CreateJobs = 'N'