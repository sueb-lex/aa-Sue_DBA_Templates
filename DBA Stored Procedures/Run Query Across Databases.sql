USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[run_query_across_databases]    Script Date: 06/17/2019 02:46:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[run_query_across_databases]
       @sql_command VARCHAR(MAX),
       @system_databases BIT = 1,
       @database_name_like VARCHAR(100) = NULL,
       @database_name_not_like VARCHAR(100) = NULL,
       @database_name_equals VARCHAR(100) = NULL
AS
/*
sp_msforeachdb: Improving on an Undocumented Stored Procedure
By Edward Pollack, 2016/04/15 (first published: 2014/12/01) 

http://www.sqlservercentral.com/articles/sp_msforeachdb/117654/
• @system_databases, when set to 0, will explicitly filter out msdb, master, tempdb, and model from our database list.
• @database_name_like will filter out any databases that are not like the string passed in for the parameter (with wildcards before and after).
• @database_name_not_like will filter out any databases that are like the string passed in for the parameter (also with wildcards surrounding it).
• @database_name_equals will filter out any databases that do not have the exact name specified (with no wildcards).

Using these parameters, we can easily pick and choose the specific databases we are looking for.  
Since the dynamic SQL is additive---ie, there are no ELSE statements in between each IF…THEN, 
we can mix and match these parameters to our heart’s content.  They can also be left NULL, causing them to be ignored.  
One last note about the SQL above: Each piece of dynamic SQL is strung together with an AND.  
OR may be used instead of you’d like to be more inclusive, rather than exclusive in your queries 
(or you can issue multiple commands with a variety of parameters).

*/
BEGIN
       SET NOCOUNT ON;
      
       DECLARE @database_name VARCHAR(300) -- Stores database name for use in the cursor
       DECLARE @sql_command_to_execute NVARCHAR(MAX) -- Will store the TSQL after the database name has been inserted
       -- Stores our final list of databases to iterate through, after filters have been applied
       DECLARE @database_names TABLE
              (database_name VARCHAR(100))

       DECLARE @SQL VARCHAR(MAX) -- Will store TSQL used to determine database list
       SET @SQL =
       '      SELECT
                     SD.name AS database_name
              FROM sys.databases SD
              WHERE 1 = 1
       '
       IF @system_databases = 0 -- Check if we want to omit system databases
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
              '
       END
       IF @database_name_like IS NOT NULL -- Check if there is a LIKE filter and apply it if one exists
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name LIKE ''%' + @database_name_like + '%''
              '
       END
       IF @database_name_not_like IS NOT NULL -- Check if there is a NOT LIKE filter and apply it if one exists
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name NOT LIKE ''%' + @database_name_not_like + '%''
              '
       END
       IF @database_name_equals IS NOT NULL -- Check if there is an equals filter and apply it if one exists
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name = ''' + @database_name_equals + '''
              '
       END
            
       -- Prepare database name list
       INSERT INTO @database_names
               ( database_name )
       EXEC (@SQL)
      
       DECLARE db_cursor CURSOR FOR SELECT database_name FROM @database_names
       OPEN db_cursor

       FETCH NEXT FROM db_cursor INTO @database_name

       WHILE @@FETCH_STATUS = 0
       BEGIN
              SET @sql_command_to_execute = REPLACE(@sql_command, '?', @database_name) -- Replace "?" with the database name
      
              EXEC sp_executesql @sql_command_to_execute

              FETCH NEXT FROM db_cursor INTO @database_name
       END

       CLOSE db_cursor;
       DEALLOCATE db_cursor;
END
