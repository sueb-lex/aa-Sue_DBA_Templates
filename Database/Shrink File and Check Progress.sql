
--shrink in 500 MB increments (Option 1)
DECLARE @DataFileName VARCHAR(255);  
SET @DataFileName = (SELECT name FROM sysfiles WHERE groupid = 1);

DECLARE @TargetSize INT; 
-- Select current size and substract 500 MB
SET @TargetSize = ROUND(8 * (SELECT size FROM sysfiles WHERE groupid = 1) / 1024, 0) - 500;

EXEC ('DBCC SHRINKFILE (' + @DataFileName + ', ' + @TargetSize + ')');

--Option 2
DECLARE @StartSize INT 
DECLARE @TargetSize INT

SET   @StartSize  = -- SET START SIZE OF THE DATABASE FILE (MB)
SET   @TargetSize = -- SET END SIZE OF THE DATABASE FILE (MB)

WHILE @StartSize > @TargetSize
BEGIN
SET @StartSize = @StartSize - 512
    DBCC SHRINKFILE (N'file name' , @StartSize)
END
GO


--https://social.msdn.microsoft.com/Forums/sqlserver/en-US/1abc8cef-a28a-42ce-ad97-635bdcc2c639/proper-way-to-stop-dbcc-shrinkfile?forum=transactsql
------------------------------------------------------------------------------------------------------

--can check progress of the shrink (1)
SELECT percent_complete,
       estimated_completion_time,
       cpu_time,
       total_elapsed_time,
       *
FROM sys.dm_exec_requests;
--https://blogs.msdn.microsoft.com/psssql/2008/03/28/how-it-works-sql-server-2005-dbcc-shrink-may-take-longer-than-sql-server-2000/

--Determines approximately how long a backup, restore or DBCC command will run (2)
USE master
GO
 
SELECT CASE
           WHEN estimated_completion_time < 36000000
           THEN '0'
           ELSE ''
       END+RTRIM(estimated_completion_time/1000/3600)+':'+RIGHT('0'+RTRIM((estimated_completion_time/1000)%3600/60), 2)+':'+RIGHT('0'+RTRIM((estimated_completion_time/1000)%60), 2) AS [Time Remaining],
       percent_complete,
       TOTAL_ELAPSED_TIME / 60000 AS [Running Time],
       *
FROM sys.dm_exec_requests
WHERE percent_complete > 0;
--https://skreebydba.com/2012/11/21/determining-estimated-completion-time-from-sys-dm_exec_requests/
------------------------------------------------------------------------------------------------------

--allows you to search the trace log for various events below we are searching for Shrink

DECLARE @TracePath NVARCHAR(1000);

-- Get the file path for the default trace
SELECT    @TracePath = 
        REVERSE(SUBSTRING(REVERSE([path]), 
        CHARINDEX('\', REVERSE([path])), 1000)) + 'log.trc'
FROM     sys.traces
WHERE     is_default = 1;

SELECT top 1000 
    TextData,
    HostName,
    ApplicationName,
    LoginName, 
    StartTime  
 FROM 
 [fn_trace_gettable](@TracePath, DEFAULT) 
 WHERE TextData LIKE '%SHRINKFILE%'
 ORDER BY StartTime  DESC; 

 --http://dba.stackexchange.com/questions/110649/catch-event-of-auto-shrink-in-sql-server-log
------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------
https://www.mssqltips.com/sqlservertip/4368/execute-sql-server-dbcc-shrinkfile-without-causing-index-fragmentation/?utm_source=dailynewsletter&utm_medium=email&utm_content=headline&utm_campaign=20190424

USE <<database_name>>
GO
DBCC SHRINKFILE (N'<<database_filename>>', <<target_size>>, TRUNCATEONLY)
GO


DBCC SHRINKFILE with TRUNCATEONLY to a target size which does not cause index fragmentation
Example:
    USE [TestFileShrink]
    GO
    DBCC SHRINKFILE (N'TestFileShrink_data', 7000, TRUNCATEONLY)
    GO

DBCC SHRINKFILE with TRUNCATEONLY to the last allocated extent which does not cause index fragmentation (enter 0 as the target size

    USE [TestFileShrink]
    GO
    DBCC SHRINKFILE (N'TestFileShrink_data', 0, TRUNCATEONLY)
    GO

DBCC SHRINKFILE which causes fragmentation (causes fragmentation)
-------------------------------------------------------------------------------
