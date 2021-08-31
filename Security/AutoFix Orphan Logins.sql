--Goes through each database to check for orphan and fix if needed


declare @name varchar(150)
declare @query nvarchar (500)

DECLARE cur CURSOR FOR
    select name from master..syslogins

Open cur

FETCH NEXT FROM cur into @name

WHILE @@FETCH_STATUS = 0
BEGIN

set @query='USE [?]
IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
BEGIN   
exec sp_change_users_login ''Auto_Fix'', '''+ @name +'''
END'

EXEC master..sp_MSForeachdb @query

    FETCH NEXT FROM cur into @name

END

CLOSE cur
DEALLOCATE cur

/*
---------------------------------------------------------------
can be used to fix one database at a time 

USE DatabaseName  --must be pointed to the correct database
EXEC sp_change_users_login 'Report';

EXEC sp_change_users_login 'Auto_Fix', 'user'
---------------------------------------------------------------
https://www.sqlshack.com/how-to-discover-and-handle-orphaned-database-users-in-sql-server/
--Discover Orphaned Users by getting the list of SIDs that are defined in sys.database_principals but not in sys.server_principals 

SELECT p.name,p.sid
FROM sys.database_principals p
WHERE p.type in ('G','S','U')
	AND p.sid NOT IN (SELECT sid FROM sys.server_principals)
	AND p.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys', 'MS_DataCollectorInternalUser');

--run this then to fix a specific login
EXEC sp_change_users_login 'Auto_Fix', 'user'

*/


/*
https://www.sqlserverscience.com/security/fix-orphaned-users-instance-wide/?utm_source=DBW&utm_medium=pubemail

Run this to identify the orphan logins

The code below shows orphaned users for every database in the instance, including system databases. It uses dynamic-SQL to fill the @cmd variable with a query for each online, non-contained database that looks for database users with no corresponding server login

DECLARE @cmd nvarchar(max);
SET @cmd = N'';
 
SELECT @cmd = @cmd + CASE WHEN @cmd = N'' THEN N'' ELSE N'
UNION ALL
' END + N'
SELECT DatabaseName = ''' + d.name + N'''
    , UserName = dp.name
FROM ' + QUOTENAME(d.name) + N'.sys.database_principals dp
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.server_principals sp
    WHERE sp.sid = dp.sid
    )
    AND dp.TYPE_DESC NOT IN ( --only users that should be mapped to a login
          ''APPLICATION_ROLE''
        , ''CERTIFICATE_MAPPED_USER''
        , ''EXTERNAL_USER''
        , ''ASYMMETRIC_KEY_MAPPED_USER''
        , ''DATABASE_ROLE''
        , ''EXTERNAL_GROUPS''
    )
    AND dp.name NOT IN ( --skip built-in principals
        ''sys''
        , ''guest''
        , ''INFORMATION_SCHEMA''
    )
'
FROM sys.databases d
WHERE d.state_desc = N'ONLINE' --only inspect databases that are online
    AND d.containment_desc = N'NONE' --skip contained databases
ORDER BY d.name;
PRINT @cmd;
EXEC sys.sp_executesql @cmd;
==============================================================

Ok, Let’s Fix ‘Em!

The next piece of code helps fix orphaned users by reconnecting them to logins that have precisely the same name, but a differing SID. This code is a variant of the above code that dynamically creates ALTER USER statements. A statement is created for each orphaned user where there is a match-by-name in the list of server logins. Once the list of dynamically created ALTER USER statements are compiled, the commands to fix orphaned users are automatically executed.

DECLARE @cmd nvarchar(max);
SET @cmd = N'';
DECLARE @ServerCollation sysname = (SELECT d.collation_name FROM sys.databases d WHERE d.name = 'master');
 
SELECT @cmd = @cmd + CASE WHEN @cmd = N'' THEN N'' ELSE N'
UNION ALL
' END + N'
SELECT N''USE ' + QUOTENAME(d.name) + N';ALTER USER '' + QUOTENAME(dp.name) COLLATE ' + @ServerCollation + N' + N'' WITH LOGIN = '' + QUOTENAME(sp.name) COLLATE ' + @ServerCollation + N' + N'';''
FROM ' + QUOTENAME(d.name) + N'.sys.database_principals dp
    INNER JOIN sys.server_principals sp ON sp.sid <> dp.sid
        AND sp.name = dp.name COLLATE ' + @ServerCollation + N'
WHERE sp.type_desc = ''SQL_LOGIN''
    AND NOT EXISTS (
        SELECT 1
        FROM sys.server_principals sp
        WHERE sp.sid = dp.sid
    )
    AND dp.TYPE_DESC NOT IN ( --only users that should be mapped to a login
          ''APPLICATION_ROLE''
        , ''CERTIFICATE_MAPPED_USER''
        , ''EXTERNAL_USER''
        , ''ASYMMETRIC_KEY_MAPPED_USER''
        , ''DATABASE_ROLE''
        , ''EXTERNAL_GROUPS''
    )
    AND dp.name NOT IN ( --skip built-in principals
        ''sys''
        , ''guest''
        , ''INFORMATION_SCHEMA''
    )
'
FROM sys.databases d
WHERE d.state_desc = N'ONLINE' --only inspect databases that are online
    AND d.containment_desc = N'NONE' --skip contained databases
ORDER BY d.name;
 
IF OBJECT_ID(N'tempdb..#t', N'U') IS NOT NULL
DROP TABLE #t;
CREATE TABLE #t 
(
    cmd nvarchar(max) NOT NULL
);
INSERT INTO #t (cmd)
EXEC sys.sp_executesql @cmd;
SET @cmd = N'';
SELECT @cmd = @cmd + #t.cmd
FROM #t;
PRINT @cmd;
EXEC sys.sp_executesql @cmd;




*/