--Detailed breakdown of server properties updated for SQL 2012 and SQL 2014

-- Get selected server properties 
SELECT SERVERPROPERTY('MachineName') AS [MachineName], 
SERVERPROPERTY('ServerName') AS [ServerName],  
SERVERPROPERTY('InstanceName') AS [Instance], 
SERVERPROPERTY('IsClustered') AS [IsClustered], 
SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
SERVERPROPERTY('Edition') AS [Edition], 
SERVERPROPERTY('ProductLevel') AS [ProductLevel],
SERVERPROPERTY('ProductUpdateLevel') AS [Product Update Level], -- This is new
SERVERPROPERTY('ProductVersion') AS [ProductVersion], 
SERVERPROPERTY('ProcessID') AS [ProcessID],
SERVERPROPERTY('Collation') AS [Collation], 
SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
SERVERPROPERTY('FilestreamConfiguredLevel') AS [FilestreamConfiguredLevel],
SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled], 
SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus],
SERVERPROPERTY('IsXTPSupported') AS [IsXTPSupported],
SERVERPROPERTY('BuildClrVersion') AS [Build CLR Version];

-- This gives you a lot of useful information about your instance of SQL Server,
-- such as the ProcessID for SQL Server and your collation
