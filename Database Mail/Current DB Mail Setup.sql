/*
Create Database Mail SQL Script
Last Revised:  07/26/2021 sb

NOTE: CHANGE ITEMS IN <> TO SERVER NAME
(if you are unable to send a test mail it is most often due to McAfee.  Uncheck item about Blocking sending of mass mailings)
(be sure to enable Database Mail in the SQL Agent properties so mail can be sent by the Sql Agent)
[GCSQL1_InstanceName] is how this might look for an instance when replacing <VMGCSQL1>

--this statement will give you information about Database Mail including the smtp server being used
EXECUTE msdb.dbo.sysmail_help_account_sp;

*/

--run this script to enable database mail features on the server
EXECUTE sp_configure 'show advanced', 1;
RECONFIGURE;
EXECUTE sp_configure 'Database Mail XPs',1;
RECONFIGURE;
GO

USE msdb
GO

DECLARE @profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
        @display_name NVARCHAR(128);

-- Profile name. Replace with the name for your profile
	SET @profile_name = '<VMGCSQL1> Public Mail Profile';

-- Account information. Replace with the information for your account.
-- NOTE-DO NOT USE \ IN EMAIL ADDRESS OR THE MAIL WILL NOT BE SENT
-- Use sending address of @lexucg.local to prevent mail being viewed as spam

	SET @account_name = '<VMGCSQL1> Public Mail Account';
--NOTE-MAY NEED TO USE smtp.lexucg.local or smtp2.lexucg.local (smtp2 is what works to send mail externally) 06/02/2016 sb
--use @lexucg.local (rather than @lexingtonky.gov in the sender email) when using smtp as it prevents mail from being blocked as it does not come from an external source - only good with smtp (not smtp2)
--when using smtp2 must use @lexingtonky.gov and notify networking of server name to give permission to send mail from that server
	SET @SMTP_servername = 'smtp2.lexucg.local';
	SET @email_address = '<VMGCSQL1>@lexingtonky.gov';
	SET @display_name = '<VMGCSQL1> Automated Mailer';

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
    RAISERROR('Failed to create the specified Database Mail account (<VMGCSQL1> Automated Mailer).', 16, 1) ;
    GOTO done;
END

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail profile (<VMGCSQL1> Mail Profile).', 16, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;

--ADDED BELOW TO SET PROFILE AS PUBLIC AND DEFAULT (CHECK THAT THIS WORKS)
-- Grant access to the profile to all users in the msdb database.
EXECUTE @rv=msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @profile_name,
    @principal_name = 'public',
    @is_default = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to associate the specified profile with the specified account (<VMGCSQL1> Automated Mailer).', 16, 1) ;
	ROLLBACK TRANSACTION;
    GOTO done;
END;

COMMIT TRANSACTION;

done:

GO
