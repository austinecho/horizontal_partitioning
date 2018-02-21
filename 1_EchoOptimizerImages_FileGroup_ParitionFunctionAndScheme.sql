/*
DataTeam
Claims Partitioning

•	ADD New File Group
•	ADD Partition Function
•	ADD Partition Scheme

Run in DB01VPRD Equivilant 
*/
USE Claims;
GO

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01' BEGIN PRINT 'Running in Environment QA2-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================
PRINT '*** ADD FILE GROUP ***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'Claims_Archive' )
BEGIN 
	ALTER DATABASE Claims ADD FILEGROUP Claims_Archive;

	IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
	BEGIN
		--PROD --Note: N:\Data\Claims.MDF --PRIMARY
		ALTER DATABASE Claims ADD FILE ( NAME = 'Claims_Archive', FILENAME = N'N:\Data\Claims_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )
		TO FILEGROUP Claims_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01'
	BEGIN
		--QA1 --Note: N:\Data\Claims.MDF --PRIMARY
		ALTER DATABASE Claims ADD FILE ( NAME = 'Claims_Archive', FILENAME = N'N:\Data\Claims_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )
		TO FILEGROUP Claims_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
	BEGIN
		--DEV DT4 --Note: D:\Data\Claims\Claims_Primary.mdf --PRIMARY
		ALTER DATABASE Claims ADD FILE ( NAME = 'Claims_Archive', FILENAME = N'D:\Data\Claims\Claims_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )
		TO FILEGROUP Claims_Archive;
	END;

	PRINT '- Filegroup [Claims_Archive] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Filegroup with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION FUNCTION
--===================================================================================================
PRINT '*** ADD PARTITION FUNCTION ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_Claims_DATETIME_3Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_Claims_DATETIME_3Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2015-01-01 00:00:00.000' ); --3YearsFromThisYear

    PRINT '- Partition Function [PF_Claims_DATETIME_3Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Function with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION SCHEME
--===================================================================================================
PRINT '*** ADD PARTITION SCHEME ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_Claims_DATETIME_3Year' )
BEGIN
    CREATE PARTITION SCHEME PS_Claims_DATETIME_3Year AS PARTITION PF_Claims_DATETIME_3Year TO ( Claims_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_Claims_DATETIME_3Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_Claims_DATETIME_3Year';

SELECT * FROM sys.partition_schemes WHERE name = 'PS_Claims_DATETIME_3Year';
*/

/*
Running in Environment QA2-DB01...
*** ADD FILE GROUP ***
- Filegroup [Claims_Archive] added
*** ADD PARTITION FUNCTION ***
- Partition Function [PF_Claims_DATETIME_3Year] added
*** ADD PARTITION SCHEME ***
- Partition Scheme [PS_Claims_DATETIME_3Year] added
*/
