--Add Extended Properties to Any

--http://www.sqlservercentral.com/articles/Metadata/72607/
--Table
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' -- The object schema
,@level0name = [Sales] -- The object schema name
,@level1type = N'TABLE' -- The object type
,@level1name = [Stock] -- The object name
,@name = N'Overview' -- The "Classification"
,@value = N'This is a stock table' -- The "Comment" 
;

--View 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [Sales] 
,@level1type = N'VIEW' 
,@level1name = [vw_Invoices]
,@name = N'Overview' 
,@value = N'View Comment' 
;

--Stored Procedure 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [dbo] 
,@level1type = N'PROCEDURE' 
,@level1name = [pr_ListClients]
,@name = N'Overview' 
,@value = N'Procedure comment' 
;

--User-defined Function 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [dbo] 
,@level1type = N'FUNCTION' 
,@level1name = [ufn_GetTownCounty]
,@name = N'Overview' 
,@value = N'Scalar Function' 
;

--table column
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' -- The object schema
,@level0name = [Sales] -- The object schema name
,@level1type = N'TABLE' -- The object type
,@level1name = [Stock] -- The object name
,@level2type = N'COLUMN' -- The object attribute
,@level2name = [Make] -- The object attribute name
,@name = N'Overview' -- The "Classification"
,@value = N'Basic column definition' -- The "Comment"
;

--Column View 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [Sales]
,@level1type = N'VIEW'
,@level1name = [vw_Invoices] 
,@level2type = N'COLUMN' 
,@level2name = [ClientName]
,@name = N'Overview' 
,@value = N'Basic column definition' 
;

--Table Index 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [Sales] 
,@level1type = N'TABLE' 
,@level1name = [Stock]
,@level2type = N'INDEX' 
,@level2name = [IX_Stock_Registration_Year]
,@name = N'Overview' 
,@value = N'Index comment' 
;

--View Index 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [Sales] 
,@level1type = N'VIEW' 
,@level1name = [vw_Stock]
,@level2type = N'INDEX' 
,@level2name = [CX_vw_Stock]
,@name = N'Overview' 
,@value = N'Comment on Index of Indexed view' 
;

--Table Trigger 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [Sales] 
,@level1type = N'TABLE' 
,@level1name = [Invoice_Lines]
,@level2type = N'TRIGGER' 
,@level2name = [trg_Invoice_Lines]
,@name = N'Overview' 
,@value = N'Comment on table trigger' 
;

--Stored Procedure Parameter 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [dbo] 
,@level1type = N'PROCEDURE' 
,@level1name = [pr_ListClients]
,@level2type = N'PARAMETER' 
,@level2name = '@ID'
,@name = N'Overview' 
,@value = N'Procedure parameter comment' 
;

--User-defined Function parameter 
EXEC sys.sp_addextendedproperty 
@level0type = N'SCHEMA' 
,@level0name = [dbo] 
,@level1type = N'FUNCTION' 
,@level1name = [ufn_GetTownCounty]
,@level2type = N'PARAMETER' 
,@level2name = '@ID'
,@name = N'Overview' 
,@value = N'Function Parameter' 
;
-------------------------------------------------------------------------------
--User account
EXEC sys.sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'<Purpose of account>',
@level0type = N'USER',
@level0name = N'<UserAccount>';
GO

EXEC sys.sp_addextendedproperty 
@name = N'Division Owner', 
@value = N'<Enter Division Owner Here>',
@level0type = N'USER',
@level0name = N'<UserAccount>';
GO

EXEC sys.sp_addextendedproperty 
@name = N'Division Contact', 
@value = N'<Enter Division Contact Here>',
@level0type = N'USER',
@level0name = N'<UserAccount>';
GO

EXEC sys.sp_addextendedproperty 
@name = N'Lastupdate', 
@value = N'<Enter date>',
@level0type = N'USER',
@level0name = N'<UserAccount>';
GO

-------------------------------------------------------------------------------
/*
Add or Update Extended Property
--https://www.red-gate.com/simple-talk/sql/database-delivery/scripting-description-database-tables-using-extended-properties/
Phil Factor March 3, 2018
*/
--Table > Column
 IF Object_Id('dbo.person') IS NOT NULL
  BEGIN
  IF not exists(SELECT * from sys.fn_Listextendedproperty ( N'MS_Description',
       N'SCHEMA',  N'dbo',
       N'TABLE',   N'Person', 
       N'column',  N'LastName'))
  EXEC sys.sp_addextendedproperty @name=N'MS_Description',  
      @value=N'Persons very last name',
      @level0type =  N'SCHEMA', @level0name = N'dbo',
      @level1type = N'TABLE',  @level1name = N'Person', 
      @level2type = N'column', @level2name = N'LastName'
  ELSE
  EXEC sys.sp_Updateextendedproperty @name = N'MS_Description',  
      @value = N'Persons very last name',
      @level0type =  N'SCHEMA', @level0name = N'dbo',
      @level1type = N'TABLE',  @level1name = N'Person', 
      @level2type = N'column', @level2name = N'LastName'
  END


-------------------------------------------------------------------------------
/*
Add Extended Property to Every Column in Every Table
https://www.sqlservercentral.com/Forums/Topic1084805-146-1.aspx
output this as text; would need to fill in the Description field for each value
does not take into account that there may already be a value in the Extended Property
*/

WITH myCTE AS
( 
 SELECT 
   SCHEMA_NAME(schema_id) AS SchemaName,
   objz.name AS TableName,
   colz.name AS ColumnName,
   '' as Descrip
   FROM sys.tables objz 
        INNER JOIN sys.columns colz on objz.object_id=   colz.object_id
) 

SELECT 
         'EXEC sys.sp_addextendedproperty
          @name = N''' + Tablename + ''', @value = N''' + REPLACE(convert(varchar(max),[Descrip]),'''','''''') + ''',
          @level0type = N''SCHEMA'', @level0name = [' + SchemaName + '],
          @level1type = N''TABLE'', @level1name = [' + Tablename + '],
          @level2type = N''COLUMN'', @level2name = [' + ColumnName + '];'

FROM myCTE
ORDER BY SchemaName, TableName
