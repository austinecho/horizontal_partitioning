/*
DataTeam
Claims Partitioning

Remove table from replication, will add back after schema changes

Run in DB01VPRD Equivilant 
*/
USE Claims
GO

EXEC sys.sp_dropsubscription @publication = 'PublicationClaims',@article ='dbo.AuditRecords', @subscriber = N'all', @destination_db = N'all'
EXEC sp_droparticle @publication = 'PublicationClaims', @article  ='dbo.AuditRecords', @force_invalidate_snapshot = 1 

EXEC sys.sp_dropsubscription @publication = 'PublicationClaims',@article ='dbo.AuditRecordFields', @subscriber = N'all', @destination_db = N'all'
EXEC sp_droparticle @publication = 'PublicationClaims', @article  ='dbo.AuditRecordFields', @force_invalidate_snapshot = 1 

