/*
DataTeam
EchoOptimizerImages Partitioning

•	ADD New File Group
•	ADD Partition Function
•	ADD Partition Scheme

Run in DB01VPRD Equivilant 
*/
USE EchoOptimizerImages;
GO

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01' BEGIN PRINT 'Running in Environment QA2-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================
PRINT '*** ADD FILE GROUP ***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'EchoOptimizerImages_Archive' )
BEGIN 
	ALTER DATABASE EchoOptimizerImages ADD FILEGROUP EchoOptimizerImages_Archive;

	IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
	BEGIN
		--PROD --Note: N:\Data\EchoOptimizerImages.MDF --PRIMARY
		ALTER DATABASE EchoOptimizerImages ADD FILE ( NAME = 'EchoOptimizerImages_Archive', FILENAME = N'J:\MSSQL\EchoOptimizerImages_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )
		TO FILEGROUP EchoOptimizerImages_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'QA2-DB01'
	BEGIN
		--QA1 --Note: N:\Data\EchoOptimizerImages.MDF --PRIMARY
		ALTER DATABASE EchoOptimizerImages ADD FILE ( NAME = 'EchoOptimizerImages_Archive', FILENAME = N'J:\MSSQL\EchoOptimizerImages_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )
		TO FILEGROUP EchoOptimizerImages_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
	BEGIN
		--DEV DT4 --Note: D:\Data\EchoOptimizerImages\EchoOptimizerImages_Primary.mdf --PRIMARY
		ALTER DATABASE EchoOptimizerImages ADD FILE ( NAME = 'EchoOptimizerImages_Archive', FILENAME = N'D:\Data\EchoOptimizerImages\EchoOptimizerImages_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )
		TO FILEGROUP EchoOptimizerImages_Archive;
	END;

	PRINT '- Filegroup [EchoOptimizerImages_Archive] added';
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

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_EchoOptimizerImages_DATETIME_2Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_EchoOptimizerImages_DATETIME_2Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2016-01-01 00:00:00.000' ); --2YearsFromThisYear

    PRINT '- Partition Function [PF_EchoOptimizerImages_DATETIME_2Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Function with same name already exists !!';
END;
GO

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_EchoOptimizerImages_DATETIME_1Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_EchoOptimizerImages_DATETIME_1Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2017-01-01 00:00:00.000' ); --1YearsFromThisYear

    PRINT '- Partition Function [PF_EchoOptimizerImages_DATETIME_1Year] added';
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

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_EchoOptimizerImages_DATETIME_2Year' )
BEGIN
    CREATE PARTITION SCHEME PS_EchoOptimizerImages_DATETIME_2Year AS PARTITION PF_EchoOptimizerImages_DATETIME_2Year TO ( EchoOptimizerImages_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_EchoOptimizerImages_DATETIME_2Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_EchoOptimizerImages_DATETIME_1Year' )
BEGIN
    CREATE PARTITION SCHEME PS_EchoOptimizerImages_DATETIME_1Year AS PARTITION PF_EchoOptimizerImages_DATETIME_1Year TO ( EchoOptimizerImages_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_EchoOptimizerImages_DATETIME_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_EchoOptimizerImages_DATETIME_3Year';

SELECT * FROM sys.partition_schemes WHERE name = 'PS_EchoOptimizerImages_DATETIME_3Year';
*/

/*
Running in Environment QA2-DB01...
*** ADD FILE GROUP ***
- Filegroup [EchoOptimizerImages_Archive] added
*** ADD PARTITION FUNCTION ***
- Partition Function [PF_EchoOptimizerImages_DATETIME_3Year] added
*** ADD PARTITION SCHEME ***
- Partition Scheme [PS_EchoOptimizerImages_DATETIME_3Year] added
*/
