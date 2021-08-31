--Identify SQL Agent Jobs which are enabled but do not have notification set up
SELECT j.name, j.enabled, j.owner_sid, SUSER_SNAME([owner_sid]) AS OwnerName, j.notify_level_email, j.notify_email_operator_id, o.name, j.date_created, j.date_modified, j.version_number
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.sysoperators AS o ON j.notify_email_operator_id = o.id
WHERE j.[Enabled] = 1
	AND j.[Notify_Level_Email] = 0
ORDER BY j.name;
GO

/*--list the enabled operators
SELECT [ID], [Name], [Enabled]
FROM MSDB.dbo.sysoperators
WHERE [Enabled] = 1
ORDER BY [Name];
GO
*/

--update notification based on ID from second query (BE SURE TO CHECK ID OF OPERATOR)
UPDATE S
SET S.[notify_level_email] = 2, -- 0=never, 1=On Success, 2 On Failure, 3=Always
S.[notify_email_operator_id] = 
	(
	SELECT id
	FROM msdb.dbo.sysoperators 
	WHERE enabled = 1 AND name = 'DBA_Notification'
	)  -- instead of using the ID of Operator let's do this by name since ID will be different on different servers
FROM MSDB.dbo.sysjobs S
WHERE S.[Enabled] = 1
	AND S.[Notify_Level_Email] = 0;
GO

/*
 --use this to update a single item by OperatorID
UPDATE S
SET S.[notify_level_email] = 2,
S.[notify_email_operator_id] = -- <ID from the previous query>
FROM MSDB.dbo.sysjobs S
WHERE S.[Notify_Level_Email] = 0
AND S.[Enabled] = 1;
GO

--update notification from a single name to another name
UPDATE s
SET s.[notify_email_operator_id] = 
	(
	SELECT id
	FROM msdb.dbo.sysoperators 
	WHERE enabled = 1 AND name = 'DBA_Notification'
	)  -- instead of using the ID of Operator let's do this by name since ID will be different on different servers
FROM msdb.dbo.sysjobs AS s
LEFT JOIN msdb.dbo.sysoperators AS o ON s.notify_email_operator_id = o.id
WHERE o.name = 'SQL_DBA';
GO

*/


--select again after update
SELECT j.name, j.enabled, j.owner_sid, SUSER_SNAME([owner_sid]) AS OwnerName, j.notify_level_email, j.notify_email_operator_id, o.name, j.date_created, j.date_modified, j.version_number
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.sysoperators AS o ON j.notify_email_operator_id = o.id
ORDER BY j.name


/*--identify newly created jobs (last 15 days)
SELECT [Name], [Date_Created]
FROM MSDB.dbo.sysjobs
WHERE [Date_Created] BETWEEN DATEADD(dd, -15, GETDATE()) AND GETDATE();
GO
*/
--http://www.mssqltips.com/sqlservertip/2390/sql-server-agent-jobs-without-an-operator/ (05/20/2011)