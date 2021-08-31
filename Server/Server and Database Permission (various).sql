
/*--changes the dbo of whatever database is pointed to when it is run
EXEC sp_changedbowner 'LEXUCG\Administrator'
*/

--report of logins and default database; report of logins and their permissions on databases
EXEC sp_helplogins


--shows owner of each database on the server (owner may not be the same as dbo)
EXEC sp_helpdb


--detailed information about logins on the server
SELECT * FROM master.dbo.syslogins ORDER BY [name]


--shows the server level role members
EXEC sp_helpsrvrolemember 
