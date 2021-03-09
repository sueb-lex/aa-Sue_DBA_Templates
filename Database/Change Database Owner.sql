--point to the database to be changed and run (single database only)
EXEC sp_changedbowner 'sa'
GO


sp_helpdb 
-------------------------------------------------
/*
https://ask.sqlservercentral.com/questions/92479/change-db-owner-for-all-databases.html
Below will print out a script so you can run to make change by database (SET QUERY RESULTS TO TEXT)
*/
SELECT 'ALTER AUTHORIZATION ON DATABASE::' + QUOTENAME(name) + ' TO [sa];' 
 FROM sys.databases
     WHERE name NOT IN ('master', 'model', 'tempdb', 'msdb')

-------------------------------------------------


ALTER AUTHORIZATION ON DATABASE::<DatabaseName> TO sa

SELECT NAME, SUSER_SNAME(owner_sid), owner_sid 
FROM   sys.databases 
ORDER BY name


EXEC sp_MSForEachDB 'EXEC sp_helpdb ?'
----I'd save this output to a text file somewhere for safe keeping 


EXEC sp_MSForEachDB 
'Declare @name varchar(100)
 select @name = ''?''
 PRINT @name
 IF db_id(@name) > 4
 BEGIN
 USE ?
 EXEC dbo.sp_changedbowner @loginame = ''sa'', @map = false
 END'

 /*  http://www.sqlservercentral.com/Forums/Topic1061409-391-1.aspx
-- list databases by a specific login . script to change below.
SELECT name, SUSER_SNAME(owner_sid) owner
FROM   sys.databases
where SUSER_SNAME(owner_sid) <> 'sa'
*/
DECLARE @sql nvarchar(4000);
DECLARE @BigSQL nvarchar(4000);
DECLARE @dbName varchar(100);

declare cbases cursor fast_forward for
 SELECT name
 FROM   sys.databases
 where SUSER_SNAME(owner_sid) = '<login to change>'
open cbases
fetch next from cbases into @dbName
while @@FETCH_STATUS = 0
begin
 SET @sql = N'exec sp_changedbowner ''''sa''''';
 SET @BigSQL = N'USE [' + @dbName + ']; EXEC sp_executesql N''' + @sql + '''';
 print @BigSQL
 --EXEC (@BigSQL)
fetch next from cbases into @dbName
end
close cbases
deallocate cbases