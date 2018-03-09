/*
DataTeam
Claims Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

•	DROP PK w/if exist (Result Heap on all table in set)
•	ADD Partition Column and Back Fill Data
•	ADD Clustered
•	ADD PK
•	Update Stats
	(The final state will be verified in a different step)

Run in DB02VPRD Equivilant 
*/
USE EchoOptimizerImages;
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME
   ) = 'DB02VPRD'
    BEGIN
        PRINT 'Running in Environment DB02VPRD...';
        END;
ELSE
    IF ( SELECT @@SERVERNAME
       ) = 'QA2-DB02'
        BEGIN
            PRINT 'Running in Environment QA2-DB02...';
            END;
    ELSE
        IF ( SELECT @@SERVERNAME
           ) = 'DATATEAM4-DB02'
            BEGIN
                PRINT 'Running in Environment DATATEAM4-DB02...';
                END;
        ELSE
            BEGIN
                PRINT 'ERROR: Server name not found. Process stopped.';
                    RETURN;
                END;


--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT  1
            FROM    sys.objects
            WHERE   type_desc = 'PRIMARY_KEY_CONSTRAINT'
                    AND parent_object_id = OBJECT_ID(N'DocumentManagementReport.Image')
                    AND name = N'PK_Image' )
    BEGIN
        ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT PK_Image;
        PRINT '- PK [PK_Image] Dropped';
    END;

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS ( SELECT  1
            FROM    sys.objects
            WHERE   type_desc = 'PRIMARY_KEY_CONSTRAINT'
                    AND parent_object_id = OBJECT_ID(N'dbo.FastLaneDocs')
                    AND name = N'PK_FastLaneDocs' )
    BEGIN
        ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT PK_FastLaneDocs;
        PRINT '- PK [PK_FastLaneDocs] Dropped';
    END;

--===================================================================================================
--[REMOVE INCORRECTLY NAMED INDEX]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove Index ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'TestX_LoadID_cov' )
    BEGIN
        DROP INDEX TestX_LoadID_cov ON DocumentManagementReport.Image;
        PRINT '- Index [TestX_LoadID_cov] Dropped';
    END;

--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'CIX_DocumentManagementReport_Image_CreateDate' )
    BEGIN
        DROP INDEX CIX_DocumentManagementReport_Image_CreateDate ON DocumentManagementReport.Image;
        PRINT '- Index [CIX_DocumentManagementReport_Image_CreateDate] Dropped';
    END;

CREATE CLUSTERED INDEX CIX_DocumentManagementReport_Image_CreateDate
ON DocumentManagementReport.Image ( CreateDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_EchoOptimizerImages_DATETIME_1Year(CreateDate);
PRINT '- Index [CIX_DocumentManagementReport_Image_CreateDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'CIX_FastLaneDocs_SubmittedDate' )
    BEGIN
        DROP INDEX CIX_FastLaneDocs_SubmittedDate ON dbo.FastLaneDocs;
        PRINT '- Index [CIX_FastLaneDocs_SubmittedDate] Dropped';
    END;

CREATE CLUSTERED INDEX CIX_FastLaneDocs_SubmittedDate
ON dbo.FastLaneDocs ( SubmittedDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_EchoOptimizerImages_DATETIME_2Year(SubmittedDate);
PRINT '- Index [CIX_FastLaneDocs_SubmittedDate] Created';


--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'PK_DocumentManagementReport_Image_ImageId_CreateDate' )
    BEGIN
        ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT PK_DocumentManagementReport_Image_ImageId_CreateDate;
        PRINT '- PK [PK_DocumentManagementReport_Image_ImageId_CreateDate] Dropped';
    END;

ALTER TABLE DocumentManagementReport.Image
ADD CONSTRAINT PK_DocumentManagementReport_Image_ImageId_CreateDate
PRIMARY KEY NONCLUSTERED ( ImageId, CreateDate ) ON [PRIMARY];
PRINT '- PK [PK_DocumentManagementReport_Image_ImageId_CreateDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'PK_FastLaneDocs_FastLaneDocId_SubmittedDate' )
    BEGIN
        ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT PK_FastLaneDocs_FastLaneDocId_SubmittedDate;
        PRINT '- PK [PK_FastLaneDocs_FastLaneDocId_SubmittedDate] Dropped';
    END;

ALTER TABLE dbo.FastLaneDocs
ADD CONSTRAINT PK_FastLaneDocs_FastLaneDocId_SubmittedDate
PRIMARY KEY NONCLUSTERED ( FastLaneDocId, SubmittedDate ) ON [PRIMARY];
PRINT '- PK [PK_FastLaneDocs_FastLaneDocId_SubmittedDate] Created';

--===================================================================================================
--[ADD INDEX]
--===================================================================================================
PRINT '***************************';
PRINT '*** Add Index ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_DocumentManagementReport_Image_LoadId_DocumentName_DocumentTypeId_StartTimeInWorkspaceDate_UpdateDate' )
    BEGIN
        DROP INDEX IX_DocumentManagementReport_Image_LoadId_DocumentName_DocumentTypeId_StartTimeInWorkspaceDate_UpdateDate ON DocumentManagementReport.Image;
        PRINT '- Index [IX_DocumentManagementReport_Image_LoadId_DocumentName_DocumentTypeId_StartTimeInWorkspaceDate_UpdateDate] Dropped';
    END;


CREATE NONCLUSTERED INDEX [IX_DocumentManagementReport_Image_LoadId_DocumentName_DocumentTypeId_StartTimeInWorkspaceDate_UpdateDate] ON [DocumentManagementReport].[Image] 
(
[LoadId] ASC,
[DocumentName] ASC,
[DocumentTypeId] ASC,
[StartTimeInWorkspaceDate] ASC,
[UpdateDate] ASC
);
PRINT '- Index [[IX_DocumentManagementReport_Image_LoadId_DocumentName_DocumentTypeId_StartTimeInWorkspaceDate_UpdateDate]] Created';
--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

UPDATE STATISTICS DocumentManagementReport.Image;
PRINT '- Statistics Updated';

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

UPDATE STATISTICS dbo.FastLaneDocs;
PRINT '- Statistics Updated';
GO


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';