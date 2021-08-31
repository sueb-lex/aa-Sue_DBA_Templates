EXECUTE sp_configure 'show advanced', 1;

RECONFIGURE;

EXECUTE sp_configure 'Database Mail XPs',1;

RECONFIGURE;

EXECUTE sp_configure 'show advanced',0;

RECONFIGURE;

GO
/*
Sue Boorman 09/05/2012
Other Tasks to Complete This:
1) Go to SQL Server Agent > Properties > Alert System and check ENABLE MAIL PROFILE
(without this setting mail will not be sent)
2) Set up a SQL Agent job to clear out the mail after 6 months
3) May want to set this up the default public profile (view Database Mail > Manage Profile Security
*/

USE msdb
GO

DECLARE @profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
	    @display_name NVARCHAR(128);

-- Profile name. Replace with the name for your profile
    SET @profile_name = N'<Server_Name, sysname, Server_Name> Public Mail Profile';

-- Account information. Replace with the information for your account.
-- NOTE-DO NOT USE \ IN EMAIL ADDRESS OR THE MAIL WILL NOT BE SENT
-- Use sending address of @lexucg.local to prevent mail being viewed as spam

	SET @account_name = N'<Server_Name, sysname, Server_Name> Public Mail Account';
--NOTE-MAY NEED TO USE smtp.lexucg.local or smtp2.lexucg.local (smtp2 is what works to send mail externally) 07/11/2012 sb
	SET @SMTP_servername = 'smtp2.lexucg.local';
	SET @email_address = N'<Server_Name, sysname, Server_Name>@lexucg.local';
    SET @display_name = N'<Server_Name, sysname, Server_Name> Automated Mailer';


-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
BEGIN
  RAISERROR('The specified Database Mail profile already exists.', 16, 1);
  GOTO done;
END;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
BEGIN
 RAISERROR('The specified Database Mail account already exists.', 16, 1) ;
 GOTO done;
END;

-- Start a transaction before adding the account and the profile
BEGIN TRANSACTION ;

DECLARE @rv INT;

-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @account_name,
    @email_address = @email_address,
    @display_name = @display_name,
    @mailserver_name = @SMTP_servername;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail account (<Server_Name, sysname, Server_Name> Automated Mailer).', 16, 1) ;
    GOTO done;
END

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail profile (<Server_Name, sysname, Server_Name> Mail Profile).', 16, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to associate the specified profile with the specified account (<Server_Name, sysname, Server_Name> Automated Mailer).', 16, 1) ;
	ROLLBACK TRANSACTION;
    GOTO done;
END;

COMMIT TRANSACTION;

done:
-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================

GO