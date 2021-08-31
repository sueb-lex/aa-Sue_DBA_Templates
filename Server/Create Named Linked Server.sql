
/*
'Created a Named Linked Server'

Author:		Sue Boorman
Create date: 06/22/2021
Description: Used to Created a Named Linked Server
LastUpdated:  06/22/2021 sb
=================================================

Use command (Ctrl-Shift-M) to Specify Values for Template Parameters 

EXAMPLE:
LinkedServerName =	 PRDSQL2019GIS\GISDATA1_AccelaGIS  (Name for the Linked Server)
RemoteServerName =	 PRDSQL2019GIS\GISDATA1	(Server Name of Remote Server)
DatabaseName =		 GIS_master (Database Name on Remote Server)
RemoteUser =		 AccelaGIS (SQL Account being used to connect to Database on Remote Server)
RemoteUserPassword = ######### (Enter Password for Remote User Account)
*/

USE [master]
GO

EXEC master.dbo.sp_addlinkedserver 
	@server = N'<LinkedServerName,,LinkedServerName>', 
	@srvproduct=N'', @provider=N'SQLNCLI', 
	@datasrc=N'<RemoteServerName,,RemoteServerName>', 
	@catalog=N'<DatabaseName,,DatabaseName>'
/* New recommendation for Provider is   */
/* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin 
	@rmtsrvname=N'<LinkedServerName,,LinkedServerName>',
	@useself=N'False',@locallogin=NULL,
	@rmtuser=N'<RemoteUser,,RemoteUser>',
	@rmtpassword='<RemotePassword,,RemotePassword>'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>',
	@optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'PRDSQL2019GIS\GISDATA1_AccelaGIS', 
	@optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption 
	@server=N'<LinkedServerName,,LinkedServerName>', 
	@optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/*
SQL Server Native Client OLE DB provider (SQLNCLI) remains deprecated and it is not recommended to use it for new development work. Instead, use the new Microsoft OLE DB Driver for SQL Server (MSOLEDBSQL) which will be updated with the most recent server features.
https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-addlinkedserver-transact-sql?view=sql-server-ver15
When using the MSOLEDBSQL it was displaying the System tables along with the database you were listing as the remote database and the System databases did not show up under the System Catalogs as was found in the old provider. 
  Since this seemed confusing so I did not use it here.
*/