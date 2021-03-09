------------------------------------------------------------------------------------------------------
--https://www.mssqltips.com/sqlservertip/5853/find-all-sql-server-triggers-to-quickly-enable-or-disable/

--find all triggers (must be pointed to specific database
SELECT 
	t2.[name] TableTriggerReference
	, SCHEMA_NAME(t2.[schema_id]) TableSchemaName
	, t1.[name] TriggerName
FROM sys.triggers t1
	INNER JOIN sys.tables t2 ON t2.object_id = t1.parent_id
WHERE t1.is_disabled = 0
	AND t1.is_ms_shipped = 0
	AND t1.parent_class = 1

--Find trigger disabled with script to enable them
SELECT 
	t2.[name] TableTriggerReference
	, SCHEMA_NAME(t2.[schema_id]) TableSchemaName
	, t3.[rowcnt] TableReferenceRowCount
	, t1.[name] TriggerName
	, 'ALTER TABLE ' + SCHEMA_NAME(t2.schema_id) + '.' + t2.[name] + ' ENABLE TRIGGER ' + t1.[name] Script
FROM sys.triggers t1
	INNER JOIN sys.tables t2 ON t2.object_id = t1.parent_id
	INNER JOIN sys.sysindexes t3 On t2.object_id = t3.id
WHERE t1.is_disabled = 1
	AND t1.is_ms_shipped = 0
	AND t1.parent_class = 1

--Find trigger enabled with script to disable them
SELECT 
	t2.[name] TableTriggerReference
	, SCHEMA_NAME(t2.[schema_id]) TableSchemaName
	, t3.[rowcnt] TableReferenceRowCount
	, t1.[name] TriggerName
	, 'ALTER TABLE ' + SCHEMA_NAME(t2.schema_id) + '.' + t2.[name] + ' DISABLE TRIGGER ' + t1.[name] Script
FROM sys.triggers t1
	INNER JOIN sys.tables t2 ON t2.object_id = t1.parent_id
	INNER JOIN sys.sysindexes t3 On t2.object_id = t3.id
WHERE t1.is_disabled = 0
	AND t1.is_ms_shipped = 0
	AND t1.parent_class = 1
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--https://zarez.net/?p=1264

--How to list all Triggers in a SQL Server Database
--To list all triggers in a SQL Server Database use this simple query:

--USE <Database_Name>
SELECT * FROM sys.triggers

--It will list all triggers (DML and DDL) in the database.

--Here is the same query, with an added column called Parent_Object_Name which shows the table name for which the trigger was created (for DML triggers), and NULL for database (DDL) triggers:

--USE <Database_Name>
SELECT OBJECT_NAME(parent_id) as Parent_Object_Name, *
FROM sys.triggers
------------------------------------------------------------------------------------------------------
