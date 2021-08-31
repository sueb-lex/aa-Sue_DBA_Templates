IF EXISTS(SELECT name FROM sysobjects WHERE name = '<Procedure_Name, sysname, ProcedureName>' AND type = 'P')
   DROP PROCEDURE <Procedure_Name, sysname, ProcedureName>
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
https://www.mssqltips.com/sqlservertip/6588/sql-server-stored-procedure-custom-templates-ssms-and-visual-studio/
-- =============================================
-- Author:        <Author,,Name>
-- Create date:  <Create Date,,>
-- Description:   <Description,,>
-- =============================================
--Change History
--Date   Changed by      Description
 
*/
CREATE PROCEDURE <Procedure_Name, sysname, ProcedureName> 
   -- Add the parameters for the stored procedure here
   <@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
   <@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
      BEGIN TRAN
      -- Insert statements for procedure here
 
      COMMIT TRAN
   END TRY
   BEGIN CATCH
      IF @@TRANCOUNT > 0
         ROLLBACK TRAN
      DECLARE @ErrorMessage NVARCHAR(4000);
      DECLARE @ErrorSeverity INT;
      DECLARE @ErrorState INT;
 
      SELECT @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
      RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState );
   END CATCH
END
GO