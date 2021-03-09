SELECT d.name, ROUND(SUM(mf.size) * 8 / 1024, 0) Size_MBs,
SUBSTRING(@@VERSION, 0 , CHARINDEX(' - ', @@VERSION, -1)) AS Version,
@@VERSION AS LongVersion
FROM sys.master_files mf
INNER JOIN sys.databases d ON d.database_id = mf.database_id
GROUP BY d.name
ORDER BY d.name

--http://www.codeproject.com/Tips/469070/SQL-Server-Get-All-Databases-Size
--SUBSTRING(@@VERSION, 0 , CHARINDEX(' - ', @@VERSION, -1)) AS Version (trims version to first hyphen)