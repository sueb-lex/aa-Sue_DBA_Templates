--https://blog.sqlauthority.com/2018/10/24/sql-server-how-to-get-list-of-sql-server-instances-installed-on-a-machine-via-t-sql/
--October 24, 2018 Pinal Dave

DECLARE @GetInstances TABLE
( Value nvarchar(100),
InstanceNames nvarchar(100),
Data nvarchar(100))
Insert into @GetInstances
EXECUTE xp_regread
@rootkey = 'HKEY_LOCAL_MACHINE',
@key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
@value_name = 'InstalledInstances'
Select InstanceNames from @GetInstances