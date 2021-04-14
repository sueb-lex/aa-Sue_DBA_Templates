--Add Extended Properties to View

EXEC sys.sp_addextendedproperty 
	@name=N'MS_Description', 
	@value=N'<MS_Description,sysname,View Description>' ,
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'VIEW', 
	@level1name=N'<view_name, sysname, View Name here>'
GO

EXEC sys.sp_addextendedproperty 
	@name=N'Developer', 
	@value=N'<Developer_Name, sysname, Developer_Name>' ,
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'VIEW', 
	@level1name=N'<view_name, sysname, View Name here>'
GO


EXEC sys.sp_addextendedproperty 
	@name = N'DivisionOwner', 
	@value = N'<Division_Name, sysname, Division_Name>',
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'VIEW', 
	@level1name=N'<view_name, sysname, View Name here>'

GO


EXEC sys.sp_addextendedproperty 
	@name = N'DateCreated', 
	@value = N'<Date_Created, sysname, LastUpdated>',
	@level0type=N'SCHEMA', 
	@level0name=N'<schema_name, sysname, dbo>', 
	@level1type=N'VIEW', 
	@level1name=N'<view_name, sysname, View Name here>'

GO



--used to select extended properties from a single database or view (must be pointed to this database)
SELECT
    s.name AS [SchemaName],
    CASE
        WHEN o.type_desc = 'user_table' and ep.minor_id = 0 then 'Table'
        --WHEN o.type_desc = 'user_table' and ep.minor_id > 0 then concat('Column from ', o.name)  --only works on new SQL versions
        WHEN o.type_desc = 'user_table' and ep.minor_id > 0 then ('Column from '+  o.name)
        WHEN o.type_desc = 'view' and ep.minor_id = 0 then 'View'
        WHEN o.type_desc = 'view' and ep.minor_id > 0 then 'View'
        WHEN o.type_desc = 'sql_stored_procedure' and ep.minor_id = 0 then 'Stored procedure'
        WHEN o.type_desc = 'sql_trigger' and ep.minor_id = 0 then 'Trigger'
        ELSE '---'
    END AS [ObjectType],
    o.name AS [ObjectName],
	ep.name AS [PropertyName],
    ep.value AS [PropertyDescripion],
    o.type AS [Type],
    o.type_desc AS [TypeDescription]
FROM sys.objects AS o
    LEFT JOIN sys.extended_properties AS ep ON o.object_id = ep.major_id --AND ep.minor_id = 0     
    LEFT JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE LEN(CONVERT(VARCHAR, ep.value)) > 1 --and o.name = 'foo'
ORDER BY o.type_desc, o.name

-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================
-- =============================================
-- Author:		Sue Boorman
-- Create date:     10/11/2011
-- Description:	Use to Add Extended Properties to a single view
-- Last Updated:    01/05/2018
-- =============================================
GO
