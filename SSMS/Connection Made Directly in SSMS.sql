SELECT C.client_net_address
	, S.host_name
	, S.login_name
	, ST.text
FROM sys.dm_exec_sessions S
	INNER JOIN sys.dm_exec_connections C
		ON S.session_id = C.session_id
         CROSS APPLY sys.dm_exec_sql_text(C.most_recent_sql_handle) ST
WHERE S.program_name LIKE 'Microsoft SQL Server Management Studio%'
ORDER BY S.program_name
	, C.client_net_address;
--http://thesqlagentman.com/2013/04/top-13-mistakes-and-missteps-in-sql-server-5-ssms-is-a-weapon-of-mass-destruction/ 
--04/10/2013