SELECT QUOTENAME(SCHEMA_NAME(tb.[schema_id])) AS 'Schema'
   ,QUOTENAME(OBJECT_NAME(tb.[OBJECT_ID])) AS 'Table'
   ,C.NAME as 'Column'
   ,T.name AS 'Type'
   ,C.max_length
   ,C.is_nullable
FROM SYS.COLUMNS C INNER JOIN SYS.TABLES tb ON tb.[object_id] = C.[object_id]
   INNER JOIN SYS.TYPES T ON C.system_type_id = T.user_type_id
WHERE tb.[is_ms_shipped] = 0
ORDER BY [Table], C.NAME



SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = '<TableName>'
ORDER BY TABLE_NAME, COLUMN_NAME