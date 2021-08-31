--use the Query menu > set to SQLCMD Mode and then run below script
:ON ERROR EXIT
:CONNECT GCSQL2
SET NOCOUNT ON;
SELECT        SERVERPROPERTY('ServerName') AS ServerName
                ,SERVERPROPERTY('ProductVersion') AS ProductVersion
                ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                ,SERVERPROPERTY('Edition') AS Edition
                ,SERVERPROPERTY('EngineEdition') AS EngineEdition;
GO
:CONNECT GCSQL1
SET NOCOUNT ON;
SELECT        SERVERPROPERTY('ServerName') AS ServerName
                ,SERVERPROPERTY('ProductVersion') AS ProductVersion
                ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                ,SERVERPROPERTY('Edition') AS Edition
                ,SERVERPROPERTY('EngineEdition') AS EngineEdition
GO
:CONNECT GCSQL1\ROUTEWARE
SET NOCOUNT ON;
SELECT        SERVERPROPERTY('ServerName') AS ServerName
                ,SERVERPROPERTY('ProductVersion') AS ProductVersion
                ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                ,SERVERPROPERTY('Edition') AS Edition
                ,SERVERPROPERTY('EngineEdition') AS EngineEdition
GO
:CONNECT GCSQL1\ONBASESQL
SET NOCOUNT ON;
SELECT        SERVERPROPERTY('ServerName') AS ServerName
                ,SERVERPROPERTY('ProductVersion') AS ProductVersion
                ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                ,SERVERPROPERTY('Edition') AS Edition
                ,SERVERPROPERTY('EngineEdition') AS EngineEdition
GO
:CONNECT GCSQL1\SP2010SQL
SET NOCOUNT ON;
SELECT        SERVERPROPERTY('ServerName') AS ServerName
                ,SERVERPROPERTY('ProductVersion') AS ProductVersion
                ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                ,SERVERPROPERTY('Edition') AS Edition
                ,SERVERPROPERTY('EngineEdition') AS EngineEdition
GO