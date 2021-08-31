/*
--SQL Undercover (c)2017
--https://sqlundercover.wordpress.com/
https://sqlundercover.com/2017/06/01/undercover-toolbox-fn_splitstring-its-like-string_split-but-for-luddites-or-those-who-havent-moved-to-sql-2016-yet/
--Written By David Fowler - 1 June 2017
--Table valued function that breaks a delimited string into a table of discrete values
--needed for SQL Servers older than SQL 2016
  sb 07/27/2018
  Example: 
	SELECT StringElement FROM master.dbo.[fn_SplitString]('a,b,c,d,e,f,g,h,i',',')
	just change the last parameter if you want to use another delimiter
*/ 
USE master
GO
 
CREATE FUNCTION fn_SplitString(@DelimitedString VARCHAR(MAX), @Delimiter CHAR(1) = ',')
RETURNS @SplitStrings TABLE (StringElement VARCHAR(255))
 
AS
 
BEGIN
 
WITH Split(XMLSplit)
AS
(SELECT CAST('<element>' + REPLACE(@DelimitedString,@Delimiter,'</element><element>') + '</element>' AS XML))
INSERT INTO @SplitStrings
SELECT p.value('.', 'VARCHAR(255)')
FROM Split
CROSS APPLY XMLSplit.nodes('/element') t(p)
 
RETURN
 
END