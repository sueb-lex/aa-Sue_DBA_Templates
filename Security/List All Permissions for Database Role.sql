/*
List All Permissions for Database Role
--change the Role Name in the Where clause
https://www.sanssql.com/2017/04/t-sql-to-list-all-permissions-for-given.html
LastUpdated:  05/12/2021
*/

SELECT DB_NAME() AS DatabaseName
      ,DatabasePrincipals.name AS PrincipalName
      ,DatabasePrincipals.type_desc AS PrincipalType
      ,DatabasePrincipals2.name AS GrantedBy
      ,DatabasePermissions.permission_name AS Permission
      ,DatabasePermissions.state_desc AS StateDescription
      ,SCHEMA_NAME(SO.schema_id) AS SchemaName
      ,SO.Name AS ObjectName
      ,SO.type_desc AS ObjectType
  FROM sys.database_permissions DatabasePermissions LEFT JOIN sys.objects SO
    ON DatabasePermissions.major_id = so.object_id LEFT JOIN sys.database_principals DatabasePrincipals
    ON DatabasePermissions.grantee_principal_id = DatabasePrincipals.principal_id LEFT JOIN sys.database_principals DatabasePrincipals2
    ON DatabasePermissions.grantor_principal_id = DatabasePrincipals2.principal_id
WHERE DatabasePrincipals.name = 'viewer' -- Change the Role Name
ORDER BY ObjectName


----------------------------------------------------------------------------------------------
/*
Exhaustive list of Database Permissions (Single Database)
--may need to exclude Public from results
https://dba.stackexchange.com/questions/36618/list-all-permissions-for-a-given-role
*/

SELECT 
@@Servername as ServerName
,DB_NAME() AS DatabaseName
,d.name AS DatabaseUser
,ISNULL(dr.name, 'Public') AS DatabaseRole
,dp.permission_name as AdditionalPermission
,dp.state_desc AS PermissionState
,ISNULL(o.type_desc, 'N/A')  AS ObjectType
,ISNULL(o.name, 'N/A') AS ObjectName
FROM sys.database_principals d
    LEFT JOIN sys.database_role_members r
        ON d.principal_id = r.member_principal_id 
    LEFT JOIN sys.database_principals dr
        ON r.role_principal_id = dr.principal_id 
    left JOIN   sys.database_permissions dp
        ON d.principal_id = dp.grantee_principal_id
    LEFT JOIN sys.objects o
        ON dp.major_id = o.object_id
WHERE d.name NOT IN('Public')
ORDER BY DatabaseUser, ObjectName;  

/*
--In order to find a User-Defined Table Types you must point to a specific database
USE RWBackOffice
GO
select * from sys.types where is_user_defined = 1
*/