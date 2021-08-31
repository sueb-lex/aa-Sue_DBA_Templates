USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[usp_Kill_Spid]    Script Date: 06/17/2019 02:43:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--use this procedure to kill all connections to a database
CREATE PROCEDURE [dbo].[usp_Kill_Spid] 
	@p_dbname VARCHAR(32) 
AS
SET NOCOUNT ON
	 
BEGIN 
	DECLARE @m_dbid INT 
	DECLARE @m_spid INT 
	DECLARE @m_sql NVARCHAR(255) 

	SELECT @m_dbid = dbid 
	FROM master..sysdatabases 
	WHERE name = @p_dbname 

	DECLARE curKillSet INSENSITIVE CURSOR 
	FOR 
	SELECT spid 
	FROM master..sysprocesses 
	WHERE dbid = @m_dbid AND spid <> @@spid --can't kill your own spid

	OPEN curKillSet 
	FETCH NEXT FROM curKillSet INTO @m_spid 
	WHILE @@FETCH_STATUS = 0 
		BEGIN 
			SET @m_sql ='KILL ' + CAST(@m_spid AS VARCHAR) 
			SELECT @m_sql
			--print @m_sql 
			EXEC sp_executesql @m_sql 
			FETCH NEXT FROM curKillSet INTO @m_spid 
		END 
	CLOSE curKillSet 
	DEALLOCATE curKillSet 
END;
 
WAITFOR DELAY '00:00:05' --Waits for 5 seconds to give time to finish
GO


