/* ** Agent Job List ******************************************************** **
** Description: Create a list of agent jobs and their schedules.
** Author: Michael McCormick
** Acknowledgments:
**   Ken Simmons - for revealing the existence of the sp_get_schedule_description
**     procedure and revealing the underlying code.
**   Michelle Ufford - for the idea of using the code as a CTE for the job query
**     and providing the basic structure for the CTE query.
**  works with SQL2008R2 (which can't handle IIF clause)
** http://www.sqlservercentral.com/Forums/Topic1779896-3794-1.aspx
** ************************************************************************** */
USE [msdb]
GO

With schedules
AS
(
SELECT
	j.job_id,
	ss.name As [schedule_name],
	CASE ss.freq_type
		WHEN 0x01 THEN N'Once on ' + cast(dbo.agent_datetime(ss.active_start_date, ss.active_start_time) AS varchar(30))
		WHEN 0x04 THEN
			CASE ss.freq_interval WHEN 1 THEN N'Every day' ELSE N'Every ' + CONVERT(nvarchar,ss.freq_interval) + N' days' END
			+ CASE when ss.freq_subday_type IN (0x02,0x04,0x08) THEN N', ' ELSE N' ' end
		WHEN 0x08 THEN
			CASE ss.freq_recurrence_factor WHEN 1 THEN N'Every week on'
				ELSE N'Every ' + CONVERT(nvarchar,ss.freq_recurrence_factor) + N' weeks on ' END
				+ STUFF( CASE WHEN ss.freq_interval & 0x01 = 0x01 then N', Sunday'    ELSE '' end
				+ CASE WHEN ss.freq_interval & 0x02 = 0x02 then N', Monday'    ELSE '' end
				+ CASE when ss.freq_interval & 0x04 = 0x04 then N', Tuesday'   ELSE '' end
				+ CASE WHEN ss.freq_interval & 0x08 = 0x08 then N', Wednesday' ELSE '' end
				+ CASE WHEN ss.freq_interval & 0x10 = 0x10 then N', Thursday'  ELSE '' end
				+ CASE WHEN ss.freq_interval & 0x20 = 0x20 THEN N', Friday'    ELSE '' end 
				+ CASE when ss.freq_interval & 0x40 = 0x40 then N', Saturday'  ELSE '' end, 1, 1, '') + ' '
		WHEN 0x10 THEN
			CASE when ss.freq_recurrence_factor = 1 then N'Every month on day ' else N'Every ' END
			+ CONVERT(nvarchar,ss.freq_recurrence_factor) + N' months on day '
			+ CONVERT(nvarchar,ss.freq_interval) + N' of that month '
		WHEN 0x20 THEN
			CASE WHEN ss.freq_recurrence_factor = 1 then N'Every month on the ' else N'Every ' end
			+ CONVERT(nvarchar,ss.freq_recurrence_factor) + N' months on the '
			+ CASE ss.freq_relative_interval
				WHEN 0x01 THEN N'first '
				WHEN 0x02 THEN N'second '
				WHEN 0x04 THEN N'third '
				WHEN 0x08 THEN N'fourth '
				WHEN 0x10 THEN N'last '
			END
			+ CASE WHEN ss.freq_interval BETWEEN 1 AND 7 THEN DATENAME(dw, N'1996120' + CONVERT(nvarchar, ss.freq_interval))
				WHEN ss.freq_interval =  8 THEN N'day'
				WHEN ss.freq_interval =  9 THEN N'weekday'
				WHEN ss.freq_interval = 10 THEN N'weekend day'
			END
			+ N' of that month'
			+ CASE when ss.freq_subday_type IN (0x02,0x04,0x08) THEN N', ' ELSE N' ' end
		WHEN 0x40 THEN FORMATMESSAGE(14579)
	END
/* Subday Portion */
	+
	CASE
		when ss.freq_type IN (0x04, 0x08, 0x10, 0x20) then
			CASE ss.freq_subday_type
				WHEN 0x1 THEN N'at ' + CONVERT(nvarchar, RIGHT('00'+CONVERT(varchar(10),ss.active_start_time/10000),2) + ':' + RIGHT('00' + CONVERT(varchar(10),(ss.active_start_time % 10000) / 100),2) ) 
				WHEN 0x2 THEN CASE WHEN ss.freq_subday_interval = 1 THEN N'every second,' ELSE N'every ' + CONVERT(nvarchar, ss.freq_subday_interval) + N' seconds,' end
				WHEN 0x4 THEN CASE when ss.freq_subday_interval = 1 THEN N'every minute,' ELSE N'every ' + CONVERT(nvarchar, ss.freq_subday_interval) + N' minutes,' end
				WHEN 0x8 THEN CASE WHEN ss.freq_subday_interval = 1 THEN N'every hour,' ELSE N'every ' + CONVERT(nvarchar, ss.freq_subday_interval) + N' hours,' end
			END
		+
		CASE
			when ss.freq_subday_type IN (0x02, 0x04, 0x08)
			then N' between '
			+ CONVERT(nvarchar, RIGHT('00'+CONVERT(varchar(10),ss.active_start_time / 10000),2) + ':' + RIGHT('00'+CONVERT(varchar(10),(ss.active_start_time % 10000) / 100),2) )
			+ N' and '
			+ CONVERT(nvarchar, RIGHT('00'+CONVERT(varchar(10),ss.active_end_time / 10000),2) + ':' + RIGHT('00'+CONVERT(varchar(10),(ss.active_end_time % 10000) / 100),2) ) 
			ELSE  N''
		end
		else N''
	end As [Description]
From dbo.sysschedules ss
Inner Join dbo.sysjobschedules js On js.schedule_id = ss.schedule_id
Inner Join dbo.sysjobs j On j.job_id = js.job_id
),

history
AS
(
SELECT
	dt_h.job_id,
	CONVERT(varchar,dt_h.RunDate,100) As [LastRunDate],
	case when PATINDEX('% invoked by User %',dt_h.[message]) = 0 THEN ''
	ELSE SUBSTRING(dt_h.[message], PATINDEX('% invoked by User %',dt_h.[message])+17,
		PATINDEX('%.  The last step to run %',dt_h.[message])-PATINDEX('% invoked by User %',dt_h.[message])-17)
	end As [User]
FROM
	(
	SELECT
		ROW_NUMBER() OVER( PARTITION BY h.job_id ORDER BY h.run_date DESC, h.run_time DESC ) As [Row],
		h.job_id,
		dbo.agent_datetime(h.run_date , h.run_time) As [RunDate],
		h.[message]
	From dbo.sysjobhistory h
	Where step_id = 0
	) dt_h
 Where [Row] = 1
)

SELECT
	j.name As [Job Name],
	SUSER_SNAME(j.owner_sid) As [Owner],
	j.[enabled] As [Enabled],
	s.schedule_name,
	CASE
		WHEN s.Description IS NULL THEN 'Not scheduled.' + ISNULL(' Last run '+h.LastRunDate+ ISNULL(' by user '+h.[User]+'.','.'),'')
		ELSE s.Description
	END As [ScheduleDescription],
	CASE
		WHEN j.[description] = 'No description available.' THEN ''
		ELSE REPLACE(REPLACE(j.[description],CHAR(13),''),CHAR(10),'')
	END As [JobDescription]
From dbo.sysjobs j
Left Outer Join schedules s On s.job_id = j.job_id
Left Outer Join history h On h.job_id = j.job_id
Order By j.name
;
