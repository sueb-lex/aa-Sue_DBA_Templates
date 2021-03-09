/*
Displaying Backup or Restore Progress

By Greg Larsen
http://www.databasejournal.com/features/mssql/displaying-backup-or-restore-progress.html
Have you ever started a database backup or a restore process that runs a long time then wanted to know when it will complete?   If you have then there is an easily way to do this.  Knowing when a database backup or restore operation will completes provides you valuable information, especially when you need to perform follow-on tasks that are waiting for the backup or restore process to complete.

By reviewing this query you can see it is using sys.dm_exec_requests and sys.dm_exec_sql_text to retrieve information for “BACKUP DATABASE” or “RESTORE DATABASE” commands.
In order to show the backup or restore status you can run the following TSQL statement:
*/



SELECT session_id as SPID, command, a.text AS Query, start_time, percent_complete, 
      dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time 
FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a 
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE'); 

