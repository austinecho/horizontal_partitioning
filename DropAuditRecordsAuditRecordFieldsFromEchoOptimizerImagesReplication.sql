exec sys.sp_dropsubscription @publication = 'PublicationClaims',@article = 'dbo.AuditRecords', @subscriber = N'all',@destination_db = N'all'
exec sp_droparticle @publication = 'PublicationClaims', @article = 'dbo.AuditRecords',@force_invalidate_snapshot = 0
--exec sys.sp_dropsubscription @publication = 'PublicationEchoOpt',@article = 'dbo.tblCustomerExtended', @subscriber = N'all',@destination_db = N'all'
--exec sp_droparticle @publication = 'PublicationEchoOpt', @article = 'dbo.tblCustomerExtended',@force_invalidate_snapshot = 0
exec sys.sp_dropsubscription @publication = 'PublicationClaims',@article = 'dbo.AuditRecordFields', @subscriber = N'all',@destination_db = N'all'
exec sp_droparticle @publication = 'PublicationClaims', @article = 'dbo.AuditRecordFields',@force_invalidate_snapshot = 0
