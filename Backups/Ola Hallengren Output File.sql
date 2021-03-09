/*
Ola Hallengren: Output File
John Morehouse 05/30/2017

http://www.sqlservercentral.com/blogs/john-morehouse-sqlruscom/2017/05/30/ola-hallengren-output-file/?utm_source=SSC&utm_medium=pubemail
can either adjust the script itself starting at line 4127 or run script below to update the job steps

Changes the way that the log file for each respective job is named.  By default, the file name is configured in the following format:
JobName_JobID_StepID_YYYYMMDD_HHMMSS.txt
which results in file names that look like this:

There are two ways to adjust this.
 Update the maintenance script itself to adjust the file names.  In the script, configuration of job logging starts approximately on line 4127.  Your mileage may vary depending on which version you have.  You can look for the phrase “Log completing information” in the file to determine where it starts.  Once you find its location, you can adjust the file name to however you want.
If you don’t want to adjust the script,  you can use the script below to manually adjust the output file name.  This script will produce the appropriate parameters for sp_update_jobstep.  You can then copy/paste the command into a query windows and execute in a controlled manner.
*/
/***************************************************************
-- Author: John Morehouse
-- Date: May 2017
-- http://sqlrus.com

--THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

--IN OTHER WORDS: USE AT YOUR OWN RISK.

--AUTHOR ASSUMES ZERO LIABILITY OR RESPONSIBILITY.

--You may alter this code for your own purposes.
--You may republish altered code as long as you give due credit.
***************************************************************/

-- NOTE: You will need to turn OFF SQLCMD mode if it is enable for this to work

USE msdb
GO
;WITH myCTE AS (
    SELECT 'IndexOptimize - USER_DATABASES' AS 'Name', 'UserDBs' AS 'FilePart' UNION
    SELECT 'DatabaseBackup - USER_DATABASES - LOG', 'UserDBs_LOG' UNION
    SELECT 'DatabaseBackup - USER_DATABASES - FULL', 'UserDBs_FULL' UNION
    SELECT 'DatabaseBackup - USER_DATABASES - DIFF', 'UserDBs_DIFF' UNION
    SELECT 'DatabaseIntegrityCheck - SYSTEM_DATABASES', 'SystemDBs' UNION
    SELECT 'DatabaseBackup - SYSTEM_DATABASES - FULL', 'SystemDBs_FULL' UNION
    SELECT 'DatabaseIntegrityCheck - USER_DATABASES', 'UserDBs' 
)
SELECT output_file_name, REPLACE(output_file_name,'$(ESCAPE_SQUOTE(JOBID))', m.FilePart) AS 'Updated_Output_File_Name'
, 'EXEC sp_update_jobstep @job_id =''' + CAST(sjs.job_id AS VARCHAR(36)) + ''', @step_id= ' + CAST(sjs.step_id AS VARCHAR(10)) + ', @output_file_name = ''' + REPLACE(output_file_name,'$(ESCAPE_SQUOTE(JOBID))', m.FilePart) + ''''
  ,* FROM dbo.sysjobsteps sjs
	INNER JOIN myCTE m ON sjs.step_name = m.name 