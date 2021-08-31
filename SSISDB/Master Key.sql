/*
Various commands to open or change Master Key encrypt password for SSISDB

https://social.msdn.microsoft.com/Forums/sqlserver/en-US/af83d9a7-0b10-4bd4-a8da-1629016d15fe/is-it-possible-to-test-the-ssisdb-encryption-password?forum=sqlintegrationservices

*/

--The password you created when creating the SSIS catalog is used to protect the encryption key, in other word, the password is for master key of SSISDB database. So if you would like to test if the password is correct, you can use following T-SQL statement.

USE [SSISDB];
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = N'YourPassword'
--If it is right, it will return: Commands completed successfully.
--If it is not correct, it will return: The key is not encrypted using the specified decryptor.



--To reset the password, you could just use:

USE [SSISDB];
GO
ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD =N'YourPassword'



--If you want to change the Integration Services Catalog (SSISDB) database Master Key encryption password, run the following statement:

USE [SSISDB];
GO
 OPEN MASTER KEY DECRYPTION BY PASSWORD = N'[old_password]'; -- Password used when creating SSISDB
ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = N'[new_password]';
GO
--In the above Transact-SQL code, you first open the Integration Services Catalog (SSISDB) database Master Key with the existing password, and then regenerated it with a new one.

-------------------------------------------------------------------------------------------------------------------
https://techcommunity.microsoft.com/t5/sql-server-integration-services/ssis-catalog-backup-and-restore/ba-p/388058

--1. Backup the master key used for encryption in SSISDB database and protect the backup file using a password. This is done using BACKUP MASTER KEY statement.

--folder must already be created for this to work; also file cannot exist in this location
--had some issues with no permissions to write to certain location for unknown reason (02/04/2021 sb)
USE SSISDB
BACKUP MASTER KEY TO FILE = 'D:\SQL_Keys\SSISDB\<keyfilename>'		
ENCRYPTION BY PASSWORD = 'SS1SC@talogMKBKUP'  --enter password here
--PRDSQL2019S1_SSISDB_Key_20201110 (Example of SSISDB Key Filename)

--This step is not necessary every time you do backup unless you have lost the file or the password or if you have changed the master key of the SSISDB database.

--7. Restore backup of the master key from the source server using the backup file created in step 1 in Backup section above.

USE SSISDB
RESTORE MASTER KEY FROM FILE = 'D:\MasterKeyBackup\SSIS-Server1234\key'
DECRYPTION BY PASSWORD = 'SS1SC@talogMKBKUP'
ENCRYPTION BY PASSWORD = 'NewC@talogPassw0rd'
FORCE

--"SS1SC@talogMKBKUP" is the password used to protect the file containing backup of the master key and "NewC@talogPassw0rd" is the new password to encrypt database master key.

--The warning reported when carrying out this step " The current master key cannot be decrypted. The error was ignored because the FORCE option was specified." can be ignored.

