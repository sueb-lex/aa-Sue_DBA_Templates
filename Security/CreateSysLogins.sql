/****** Object:  StoredProcedure [dbo].[usp_CreateSysLogins]    Script Date: 12/06/2017 04:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_CreateSysLogins] as 
  --Programmer: C.Cunningham
  --Purpose: write script to create sql logins
declare @SysAdmin bit,@SecurityAdmin bit,@ServerAdmin bit,@SetupAdmin bit,@ProcessAdmin bit,@DiskAdmin bit,@DBCreator bit,@BulkAdmin bit,@isntuser bit,@isntgroup bit
declare crs_Logins cursor for 
  select [loginname],sysadmin,securityadmin,serveradmin,setupadmin,processadmin,diskadmin,dbcreator,bulkadmin,isntuser,isntgroup 
  from master..syslogins where sid<>1 and patindex('%BUILTIN%',[name])=0
declare @username sysname
declare @sqlcmd nvarchar(1024)
print '--'
print '--Output from usp_CreateSysLogins'
print '--'
open crs_Logins
fetch next from crs_Logins into @username,@SysAdmin,@SecurityAdmin,@ServerAdmin,@SetupAdmin,@ProcessAdmin,@DiskAdmin,@DBCreator,@BulkAdmin,@isntuser,@isntgroup
while @@fetch_status=0
  begin
  	print '--------------------------------------------------------'
  	print '--begin create user ' + @username
  	print '--'
    print 'if not exists(select * from master.dbo.syslogins where [loginname]=''' + @username + ''')'
    print 'begin'
    if @isntuser=0 and @isntgroup=0
  	begin
   	  set @sqlcmd='sp_help_revlogin ''' + @username + ''''
   	  print ''
      exec sp_executesql @sqlcmd
    end
    else
    begin
      print '  exec sp_grantlogin ''' + @username + ''''
    end
    if @SysAdmin=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''sysadmin'''
    end
    if @SecurityAdmin=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''securityadmin'''
    end
    if @ServerAdmin=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''serveradmin'''
    end
    if @SetupAdmin=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''setupadmin'''
    end
    if @ProcessAdmin=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''processadmin'''
    end
    if @DiskAdmin=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''diskadmin'''
    end
    if @DBCreator=1
    begin
     print ''
     print '   exec sp_addsrvrolemember ''' + @username + ''',''dbcreator'''
    end
    if @BulkAdmin=1
    begin
     print ''
     print '  exec sp_addsrvrolemember ''' + @username + ''',''bulkadmin'''
    end
    print 'end'
    print 'go'
    print '--create user ' + @username + ' finished '
    print '--------------------------------------------------------'
    print ''
    print ''
    fetch next from crs_Logins into @username,@SysAdmin,@SecurityAdmin,@ServerAdmin,@SetupAdmin,@ProcessAdmin,@DiskAdmin,@DBCreator,@BulkAdmin,@isntuser,@isntgroup
  end
  close crs_Logins
  deallocate crs_Logins
