--LastUpdated  03/15/2021 sb

--CommandLog Cleanup (Sunday 12 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "DELETE FROM  dbo.CommandLog WHERE StartTime < DATEADD(dd,-30,GETDATE())" -b

DELETE FROM DBA.dbo.CommandLog
WHERE StartTime < DATEADD(dd,-30,GETDATE())

--Backup - SYSTEM DATABASES (Sunday 1245 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE dbo.DatabaseBackup @Databases = 'SYSTEM_DATABASES', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 144, @CheckSum = 'Y', @LogToTable = 'Y'" -b

EXECUTE DBA.dbo.DatabaseBackup
@Databases = 'SYSTEM_DATABASES',
@Directory = N'\\prdsqlbus2\sql_data_backup$',
@BackupType = 'FULL',
@Verify = 'Y',
@CleanupTime = 144,
@CheckSum = 'Y',
@LogToTable = 'Y',
@Compress = 'Y'
------------------------------------------------------------------------------------------------------------------------------------------------
--Backup - USER DATABASES FULL (Sunday 230 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE dbo.DatabaseBackup @Databases = 'USER_DATABASES', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 144, @Compress = 'Y', @CheckSum = 'Y', @LogToTable = 'Y'" -b

EXECUTE DBA.dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = N'\\prdsqlbus2\sql_data_backup$',
@BackupType = 'FULL',
@Verify = 'Y',
@CleanupTime = 144,
@CheckSum = 'Y',
@LogToTable = 'Y',
@Compress = 'Y'

/*
EXAMPLE FROM WEBSITE
sqlcmd -E -S .\SQLEXPRESS -d DBA -Q "EXECUTE dbo.DatabaseBackup @Databases = 'USER_DATABASES', @Directory = N'C:\Backup', @BackupType = 'FULL'" -b -o C:\Log\DatabaseBackup.txt
*/
------------------------------------------------------------------------------------------------------------------------------------------------
--Backup - USER DATABASES LOG (Sunday 230 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE dbo.DatabaseBackup @Databases = 'USER_DATABASES, -%tkcsdb% ', @Directory = N'\\prdsqlbus2\sql_data_backup$', @BackupType = 'LOG', @Verify = 'Y', @CleanupTime = 144, @Compress = 'Y', @CheckSum = 'Y', @LogToTable = 'Y'" -b

EXECUTE DBA.dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = N'\\prdsqlbus2\sql_data_backup$',
@BackupType = 'LOG',
@Verify = 'Y',
@CleanupTime = 144,
@CheckSum = 'Y',
@LogToTable = 'Y',
@Compress = 'Y'

------------------------------------------------------------------------------------------------------------------------------------------------
--Database Integrity Check - SYSTEM DATABASES (Sunday 1215 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE dbo.DatabaseIntegrityCheck @Databases = ''SYSTEM_DATABASES'', @LogToTable = 'Y'" -b

EXECUTE DBA.dbo.DatabaseIntegrityCheck
@Databases = 'SYSTEM_DATABASES',
@LogToTable = 'Y'

------------------------------------------------------------------------------------------------------------------------------------------------
--Database Integrity Check - USER DATABASES (Saturday 1030 pm)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE dbo.DatabaseIntegrityCheck @Databases = ''USER_DATABASES'', @LogToTable = 'Y'" -b

EXECUTE DBA.dbo.DatabaseIntegrityCheck
@Databases = 'USER_DATABASES',
@LogToTable = 'Y'

------------------------------------------------------------------------------------------------------------------------------------------------
--Index Optimize - USER DATABASES (Saturday 130 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA -Q "EXECUTE dbo.IndexOptimize @Databases = 'USER_DATABASES', @LogToTable = 'Y'" -b

EXECUTE DBA.dbo.IndexOptimize
@Databases = 'USER_DATABASES',
@LogToTable = 'Y'

------------------------------------------------------------------------------------------------------------------------------------------------
--Output File Cleanup (Sunday 12 am)
cmd /q /c "For /F "tokens=1 delims=" %v In ('ForFiles /P "$(ESCAPE_SQUOTE(SQLLOGDIR))" /m *_*_*_*.txt /d -30 2^>^&1') do if EXIST "$(ESCAPE_SQUOTE(SQLLOGDIR))"\%v echo del "$(ESCAPE_SQUOTE(SQLLOGDIR))"\%v& del "$(ESCAPE_SQUOTE(SQLLOGDIR))"\%v"

------------------------------------------------------------------------------------------------------------------------------------------------
--sp_delete_backuphistory (Sunday 12 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d msdb -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate" -b

DECLARE @CleanupDate datetime
SET @CleanupDate = DATEADD(dd,-30,GETDATE())
EXECUTE msdb.dbo.sp_delete_backuphistory @oldest_date = @CleanupDate

------------------------------------------------------------------------------------------------------------------------------------------------
--sp_purge_jobhistory (Sunday 12 am)
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d msdb -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate" -b

DECLARE @CleanupDate datetime
SET @CleanupDate = DATEADD(dd,-30,GETDATE())
EXECUTE msdb.dbo.sp_purge_jobhistory @oldest_date = @CleanupDate

Compress
If no value is specified then the backup compression default in sys.configurations is used
NULL (default), Y (Compress), N (Do not Compress)


-------------------------------------------------------------------
You can exclude databases by using syntax like:
Databases
Select databases. The keywords SYSTEM_DATABASES, USER_DATABASES, ALL_DATABASES, and AVAILABILITY_GROUP_DATABASES are supported. The hyphen character (-) is used to exclude databases, and the percent character (%) is used for wildcard selection. All of these operations can be combined by using the comma (,).
Value									  Description
SYSTEM_DATABASES								All system databases (master, msdb, and model)
USER_DATABASES									All user databases (includes distribution)
ALL_DATABASES									All databases
AVAILABILITY_GROUP_DATABASES					All databases in availability groups
USER_DATABASES, -AVAILABILITY_GROUP_DATABASES	All user databases that are not in availability groups
Db1												The database Db1
Db1, Db2										The databases Db1 and Db2
USER_DATABASES, -Db1							All user databases, except Db1
%Db%											All databases that have “Db” in the name (can use single % if needed)
%Db%, -Db1								  		All databases that have “Db” in the name, except Db1
ALL_DATABASES, -%Db%							All databases that do not have “Db” in the name


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

------------------------------------------------------------------------------------------------------------------------------------------------

Script to allow you to run Update Modified Stats for all user databases without rebuilding indexes
https://www.brentozar.com/archive/2016/04/updating-statistics-ola-hallengrens-scripts/


EXECUTE [dbo].[IndexOptimize]
    @Databases = 'USER_DATABASES' ,
    @FragmentationLow = NULL ,
    @FragmentationMedium = NULL ,
    @FragmentationHigh = NULL ,
    @UpdateStatistics = 'ALL' ,
    @OnlyModifiedStatistics = N'Y' ,
    @LogToTable = N'Y';

------------------------------------------------------------------------------------------------------------------------------------------------
