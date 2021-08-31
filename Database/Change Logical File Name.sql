/* 
 Change Logical File Name for Databases Files
 LastUpdated:  03/29/2021 sb
*/
--BE SURE TO POINT TO THE CORRECT DATABASE
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
GO

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

--another way to look at the file information
sp_helpfile