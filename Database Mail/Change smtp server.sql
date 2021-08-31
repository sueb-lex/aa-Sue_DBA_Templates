SELECT [sysmail_server].[account_id]
		,[sysmail_account].[name] AS [Account Name]
      ,[servertype]
      ,[servername] AS [SMTP Server Address]
      ,[Port]
     
  FROM [msdb].[dbo].[sysmail_server]
  INNER JOIN [msdb].[dbo].[sysmail_account]
  ON [sysmail_server].[account_id]=[sysmail_account].[account_id]
--------------------------------------------------------------------------------------
  -- Run below SP to change any info of mail account. Replace XXXX & XX with your correct SMTP IP address and port no.
EXECUTE msdb.dbo.sysmail_update_account_sp
	 @account_id = 1
    --@account_name = 'CJMaster'
    --,@description = 'Mail account for administrative e-mail.'
    ,@mailserver_name = 'gcsmtp2.lexucg.local'
    ,@mailserver_type = 'SMTP'
    ,@port = 25
--------------------------------------------------------------------------------------
--check again to be sure it has been changed
SELECT [sysmail_server].[account_id]
	  ,[sysmail_account].[name] AS [Account Name]
      ,[servertype]
      ,[servername] AS [SMTP Server Address]
      ,[Port]
     
  FROM [msdb].[dbo].[sysmail_server]
  INNER JOIN [msdb].[dbo].[sysmail_account]
  ON [sysmail_server].[account_id]=[sysmail_account].[account_id]

--sueb@lexingtonky.gov
--https://www.mssqltips.com/sqlservertip/3654/how-to-modify-sql-server-database-mail-accounts/