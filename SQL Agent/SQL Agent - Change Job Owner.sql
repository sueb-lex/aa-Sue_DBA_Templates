/* CHANGE JOB OWNER
Determined that if a package is created as a user then when anything is changed (such as revise a maintenance plan) then the owner will revert back to the original owner
(after Chris Cunningham left jobs starting failing without warning)
important to also set notification in the SQL Agent job or the jobs will fail without notifying you of this

(03/10/2014 sb) use below script to change all the jobs to be owned by sa to prevent failures in the future
*/

--THESE UPDATES CHANGE THE SSIS PACKAGE OWNER
-------------------------------------------------------------------------------
--shows you details about the package include ownersid and OwnerName
--(2008)
SELECT name, description, [ownersid], SUSER_SNAME([ownersid]) AS OwnerName, createdate, packagetype, verbuild
FROM msdb.dbo.sysssispackages
ORDER BY name

--(2005)
SELECT name, description, [ownersid], SUSER_SNAME([owner_sid]) AS OwnerName, createdate, packagetype, verbuild
--select *
FROM msdb.dbo.sysdtspackages90
ORDER BY name

--change everything to sa which is not currently sa (2008)
UPDATE msdb.dbo.sysssispackages
SET [ownersid] = suser_sid('sa')
 WHERE [ownersid] <> suser_sid('sa')

--change everything to sa which is not currently sa (2005)
UPDATE msdb.dbo.sysdtspackages90
SET [ownersid] = suser_sid('sa')
 WHERE [ownersid] <> suser_sid('sa')

/*
--allows you to change a single user
UPDATE msdb.dbo.sysssispackages
SET [ownersid] = suser_sid('sa')
WHERE [ownersid] = suser_sid('LEXUCG\ccunningham')
 */ 

--shows you details about the package include ownersid and OwnerName
SELECT name, description, [ownersid], SUSER_SNAME([ownersid]) AS OwnerName, createdate, packagetype, verbuild
FROM msdb.dbo.sysssispackages
ORDER BY name

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--USE THIS TO CHANGE THE OWNER OF A SQL AGENT JOB (not the same as changing the owner of the maintenance plan)

--who is the owner of the job
SELECT job_id, name, enabled, owner_sid, SUSER_SNAME([owner_sid]) AS OwnerName, notify_email_operator_id, date_created, date_modified, version_number
FROM MSDB.dbo.sysjobs
ORDER BY name

--use this if you want to change all
UPDATE msdb.dbo.sysjobs
SET owner_sid = SUSER_SID('sa')
WHERE owner_sid <> SUSER_SID('sa')

/* use this if you want to change a single name
--reassign the job (must specify old owner)
EXEC  msdb.dbo.sp_manage_jobs_by_login
    @action = N'REASSIGN',
    @current_owner_login_name = N'sueb',
    @new_owner_login_name = N'sa' ;
GO
*/

--who is the owner of the job
SELECT job_id, name, enabled, owner_sid, SUSER_SNAME([owner_sid]) AS OwnerName, notify_email_operator_id, date_created, date_modified, version_number
FROM MSDB.dbo.sysjobs
ORDER BY name


--other examples of changing just specific SSIS items (not the same as changing the job owner)
-------------------------------------------------------------------------------
--update plans ownership
update msdb.dbo.sysssispackages
set [ownersid] = suser_sid('sa')
where [name] like '&MaintenancePlan%'

--type 6 is a maintenance plan
update msdb.dbo.sysssispackages
set [ownersid] = suser_sid('sa')
 where [packagetype] = 6
-------------------------------------------------------------------------------

--THIS IS A ANOTHER WAY TO MAKE THE CHANGE THE JOB OWNER
/*
HOW TO CHANGE THE JOB OWNER FOR ALL JOBS
run the first script using Registered Servers so it can be done on several servers at once
--will only work against SQL 2005\2008\2008R2
*/

--show who is the owner
SELECT
    sv.name AS [Name],
    sv.job_id AS [JobID],
    l.name AS OwnerName
FROM
    msdb.dbo.sysjobs_view AS sv
    INNER JOIN [master].[sys].[syslogins] l ON sv.owner_sid = l.sid
ORDER BY
    sv.[Name] ASC
GO

--change the owner
DECLARE @JobID uniqueidentifier
DECLARE @NewOwner varchar(200)
DECLARE @OldName varchar(200)
 
SET @NewOwner = 'sa'
SET @OldName = 'LEXUCG\sueb'
 
SELECT
sv.name AS [Name],
sv.job_id AS [JobID],
l.name AS [OwnerName]
INTO #SQLJobs
FROM
msdb.dbo.sysjobs_view AS sv
INNER JOIN [master].[sys].[syslogins] l ON sv.owner_sid = l.sid
WHERE l.name like @OldName
ORDER BY
sv.[Name] ASC
 
SELECT * FROM #SQLJobs
WHILE (SELECT COUNT(*) FROM #SQLJobs ) > 0 BEGIN
    SELECT TOP 1 @JobID = JobID FROM #SQLJobs
    EXEC msdb.dbo.sp_update_job @job_id= @JobID,
        @owner_login_name=@NewOwner
        DELETE FROM #SQLJobs WHERE JobID = @JobID 
END
 
DROP TABLE #SQLJobs
GO

--show who is the owner
SELECT
    sv.name AS [Name],
    sv.job_id AS [JobID],
    l.name AS OwnerName
FROM
    msdb.dbo.sysjobs_view AS sv
    INNER JOIN [master].[sys].[syslogins] l ON sv.owner_sid = l.sid
ORDER BY
    sv.[Name] ASC
GO
