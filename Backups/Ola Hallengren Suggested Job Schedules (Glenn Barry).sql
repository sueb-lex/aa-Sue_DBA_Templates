-- Add schedules for Ola Hallengren Agent jobs
-- Glenn Berry
-- SQLskills.com
-- https://glennsqlperformance.com/2021/01/27/creating-schedules-for-ola-hallengrens-maintenance-solution/  (newest)
-- https://www.sqlskills.com/blogs/glenn/creating-sql-server-agent-job-schedules-for-ola-hallengrens-maintenance-solution/
-- https://www.dropbox.com/s/yjw1j4gjco4gaen/Add%20schedules%20for%20Ola%20Hallengren%20Agent%20jobs.sql?dl=0
-- Take care of cleanup jobs first  *********
 
-- Add schedule for CommandLog Cleanup job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'CommandLog Cleanup',      -- Job name
        @name = N'CommandLog Cleanup',          -- Schedule name
        @freq_type = 8,                         -- Weekly
        @freq_interval = 1,                     -- Sunday
        @freq_recurrence_factor = 1,            -- every week
        @active_start_time = 100;               -- 12:01 AM
 
-- Add schedule for Output File Cleanup job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'Output File Cleanup',     -- Job name
        @name = N'Output File Cleanup',         -- Schedule name
        @freq_type = 8,                         -- Weekly
        @freq_interval = 1,                     -- Sunday
        @freq_recurrence_factor = 1,            -- every week
        @active_start_time = 200;               -- 12:02 AM
 
-- Add schedule for sp_delete_backuphistory job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'sp_delete_backuphistory', -- Job name
        @name = N'sp_delete_backuphistory',     -- Schedule name
        @freq_type = 8,                         -- Weekly
        @freq_interval = 1,                     -- Sunday
        @freq_recurrence_factor = 1,            -- every week
        @active_start_time = 300;               -- 12:03 AM
 
-- Add schedule for sp_purge_jobhistory job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'sp_purge_jobhistory',     -- Job name
        @name = N'sp_purge_jobhistory',         -- Schedule name
        @freq_type = 8,                         -- Weekly
        @freq_interval = 1,                     -- Sunday
        @freq_recurrence_factor = 1,            -- every week
        @active_start_time = 400;               -- 12:04 AM
 
 
-- System Database jobs *******************************
 
-- Add schedule for DatabaseBackup - SYSTEM_DATABASES - FULL job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'DatabaseBackup - SYSTEM_DATABASES - FULL',        -- Job name
        @name = N'DatabaseBackup - SYSTEM_DATABASES - FULL',            -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @active_start_time = 500;                                       -- 12:05 AM
 
 
-- Add schedule for DatabaseIntegrityCheck - SYSTEM_DATABASES job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'DatabaseIntegrityCheck - SYSTEM_DATABASES',       -- Job name
        @name = N'DatabaseIntegrityCheck - SYSTEM_DATABASES',           -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @active_start_time = 1000;                                      -- 12:10 AM
 
 
-- User Database jobs *******************************
-- Adjust the schedules and frequency to meet your business and infrastructure requirements
-- IndexOptimize can be run before DatabaseIntegrityCheck since sometimes IndexOptimize can fix errors

-- Add schedule for IndexOptimize - USER_DATABASES job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'IndexOptimize - USER_DATABASES',                  -- Job name
        @name = N'IndexOptimize - USER_DATABASES',                      -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @active_start_time = 10000;                                     -- 1:00 AM
 
 
-- Add schedule for DatabaseIntegrityCheck - USER_DATABASES job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'DatabaseIntegrityCheck - USER_DATABASES',         -- Job name
        @name = N'DatabaseIntegrityCheck - USER_DATABASES',             -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @active_start_time = 20000;                                     -- 2:00 AM  
 
 
-- Add schedule for DatabaseBackup - USER_DATABASES - FULL job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'DatabaseBackup - USER_DATABASES - FULL',          -- Job name
        @name = N'DatabaseBackup - USER_DATABASES - FULL',              -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @active_start_time = 30000;                                     -- 3:00 AM  
 
 
-- Add schedule for DatabaseBackup - USER_DATABASES - DIFF job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'DatabaseBackup - USER_DATABASES - DIFF',          -- Job name
        @name = N'DatabaseBackup - USER_DATABASES - DIFF',              -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @active_start_time = 150000;                                    -- 3:00 PM  
 
 
-- Add schedule for DatabaseBackup - USER_DATABASES - LOG job
EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = N'DatabaseBackup - USER_DATABASES - LOG',           -- Job name
        @name = N'DatabaseBackup - USER_DATABASES - LOG',               -- Schedule name
        @freq_type = 4,                                                 -- Daily
        @freq_interval = 1,                                             -- Daily
        @freq_subday_type = 4,                                          -- Minutes
        @freq_subday_interval = 15;                                     -- Every 15 minutes
         
 
-- Get SQL Server Agent jobs and Category information 
SELECT sj.name AS [Job Name], sj.[description] AS [Job Description], 
SUSER_SNAME(sj.owner_sid) AS [Job Owner],
sj.date_created AS [Date Created], sj.[enabled] AS [Job Enabled], 
sj.notify_email_operator_id, sj.notify_level_email, sc.name AS [CategoryName],
s.[enabled] AS [Sched Enabled], js.next_run_date, js.next_run_time
FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
INNER JOIN msdb.dbo.syscategories AS sc WITH (NOLOCK)
ON sj.category_id = sc.category_id
LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js WITH (NOLOCK)
ON sj.job_id = js.job_id
LEFT OUTER JOIN msdb.dbo.sysschedules AS s WITH (NOLOCK)
ON js.schedule_id = s.schedule_id
ORDER BY sj.name OPTION (RECOMPILE);        
 
 
-- sp_add_jobschedule (Transact-SQL)
-- https://bit.ly/2Vzll5n