/*
Checking the Version and Build Number of an SSIS Package
Last Updated:  08/18/2021 sb
Gives the Major and Minor Version numbers from the dtsx project
https://www.sqlmatters.com/Articles/Checking%20the%20Version%20and%20Build%20Number%20of%20an%20Installed%20SSIS%20Package.aspx
*/

USE SSISDB
GO
--Check full version history of installed SSIS packages
--NB only works for project deployment model
SELECT folders.name [Folder Name]
      ,projects.name [Project Name]
      ,packages.name [Package Name]
      ,version_major [Version Major]
      ,version_minor [Version Minor]
      ,version_build [Version Build]
      ,project_version_lsn [Project LSN]
      ,object_versions.created_time [Installed]
      ,IIF(object_versions.object_version_lsn=projects.object_version_lsn,'Yes','No') [Latest Version?]
FROM    internal.packages
JOIN    internal.projects
ON      projects.project_id=packages.project_id
JOIN    internal.object_versions
ON      object_versions.object_id=projects.project_id
AND     object_versions.object_version_lsn=packages.project_version_lsn
JOIN    internal.folders
ON      folders.folder_id=projects.folder_id
ORDER BY projects.name,packages.name,version_build DESC,project_version_lsn DESC