/*
https://www.mssqltips.com/sqlservertip/3095/monitor-sql-server-databases-changes-using-wmi-alerts/
--Monitor SQL Server Database Changes Using WMI Alerts

--SEE NAMESPACE FOR POSSIBLE CHANGE TO INSTANCE
*/

EXEC msdb.dbo.sp_add_job @job_name=N'WMI Response - DATABASE Class Event', 
  @enabled=1, 
  @notify_level_eventlog=0, 
  @description=N'Sends notifications to DBA when DATABASE DDL event(s) occur(s)

created by Sue Boorman to monitor database change events
script can be found in SharePoint > Technical Documentation > SQL Server > Monitoring', 
  @owner_login_name=N'sa'
EXEC msdb.dbo.sp_add_jobstep @job_name=N'WMI Response - DATABASE Class Event', 
  @step_name=N'Send e-mail in response to WMI alert(s)', 
  @step_id=1, 
  @subsystem=N'TSQL', 
  @command=N'DECLARE @class_string NVARCHAR(200), @str_body NVARCHAR(max), @xdoc INT, @doc NVARCHAR(max)
-- get TSQL Command Text from XML
SET @doc =''$(ESCAPE_SQUOTE(WMI(TSQLCommand)))''
EXEC sp_xml_preparedocument @xdoc OUTPUT, @doc
SELECT   @str_body = ''TSQL Command: "'' + CommandText + ''"; 
 Database Name: $(ESCAPE_SQUOTE(WMI(DatabaseName)));
 SQL Server: '' + @@SERVERNAME + '';
 Post Time: $(ESCAPE_SQUOTE(WMI(PostTime))); 
 Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));''
FROM       OPENXML (@xdoc , ''/TSQLCommand/CommandText'',1)
      WITH (CommandText  varchar(max) ''text()'')
EXEC sp_xml_removedocument @xdoc
-- identify type of the event
SELECT @class_string = ''"$(ESCAPE_SQUOTE(WMI(DatabaseName)))": $(ESCAPE_SQUOTE(WMI(__CLASS))) event''
  
-- send e-mail with database change details
EXEC msdb.dbo.sp_send_dbmail
   -- @profile_name = ''DBServerAlerts'', -- update with your value
    @recipients = ''DBA_Notification@lexingtonky.gov'', -- update with your value
    @body = @str_body,
    @subject = @class_string ;
', 
  @database_name=N'master'
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'WMI Response - DATABASE Class Event',  @server_name = @@SERVERNAME
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
EXEC msdb.dbo.sp_add_alert @name=N'WMI - Database DDL Events', 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=15, 
  @include_event_description_in=1, 
  @notification_message=N'WMI - DB Change notification', 
  @wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
  @wmi_query=N'select * from DDL_DATABASE_EVENTS', 
  @job_name=N'WMI Response - DATABASE Class Event'
GO