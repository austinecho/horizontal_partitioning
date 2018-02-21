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

PRINT 'Running in Environment ' + @@SERVERNAME + '...';

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

DECLARE @PKname AS sysname;
DECLARE @SQL AS NVARCHAR(4000);

--************************************************
PRINT 'Working on table [dbo].[AuditRecords] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecords' )
                AND  name LIKE N'PK__AuditRec%' )
BEGIN
    SELECT @PKname = name
    FROM   sys.objects
    WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
      AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecords' )
      AND  name LIKE N'PK__AuditRec%';

    SET @SQL = 'ALTER TABLE dbo.AuditRecords DROP CONSTRAINT ' + @PKname;

    EXECUTE sys.sp_executesql @stmt = @SQL;
    PRINT '- PK [' + @PKname + '] Dropped';
END;

--*****************************************************
PRINT 'Working on table [dbo].[AuditRecordFields] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecordFields' )
                AND  name LIKE N'PK__AuditRec%' )
BEGIN
    SELECT @PKname = name
    FROM   sys.objects
    WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
      AND  parent_object_id = OBJECT_ID( N'dbo.AuditRecordFields' )
      AND  name LIKE N'PK__AuditRec%';

    SET @SQL = 'ALTER TABLE dbo.AuditRecordFields DROP CONSTRAINT ' + @PKname;

    EXECUTE sys.sp_executesql @stmt = @SQL;
    PRINT '- PK [' + @PKname + '] Dropped';
END;

--******************************************************
PRINT 'Working on table [dbo].[ClaimNotifications] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.ClaimNotifications' )
                AND  name LIKE N'PK__ClaimNot%' )
BEGIN
    SELECT @PKname = name
    FROM   sys.objects
    WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
      AND  parent_object_id = OBJECT_ID( N'dbo.ClaimNotifications' )
      AND  name LIKE N'PK__ClaimNot%';

    SET @SQL = 'ALTER TABLE dbo.ClaimNotifications DROP CONSTRAINT ' + @PKname;

    EXECUTE sys.sp_executesql @stmt = @SQL;
    PRINT '- PK [' + @PKname + '] Dropped';
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

