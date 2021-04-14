--Used to add Extended Properties to a Table

EXEC sys.sp_addextendedproperty 
	@name=N'MS_Description', 
	@value=N'<MS_Description,sysname,Table Description>' ,
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'TABLE', 
	@level1name=N'<table_name, sysname, Table Name here>'
GO

EXEC sys.sp_addextendedproperty 
	@name=N'Developer', 
	@value=N'<Developer_Name, sysname, Developer_Name>' ,
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'TABLE', 
	@level1name=N'<table_name, sysname, Table Name here>'
GO


EXEC sys.sp_addextendedproperty 
	@name = N'DivisionOwner', 
	@value = N'<Division_Name, sysname, Division_Name>',
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'TABLE', 
	@level1name=N'<table_name, sysname, Table Name here>'

GO


EXEC sys.sp_addextendedproperty 
	@name = N'LastUpdated', 
	@value = N'<LastUpdated, sysname, LastUpdated>',
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'TABLE', 
	@level1name=N'<table_name, sysname, Table Name here>'

GO



--used to select extended properties from a single database (must be pointed to this database)
SELECT major_id, minor_id, t.name AS [Table Name], value AS [Extended Property]
FROM sys.extended_properties AS ep
INNER JOIN sys.tables AS t ON ep.major_id = t.object_id 
WHERE class = 1
ORDER BY [Table Name];

-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================
-- =============================================
-- Author:		Sue Boorman
-- Create date:     10/11/2011
-- Description:	Use to Add Extended Properties to a single table
-- Last Updated:    01/05/2018
-- =============================================
GO
