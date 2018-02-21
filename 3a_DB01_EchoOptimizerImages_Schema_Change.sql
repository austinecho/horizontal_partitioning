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
USE Claims
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
--[REMOVE FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Remove FK ***';
PRINT '*****************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'AuditRecordField_AuditRecord'
                AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecordFields' ))
BEGIN
    ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT AuditRecordField_AuditRecord;
    PRINT '- FK [AuditRecordField_AuditRecord] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_AuditRecordFields_AuditRecords_Id'
                     AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecordFields' ))
BEGIN
    ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT FK_AuditRecordFields_AuditRecords_Id;
    PRINT '- FK [FK_AuditRecordFields_AuditRecords_Id] Dropped';
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
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecords' )
				AND  name LIKE N'PK__AuditRec%'
          )
BEGIN
    IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
    BEGIN
        ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK__AuditRec__3214EC077F60ED59;
        PRINT '- PK [PK__AuditRec__3214EC077F60ED59] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01'
    BEGIN
        ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK__AuditRec__3214EC077F60ED59;
        PRINT '- PK [PK__AuditRec__3214EC077F60ED59] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
    BEGIN
        ALTER TABLE dbo.AuditRecords DROP CONSTRAINT PK__AuditRec__3214EC070AD2A005;
        PRINT '- PK [PK__AuditRec__3214EC070AD2A005] Dropped';
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
    IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
    BEGIN
        ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK__AuditRec__3214EC0703317E3D;
        PRINT '- PK [PK__AuditRec__3214EC0703317E3D] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01'
    BEGIN
        ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK__AuditRec__3214EC0703317E3D;
        PRINT '- PK [PK__AuditRec__3214EC0703317E3D] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
    BEGIN
        ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT PK__AuditRec__3214EC0707020F21;
        PRINT '- PK [PK__AuditRec__3214EC0707020F21] Dropped';
    END;
END;

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.ClaimNotifications' )
				AND  name LIKE N'PK__ClaimNot%'
          )
BEGIN
    IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
    BEGIN
        ALTER TABLE dbo.ClaimNotifications DROP CONSTRAINT PK__ClaimNot__3214EC0729572725;
        PRINT '- PK [PK__ClaimNot__3214EC0729572725] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01'
    BEGIN
        ALTER TABLE dbo.ClaimNotifications DROP CONSTRAINT PK__ClaimNot__3214EC0729572725;
        PRINT '- PK [PK__ClaimNot__3214EC0729572725] Dropped';
    END;
    ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
    BEGIN
        ALTER TABLE dbo.ClaimNotifications DROP CONSTRAINT PK__ClaimNot__3214EC0729572725;
        PRINT '- PK [PK__ClaimNot__3214EC0729572725] Dropped';
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

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE     cn
    SET        cn.CreatedDate = c.ClaimSubmissionDate
    FROM       dbo.ClaimNotifications AS cn
    INNER JOIN dbo.Claims AS c
            ON c.Id = cn.ClaimId
    WHERE      cn.CreatedDate IS NULL;

    UPDATE     dbo.ClaimNotifications 
	SET        CreatedDate = '1753-01-01 00:00:00.000' 
	WHERE      CreatedDate IS NULL;

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
--[ALTER NULL COLUMN AND ADD DF]
--===================================================================================================
PRINT '************************************';
PRINT '*** Alter NULL Column And Add DF ***';
PRINT '************************************';

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

IF EXISTS (   SELECT 1
              FROM   sys.columns
              WHERE  name = 'CreatedDate'
                AND  object_id = OBJECT_ID( N'dbo.ClaimNotifications' )
                AND  is_nullable = 1 )
BEGIN
    ALTER TABLE dbo.ClaimNotifications ALTER COLUMN CreatedDate DATETIME NOT NULL;
    PRINT '- Column [CreatedDate] Changed to Not Null';
END;

IF NOT EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_ClaimNotifications_CreatedDate'
                    AND  parent_object_id = OBJECT_ID( N'dbo.ClaimNotifications' ))
BEGIN
    ALTER TABLE dbo.ClaimNotifications ADD CONSTRAINT DF_ClaimNotifications_CreatedDate DEFAULT GETDATE() FOR CreatedDate;
    PRINT '- DF [DF_ClaimNotifications_CreatedDate] Created';
END;
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
ON dbo.AuditRecords ( CreatedDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_Claims_DATETIME_3Year(CreatedDate);
PRINT '- Index [CIX_AuditRecords_CreatedDate] Created';

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_AuditRecordFields_CreatedDate' )
BEGIN
    DROP INDEX CIX_AuditRecordFields_CreatedDate ON dbo.AuditRecordFields;
	PRINT '- Index [CIX_AuditRecordFields_CreatedDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_AuditRecordFields_CreatedDate
ON dbo.AuditRecordFields ( CreatedDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_Claims_DATETIME_3Year(CreatedDate);
PRINT '- Index [CIX_AuditRecordFields_CreatedDate] Created';

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_ClaimNotifications_CreatedDate' )
BEGIN
    DROP INDEX CIX_ClaimNotifications_CreatedDate ON dbo.ClaimNotifications;
	PRINT '- Index [CIX_ClaimNotifications_CreatedDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_ClaimNotifications_CreatedDate
ON dbo.ClaimNotifications ( CreatedDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_Claims_DATETIME_3Year(CreatedDate);
PRINT '- Index [CIX_ClaimNotifications_CreatedDate] Created';
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
    PRIMARY KEY NONCLUSTERED ( Id, CreatedDate )
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_Claims_DATETIME_3Year(CreatedDate);
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
    PRIMARY KEY NONCLUSTERED ( Id, CreatedDate )
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_Claims_DATETIME_3Year(CreatedDate);
PRINT '- PK [PK_AuditRecordFields_Id_CreatedDate] Created';

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_ClaimNotifications_Id_CreatedDate' )
BEGIN
    ALTER TABLE dbo.ClaimNotifications DROP CONSTRAINT PK_ClaimNotifications_Id_CreatedDate;
	PRINT '- PK [PK_ClaimNotifications_Id_CreatedDate] Dropped';
END;

ALTER TABLE dbo.ClaimNotifications
ADD CONSTRAINT PK_ClaimNotifications_Id_CreatedDate
    PRIMARY KEY NONCLUSTERED ( Id, CreatedDate )
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_Claims_DATETIME_3Year(CreatedDate);
PRINT '- PK [PK_ClaimNotifications_Id_CreatedDate] Created';
GO


--===================================================================================================
--[CREATE UX]
--===================================================================================================
PRINT '***************************';
PRINT '*** Create Unique Index ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'UX_AuditRecords_Id' )
BEGIN
    DROP INDEX UX_AuditRecords_Id ON dbo.AuditRecords;
	PRINT '- Index [UX_AuditRecords_Id] Dropped';
END;

CREATE UNIQUE NONCLUSTERED INDEX UX_AuditRecords_Id
ON dbo.AuditRecords ( Id )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON [PRIMARY];
PRINT '- Index [UX_AuditRecords_Id] Created';
GO


--===================================================================================================
--[CREATE FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Create FK ***';
PRINT '*****************';

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

ALTER TABLE dbo.AuditRecordFields WITH NOCHECK
ADD CONSTRAINT FK_AuditRecordFields_AuditRecords_Id
    FOREIGN KEY ( AuditRecordId )
    REFERENCES dbo.AuditRecords ( Id ) ON DELETE CASCADE;
PRINT '- FK [FK_AuditRecordFields_AuditRecords_Id] Created';

ALTER TABLE dbo.AuditRecordFields CHECK CONSTRAINT FK_AuditRecordFields_AuditRecords_Id;
PRINT '- FK [FK_AuditRecordFields_AuditRecords_Id] Enabled';
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

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

UPDATE STATISTICS dbo.ClaimNotifications;
PRINT '- Statistics Updated';
GO


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';

/* Time Taken = 00:04:30(backfill) + 00:01:20(CIX) + 00:00:19(PK) + 00:00:16(others)
********************
!!! Script START !!!
********************
Running in Environment QA2-DB01...
*****************
*** Remove FK ***
*****************
Working on table [dbo].[AuditRecordFields] ...
- FK [AuditRecordField_AuditRecord] Dropped
***************************
*** Remove PK/Clustered ***
***************************
Working on table [dbo].[AuditRecords] ...
- PK [PK__AuditRec__3214EC077F60ED59] Dropped
Working on table [dbo].[AuditRecordFields] ...
- PK [PK__AuditRec__3214EC0703317E3D] Dropped
Working on table [dbo].[ClaimNotifications] ...
- PK [PK__ClaimNot__3214EC0729572725] Dropped
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

(1396993 row(s) affected)
- Back fill data Done
Working on table [dbo].[AuditRecordFields] ...

(5585021 row(s) affected)
- Back fill data Done
Working on table [dbo].[ClaimNotifications] ...

(0 row(s) affected)

(0 row(s) affected)
- Back fill data Done
************************************
*** Alter NULL Column And Add DF ***
************************************
Working on table [dbo].[ClaimNotifications] ...
- Column [CreatedDate] Changed to Not Null
- DF [DF_ClaimNotifications_CreatedDate] Created
******************************
*** Create Clustered Index ***
******************************
Working on table [dbo].[AuditRecords] ...
- Index [CIX_AuditRecords_CreatedDate] Created
Working on table [dbo].[AuditRecordFields] ...
- Index [CIX_AuditRecordFields_CreatedDate] Created
Working on table [dbo].[ClaimNotifications] ...
- Index [CIX_ClaimNotifications_CreatedDate] Created
******************
*** Create PKs ***
******************
Working on table [dbo].[AuditRecords] ...
- PK [PK_AuditRecords_Id_CreatedDate] Created
Working on table [dbo].[AuditRecordFields] ...
- PK [PK_AuditRecordFields_Id_CreatedDate] Created
Working on table [dbo].[ClaimNotifications] ...
- PK [PK_ClaimNotifications_Id_CreatedDate] Created
***************************
*** Create Unique Index ***
***************************
Working on table [dbo].[AuditRecords] ...
- Index [UX_AuditRecords_Id] Created
*****************
*** Create FK ***
*****************
Working on table [dbo].[AuditRecordFields] ...
- FK [FK_AuditRecordFields_AuditRecords_Id] Created
- FK [FK_AuditRecordFields_AuditRecords_Id] Enabled
********************
*** Update Stats ***
********************
Working on table [dbo].[AuditRecords] ...
- Statistics Updated
Working on table [dbo].[AuditRecordFields] ...
- Statistics Updated
Working on table [dbo].[ClaimNotifications] ...
- Statistics Updated
***********************
!!! Script COMPLETE !!!
***********************
*/
