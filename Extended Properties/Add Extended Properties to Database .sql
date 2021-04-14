--Add extended properties to Database
  
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'<MS_Description,text,Database Description>' 
EXEC sp_addextendedproperty @name = N'Developer_Contact', @value = N'<Developer_Contact,text,Developer or Contact>'
EXEC sp_addextendedproperty @name = N'DivisionOwner', @value = N'<DivisionOwner,text,Division Owner>'
EXEC sp_addextendedproperty @name = N'LastUpdated', @value = N'<LastUpdated,text,Date>'
EXEC sp_addextendedproperty @name = N'Notes', @value = N'<Notes,text,Notes>'

--used to select extended properties from a single database (must be pointed to this database)
SELECT [name] 
    , [value] 
FROM sys.extended_properties 
WHERE [class] = 0

-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================
-- =============================================
-- Author:		Sue Boorman
-- Create date: 02/01/2011
-- Description:	Use to Add Extended Properties to databases
-- =============================================
GO
