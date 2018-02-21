/*
DataTeam
EchoOptimizerImages Partitioning

Remove table from replication, will add back after schema changes

Run in DB01VPRD Equivilant 
*/
USE EchoOptimizerImages
GO

EXEC sys.sp_dropsubscription @publication = 'PublicationEchoOptImages',@article ='DocumentManagementReport.Image', @subscriber = N'all', @destination_db = N'all'
EXEC sp_droparticle @publication = 'PublicationEchoOptImages', @article  ='DocumentManagementReport.Image', @force_invalidate_snapshot = 1 

EXEC sys.sp_dropsubscription @publication = 'PublicationEchoOptImages',@article ='dbo.FastLaneDocs', @subscriber = N'all', @destination_db = N'all'
EXEC sp_droparticle @publication = 'PublicationEchoOptImages', @article  ='dbo.FastLaneDocs', @force_invalidate_snapshot = 1 

