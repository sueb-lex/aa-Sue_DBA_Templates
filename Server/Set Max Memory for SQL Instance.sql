/*
Brent Ozar rcommendations of Max Server Memory
https://www.brentozar.com/blitz/max-memory/
Decide what to set your max server memory (MB) to. Our simple “starter” rule of thumb is to leave 4GB or 10% of total memory free, whichever is LARGER on your instance to start with, and adjust this as needed.
for lower memory amounts may need to check that 4GB is available at least
EXAMPLE
EXEC sys.sp_configure ‘max server memory (MB)’, ‘29491’; RECONFIGURE;
*/

--from Brent Ozar script (viewed online 03/15/2021 sb)
DECLARE @StringToExecute NVARCHAR (400)
SELECT @StringToExecute = N'EXEC sys.sp_configure N''max server memory (MB)'', N''' + CAST(CAST(physical_memory_kb/1024 *.9 AS INT) AS NVARCHAR(20)) + N''';'
FROM sys.dm_os_sys_info;
PRINT @StringToExecute

--EXEC (@StringToExecute);
GO
RECONFIGURE;
GO
--------------------------------------------------------------------------------------------------
/*
Code to generate the below script (GenerateMaxRamTSQL) furnished by Dell (Steven Heinz 10/26/2020)
--SEE ABOVE FOR BRENT OZAR RECOMMENDATION OF .9 OR 4GB, WHICHEVER IS LARGER
-- Configure Max Memory for SQL Instance @ 80% of System Memory
DECLARE @SQLMemoryMB NVARCHAR(10)
SELECT @SQLMemoryMB = CAST(CAST(((total_physical_memory_kb/1024)*.8) AS INT) AS NVARCHAR(10)) FROM sys.dm_os_sys_memory
-- SELECT @SQLMemoryMB

-- Get the script to run the command
SELECT 'EXEC sys.sp_configure N''show advanced options'', N''1''  RECONFIGURE WITH OVERRIDE
        EXEC sys.sp_configure N''max server memory (MB)'', ' + @SQLMemoryMB

--Amount of memory when not reduced
DECLARE @SQLMemoryMB NVARCHAR(10)
SELECT @SQLMemoryMB = CAST(CAST(((total_physical_memory_kb/1024)) AS INT) AS NVARCHAR(10)) FROM sys.dm_os_sys_memory
SELECT @SQLMemoryMB
*/
-------------------------------------------------------------------------------------------------
--
-- SCRIPTS TO SET MAX MEMORY = 80% of TOTAL RAM ON ALL PRODUCTION INSTANCES 
-- furnished by Dell vendor (Steven Heinz) 10/24/2020
-------------------------------------------------------------------------------------------------


-- Set Max Memory for server [VM-GCSQL3]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE  
EXEC sys.sp_configure N'max server memory (MB)', 6552
--Current Max = 4000 (Lower than 80%)

-- Set Max Memory for server [PRDGISSQL1\GISDATA1]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 52428
--Current Max = 40000 (Lower than 80%)

-- Set Max Memory for server [WQDATA]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 25908
-- Current Max = 28000 (Higher than 80%)

-- Set Max Memory for server [PRDSQLSERVER1]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 13106
-- Current Max = 12000 (Lower than 80%)

-- Set Max Memory for server [WEBEOCDB01]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 13106
-- Current Max = 10000 (Lower than 80%)

-- Set Max Memory for server [TRAFSQLS1]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 26213
-- Current Max = 25000 (Lower than 80%)

-- Set Max Memory for server [PVATMPSQL]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 6552
-- Current Max = 2147483647 (This is the one that was still unlimited)

-- Set Max Memory for server [GCSQL2]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 8191
-- Current Max = 8000 (Lower than 80%)

-- Set Max Memory for server [PSOCSQLS1]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 6552
-- Current Max = 8000 (Higer than 80%)

-- Set Max Memory for server [VISION1]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 13106
-- Current Max = 12000 (Lower than 80%)

-----------------------------------------------------------------------------------
-- As for the four (4) instances on GCSQL1
--   Total RAM								= 147,000
--   Total Allocated to SQL					=  95,000
--   Max for all intances should be under  <= 120,000 (a little over 80%) 
--   I added 6,000 per instance		        = 119,000
-----------------------------------------------------------------------------------

-- Set Max Memory for server [GCSQL1\SQL2016]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 31000
-- Current Max = 25000 

-- Set Max Memory for server [GCSQL1\SQL2014]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 31000
-- Current Max = 25000

-- Set Max Memory for server [GCSQL1\ROUTEWARE]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 36000
-- Current Max = 30000 (Lower than 80%)

-- Set Max Memory for server [GCSQL1\AMICUS]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 21000
-- Current Max = 15000


/*  WAIT FOR JAIL MAINTENANCE WINDOW
-- Set Max Memory for server [PRDJMS]  
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE   
EXEC sys.sp_configure N'max server memory (MB)', 52428
-- Current Max = 35000 (lower than 80%)
*/




-----------------------------------------------------------------------------------------------------------

--script used to CollectFileInfo
CREATE TABLE #TMPSPACEUSED ( 
  DBNAME    VARCHAR(255), 
  FILENME   VARCHAR(255), 
  CurrentSize numeric(18,3),
  SPACEUSED numeric(18,3)) 

INSERT INTO #TMPSPACEUSED 
EXEC ( 'sp_msforeachdb''use [?];   SELECT DB_NAME() AS DbName, 
name AS FileName, 
size/128.0 AS CurrentSizeMB, 
CAST(FILEPROPERTY(name, ''''SpaceUsed'''') AS INT)/128.0 AS SpaceUsedMB 
FROM sys.database_files; ''') 

SELECT 
    	1 as DatabaseId,
	@@serverName ServerName, 
	db.Name AS [DatabaseName], 
	CAST((mf.Size * 8) / 1024.0 AS DECIMAL(18, 3)) AS [FileSizeMB], 
	mf.name AS [LogicalFileName], 
	mf.physical_name AS [physicalFileName], 
	mf.file_id AS SqlFileID,
	db.recovery_model_desc RecoveryMode,
	d.SPACEUSED AS SpaceUsedMB,
	CAST((mf.Size * 8) / 1024.0 AS DECIMAL(18, 3)) - d.SPACEUSED AS FreeSpaceMB,
	getdate() PollDate
--	IIF(mf.is_percent_growth = 1, CAST(mf.growth AS VARCHAR(10))+'%', CONVERT(VARCHAR(30),
	--	CAST((mf.growth * 8        ) / 1024.0 AS DECIMAL(18, 1)))+' MB') AS [Autogrowth], 
	--IIF(mf.max_size = 0, Cast((mf.Size * 8) / 1024.0 AS DECIMAL(18, 1)), 
	--IIF(mf.max_size = -1, NULL, (CAST(mf.max_size AS Decimal(15,3)) * 8) / 1024 )) AS [MaximumSizeMB],
	--,*
FROM sys.master_files AS mf
	INNER JOIN sys.databases AS db 
		ON db.database_id = mf.database_id
	inner join #TMPSPACEUSED  d
		on d.DBNAME = db.name	
			and d.FILENME = mf.name
where db.database_id > 4

DROP TABLE #TMPSPACEUSED

-----------------------------------------------------------------------------------------------------------