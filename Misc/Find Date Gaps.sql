/*
Find Missing Dates From Existing Table (Using Except Operator)
http://social.msdn.microsoft.com/Forums/sqlserver/en-US/6f91f407-8eb4-4794-85d6-f734f8f66616/how-to-find-missing-dates-from-exting-table?forum=transactsql
Thursday, June 18, 2009 3:41 PM
*/
DECLARE  @MaxDate DATE, 
         @MinDate DATE, 
         @iDate  DATE 

-- SQL Server table variable 
DECLARE  @DateSequence TABLE( 
                          DATE DATE 
                          ) 

SELECT @MaxDate = Convert(DATE,Max(IncidentDate)), 
       @MinDate = Convert(DATE,Min(IncidentDate)) 
FROM   dbo.PoliceRaids 

SET @iDate = @MinDate 

WHILE (@iDate <= @MaxDate) 
  BEGIN 
    INSERT @DateSequence
    SELECT @iDate 
     
    SET @iDate = Convert(DATE,Dateadd(DAY,1,@iDate)) 
  END 

SELECT Gaps = DATE 
FROM   @DateSequence
EXCEPT 
SELECT DISTINCT Convert(DATE,IncidentDate) 
FROM   dbo.PoliceRaids 
GO 
