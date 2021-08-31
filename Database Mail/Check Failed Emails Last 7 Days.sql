USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[usp_CheckForFailedEmails]    Script Date: 6/17/2019 1:23:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_CheckForFailedEmails]
AS
/*******************************************************************************************
Created By: Sue Boorman 07/11/2012
Notes: This is used to catch failed email messages within the last 7 days
(07/11/2012) created
(05/24/2014) sb changed notification to go to group rather than individuals
(06/17/2019) sb changed so < 7 days rather than <= 7 days
*******************************************************************************************/

SET NOCOUNT ON

DECLARE @tableHTML  NVARCHAR(MAX)
DECLARE @Count INT = 0
DECLARE @Days INT = 7
DECLARE @MailTo VARCHAR(50) = 'DBA_Notification@lexingtonky.gov';

SELECT @Count = COUNT(*)
FROM msdb.dbo.sysmail_faileditems as fi
INNER JOIN msdb.dbo.sysmail_event_log AS l
    ON fi.mailitem_id = l.mailitem_id
WHERE DATEDIFF(dd, fi.last_mod_date, getdate()) < @Days  --changed to = 0 for testing

IF @Count > 0
  BEGIN

    SET @tableHTML =
        N'<H1>Failed Emails Within Last 7 Days</H1>' +
        N'<table border="1">' +
        N'<tr><th>Subject</th><th>LastModifiedDAte</th>' +
        N'<th>Recipients</th><th>Decription</th></tr>' +
        CAST ( ( SELECT td = fi.subject,       '',
                        td = fi.last_mod_date, '',
                        td = fi.recipients, '',
                        td = l.description
                  FROM msdb.dbo.sysmail_faileditems AS fi
                    INNER JOIN msdb.dbo.sysmail_event_log AS l
                      ON fi.mailitem_id = l.mailitem_id
                  WHERE DATEDIFF(dd, fi.last_mod_date, getdate()) <= @Days
                  ORDER BY fi.last_mod_date DESC
                  FOR XML PATH('tr'), TYPE 
        ) AS NVARCHAR(MAX) ) +
        N'</table>' ;

    EXEC msdb.dbo.sp_send_dbmail 
        @recipients = @MailTo,
        @subject = 'Failed Mail Count',
        @body = @tableHTML,
        @body_format = 'HTML' ;
  END    
ELSE
  BEGIN
      EXEC msdb.dbo.sp_send_dbmail 
	      @recipients = @MailTo,
        @subject = 'No Failed Emails',
        @body = 'No failed emails have been found within the last 7 days.' ;
  END

GO


