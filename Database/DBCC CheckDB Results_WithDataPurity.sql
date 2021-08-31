/*
SQL : DBCC CHECKDB last execution
gives table of all databases and the last DBCC CHECKDB results (shows if DataPurityCheck is enabled)

DBCC CHECKDB ([<DatabaseName>]) WITH DATA_PURITY
(run this on old database so it shows as enabled)

LastUpdated:  04/08/2021 sb
http://www.mathdax.ca/2016/08/sql-dbcc-checkdb-last-execution.html
*/

DECLARE @name VARCHAR (256)

CREATE TABLE #dbinfo
(ParentObject varchar (100),
Object varchar (100),
Field varchar ( 100),
Value varchar (100))

CREATE TABLE #dbinforesults
(dbname varchar (256),
LastRanDate datetime ,
Status varchar (100),
DataPurityCheckEnabled varchar (3))

DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases
WHERE state_desc='ONLINE'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name
WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO #dbinfo
EXEC('DBCC DBINFO (['+@name+']) WITH TABLERESULTS')

INSERT INTO #dbinforesults (dbname, LastRanDate, Status)
(SELECT DISTINCT @name as dbname, Value as LastRanDate,
CASE
WHEN Value = '1900-01-01 00:00:00.000' THEN CONVERT(nvarchar (50),'BAD! DBCC CHECKDB Never Executed')
WHEN DATEDIFF(d, Value, GETDATE()) > 14 THEN CONVERT(nvarchar (50),'BAD! DBCC CHECKDB last execution more than 14 days ago')
ELSE CONVERT(nvarchar(50),'OK! DBCC CHECKDB last execution less than 14 days ago')
END AS Status
FROM #dbinfo
WHERE Field='dbi_dbccLastKnownGood')

UPDATE #dbinforesults SET DataPurityCheckEnabled=(SELECT
CASE
WHEN @name='master' OR @name='model' THEN 'N/A'
WHEN Value=0 THEN 'No'
WHEN Value=2 THEN 'Yes'
END as DataPurityEnabled
FROM #dbinfo
WHERE Field='dbi_dbccFlags')
WHERE dbname=@name

TRUNCATE TABLE #dbinfo

FETCH NEXT FROM db_cursor INTO @name
END
CLOSE db_cursor
DEALLOCATE db_cursor

DROP TABLE #dbinfo
SELECT
dbname AS [Database Name],
LastRanDate AS [Last execution date],
Status AS [Comments],
DataPurityCheckEnabled AS [Data Purity Check Enabled]
FROM #dbinforesults
DROP TABLE #dbinforesults