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

PRINT 'Running in Environment ' + @@SERVERNAME + '...';

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================

PRINT '*** ADD FILE GROUP ***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'EchoOptimizerImages_Archive' )
BEGIN
    ALTER DATABASE EchoOptimizerImages ADD FILEGROUP EchoOptimizerImages_Archive;

    ALTER DATABASE EchoOptimizerImages
    ADD FILE ( NAME = 'EchoOptimizerImages_Archive'
             , FILENAME = N'D:\Data\EchoOptimizerImages\EchoOptimizerImages_Archive.NDF'
             , SIZE = 50MB
             , MAXSIZE = UNLIMITED
             , FILEGROWTH = 10MB )
    TO FILEGROUP EchoOptimizerImages_Archive;

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

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_EchoOptimizerImages_DATETIME_3Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_EchoOptimizerImages_DATETIME_3Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2015-01-01 00:00:00.000' ); --3YearsFromThisYear

    PRINT '- Partition Function [PF_EchoOptimizerImages_DATETIME_3Year] added';
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

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_EchoOptimizerImages_DATETIME_3Year' )
BEGIN
    CREATE PARTITION SCHEME PS_EchoOptimizerImages_DATETIME_3Year AS PARTITION PF_EchoOptimizerImages_DATETIME_3Year TO ( EchoOptimizerImages_Archive
                                                                                              , [PRIMARY] );

    PRINT '- Partition Scheme [PS_EchoOptimizerImages_DATETIME_3Year] added';
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
