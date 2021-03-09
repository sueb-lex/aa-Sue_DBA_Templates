
/*
Suggested Backup Schedules for Ola Hallengren Backups
Last Updated:  12/14/2017

CommandLog Cleanup	     Sunday 12 am
Output File Cleanup 	Sunday 12 am
sp_delete_backuphistory 	Sunday 12 am
sp_purge_jobhistory 	Sunday 12 am

DatabaseBackup - SYSTEM_DATABASES - FULL	Sunday 1245 am
DatabaseBackup - USER_DATABASES - DIFF	not currently scheduled
DatabaseBackup - USER_DATABASES - FULL	Sunday 230 am
DatabaseBackup - USER_DATABASES - LOG	Mon-Sat 230 am
DatabaseIntegrityCheck - SYSTEM_DATABASES	Sunday 1215 am
DatabaseIntegrityCheck - USER_DATABASES	Saturday 1130 pm
IndexOptimize - USER_DATABASES	Saturday 130 am

--Other jobs which should be put on each server
Database Mail Archive	First Saturday of Each Month. 1230 am
Database Mail Failed Emails	Sunday 11 pm

--Create Schedule for once a week on Sunday at midnight
--create a schedule that can be used by one or more of jobs (used by the next 4 jobs)
EXEC msdb.dbo.sp_add_schedule  
    @schedule_name = N'Sunday 12 am' ,  
    @freq_type = 8,  --once a week
    @freq_interval = 1,  --Sunday
    @freq_recurrence_factor = 1,-- every week
    @active_start_time = 0;  --midnight
GO  
-------------------------------------------------------------------
--CommandLog Cleanup
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'CommandLog Cleanup',  
    @new_name = N'CommandLog Cleanup.Sunday 12 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--now attach schedule to the job
EXEC msdb.dbo.sp_attach_schedule  
   @job_name = N'CommandLog Cleanup.Sunday 12 am',  
   @schedule_name = N'Sunday 12 am';  
GO  

--Output File Cleanup
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'Output File Cleanup',  
    @new_name = N'Output File Cleanup.Sunday 12 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--now attach schedule to the job
EXEC msdb.dbo.sp_attach_schedule  
   @job_name = N'Output File Cleanup.Sunday 12 am',  
   @schedule_name = N'Sunday 12 am';  
GO  
--sp_delete_backuphistory
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'sp_delete_backuphistory',  
    @new_name = N'sp_delete_backuphistory.Sunday 12 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--now attach schedule to the job
EXEC msdb.dbo.sp_attach_schedule  
   @job_name = N'sp_delete_backuphistory.Sunday 12 am',  
   @schedule_name = N'Sunday 12 am';  
GO

--sp_purge_jobhistory
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'sp_purge_jobhistory',  
    @new_name = N'sp_purge_jobhistory.Sunday 12 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--now attach schedule to the job
EXEC msdb.dbo.sp_attach_schedule  
   @job_name = N'sp_purge_jobhistory.Sunday 12 am',  
   @schedule_name = N'Sunday 12 am';  
GO  
-------------------------------------------------------------------
--Below databases have their own schedule attached to the job

--DatabaseBackup - SYSTEM_DATABASES - FULL
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'DatabaseBackup - SYSTEM_DATABASES - FULL',  
    @new_name = N'DatabaseBackup - SYSTEM_DATABASES - FULL.Sunday 1245 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--create a job schedule 
EXEC msdb.dbo.sp_add_jobschedule  
    @job_name = N'DatabaseBackup - SYSTEM_DATABASES - FULL.Sunday 1245 am',  
    @name = N'Sunday 1245 am',  
    @freq_type = 8,  --once a week
    @freq_interval = 1,  --Sunday
    @freq_recurrence_factor = 1,  -- every week
    @active_start_time=4500;  --1245 am
GO  

--DatabaseBackup - USER_DATABASES - DIFF
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'DatabaseBackup - USER_DATABASES - DIFF',  
    @new_name = N'DatabaseBackup - USER_DATABASES - DIFF.Unscheduled',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO
--WILL NOT HAVE A JOB SCHEDULE ADDED AT THIS TIME  (may do 72 hour cleanup = 3 days)

--DatabaseBackup - USER_DATABASES - FULL
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'DatabaseBackup - USER_DATABASES - FULL',  
    @new_name = N'DatabaseBackup - USER _DATABASES - FULL.Sunday 230 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--create a job schedule 
EXEC msdb.dbo.sp_add_jobschedule  
    @job_name = N'DatabaseBackup - USER _DATABASES - FULL.Sunday 230 am',  
    @name = N'Sunday 230 am',  
    @freq_type = 8,  --once a week
    @freq_interval = 1,  --Sunday
    @freq_recurrence_factor = 1,  --every week
    @active_start_time=23000;  --230 am
GO  

--DatabaseBackup - USER_DATABASES - LOG
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'DatabaseBackup - USER_DATABASES - LOG',  
    @new_name = N'DatabaseBackup - USER_DATABASES - LOG.Mon-Sat 230 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--create a job schedule 
EXEC msdb.dbo.sp_add_jobschedule  
    @job_name = N'DatabaseBackup - USER_DATABASES - LOG.Mon-Sat 230 am',  
    @name = N'Mon-Sat 230 am',  
    @freq_type = 8,  --once a day Mon-Sat
    @freq_interval = 126,  --Mon-Sat
    @freq_recurrence_factor = 1,  --every week
    @active_start_time=23000;  --230 am
GO  


--DatabaseIntegrityCheck - SYSTEM_DATABASES
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'DatabaseIntegrityCheck - SYSTEM_DATABASES',  
    @new_name = N'DatabaseIntegrityCheck - SYSTEM_DATABASES.Sunday 1215 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--create a job schedule 
EXEC msdb.dbo.sp_add_jobschedule  
    @job_name = N'DatabaseIntegrityCheck - SYSTEM_DATABASES.Sunday 1215 am',  
    @name = N'Sunday 1215 am',  
    @freq_type = 8,  --once a week
    @freq_interval = 1,  --Sunday
    @freq_recurrence_factor = 1,  --every week
    @active_start_time=1500;  --1215 am
GO  

--DatabaseIntegrityCheck - USER_DATABASES
--change name of job to append schedule and add notification

EXEC msdb.dbo.sp_update_job  
    @job_name = N'DatabaseIntegrityCheck - USER_DATABASES',  
    @new_name = N'DatabaseIntegrityCheck - USER_DATABASES.Saturday 1130 pm',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--create a job schedule 
EXEC msdb.dbo.sp_add_jobschedule  
    @job_name = N'DatabaseIntegrityCheck - USER_DATABASES.Saturday 1130 pm',  
    @name = N'Saturday 1130 pm',  
    @freq_type = 8,  --once a week
    @freq_interval = 64,  --Saturday
    @freq_recurrence_factor = 1,  --every week
    @active_start_time=233000;  --1130 pm
GO  

--IndexOptimize - USER_DATABASES
--change name of job to append schedule and add notification
--IndexOptimize can be run before DatabaseIntegrityCheck since sometimes IndexOptimize can fix errors

EXEC msdb.dbo.sp_update_job  
    @job_name = N'IndexOptimize - USER_DATABASES',  
    @new_name = N'IndexOptimize - USER_DATABASES.Saturday 130 am',  
    @notify_level_email = 2,
    @notify_email_operator_name=N'DBA_Notification'
GO

--create a job schedule 
EXEC msdb.dbo.sp_add_jobschedule  
    @job_name = N'IndexOptimize - USER_DATABASES.Saturday 130 am',  
    @name = N'Saturday 130 am',  
    @freq_type = 8,  --once a week
    @freq_interval = 64,  --Saturday
    @freq_recurrence_factor = 1,  --every week
    @active_start_time=13000;  --130 am
GO  

-------------------------------------------------------------------
You can exclude databases by using syntax like:
Databases
Select databases. The keywords SYSTEM_DATABASES, USER_DATABASES, ALL_DATABASES, and AVAILABILITY_GROUP_DATABASES are supported. The hyphen character (-) is used to exclude databases, and the percent character (%) is used for wildcard selection. All of these operations can be combined by using the comma (,).
Value									  Description
SYSTEM_DATABASES							  All system databases (master, msdb, and model)
USER_DATABASES								  All user databases (includes distribution)
ALL_DATABASES								  All databases
AVAILABILITY_GROUP_DATABASES					  All databases in availability groups
USER_DATABASES, -AVAILABILITY_GROUP_DATABASES	  All user databases that are not in availability groups
Db1										  The database Db1
Db1, Db2									  The databases Db1 and Db2
USER_DATABASES, -Db1						  All user databases, except Db1
%Db%										  All databases that have “Db” in the name
%Db%, -Db1								  All databases that have “Db” in the name, except Db1
ALL_DATABASES, -%Db%						  All databases that do not have “Db” in the name


Examples
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES, -tkcsdb_OLD, -tkcsdb_ps_TEST', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 144, @Compress = 'Y', @CheckSum = 'Y', @LogToTable = 'Y'" -b

If server is set to Compress backups then this should just take the default setting (checked and seems to work)

sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = 'GIS_raster, DBA', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 144, @Compress = 'Y', @CheckSum = 'Y', @LogToTable = 'Y'" -b

this show example of excluding databases
@CleanupTime is in hours (144 hours = 6 days)

sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES, -tkcsdb_OLD, -tkcsdb_ps_TEST', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 144, @Compress = 'Y', @CheckSum = 'Y', @LogToTable = 'Y'" -b


Log Backup

sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES, -AccelaProd', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'LOG', @Verify = 'Y', @CleanupTime = 144, @CheckSum = 'Y', @LogToTable = 'Y'" -b

Data Backup

sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 144, @CheckSum = 'Y', @LogToTable = 'Y'" -b
*/
