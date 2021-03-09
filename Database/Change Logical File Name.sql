  

--be sure to point to correct database
SELECT  * FROM sysfiles --(point to database to get the name (which is the logical file name)

ALTER DATABASE <Database_Name, sysname, Database_Name> --Change Database Name Here
MODIFY FILE (NAME = <OldLogicalName_Data, sysname, OldLogicalName_Data>
, NEWNAME = <Database_Name, sysname, Database_Name>_Data)
GO
ALTER DATABASE <Database_Name, sysname, Database_Name> --Change Database Name Here
MODIFY FILE (NAME = <OldLogicalName_Log, sysname, OldLogicalName_Log>
, NEWNAME = <Database_Name, sysname, Database_Name>_Log)
GO

SELECT  * FROM sysfiles

-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================
-- =============================================
-- Author:		<Author,,Sue Boorman>
-- Create date: <CreateDate,,Date Created>
-- Description:	<Description,,Purpose>
-- =============================================
GO


sp_helpfile