--Used to add Extended Properties to a User Account (in a database only)

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'used when importing streets into GIS database',
	@level0type = N'USER',@level0name = N'LEXUCG\PrdSql2019S1Agt$'
EXEC sp_addextendedproperty @name = N'Developer_Contact', @value = N'Sue Boorman, Chris Doerge',
	@level0type = N'USER',@level0name = N'LEXUCG\PrdSql2019S1Agt$'
EXEC sp_addextendedproperty @name = N'DivisionOwner', @value = N'Computer Services',
	@level0type = N'USER',@level0name = N'LEXUCG\PrdSql2019S1Agt$'
EXEC sp_addextendedproperty @name = N'LastUpdated', @value = N'01/11/2021 sb',
	@level0type = N'USER',@level0name = N'LEXUCG\PrdSql2019S1Agt$'

/*
--used to select extended properties from a single database (must be pointed to this database)
SELECT *
FROM sys.extended_properties 
WHERE [class] = 4 --user accounts
*/
----------------------------------------------
--lists extended properties for database plus user accounts
SELECT DB_NAME(), 'Database', ep.name,value
 FROM sys.extended_properties ep where class=0 
UNION all--XML Schema Collections
SELECT SCHEMA_NAME(SCHEMA_ID)+'.'+XC.name, 'schema/xml_Schema_collection', ep.name,value
 FROM sys.extended_properties ep
 INNER JOIN sys.xml_schema_collections xc
 ON class=10 AND ep.major_id=xml_collection_id
UNION all
--SELECT --Database Files
-- df.name, 'database_file',ep.name,value FROM sys.extended_properties ep
-- INNER JOIN sys.database_files df ON class=22 AND ep.major_id=file_id
--UNION all
--SELECT --Data Spaces
-- ds.name,'dataspace', ep.name,value FROM sys.extended_properties ep
-- INNER JOIN sys.data_spaces ds ON class=20 AND ep.major_id=data_space_id
--UNION ALL 
SELECT --USER
 dp.name,'database_principal', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.database_principals dp ON class=4 AND ep.major_id=dp.principal_id


/*
-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================
-- =============================================
-- Author:		Sue Boorman
-- Create date: 11/06/2020
-- Description:	Use to Add Extended Properties to user account within a database
	not able to add Extended Properties to a login
	be nice to expand the select so you can tell which account has extended properties when viewing
-- =============================================

EXEC sp_dropextendedproperty   
     @name = 'MS_Description'   
    ,@level0type = 'USER'   
    ,@level0name = 'LEXUCG\Fleet_ReadOnly';

EXEC sp_dropextendedproperty   
     @name = 'Developer_Contact'   
    ,@level0type = 'USER'   
    ,@level0name = 'LEXUCG\Fleet_ReadOnly';

EXEC sp_dropextendedproperty   
     @name = 'DivisionOwner'   
    ,@level0type = 'USER'   
    ,@level0name = 'LEXUCG\Fleet_ReadOnly';

EXEC sp_dropextendedproperty   
     @name = 'LastUpdated'   
    ,@level0type = 'USER'   
    ,@level0name = 'LEXUCG\Fleet_ReadOnly';


*/
GO
