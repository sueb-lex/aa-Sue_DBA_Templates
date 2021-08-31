/*
Facts about msdb Database
Updated: 2021-04-19
https://www.mssqltips.com/sqlservertip/6835/sql-server-msdb-database-facts/?utm_source=dailynewsletter&utm_medium=email&utm_content=headline&utm_campaign=20210426
*/

--------------------------------------------------------
--List Backups
USE msdb
GO
 
SELECT bs.database_name, bmf.physical_device_name, 
       CASE bs.type WHEN 'D' THEN 'FULL'
                    WHEN 'I' THEN 'DIFFERENTIAL'
                    WHEN 'L' THEN 'TRANSACTION LOG'
                    ELSE bs.type
            END AS BackupType,
       bs.backup_size AS BackupSizeInBytes,
       bs.backup_start_date, backup_finish_date
FROM   
backupmediafamily bmf
INNER JOIN
msdb.dbo.backupset bs
ON bmf.media_set_id = bs.media_set_id 
ORDER BY bs.database_name, backup_finish_date DESC

--------------------------------------------------------
--List Jobs
USE msdb
GO
 
SELECT j.name,
       jh.run_date,
       jh.step_name,
       jh.run_time,
       jh.run_duration
FROM 
sysjobs j
INNER JOIN 
sysjobhistory jh
ON j.job_id = jh.job_id 
ORDER BY j.name, jh.run_date DESC