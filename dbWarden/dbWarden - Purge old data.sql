--http://www.sqlservercentral.com/scripts/dbWarden+monitoring+maintenance/118935/              --broken link
--http://dba.stackexchange.com/questions/68262/how-to-clean-huge-dbwarden-queryhistory-table   --good

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc4HistoryTableCleanup]'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [dbo].[Proc4HistoryTableCleanup] ( ' +
			'    @TableOwner	varchar(64),' +
            '    @TableName     varchar(512), ' +
            '    @DateFieldName varchar(50), ' +
			'	 @retentionDays INT = 0,' +
			'    @Debug 	    TINYINT = 0' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   SELECT ''Not implemented'' ' +
            'END')	
END
GO

ALTER PROCEDURE [dbo].[Proc4HistoryTableCleanup] (
	@TableOwner		varchar(64),
    @TableName  	varchar(64),
    @DateFieldName  varchar(64),
    @retentionDays	INT,
	@maxRowCnt		INT = 10000,
	@debug		 	TINYINT = 0
)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This procedure takes in charge the clean-up for a given table based on a date field
	given as parameter and a retention expressed as a number of days.
	If the number of records to delete is more than a configurable limit, a dichotomic 
	delete will be performed so that there is no matter on big open transaction without 
	commit.
 
  ARGUMENTS :
	@TableOwner		name of the owner of the table to clean up
    @TableName     	name of the table to clean up
	@DateFieldName	name of the date field to use for clean up
	@retentionDays	number of days to keep track
	@maxRowCnt		maximal number of rows to consider in an open transaction.
					If the cleanup needs more than that number, the query will be cut 
					into pieces implying maximum @maxRowCnt
    @debug			if set to 1, this enables the debug mode
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================	
    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Revision History
 
    Date        Nom         Description
    ==========  =====       ==========================================================
    18/11/2014  JEL         Version 0.1.0
    ----------------------------------------------------------------------------------
 ===================================================================================
*/

BEGIN

    --SET NOCOUNT ON;
	
    DECLARE @versionNb        varchar(16) = '0.1.0';
    DECLARE @tsql             nvarchar(max);			-- text to execute via dynamic SQL
	DECLARE @tmpRetentionDays INT;						-- number of retention days to remove 
	DECLARE @retentionInc	  INT;						-- increment for tmpRetentionDays
	
	
	BEGIN TRY
		-- 
		-- check parameter :
		-- 		retention days 
		--
		if @retentionDays < 0
		BEGIN
			RAISERROR ('Parameter "retentionDays" is negative. Avorting execution', 10,1,@retentionDays);
		END		
		
		if @retentionDays = 0
			return
		
		--
		-- check parameters
		-- 		table-related parameters are usable ?
		--
		IF(NOT EXISTS (
			SELECT 1
			FROM 
				information_schema.COLUMNS 
			where 
				TABLE_CATALOG= DB_NAME(DB_id()) -- in current database
			AND TABLE_SCHEMA = @TableOwner
			AND TABLE_NAME   = @TableName
			and COLUMN_NAME  = @DateFieldName
		  ))
		  
		BEGIN			
			RAISERROR('Parameters about the table are unusable in current database ', 10,1,@TableOwner, @TableName ,@DateFieldName )
		END
		
		if @debug = 1
		BEGIN
			PRINT '----------------------------------------------------'
			PRINT OBJECT_NAME(@@PROCID)
			PRINT '===================================================='
			PRINT 'Owner	  = ' + @TableOwner
			PRINT 'TableName  = ' + @TableName
			PRINT 'Column     = ' + @DateFieldName
			PRINT 'Retention  = ' + CONVERT (VARCHAR ,@retentionDays)
			PRINT 'Max Row Nb = ' + CONVERT (VARCHAR ,@maxRowCnt)
			PRINT '----------------------------------------------------'
			PRINT CHAR(10)
		END
		
		-- 
		-- Iteration number evaluation
		--
		DECLARE @dateThresh DATETIME
		SET @dateThresh = GETDATE() - @retentionDays
		
		DECLARE @dateThreshStr   VARCHAR(100)
		SELECT @dateThreshStr = convert(varchar(100),@dateThresh,112)
		
		DECLARE @totalRecordNb   BIGINT
		DECLARE @MinDateFieldVal DATETIME
		
		SET @tsql =  N'SELECT ' 							+ CHAR(10) +
					'	 @totalRecNb = COUNT_BIG(*),' 			  	+ CHAR(10) +
					'    @minDate    = MIN([' + @DateFieldName + '])' 	+ CHAR(10) +
					'FROM'  + CHAR(10) +
					'    [' + @TableOwner + '].[' + @TableName + ']' + CHAR(10) +
					'WHERE' + CHAR(10) +
					'    '  + @DateFieldName + ' < convert(DATETIME,@dateThresh,112)'
		
		execute sp_executesql @tsql, N'@totalRecNb BIGINT OUTPUT, @minDate DATETIME OUTPUT,@dateThresh VARCHAR(100)', @minDate = @MinDateFieldVal OUTPUT, @totalRecNb = @totalRecordNb OUTPUT, @dateThresh = @dateThreshStr
		
		if @debug = 1
		BEGIN
			PRINT 'Min Date in table : ' + CONVERT (VARCHAR ,@MinDateFieldVal,112)
			PRINT 'Number of records : ' + CONVERT (VARCHAR ,@totalRecordNb)
		END
		
		if(@totalRecordNb > @maxRowCnt) 
		BEGIN				
			
			-- divide by 2 the number of days between min date and the retention period
			DECLARE @nbOfDaysToAdd INT
			SELECT @nbOfDaysToAdd = (DATEDIFF(day,@MinDateFieldVal,@dateThresh) / 2)
			
			if @debug = 1
			BEGIN
				PRINT 'Too many records to take care at once !'
				PRINT 'Days to play with : ' + CONVERT (VARCHAR ,@nbOfDaysToAdd)
			END	
			
			-- TODO : if days is not enough => play with hours !		
						
			SET @tmpRetentionDays = @retentionDays+@nbOfDaysToAdd
			if @debug = 1
			BEGIN				
				PRINT 'New retention : ' + convert(varchar,@tmpRetentionDays)
			END		
					
			exec [dbo].[Proc4HistoryTableCleanup] @TableOwner=@TableOwner,@TableName=@TableName,@DateFieldName=@DateFieldName,@retentionDays=@tmpRetentionDays,@maxRowCnt=@maxRowCnt,@debug=@debug			
			
			if @debug = 1
			BEGIN
				PRINT 'Restarting procedure with the previous retention :' + CONVERT (varchar,@retentionDays)
			END
			
			execute [dbo].[Proc4HistoryTableCleanup] @TableOwner=@TableOwner,@TableName=@TableName,@DateFieldName=@DateFieldName,@retentionDays=@retentionDays,@maxRowCnt=@maxRowCnt,@debug=@debug
		END
		ELSE
		BEGIN			
			if @debug = 1
			BEGIN
				PRINT 'Deleting ' + CONVERT (varchar,@totalRecordNb) + ' records' 
			END
			
			SET @tsql = 'DELETE' 	+ CHAR(10) +
						'FROM'  + CHAR(10) +
						'    [' + @TableOwner + '].[' + @TableName + ']' + CHAR(10) +
						'WHERE' + CHAR(10) +
						'    '  + @DateFieldName + ' < convert(DATETIME,@dateThresh,112)'
			
			execute sp_executesql @tsql, N'@dateThresh VARCHAR(100)', @dateThresh = @dateThreshStr						
		
			if @debug = 1
			BEGIN
				SET @tsql =  N'SELECT ' 							+ CHAR(10) +
						'	 @totalRecNb = COUNT_BIG(*),' 			  	+ CHAR(10) +
						'    @minDate    = MIN([' + @DateFieldName + '])' 	+ CHAR(10) +
						'FROM'  + CHAR(10) +
						'    [' + @TableOwner + '].[' + @TableName + ']' + CHAR(10) +
						'WHERE' + CHAR(10) +
						'    '  + @DateFieldName + ' < convert(DATETIME,@dateThresh,112)'
		
				execute sp_executesql @tsql, N'@totalRecNb BIGINT OUTPUT, @minDate DATETIME OUTPUT,@dateThresh VARCHAR(100)', @minDate = @MinDateFieldVal OUTPUT, @totalRecNb = @totalRecordNb OUTPUT, @dateThresh = @dateThreshStr			
			
				PRINT 'Nb of records after delete : ' + CONVERT (varchar,@totalRecordNb)
				PRINT 'Minimum date after delete  : ' + CONVERT(varchar,@MinDateFieldVal,112)
			END				
		
		END
		
		
	END TRY
	
	BEGIN CATCH
		PRINT 'ErrorNumber    : ' + CONVERT (VARCHAR , ERROR_NUMBER())
		PRINT 'ErrorSeverity  : ' + CONVERT (VARCHAR , ERROR_SEVERITY())
		PRINT 'ErrorState     : ' + CONVERT (VARCHAR , ERROR_STATE())
		PRINT 'ErrorProcedure : ' + CONVERT (VARCHAR , ERROR_PROCEDURE())
		PRINT 'ErrorLine      : ' + CONVERT (VARCHAR , ERROR_LINE())
		PRINT 'ErrorMessage   : ' + CONVERT (VARCHAR , ERROR_MESSAGE()) 
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN --RollBack in case of Error
			
		RAISERROR ('Unable to proceed !', 10,1,@retentionDays);
		
	END CATCH
END 

/**

Usage example :
==============
exec dbo.Proc4HistoryTableCleanup 
	@TableOwner		= 'dbo',
	@TableName		= 'CPUStatsHistory',
	@DateFieldName	= 'DateStamp',
	@retentionDays  = 700,
	@debug			= 1

exec dbo.Proc4HistoryTableCleanup 
	@TableOwner		= 'dbo',
	@TableName		= 'CPUStatsHistory',
	@DateFieldName	= 'DateStamp',
	@retentionDays  = 300,
	@debug			= 1		
*/


alter table  dbo.DataDictionary_Tables 
add retentionDays INT DEFAULT 90

update dbo.DataDictionary_Tables
set retentionDays = null
where TableName in (
	'AlertContacts','AlertSettings','DatabaseSettings','DataDictionary_Fields',
	'DataDictionary_Tables','SchemaChangeLog','ServerChangeLog'
)

update dbo.DataDictionary_Tables
set retentionDays = 90
where TableName in (
	'BlockingHistory','CPUStatsHistory','FileStatsHistory','HealthReport','JobStatsHistory',
	'MemoryUsageHistory','PerfStatsHistory','QueryHistory'
)

alter table  dbo.DataDictionary_Tables 
add dateField VARCHAR(100)

update dbo.DataDictionary_Tables
set dateField = 'DateStamp'
where TableName in (
	'BlockingHistory','CPUStatsHistory','HealthReport',
	'MemoryUsageHistory','QueryHistory'
)
update dbo.DataDictionary_Tables
set dateField = 'FileStatsDateStamp'
where TableName = 'FileStatsHistory'

update dbo.DataDictionary_Tables
set dateField = 'JobStatsDateStamp'
where TableName = 'JobStatsHistory'

update dbo.DataDictionary_Tables
set dateField = 'StatDate'
where TableName = 'PerfStatsHistory'


create view dbo.CleanupSettings
AS
select 
	SchemaName,
	TableName,
	dateField as DateFieldName,
	retentionDays
from dbo.DataDictionary_Tables 
where retentionDays is not null;


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbWarden_HistoryCleanup]'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [dbo].[dbWarden_HistoryCleanup] ( ' +			
			'    @Debug 	    TINYINT = 0' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   SELECT ''Not implemented'' ' +
            'END')	
END
GO

ALTER PROCEDURE [dbo].dbWarden_HistoryCleanup (	
	@debug		 	TINYINT = 0
)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This procedure takes care of purging old data inside tables defined in the
    table or view dbo.CleanupSettings of the same database as the one in which this
    procedure has been created.
 
  ARGUMENTS :
    @debug			if set to 1, this enables the debug mode
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================	
    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Revision History
 
    Date        Nom         Description
    ==========  =====       ==========================================================
    19/11/2014  JEL         Version 0.1.0
    ----------------------------------------------------------------------------------
 ===================================================================================
*/

BEGIN

    --SET NOCOUNT ON;
	
    DECLARE @versionNb        varchar(16) = '0.1.0';
    DECLARE @tsql             nvarchar(max);			-- text to execute via dynamic SQL

	DECLARE @CurrentOwner		VARCHAR(50)
	DECLARE @CurrentTable		VARCHAR(50)
	DECLARE @CurrentColumn		VARCHAR(50)
	DECLARE @CurrentRetention	INT

	DECLARE getTablesToPurge CURSOR FOR
        SELECT *
        FROM [dbo].[CleanupSettings]        		
	
	open getTablesToPurge
    FETCH NEXT
    FROM getTablesToPurge INTO @CurrentOwner,@CurrentTable,@CurrentColumn,@CurrentRetention
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
		
		if @debug = 1 
		BEGIN
			PRINT 'Current Owner  : '    + @CurrentOwner
			PRINT 'Current Table  : '    + @CurrentTable
			PRINT 'Current Column : '    + @CurrentColumn + '(datetime column used in where clause)'
			PRINT 'Current retention : ' + convert(varchar,@CurrentRetention)
		END
		
		exec dbo.Proc4HistoryTableCleanup 
			@TableOwner		= @CurrentOwner,
			@TableName		= @CurrentTable,
			@DateFieldName	= @CurrentColumn,
			@retentionDays  = @CurrentRetention,
			@debug			= @debug
			
		-- carry on ...
        FETCH NEXT
        FROM getTablesToPurge INTO @CurrentOwner,@CurrentTable,@CurrentColumn,@CurrentRetention
    END
    CLOSE getTablesToPurge
    DEALLOCATE getTablesToPurge
	
END


/**

Usage example :
==============
exec dbo.[dbWarden_HistoryCleanup] 
	@debug			= 1

exec dbo.[dbWarden_HistoryCleanup]
*/


-- 
-- ------------------------------
-- Sample job : everyday @8:15PM
-- ------------------------------
--
IF NOT EXISTS (SELECT * FROM msdb..sysjobs WHERE name = 'dbWarden_HistoryCleanup')
BEGIN
	BEGIN TRANSACTION
		DECLARE @ReturnCode INT
		SELECT @ReturnCode = 0

		DECLARE @jobId BINARY(16)
		EXEC 
			@ReturnCode =  msdb..sp_add_job @job_name=N'dbWarden_HistoryCleanup', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=2, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'Database Monitoring', 
			@owner_login_name=N'sa', 
			@notify_email_operator_name=N'SQL_DBA', @job_id = @jobId OUTPUT
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
		EXEC 
			@ReturnCode = msdb..sp_add_jobstep @job_id=@jobId, @step_name=N'run proc', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'SET NOCOUNT ON
EXEC [DBA].dbo.dbWarden_HistoryCleanup', 
			@database_name=N'master', 
			@flags=0
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
		EXEC @ReturnCode = msdb..sp_update_job @job_id = @jobId, @start_step_id = 1

		DECLARE @schedule_id int
		EXEC msdb.dbo.sp_add_jobschedule 	@job_id=@jobId, @name=N'dbWarden_Schedule_HistoryCleanup', 
											@enabled=1, 
											@freq_type=4, 
											@freq_interval=1, 
											@freq_subday_type=1, 
											@freq_subday_interval=0, 
											@freq_relative_interval=0, 
											@freq_recurrence_factor=1, 
											@active_start_date=20141119, 
											@active_end_date=99991231, 
											@active_start_time=201500, 
											@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
		EXEC @ReturnCode = msdb..sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
		COMMIT TRANSACTION
		GOTO EndSave
QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
END
GO		
