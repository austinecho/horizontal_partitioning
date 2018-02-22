/*
DataTeam
EchoOptimizerImages Partitioning

Add table back to replication

Run in DB01VPRD Equivilant 
*/
USE EchoOptimizerImages
GO

-- Pause Replication
EXEC sys.sp_changepublication @publication = 'PublicationEchoOptImages', @property = 'allow_anonymous', @value = 'false';
EXEC sys.sp_changepublication @publication = 'PublicationEchoOptImages', @property = 'immediate_sync', @value = 'false';

-- Make sure the DDL changes are carried over
EXEC sys.sp_changepublication @publication = 'PublicationEchoOptImages', @property = 'replicate_ddl', @value = '1';
GO

/*****   Run script to re-add affected article(s) back to replication.   ************/
EXEC sys.sp_addarticle @publication = N'PublicationEchoOptImages'
                     , @article = N'Image'
                     , @source_owner = N'DocumentManagementReport'
                     , @source_object = N'Image'
                     , @type = N'logbased'
                     , @description = N''
                     , @creation_script = N''
                     , @pre_creation_cmd = N'truncate'
                     , @schema_option = 0x000000000803509F
                     , @identityrangemanagementoption = N'manual'
                     , @destination_table = N'Image'
                     , @destination_owner = N'DocumentManagementReport'
                     , @status = 24
                     , @vertical_partition = N'false';

EXEC sys.sp_addarticle @publication = N'PublicationEchoOptImages'
                     , @article = N'FastLaneDocs'
                     , @source_owner = N'dbo'
                     , @source_object = N'FastLaneDocs'
                     , @type = N'logbased'
                     , @description = N''
                     , @creation_script = N''
                     , @pre_creation_cmd = N'truncate'
                     , @schema_option = 0x000000000803509F
                     , @identityrangemanagementoption = N'manual'
                     , @destination_table = N'FastLaneDocs'
                     , @destination_owner = N'dbo'
                     , @status = 24
                     , @vertical_partition = N'false';
GO

/*****   Run script to re-add affected subscriptions back to replication.   ************/

EXEC sp_addSubscription @publication ='PublicationEchoOptImages',@subscriber = 'QA2-DB02.qa.echogl.net',@destination_db='EchoOptimizerImages',@reserved='Internal',@article='DocumentManagementReport.Image',@sync_type='automatic'
EXEC sp_addSubscription @publication ='PublicationEchoOptImages',@subscriber = 'QA2-DB02.qa.echogl.net',@destination_db='EchoOptimizerImages',@reserved='Internal',@article='dbo.FastLaneDocs',@sync_type='automatic'
GO


-- ===================================================================================================

-- ***** IMPORTANT MANUAL STEP (UNTIL WE FIGURE OUT HOW TO AUTOMATICALLY DO THIS) *****
-- Remote in to SQL Server Box 
-- Start SSMS
-- Connect to DB01
-- Expand Replication / Local Publications
-- Right Click the Publication, choose "View Snapshot Agent Status"
-- Click Start
-- You should see it say "Starting Agent"
-- Within a minute or so (depending on number of articles modified), you should see:
--      [100%] A snapshot of 1 article(s) was generated.

-- ===================================================================================================
--
-- If Server doesn't have SSMS, you can also start snapshot agent by running script below:
EXECUTE sys.sp_startpublication_snapshot @publication = 'PublicationEchoOptImages';
--
-- Check Run Status of Snapshot:
-- If [runstatus] = 2 and [comments] starts with [100%] then snapshot job is done
USE distribution;
GO

SELECT     TOP ( 20 ) a.runstatus, a.start_time, a.time, a.duration, a.comments
FROM       distribution.dbo.MSsnapshot_history AS a
INNER JOIN distribution.dbo.MSsnapshot_agents AS b
        ON b.id = a.agent_id
WHERE      b.publisher_db = 'EchoOptimizerImages'
ORDER BY   a.time DESC;

-- Snapshot Done
-- ===================================================================================================
--

-- Re-Enable the publication
USE Claims
GO

EXEC sys.sp_changepublication @publication = 'PublicationEchoOptImages', @property = 'immediate_sync', @value = 'true';
EXEC sys.sp_changepublication @publication = 'PublicationEchoOptImages', @property = 'allow_anonymous', @value = 'true';

-- Make sure the DDL changes are NOT carried over any more
EXEC sys.sp_changepublication @publication = 'PublicationEchoOptImages', @property = 'replicate_ddl', @value = '0';
GO

