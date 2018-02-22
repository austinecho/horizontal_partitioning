/*
DataTeam
Claims Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

•	DROP FK w/if exist
•	DROP PK w/if exist (Result Heap on all table in set)
•	ADD Partition Column and Back Fill Data
•	ALTER NULL Column and ADD DF 
•	ADD Clustered
•	ADD PK
•	ADD UX
•	ADD FK
•	Update Stats
	(The final state will be verified in a different step)

Run in DB01VPRD Equivilant 
*/
USE EchoOptimizerImages
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01' BEGIN PRINT 'Running in Environment QA2-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;


--===================================================================================================
--[REMOVE ALL FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Remove FK ***';
PRINT '*****************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_Image_Load'
                AND  parent_object_id = OBJECT_ID( N'DocumentManagementReport.Image' ))
BEGIN
    ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT FK_Image_Load;
    PRINT '- FK [FK_Image_Load] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID'
                     AND  parent_object_id = OBJECT_ID( N'DocumentManagementReport.Image' ))
BEGIN
    ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID;
    PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID] Dropped';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_Image_SourceFile'
                AND  parent_object_id = OBJECT_ID( N'DocumentManagementReport.Image' ))
BEGIN
    ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT FK_Image_SourceFile;
    PRINT '- FK [FK_Image_SourceFile] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId'
                     AND  parent_object_id = OBJECT_ID( N'DocumentManagementReport.Image' ))
BEGIN
    ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId;
    PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId] Dropped';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO


--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'DocumentManagementReport.Image' )
				AND  name = N'PK_Image'
          )
	BEGIN
        ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT PK_Image;
        PRINT '- PK [PK_Image] Dropped';
	END;

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.FastLaneDocs' )
				AND  name LIKE N'PK__AuditRec%'
          )
	BEGIN
        ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT PK_FastLaneDocs;
        PRINT '- PK [PK_FastLaneDocs] Dropped';
	END;


--===================================================================================================
--[REMOVE ALL DFs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove DF ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS ( SELECT  1
            FROM    sys.objects
            WHERE   parent_object_id = OBJECT_ID(N'dbo.FastLaneDocs')
                    AND type_desc = 'DEFAULT_CONSTRAINT'
                    AND name LIKE 'DF__FastLaneD%' )
    BEGIN
        IF (SELECT @@SERVERNAME) = 'DB01VPRD'
            BEGIN 
                ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__RecSt__7FB5F314;
                PRINT '- DF [DF__FastLaneD__RecSt__7FB5F314] Dropped';

				ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Statu__7EC1CEDB;
                PRINT '- DF [DF__FastLaneD__Statu__7EC1CEDB] Dropped';

				ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Submi__7DCDAAA2;
                PRINT '- DF [DF__FastLaneD__Submi__7DCDAAA2] Dropped';
            END;
		ELSE IF (SELECT @@SERVERNAME) = 'QA'
            BEGIN 
                ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Submi__164452B1;
                PRINT '- DF [DF__FastLaneD__Submi__164452B1] Dropped';

				ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Submi__164452B1;
                PRINT '- DF [DF__FastLaneD__Submi__164452B1] Dropped';

				ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Submi__164452B1;
                PRINT '- DF [DF__FastLaneD__Submi__164452B1] Dropped';
            END;
		ELSE IF (SELECT @@SERVERNAME) = 'DATATEAM4-DB01\DB01'
            BEGIN 
                ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__RecSt__182C9B23;
                PRINT '- DF [DF__FastLaneD__RecSt__182C9B23] Dropped';

				ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Statu__173876EA;
                PRINT '- DF [DF__FastLaneD__Statu__173876EA] Dropped';

				ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT DF__FastLaneD__Submi__164452B1;
                PRINT '- DF [DF__FastLaneD__Submi__164452B1] Dropped';
            END;                                    
    END;         

--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_DocumentManagementReport_Image_CreateDate' )
BEGIN
    DROP INDEX CIX_DocumentManagementReport_Image_CreateDate ON DocumentManagementReport.Image;
	PRINT '- Index [CIX_DocumentManagementReport_Image_CreateDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_DocumentManagementReport_Image_CreateDate
ON DocumentManagementReport.Image ( CreateDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_EchoOptimizerImages_DATETIME_3Year(CreatedDate);
PRINT '- Index [CIX_DocumentManagementReport_Image_CreateDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_FastLaneDocs_SubmittedDate' )
BEGIN
    DROP INDEX CIX_FastLaneDocs_SubmittedDate ON dbo.FastLaneDocs;
	PRINT '- Index [CIX_FastLaneDocs_SubmittedDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_FastLaneDocs_SubmittedDate
ON dbo.FastLaneDocs ( SubmittedDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_EchoOptimizerImages_DATETIME_3Year(CreatedDate);
PRINT '- Index [CIX_FastLaneDocs_SubmittedDate] Created';

--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_DocumentManagementReport_Image_ImageId_CreateDate' )
BEGIN
    ALTER TABLE DocumentManagementReport.Image DROP CONSTRAINT PK_DocumentManagementReport_Image_ImageId_CreateDate;
	PRINT '- PK [PK_DocumentManagementReport_Image_ImageId_CreateDate] Dropped';
END;

ALTER TABLE DocumentManagementReport.Image
ADD CONSTRAINT PK_DocumentManagementReport_Image_ImageId_CreateDate
    PRIMARY KEY NONCLUSTERED ( ImageId, CreateDate )
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_EchoOptimizerImages_DATETIME_3Year(CreatedDate);
PRINT '- PK [PK_DocumentManagementReport_Image_ImageId_CreateDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[FastLaneDocs] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_FastLaneDocs_FastLaneDocId_SubmittedDate' )
BEGIN
    ALTER TABLE dbo.FastLaneDocs DROP CONSTRAINT PK_FastLaneDocs_FastLaneDocId_SubmittedDate;
	PRINT '- PK [PK_FastLaneDocs_FastLaneDocId_SubmittedDate] Dropped';
END;

ALTER TABLE dbo.FastLaneDocs
ADD CONSTRAINT PK_FastLaneDocs_FastLaneDocId_SubmittedDate
    PRIMARY KEY NONCLUSTERED ( FastLaneDocId, SubmittedDate )
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_EchoOptimizerImages_DATETIME_3Year(CreatedDate);
PRINT '- PK [PK_FastLaneDocs_FastLaneDocId_SubmittedDate] Created';

--===================================================================================================
--[CREATE FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Create FK ***';
PRINT '*****************';

--*****************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

ALTER TABLE DocumentManagementReport.Image WITH NOCHECK
ADD CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID
    FOREIGN KEY ( LoadId )
    REFERENCES DocumentManagementReport.Load ( LoadId ) ON DELETE CASCADE;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID] Created';

ALTER TABLE DocumentManagementReport.Image CHECK CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID] Enabled';
GO

ALTER TABLE DocumentManagementReport.Image WITH NOCHECK
ADD CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId
    FOREIGN KEY ( SourceFileId )
    REFERENCES DocumentManagementReport.SourceFile ( LoadId ) ON DELETE CASCADE;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId] Created';

ALTER TABLE DocumentManagementReport.Image CHECK CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId] Enabled';
GO

--===================================================================================================
--[CREATE DF]
--===================================================================================================
PRINT '*****************';
PRINT '*** Create DF ***';
PRINT '*****************';

--*****************************************************
PRINT 'Working on table [DocumentManagementReport].[Image] ...';

ALTER TABLE DocumentManagementReport.Image WITH NOCHECK
ADD CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID
    FOREIGN KEY ( LoadId )
    REFERENCES DocumentManagementReport.Load ( LoadId ) ON DELETE CASCADE;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID] Created';

ALTER TABLE DocumentManagementReport.Image CHECK CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_Load_LoadID] Enabled';
GO

ALTER TABLE DocumentManagementReport.Image WITH NOCHECK
ADD CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId
    FOREIGN KEY ( SourceFileId )
    REFERENCES DocumentManagementReport.SourceFile ( LoadId ) ON DELETE CASCADE;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId] Created';

ALTER TABLE DocumentManagementReport.Image CHECK CONSTRAINT FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId;
PRINT '- FK [FK_DocumentManagementReport_Image_DocumentManagementReport_SourceFile_SourceFileId] Enabled';
GO

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

--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';