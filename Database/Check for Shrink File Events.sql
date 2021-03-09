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