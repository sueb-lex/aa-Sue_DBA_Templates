--==========================================-- Create Synonym with Check (Template)
--==========================================
--https://www.mssqltips.com/sqlservertip/4849/template-to-create-sql-server-synonyms-with-checks/

--To use the template, copy this code into a query window and type Ctrl+Shift+M to execute.

IF (SELECT OBJECT_ID('<database_name, sysname, AdventureWorks>.<schema_name, sysname, Production>.<object_name, sysname, Product>')) IS NOT NULL
BEGIN
CREATE SYNONYM <synonym_schema_name, sysname, dbo>.<synonym_name, sysname, sample_synonym>
  FOR <database_name, sysname, AdventureWorks>.<schema_name, sysname, Production>.<object_name, sysname, Product>
PRINT 'Synonym <synonym_name, sysname, sample_synonym> for object <database_name, sysname, AdventureWorks>.<schema_name, sysname, Production>.<object_name, sysname, Product> Created'
END
ELSE PRINT 'Can not create Synonym for non-existing object'
GO