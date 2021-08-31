/*
Take Database Offline with Rollback Immediate
LastUpdated 03/18/2021
*/

/*
USE [master]
GO
ALTER DATABASE [webctrl_alarms] SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO	

USE [master]
GO
ALTER DATABASE [webctrl_audit] SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO	

USE [master]
GO
ALTER DATABASE [webctrl_main] SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO	

USE [master]
GO
ALTER DATABASE [webctrl_trends] SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO	

SELECT * FROM sys.databases
ORDER BY NAME;
*/