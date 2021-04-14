--https://www.mssqltips.com/sqlservertip/3128/monitor-sql-server-database-file-growth-with-wmi-alerts/
--Monitor SQL Server Database File Growth WMI Alerts

EXEC msdb.dbo.sp_add_job @job_name=N'WMI Response - DATABASE Growth Event', 
  @enabled=1, 
  @notify_level_eventlog=0, 
  @description=N'Sends notifications to DBA when DATABASE File Growth event(s) occur(s)

created by Sue Boorman to monitor database change events
script can be found in SharePoint > Technical Documentation > SQL Server > Monitoring',
  @owner_login_name=N'sa'
EXEC msdb.dbo.sp_add_jobstep @job_name=N'WMI Response - DATABASE Growth Event', 
  @step_name=N'Send e-mail in response to WMI alert(s)', 
  @step_id=1, 
  @subsystem=N'TSQL', 
  @command=N'EXEC msdb.dbo.sp_send_dbmail
    --@profile_name = ''DBServerAlerts'', -- update with your value
    @recipients = ''DBA_Notification@lexingtonky.gov'', -- update with your value
    @body = ''File Name: $(ESCAPE_SQUOTE(WMI(FileName))); 
Start Time: $(ESCAPE_SQUOTE(WMI(STartTime))); 
Duration: $(ESCAPE_SQUOTE(WMI(Duration))); 
Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName))); 
Host Name: $(ESCAPE_SQUOTE(WMI(HostName))); 
Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));'',
    @subject = ''Database file growth event - $(ESCAPE_SQUOTE(WMI(DatabaseName)))'' ;
',   @database_name=N'master'
GO
EXEC msdb.dbo.sp_add_jobserver  @job_name=N'WMI Response - DATABASE Growth Event', @server_name = @@SERVERNAME
GO

/*
-- Example of the DEFAULT instance's namespace ("DEMOSQL1" SQL Server):
\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER
-- Example of the NAMED instance's namespace ("DEMOSQL1\INSTANCE1" SQL Server):
\\.\root\Microsoft\SqlServer\ServerEvents\INSTANCE1

Service Broker must be enabled (which it should be by default)
SELECT is_broker_enabled  FROM sys.databases WHERE name = 'msdb';
*/
--setting up the alert
EXEC msdb.dbo.sp_add_alert @name=N'WMI - Database Growth Events', 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=15, 
  @include_event_description_in=1, 
  @notification_message=N'WMI - DB Growth notification', 
  @wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
  @wmi_query=N'select * from DATA_FILE_AUTO_GROW', 
  @job_name=N'WMI Response - DATABASE Growth Event'
GO