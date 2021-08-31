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