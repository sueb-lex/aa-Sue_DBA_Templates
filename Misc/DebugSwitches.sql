/*
Controls The Output of Debugging Information and Code Execution
https://therestisjustcode.wordpress.com/2018/07/10/t-sql-tuesday-104-code-you-would-hate-to-live-without/
*/

DECLARE @Debug BIT= 1;
DECLARE @ImSure BIT= 0;

IF(@Debug = 1)
  BEGIN
    PRINT @MyQuery;
  END;
IF(@ImSure = 1)
  BEGIN
    EXEC sp_executesql @MyQuery;
END;