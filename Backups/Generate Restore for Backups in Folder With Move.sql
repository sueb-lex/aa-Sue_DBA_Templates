/** Script to Generate RESTORE DATABASE WITH MOVE Commands for all Backups in a Folder
https://sqlbie.wordpress.com/2011/11/29/script-to-generate-restore-database-with-move/#comments
 AUTHOR : Sasi Vardhan Thonangi
 DATE : 28th Nov 2011
 PURPOSE : Generate script to RESTORE DATABASES WITH MOVE for all the Backups in a single folder
 REMARKS : set the @backupLocationFolder parameter to the folder that holds the backups.
 @DataFileFolder : Parameter to hold the Default location of Datafiles
 @LogFileFolder : Parameter to hold the Default Location of Logfiles
sp_restoreFilelistOnly is inspired from the code at
 http://troubleshootingsql.com/2010/07/17/converting-restore-filelistonly-command-into-restore-database-command/
 --above is an older version but does not use xp_cmdshell (permission error)
 
---------------------------------------------------------------------------------
 Requires use of xp_cmdshell; can be enabled and then disabled if necessary
---------------------------------------------------------------------------------
 --enable xp_cmdshell
Use Master
GO

EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE WITH OVERRIDE
GO
-- To enable the feature.  
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE WITH OVERRIDE
GO
---------------------------------------------------------------------------------
 
--disable xp_cmdshell
Use Master
GO

EXEC master.dbo.sp_configure 'xp_cmdshell', 0
RECONFIGURE WITH OVERRIDE
GO

EXEC master.dbo.sp_configure 'show advanced options', 0
RECONFIGURE WITH OVERRIDE
GO
---------------------------------------------------------------------------------
*/
 
/* Create the temp SP sp_restoreFilelistOnly that would read the FILELISTONLY details
*/
/*
IF EXISTS ( SELECT 1 from tempdb.sys.objects WHERE name LIKE '%#sp_restoreFilelistOnly%' )
DROP PROCEDURE #sp_restoreFilelistOnly
ELSE
*/ 
SET NOCOUNT ON
GO

CREATE PROCEDURE #sp_restoreFilelistOnly
@backupFileLocation VARCHAR(MAX)
AS
RESTORE FILELISTONLY FROM DISK = @backupFileLocation
GO
 
IF EXISTS (SELECT 1 FROM tempdb.sys.objects WHERE name LIKE '%#FileListHeader_tab%')
DROP TABLE #FileListHeader_tab
ELSE
CREATE TABLE #FileListHeader_tab
(LogicalName VARCHAR(255),
PhysicalName VARCHAR(255),
Type VARCHAR(1),
FileGroupName VARCHAR(50),
Size BIGINT,
MaxSize BIGINT,
FileId INT,
CreateLSN NUMERIC(30,2),
DropLSN NUMERIC(30,2),
UniqueId UNIQUEIDENTIFIER,
ReadOnlyLSN NUMERIC(30,2),
ReadWriteLSN NUMERIC(30,2),
BackupSizeInBytes BIGINT,
SourceBlockSize INT,
FileGroupId INT,
LogGroupGUID UNIQUEIDENTIFIER,
DifferentialBaseLSN NUMERIC(30,2),
DifferentialBaseGUID UNIQUEIDENTIFIER,
IsReadOnly INT,
IsPresent INT,
TDEThumbprint VARCHAR(10))
IF EXISTS ( SELECT 1 FROM tempdb.sys.objects WHERE name LIKE '%#filelist_tab%')
DROP TABLE #filelist_tab
ELSE
CREATE TABLE #filelist_tab
(
fname VARCHAR(100)
)
 
DECLARE @backupLocationFolder VARCHAR(200),@DataFileFolder VARCHAR(200),@LogFileFolder VARCHAR(200),@backupFileLocation VARCHAR(200),@SQL VARCHAR(max)
 
SET @DataFileFolder = 'E:\SPT2010SQL.SQL_Data'
SET @LogFileFolder = 'E:\SPT2010SQL.SQL_Log'
SET @backupLocationFolder = 'E:\TEMP\SharePoint2010'
DECLARE @sql_stat NVARCHAR(MAX)
SET @sql_stat = 'xp_cmdshell ''dir /B ' + @backupLocationFolder + ''''
 
INSERT INTO #filelist_tab
EXECUTE sp_executesql @sql_stat
 
DECLARE fileName_cur CURSOR
FOR
SELECT fname FROM #filelist_tab
WHERE fname != 'NULL'
OPEN fileName_cur
DECLARE @fname varchar(200)
FETCH NEXT FROM fileName_cur INTO @fname
 
WHILE (@@FETCH_STATUS = 0)
BEGIN
SET @backupFileLocation = @backupLocationFolder+'\'+@fname
 
DELETE from #FileListHeader_tab
INSERT into #FileListHeader_tab
EXEC #sp_restoreFilelistOnly @backupFileLocation
 
/* REMOVE THESE COMMENTS IF YOU NEED TO MOVE DATABASE TO A NEW LOCATION
 --ADDED '-4' TO THE @fname AS IT WAS ADDING '.BAK' TO THE NAME OF THE DATABASE AND THIS STRIPS IT OFF
SET @SQL = 'RESTORE DATABASE ['+SUBSTRING(@fname,1,LEN(@fname)-4) +
'] from disk='''+@backupLocationFolder+'\'+@fname+''' WITH FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5, '
 
--use if already has database in place (use this if database is new and needs move)
--'] from disk='''+@backupLocationFolder+'\'+@fname+''' WITH STATS = 5, '
SELECT @SQL = @SQL + char(13) + ' MOVE ''' + LogicalName + ''' TO N''' +
CASE flht.[TYPE]
 WHEN 'D' THEN @DataFileFolder
 WHEN 'L' THEN @LogFileFolder
END +'\'+ LogicalName +
 '.' + RIGHT(PhysicalName,CHARINDEX('\',PhysicalName)) + ''','
FROM #FileListHeader_tab as flht
*/
 
SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
 
PRINT @SQL
 
FETCH NEXT FROM fileName_cur INTO @fname;
 
END
CLOSE fileName_cur
DEALLOCATE fileName_cur
GO
DROP PROC #sp_restoreFilelistOnly
DROP TABLE #FileListHeader_tab
DROP TABLE #filelist_tab