-----------------------------------------------------------------------------------------------------------------------
/*
Check Default Trace File for Shrink Events
needs to be run on the actual server as you will have to point to the actual trc file (will need to check file name)
http://blogs.lessthandot.com/index.php/datamgmt/dbprogramming/find-who-ran-shrinkfile/
*/

SELECT 
    TextData,
    HostName,
    ApplicationName,
    LoginName, 
    StartTime  
FROM 
[fn_trace_gettable]('D:\Program Files\Microsoft SQL Server\MSSQL10_50.AMICUS\MSSQL\Log\log_6.trc', DEFAULT) 
WHERE TextData LIKE 'DBCC SHRINKFILE%' --AND ApplicationName LIKE 'Amicus Attorney';


-----------------------------------------------------------------------------------------------------------------------
/*
Read Error Log
http://www.mssqltips.com/sqlservertip/2551/automate-sql-server-monitoring-with-email-alerts/
running on GCSQL1 (several alerts for monitoring)
*/


declare @Time_Start datetime;
declare @Time_End datetime;
set @Time_Start=getdate()-2;
set @Time_End=getdate();

create table #ErrorLog (logdate datetime
                      , processinfo varchar(255)
                      , Message varchar(500) )

insert #ErrorLog (logdate, processinfo, Message)
   EXEC master.dbo.xp_readerrorlog 0, 1, null, null , @Time_Start, @Time_End, N'desc';

create table SQL_Log_Errors (
	[logdate] datetime,
    [Message] varchar (500) )

insert into SQL_Log_Errors 
  select LogDate, Message FROM #ErrorLog
   where (Message LIKE '%error%' OR Message LIKE '%failed%' OR Message LIKE '%backed up%') 
     and processinfo NOT LIKE 'logon'
   order by logdate desc;

select * from #ErrorLog;

drop table #ErrorLog;

Select * from SQL_Log_Errors;
drop table SQL_Log_Errors;