--List Extended Properties for Database

/*
Modified to  list extended properties for database only
(pulls each database name during insert - may need to add dbid in the future for joining to other tables)
--this would need to be re-run 
https://stackoverflow.com/questions/40071498/how-to-get-a-list-of-all-the-databases-with-their-extended-properties
I modified this 07/28/2020 sb so I could sort by [name] (changed from sql_variant to nvarchar)
*/
--IF OBJECT_ID(N'DBA.dbo.ExtendedProperties') IS NOT NULL DROP TABLE DBA.dbo.ExtendedProperties;

IF OBJECT_ID(N'DBA.dbo.ExtendedProperties') IS NULL
	CREATE TABLE DBA.dbo.ExtendedProperties (
		[dbname] nvarchar(100),
		[class_desc] nvarchar(100),
		[name] nvarchar(100),
		[value] sql_variant,
		[database_id] int,
		[LastUpdated] [smalldatetime] DEFAULT (getdate())
	)
ELSE 
    TRUNCATE TABLE DBA.dbo.ExtendedProperties;


DECLARE @sql NVARCHAR(max)

SELECT @sql = (
    SELECT 'USE '+QUOTENAME([name])+ ' INSERT INTO DBA.dbo.ExtendedProperties (dbname, class_desc, [name], [value]) SELECT ''' +[name] + ''' AS dbname, class_desc, [name], [value] FROM sys.extended_properties WHERE class = 0;' + CHAR(10)
    FROM sys.databases WHERE database_id > 4 AND state_desc = 'ONLINE'
    FOR XML PATH('')
)

--had to add this since one database name had '&' in the database name  sb 12/14/2020 -must use nvarchar
SET @sql =  REPLACE(CONVERT(NVARCHAR(max), @sql, 1), '&amp;', '&');

PRINT @sql;

EXEC sp_executesql @sql;


UPDATE DBA.dbo.ExtendedProperties 
SET [database_id] = s.database_id
FROM
(SELECT database_id, [name]
FROM sys.databases) AS s
WHERE DBA.dbo.ExtendedProperties.dbname = s.[name] 

SELECT *
FROM DBA.dbo.ExtendedProperties
ORDER BY dbname, [name]
