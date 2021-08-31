USE  SignInOutSheets
go

SELECT CurrentInOut, InOutStatus, CurrentNotes, CurrentLastUpdated, CONVERT(varchar(20),CurrentLastUpdated, 100) AS ActualTime, 
  DATENAME(WEEKDAY,CurrentLastUpdated) AS WeekDay, UpdatedBy, UserID, Audit_Timestamp
FROM dbo.CS_SignInOut_Audit
WHERE UserID = N'<User_ID, text, Enter UserID here>'
ORDER BY Audit_Timestamp desc

-- ================================================
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
-- ================================================
-- =============================================
-- Author:		Sue Boorman
-- Create date: 03/07/2013
-- Description:	look up the sign in/out times for a user
-- =============================================