/*
try to determine which field is being truncated
http://sqlservercode.blogspot.com/2017/01/t-sql-tuesday-86-string-or-binary-data.html?utm_source=Brent+Ozar+Unlimited%C2%AE+List&utm_campaign=ff051dcc6d-RSS_EMAIL_CAMPAIGN&utm_medium=email&utm_term=0_8e3e861dd9-ff051dcc6d-296102973
*/

declare @ImportTable varchar(100)
declare @DestinationTable varchar(100)
select @ImportTable = 'temp'
select @DestinationTable = 'TestTrunc'
 
declare @ImportTableCompare varchar(100)
declare @DestinationTableCompare varchar(100)
select @ImportTableCompare = 'MaxLengths'
select @DestinationTableCompare = 'TempTrunc'
 
 
declare @sql varchar(8000)
select @sql  = ''
select @sql = 'select  0 as _col0 ,'
select @sql +=   'max(len( ' + column_name+ ')) AS ' + column_name + ',' 
from information_schema.columns
where table_name = @ImportTable
and data_type in('varchar','char','nvarchar','nchar')
 
select @sql = left(@sql,len(@sql) -1)
select @sql +=' into ' + @ImportTableCompare + ' from ' + @ImportTable
 
--select @sql -debugging so simple, a caveman can do it
 
exec (@sql)
 
 
 
select @sql  = ''
select @sql = 'select 0 as _col0, '
select @sql +=   '' + convert(varchar(20),character_maximum_length)
+ ' AS ' + column_name + ',' 
from information_schema.columns
where table_name = @DestinationTable
and data_type in('varchar','char','nvarchar','nchar')
 
select @sql = left(@sql,len(@sql) -1)
select @sql +=' into ' + @DestinationTableCompare
 
--select @sql -debugging so simple, a caveman can do it
 
exec (@sql)
 
 
select @sql  = ''
select @sql = 'select  '
select @sql +=   '' + 'case when  t.' + column_name + ' > tt.' + column_name
+ ' then ''truncation'' else ''no truncation'' end as '+ column_name
+ ',' 
from information_schema.columns
where table_name = @ImportTableCompare
and column_name <> '_col0'
select @sql = left(@sql,len(@sql) -1)
select @sql +='  from ' + @ImportTableCompare + ' t
join ' + @DestinationTableCompare + ' tt on t._col0 = tt._col0 '
 
--select @sql -debugging so simple, a caveman can do it
 
exec (@sql)
 
 
exec ('drop table ' + @ImportTableCompare+ ',' + @DestinationTableCompare )