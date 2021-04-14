--List Extended Properties

/*
How to get a list of all extended properties for all objects
https://www.red-gate.com/simple-talk/uncategorized/reading-writing-creating-sql-server-extended-properties/
2016 Phil Factor
list schema, tables and columns with Extended Properties Name and Value
only works on one database at a time
*/

SELECT --objects AND columns
 CASE WHEN ob.parent_object_id>0 
 THEN OBJECT_SCHEMA_NAME(ob.parent_object_id)
 + '.'+OBJECT_NAME(ob.parent_object_id)+'.'+ob.name 
 ELSE OBJECT_SCHEMA_NAME(ob.object_id)+'.'+ob.name END 
 + CASE WHEN ep.minor_id>0 THEN '.'+col.name ELSE '' END AS path,
 'schema'+ CASE WHEN ob.parent_object_id>0 THEN '/table'ELSE '' END 
 + '/'+
 CASE WHEN ob.type IN ('TF','FN','IF','FS','FT') THEN 'function'
 WHEN ob.type IN ('P', 'PC','RF','X') then 'procedure' 
 WHEN ob.type IN ('U','IT') THEN 'table'
 WHEN ob.type='SQ' THEN 'queue'
 ELSE LOWER(ob.type_desc) end
 + CASE WHEN col.column_id IS NULL THEN '' ELSE '/column'END AS thing, 
 ep.name,value 
 FROM sys.extended_properties ep
 inner join sys.objects ob ON ep.major_id=ob.OBJECT_ID AND class=1
 LEFT outer join sys.columns col 
 ON ep.major_id=col.Object_id AND class=1 
 AND ep.minor_id=col.column_id
UNION ALL
SELECT --indexes
 OBJECT_SCHEMA_NAME(ob.object_id)+'.'+OBJECT_NAME(ob.object_id)+'.'+ix.name,
 'schema/'+ LOWER(ob.type_desc) +'/index', ep.name, value
 FROM sys.extended_properties ep
 inner join sys.objects ob 
 ON ep.major_id=ob.OBJECT_ID AND class=7
 inner join sys.indexes ix 
 ON ep.major_id=ix.Object_id AND class=7 
 AND ep.minor_id=ix.index_id
UNION ALL
SELECT --Parameters
 OBJECT_SCHEMA_NAME(ob.object_id)
 + '.'+OBJECT_NAME(ob.object_id)+'.'+par.name,
 'schema/'+ LOWER(ob.type_desc) +'/parameter', ep.name,value
 FROM sys.extended_properties ep
 inner join sys.objects ob 
 ON ep.major_id=ob.OBJECT_ID AND class=2
 inner join sys.parameters par 
 ON ep.major_id=par.Object_id 
 AND class=2 AND ep.minor_id=par.parameter_id
UNION all
SELECT --schemas
 sch.name, 'schema', ep.name, value
 FROM sys.extended_properties ep
 INNER JOIN sys.schemas sch
 ON class=3 AND ep.major_id=SCHEMA_ID
UNION all --Database 
SELECT DB_NAME(), 'database', ep.name,value
 FROM sys.extended_properties ep where class=0 
UNION all--XML Schema Collections
SELECT SCHEMA_NAME(SCHEMA_ID)+'.'+XC.name, 'schema/xml_Schema_collection', ep.name,value
 FROM sys.extended_properties ep
 INNER JOIN sys.xml_schema_collections xc
 ON class=10 AND ep.major_id=xml_collection_id
UNION all
SELECT --Database Files
 df.name, 'database_file',ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.database_files df ON class=22 AND ep.major_id=file_id
UNION all
SELECT --Data Spaces
 ds.name,'dataspace', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.data_spaces ds ON class=20 AND ep.major_id=data_space_id
UNION ALL SELECT --USER
 dp.name,'database_principal', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.database_principals dp ON class=4 AND ep.major_id=dp.principal_id
UNION ALL SELECT --PARTITION FUNCTION
 pf.name,'partition_function', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.partition_functions pf ON class=21 AND ep.major_id=pf.function_id
UNION ALL SELECT --REMOTE SERVICE BINDING
 rsb.name,'remote service binding', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.remote_service_bindings rsb 
 ON class=18 AND ep.major_id=rsb.remote_service_binding_id
UNION ALL SELECT --Route
 rt.name,'route', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.routes rt ON class=19 AND ep.major_id=rt.route_id
UNION ALL SELECT --Service
 sv.name COLLATE DATABASE_DEFAULT ,'service', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.services sv ON class=17 AND ep.major_id=sv.service_id
UNION ALL SELECT -- 'CONTRACT'
 svc.name,'service_contract', ep.name,value FROM sys.service_contracts svc
 INNER JOIN sys.extended_properties ep ON class=16 AND ep.major_id=svc.service_contract_id
UNION ALL SELECT -- 'MESSAGE TYPE'
 smt.name,'message_type', ep.name,value FROM sys.service_message_types smt
 INNER JOIN sys.extended_properties ep ON class=15 AND ep.major_id=smt.message_type_id
UNION ALL SELECT -- 'assembly'
 asy.name,'assembly', ep.name,value FROM sys.assemblies asy
 INNER JOIN sys.extended_properties ep ON class=5 AND ep.major_id=asy.assembly_id
/*UNION ALL SELECT --'CERTIFICATE'
 cer.name,'certificate', ep.name,value from sys.certificates cer
 INNER JOIN sys.extended_properties ep ON class=? AND ep.major_id=cer.certificate_id
UNION ALL SELECT --'ASYMMETRIC KEY'
 amk.name,'asymmetric_key', ep.name,value SELECT * from sys.asymmetric_keys amk
 INNER JOIN sys.extended_properties ep ON class=? AND ep.major_id=amk.asymmetric_key_id
SELECT --'SYMMETRIC KEY'
 smk.name,'symmetric_key', ep.name,value from sys.symmetric_keys smk
 INNER JOIN sys.services sv ON class=? AND ep.major_id=smk.symmetric_key_id */
UNION ALL SELECT -- 'PLAN GUIDE' 
 pg.name,'plan_guide', ep.name,value FROM sys.plan_guides pg
 INNER JOIN sys.extended_properties ep ON class=27 AND ep.major_id=pg.plan_guide_id
 ORDER BY [path]


------------------------------------------------------------------
/*
How to get a list of all extended properties for all objects
https://stackoverflow.com/questions/15221338/how-to-get-a-list-of-all-extended-properties-for-all-objects
2013
shows these 4 fields for objects that have a value (includes tables and columns but does not identify which it is)
*/

SELECT s.name AS [SchemaName], O.name AS [ObjectName], ep.name AS [ExtendedPropertyName], ep.value AS [ExtendedPropertyValue]
FROM sys.extended_properties AS ep
    LEFT JOIN sys.all_objects AS o ON ep.major_id = o.object_id 
    LEFT JOIN sys.schemas AS s on o.schema_id = s.schema_id
    LEFT JOIN sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
ORDER BY [SchemaName], [ObjectName]

------------------------------------------------------------------
------------------------------------------------------------------
/*
Querying Extended Properties on SQL Server Columns
https://www.sqlchick.com/entries/2010/11/5/querying-extended-properties-on-sql-server-columns.html
Nov 2010
includes table, column, data type and size
*/

SELECT
     Sch.name AS [Schema Name]
    ,SysTbls.name AS [Table Name]
    ,SysCols.name AS [Column Name]
    ,ExtProp.value AS [Extended Property]
    ,Systyp.name AS [Data Type]
    ,CASE WHEN Systyp.name IN('nvarchar','nchar')
               THEN (SysCols.max_length / 2)
          ELSE SysCols.max_length
          END AS 'Length of Column'
    ,CASE WHEN SysCols.is_nullable = 0
               THEN 'No'
          WHEN SysCols.is_nullable = 1
               THEN 'Yes'
          ELSE NULL
          END AS 'Column is Nullable'   
    ,SysObj.create_date AS [Table Create Date]
    ,SysObj.modify_date AS [Table Modify Date]
FROM sys.tables AS SysTbls
   LEFT JOIN sys.extended_properties AS ExtProp
         ON ExtProp.major_id = SysTbls.[object_id]
   LEFT JOIN sys.columns AS SysCols
         ON ExtProp.major_id = SysCols.[object_id]
         AND ExtProp.minor_id = SysCols.column_id
   LEFT JOIN sys.objects AS SysObj
         ON SysTbls.[object_id] = SysObj.[object_id]
   LEFT JOIN sys.schemas AS Sch 
         ON SysObj.schema_id = Sch.schema_id
   LEFT JOIN sys.types AS SysTyp
         ON SysCols.user_type_id = SysTyp.user_type_id
WHERE ExtProp.class >=0 --Object or column
  --AND SysTbls.name IS NOT NULL --remove of it excludes blank values
  --AND SysCols.name IS NOT NULL --remove of it excludes blank values
ORDER BY [Schema Name], [Table Name]
------------------------------------------------------------------
------------------------------------------------------------------
/*
used to select extended properties from a single database or view (must be pointed to this database)
Limited to only those rows that have an Extended Properts (both tables and views)
don't have a url for this one
*/
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

------------------------------------------------------------------
------------------------------------------------------------------
/*
--https://dba.stackexchange.com/questions/144553/querying-sql-server-extended-properties-for-tables-views-and-its-columns
--only includes tables > column names (does not include views) - changed to left join to see those without Extended Properties
*/

SELECT
    ObjectType = o.type_desc,
    SchemaName = SCHEMA_NAME(o.schema_id),  
    ObjectName = o.name, 
    ColumnName = clmns.name,
    ExtendedPropertyName = p.name,
    ExtendedPropertyValue = CAST(p.value AS sql_variant)
FROM sys.objects AS o
LEFT JOIN sys.all_columns AS clmns
    ON clmns.object_id = o.object_id
LEFT JOIN sys.extended_properties AS p
    ON p.major_id = o.object_id
    AND p.minor_id = clmns.column_id
    AND p.class = 1
WHERE o.type IN ('U','V') -- User Tables and Views
	AND LEN(p.name) > 1  -- limiting to only items with Extended Properties
ORDER BY o.type_desc, SCHEMA_NAME(o.schema_id), o.name




------------------------------------------------------------------
------------------------------------------------------------------
/*


*/