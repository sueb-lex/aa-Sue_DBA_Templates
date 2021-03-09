SELECT 'PK_Table_Schema'=ccu.table_schema,'PK_Table_Name'=ccu.table_name,
  'PK_Column_Name'=ccu.column_name,'PK_Constraint_Name'=ccu.constraint_name, 
  'FK_Table_Schema'=ccu1.table_schema,'FK_Table_Name'=ccu1.table_name, 
  'FK_Column_Name'=ccu1.column_name, 'FK_Constraint_Name'=rc.constraint_name 
FROM information_schema.constraint_column_usage CCU 
  INNER JOIN information_schema.referential_constraints RC
    ON CCU.constraint_name=RC.unique_constraint_name
  INNER JOIN information_schema.constraint_column_usage CCU1 
    ON RC.constraint_name=ccu1.constraint_name
WHERE ccu.constraint_name NOT IN(SELECT constraint_name FROM information_schema.referential_constraints)
/*
http://www.sqlservercentral.com/scripts/Miscellaneous/61481/
Effectively mapping primary key – foreign key relations
By John Liu, 2007/11/07
*/