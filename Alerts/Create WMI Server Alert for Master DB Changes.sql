/*
Monitor SQL Server Master Database Changes with WMI Alerts
https://www.mssqltips.com/sqlservertip/3601/monitor-sql-server-master-database-changes-with-wmi-alerts/

--SEE NAMESPACE FOR POSSIBLE CHANGE TO INSTANCE

*/

--CREATE JOB - 'WMI Response - Audit master Database Object Management Event'
USE [msdb]
GO

/****** Object:  Job [WMI Response - Audit master Database Object Management Event]    Script Date: 11/02/2016 08:30:59 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Monitoring]    Script Date: 11/02/2016 08:30:59 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Monitoring' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category 
		@class=N'JOB', 
		@type=N'LOCAL', 
		@name=N'Database Monitoring'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'WMI Response - Audit master Database Object Management Event')
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job 
		@job_name=N'WMI Response - Audit master Database Object Management Event', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends email to DBA when master DB object modification event occur', 
		@category_name=N'Database Monitoring', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Notification', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
/****** Object:  Step [Send e-mail in response to WMI alert(s)]    Script Date: 11/02/2016 08:30:59 AM ******/
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
		@job_name=N'WMI Response - Audit master Database Object Management Event', 
		@step_name=N'Send e-mail in response to WMI alert(s)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N'TSQL', 
		@command=N'DECLARE @p_body nvarchar(max)

	  SELECT @p_body = ''Server Name: $(ESCAPE_SQUOTE(WMI(ServerName)));
	  Start Time: $(ESCAPE_SQUOTE(WMI(STartTime))); 
	  Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName))); 
	  Host Name: $(ESCAPE_SQUOTE(WMI(HostName))); 
	  Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
	  Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));
	  ObjectName: $(ESCAPE_SQUOTE(WMI(ObjectName)));
	  EventSubClass: '' + CASE 
	  	WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) =1  THEN ''Create'' 
		WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) = 2  THEN ''Alter'' 
		WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) = 3  THEN ''Drop'' 
		WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) = 4  THEN ''Dump'' 
		WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) = 10  THEN ''Open'' 
		WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) = 11  THEN ''Load'' 
		WHEN $(ESCAPE_SQUOTE(WMI(EventSubClass))) = 12  THEN ''Access'' END
	  EXEC msdb.dbo.sp_send_dbmail
    	 -- @profile_name = ''DBServerAlerts'', -- update with your value
    	  @recipients = ''DBA_Notification@lexingtonky.gov'', -- update with your value
    	  @body = @p_body,
    	  @subject = ''master DB object change - $(ESCAPE_SQUOTE(WMI(ServerName)))'' ;', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job 
		@job_name=N'WMI Response - Audit master Database Object Management Event', 
		@start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver 
		@job_name=N'WMI Response - Audit master Database Object Management Event', 
		@server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/*
-- Example of the DEFAULT instance's namespace ("DEMOSQL1" SQL Server):
\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER
-- Example of the NAMED instance's namespace ("DEMOSQL1\INSTANCE1" SQL Server):
\\.\root\Microsoft\SqlServer\ServerEvents\INSTANCE1

Service Broker must be enabled (which it should be by default)
SELECT is_broker_enabled  FROM sys.databases WHERE name = 'msdb';
*/


--CREATE ALERT - 'WMI - Audit master Schema Object Management Event'
USE [msdb]
GO

/****** Object:  Alert [WMI - Audit master Schema Object Management Event]    Script Date: 11/02/2016 08:32:41 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'WMI - Audit master Schema Object Management Event')
EXEC msdb.dbo.sp_add_alert
		@name=N'WMI - Audit master Schema Object Management Event', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=10, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'select * from AUDIT_SCHEMA_OBJECT_MANAGEMENT_EVENT 
			where DatabaseName=''master''', 
		@job_name=N'WMI Response - Audit master Database Object Management Event'
GO

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--CREATE JOB - 'WMI Response - Audit Add master DB user Event'
USE [msdb]
GO

/****** Object:  Job [WMI Response - Audit Add master DB user Event]    Script Date: 11/02/2016 08:34:02 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Monitoring]    Script Date: 11/02/2016 08:34:02 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Monitoring' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category 
		@class=N'JOB', 
		@type=N'LOCAL', 
		@name=N'Database Monitoring'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'WMI Response - Audit Add master DB user Event')
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job 
		@job_name=N'WMI Response - Audit Add master DB user Event', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends email to DBA when user created in master DB', 
		@category_name=N'Database Monitoring', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Notification', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
/****** Object:  Step [Send e-mail in response to WMI alert(s)]    Script Date: 11/02/2016 08:34:02 AM ******/
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
		@job_name=N'WMI Response - Audit Add master DB user Event', 
		@step_name=N'Send e-mail in response to WMI alert(s)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_send_dbmail
   		--@profile_name = ''DBServerAlerts'', -- update with your value
  		@recipients = ''DBA_Notification@lexingtonky.gov'', -- update with your value
   		@body = ''Server Name: $(ESCAPE_SQUOTE(WMI(ServerName)));
			Start Time: $(ESCAPE_SQUOTE(WMI(STartTime))); 
			Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName))); 
			Host Name: $(ESCAPE_SQUOTE(WMI(HostName))); 
			Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
			Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));
			Target User Name: $(ESCAPE_SQUOTE(WMI(TargetUserName)));
			DBuserName: $(ESCAPE_SQUOTE(WMI(DBuserName)));'',
    		@subject = ''master DB user added - $(ESCAPE_SQUOTE(WMI(ServerName)))'' ;', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job 
		@job_name=N'WMI Response - Audit Add master DB user Event', 
		@start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver 
		@job_name=N'WMI Response - Audit Add master DB user Event', 
		@server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/*
-- Example of the DEFAULT instance's namespace ("DEMOSQL1" SQL Server):
\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER
-- Example of the NAMED instance's namespace ("DEMOSQL1\INSTANCE1" SQL Server):
\\.\root\Microsoft\SqlServer\ServerEvents\INSTANCE1

Service Broker must be enabled (which it should be by default)
SELECT is_broker_enabled  FROM sys.databases WHERE name = 'msdb';
*/

--CREATE ALERT - 'WMI - Audit Add master DB user Event'
USE [msdb]
GO

/****** Object:  Alert [WMI - Audit Add master DB user Event]    Script Date: 11/02/2016 08:34:26 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'WMI - Audit Add master DB user Event')
EXEC msdb.dbo.sp_add_alert 
		@name=N'WMI - Audit Add master DB user Event', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=10, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'select * from AUDIT_ADD_DB_USER_EVENT where DatabaseName=''master''', 
		@job_name=N'WMI Response - Audit Add master DB user Event'
GO

