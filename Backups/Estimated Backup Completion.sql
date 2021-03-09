SELECT db.name,
	er.percent_complete,
	er.total_elapsed_time/60000 AS ElapsedMinutes,
	er.estimated_completion_time/60000 AS remaining_minutes 
FROM
sys.sysdatabases db
INNER JOIN sys.dm_exec_requests er
ON db.DBID=er.database_id 
--AND er.command LIKE '%BACKUP%'
AND er.command LIKE '%RESTORE%'

--can substitute RESTORE in above

/*
Shows the time backup has been running, % complete, estimated time left to complete
http://www.sqlservercentral.com/Forums/Topic1349180-1550-1.aspx
*/
==============================================================================================================
SELECT A.NAME,B.TOTAL_ELAPSED_TIME/60000 AS [Running Time],
B.ESTIMATED_COMPLETION_TIME/60000 AS [Remaining],
B.PERCENT_COMPLETE as [%],(SELECT TEXT FROM sys.dm_exec_sql_text(B.SQL_HANDLE))AS COMMAND FROM
MASTER..SYSDATABASES A, sys.dm_exec_requests B
WHERE A.DBID=B.DATABASE_ID AND B.COMMAND LIKE '%BACKUP%'
ORDER BY percent_complete desc,B.TOTAL_ELAPSED_TIME/60000 desc

--this is just another way to do it (includes Backup command)
==============================================================================================================
SELECT  
   DISTINCT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name,  
   msdb.dbo.backupset.backup_start_date,  
   msdb.dbo.backupset.backup_finish_date, 
 CAST((DATEDIFF(second,  msdb.dbo.backupset.backup_start_date,msdb.dbo.backupset.backup_finish_date)) AS varchar)+ ' secs  ' AS [Total Time] ,

   Cast(msdb.dbo.backupset.backup_size/1024/1024 AS numeric(10,2)) AS 'Backup Size(MB)',   
   msdb.dbo.backupset.name AS backupset_name
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id   
--Enter your database below
and database_name = 'ArchiveManager'
--and msdb.dbo.backupset.backup_start_date>'2016-01-31' and msdb.dbo.backupset.backup_start_date<'2014-01-27 23:59:59'
ORDER BY  
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_start_date
==============================================================================================================
SELECT p.database_name AS DatabaseName,
p.backup_start_date AS 'Backup Start Time',
p.backup_finish_date AS 'Backup Finish Time',
CAST((DATEDIFF(MINUTE, p.backup_start_date, p.backup_finish_date)) AS varchar)+ ' min  '+ CAST((DATEDIFF(ss, p.backup_start_date, p.backup_finish_date)) AS varchar) + ' sec ' AS [Total Time] ,
CASE p.type
WHEN 'D' THEN 'Full '
WHEN 'I' THEN 'Diffrential'
WHEN 'L' THEN 'Log'
END AS 'Backup Type',
Cast(p.backup_size/1024/1024 AS numeric(10,2)) AS 'Backup Size(MB)' ,
a.physical_device_name AS 'Physical File location'
FROM msdb..backupmediafamily a,
msdb..backupset p
WHERE a.media_set_id=p.media_set_id
 
-- UNCOMMENT BELOW LINE AND REPLACE <DATABASE NAME> WITH DB YOU WANT TO CHECK BACKUP HISTORY
--AND P.DATABASE_NAME='DATABASE NAME'
 
-- UNCOMMENT BELOW LINE AND REPLACE START AND END DATES WITH DATES YOU WANT TO CHECK HISTORY
--AND P.BACKUP_START_DATE>'2013-01-20' AND P.BACKUP_START_DATE<'2013-01-25 23:59:59'
 
--UNCOMMENT BELOW LINE TO SEE ONLY THE FULL BACKUPS, REPLACE WITH 'I' TO CHECK DIFFRENTIAL AND 'L' TO CHECK ONLY LOG BACKUPS.
--AND P.TYPE='D'
 
ORDER BY p.backup_start_date DESC