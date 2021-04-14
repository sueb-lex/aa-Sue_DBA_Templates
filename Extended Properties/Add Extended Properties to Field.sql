--Used to add Extended Properties to a Field

EXEC sys.sp_addextendedproperty 
  @name=N'MS_Description'
 ,@value=N'Here is my description!'  --<<<<
 ,@level0type=N'SCHEMA'
 ,@level0name=N'dbo'
 ,@level1type=N'TABLE'
 ,@level1name=N'TABLE_NAME' --<<<<
 ,@level2type=N'COLUMN'
 ,@level2name=N'FIELD_NAME'  --<<<<

/* code to view description from fields
SELECT        o.Name AS ObjectName,
            o.type AS ObjectType,
            s.name AS SchemaOwner,
            ep.name AS PropertyName,
            ep.value AS PropertyValue,
            c.name AS ColumnName,
            c.colid AS Ordinal
FROM        sys.objects o INNER JOIN sys.extended_properties ep
            ON o.object_id = ep.major_id
            INNER JOIN sys.schemas s
            ON o.schema_id = s.schema_id
            LEFT JOIN syscolumns c
            ON ep.minor_id = c.colid
            AND ep.major_id = c.id
WHERE        o.type IN ('V', 'U', 'P')
ORDER BY    SchemaOwner,ObjectName, ObjectType, Ordinal
*/