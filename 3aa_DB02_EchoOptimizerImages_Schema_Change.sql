/*
DataTeam
Claims Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

�	DROP PK w/if exist (Result Heap on all table in set)
�	ADD Partition Column and Back Fill Data
�	ADD Clustered
�	ADD PK
�	Update Stats
	(The final state will be verified in a different step)

Run in DB02VPRD Equivilant 
*/
USE Claims
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME ) = 'DB02VPRD' BEGIN PRINT 'Running in Environment DB02VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB02' BEGIN PRINT 'Running in Environment QA2-DB02...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB02' BEGIN PRINT 'Running in Environment DATATEAM4-DB02...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;


--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecords' )
				AND  name LIKE N'PK__AuditRec%'
          )
BEGIN
    IF ( SELECT @@SERVERNAME ) = 'DB02VPRD'
    BEGIN
        ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK__AuditRec__3214EC077F60ED59;
        PRINT '- PK [PK__AuditRec__3214EC077F60ED59] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB02'
    BEGIN
        ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK__AuditRec__3214EC077F60ED59;
        PRINT '- PK [PK__AuditRec__3214EC077F60ED59] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB02'
    BEGIN
        ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK__AuditRec__3214EC077F60ED59;
        PRINT '- PK [PK__AuditRec__3214EC077F60ED59] Dropped';
    END;
END;

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecordFields' )
				AND  name LIKE N'PK__AuditRec%'
          )
BEGIN
    IF ( SELECT @@SERVERNAME ) = 'DB02VPRD'
    BEGIN
        ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK__AuditRec__3214EC0703317E3D;
        PRINT '- PK [PK__AuditRec__3214EC0703317E3D] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB02'
    BEGIN
        ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK__AuditRec__3214EC0703317E3D;
        PRINT '- PK [PK__AuditRec__3214EC0703317E3D] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB02'
    BEGIN
        ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK__AuditRec__3214EC0703317E3D;
        PRINT '- PK [PK__AuditRec__3214EC0703317E3D] Dropped';
    END;
END;
GO


--===================================================================================================
--[ADD PARTITION COLUMNs]
--===================================================================================================
PRINT '*****************************';
PRINT '*** Add Partition Columns ***';
PRINT '*****************************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF NOT EXISTS ( SELECT 1 FROM sys.columns WHERE name = N'CreatedDate' AND object_id = OBJECT_ID( N'dbo.AuditRecords' ))
BEGIN
    ALTER TABLE dbo.AuditRecords
    ADD CreatedDate DATETIME NOT NULL CONSTRAINT DF_AuditRecords_CreatedDate DEFAULT GETDATE();
	PRINT '- Column [CreatedDate] Created';
END;

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF NOT EXISTS ( SELECT 1 FROM sys.columns WHERE name = N'CreatedDate' AND object_id = OBJECT_ID( N'dbo.AuditRecordFields' ))
BEGIN
    ALTER TABLE dbo.AuditRecordFields
    ADD CreatedDate DATETIME NOT NULL CONSTRAINT DF_AuditRecordFields_CreatedDate DEFAULT GETDATE();
	PRINT '- Column [CreatedDate] Created';
END;
GO


--===================================================================================================
--[BACK FILL DATA]
--===================================================================================================
PRINT '**********************';
PRINT '*** Back Fill Data ***';
PRINT '**********************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE     ar
    SET        ar.CreatedDate = c.ClaimSubmissionDate
    FROM       dbo.AuditRecords AS ar
    INNER JOIN dbo.Claims AS c
            ON c.Id = ar.TableKey;

    COMMIT TRANSACTION;
	PRINT '- Back fill data Done';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE     arf
    SET        arf.CreatedDate = c.ClaimSubmissionDate
    FROM       dbo.AuditRecordFields AS arf
    INNER JOIN dbo.AuditRecords AS ar
            ON ar.Id = arf.AuditRecordId
    INNER JOIN dbo.Claims AS c
            ON c.Id = ar.TableKey;

    COMMIT TRANSACTION;
	PRINT '- Back fill data Done';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;
GO


--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_AuditRecords_CreatedDate' )
BEGIN
    DROP INDEX CIX_AuditRecords_CreatedDate ON dbo.AuditRecords;
	PRINT '- Index [CIX_AuditRecords_CreatedDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_AuditRecords_CreatedDate 
ON dbo.AuditRecords ( CreatedDate ASC ) ON [PRIMARY];
PRINT '- Index [CIX_AuditRecords_CreatedDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_AuditRecordFields_CreatedDate' )
BEGIN
    DROP INDEX CIX_AuditRecordFields_CreatedDate ON dbo.AuditRecordFields;
	PRINT '- Index [CIX_AuditRecordFields_CreatedDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_AuditRecordFields_CreatedDate 
ON dbo.AuditRecordFields ( CreatedDate ASC ) ON [PRIMARY];
PRINT '- Index [CIX_AuditRecordFields_CreatedDate] Created';
GO


--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_AuditRecords_Id_CreatedDate' )
BEGIN
    ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK_AuditRecords_Id_CreatedDate;
	PRINT '- PK [PK_AuditRecords_Id_CreatedDate] Dropped';
END;

ALTER TABLE dbo.AuditRecords
ADD CONSTRAINT PK_AuditRecords_Id_CreatedDate
    PRIMARY KEY NONCLUSTERED ( Id, CreatedDate ) ON [PRIMARY];
PRINT '- PK [PK_AuditRecords_Id_CreatedDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_AuditRecordFields_Id_CreatedDate' )
BEGIN
    ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK_AuditRecordFields_Id_CreatedDate;
	PRINT '- PK [PK_AuditRecordFields_Id_CreatedDate] Dropped';
END;

ALTER TABLE dbo.AuditRecordFields
ADD CONSTRAINT PK_AuditRecordFields_Id_CreatedDate
    PRIMARY KEY NONCLUSTERED ( Id, CreatedDate ) ON [PRIMARY];
PRINT '- PK [PK_AuditRecordFields_Id_CreatedDate] Created';
GO


--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

UPDATE STATISTICS dbo.AuditRecords;
PRINT '- Statistics Updated';

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

UPDATE STATISTICS dbo.AuditRecordFields;
PRINT '- Statistics Updated';
GO


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';

/* Time Taken = 
********************
!!! Script START !!!
********************
Running in Environment QA2-DB02...
***************************
*** Remove PK/Clustered ***
***************************
Working on table [dbo].[AuditRecords] ...
- PK [PK__AuditRec__3214EC077F60ED59] Dropped
Working on table [dbo].[AuditRecordFields] ...
- PK [PK__AuditRec__3214EC0703317E3D] Dropped
*****************************
*** Add Partition Columns ***
*****************************
Working on table [dbo].[AuditRecords] ...
- Column [CreatedDate] Created
Working on table [dbo].[AuditRecordFields] ...
- Column [CreatedDate] Created
**********************
*** Back Fill Data ***
**********************
Working on table [dbo].[AuditRecords] ...

(62 row(s) affected)
- Back fill data Done
Working on table [dbo].[AuditRecordFields] ...

(688 row(s) affected)
- Back fill data Done
******************************
*** Create Clustered Index ***
******************************
Working on table [dbo].[AuditRecords] ...
- Index [CIX_AuditRecords_CreatedDate] Created
Working on table [dbo].[AuditRecordFields] ...
- Index [CIX_AuditRecordFields_CreatedDate] Created
******************
*** Create PKs ***
******************
Working on table [dbo].[AuditRecords] ...
- PK [PK_AuditRecords_Id_CreatedDate] Created
Working on table [dbo].[AuditRecordFields] ...
- PK [PK_AuditRecordFields_Id_CreatedDate] Created
********************
*** Update Stats ***
********************
Working on table [dbo].[AuditRecords] ...
- Statistics Updated
Working on table [dbo].[AuditRecordFields] ...
- Statistics Updated
***********************
!!! Script COMPLETE !!!
***********************
*/
