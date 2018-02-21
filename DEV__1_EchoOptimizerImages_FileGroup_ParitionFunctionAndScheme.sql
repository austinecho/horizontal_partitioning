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

PRINT 'Running in Environment ' + @@SERVERNAME + '...';

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================

PRINT '*** ADD FILE GROUP ***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'Claims_Archive' )
BEGIN
    ALTER DATABASE Claims ADD FILEGROUP Claims_Archive;

    ALTER DATABASE Claims
    ADD FILE ( NAME = 'Claims_Archive'
             , FILENAME = N'D:\Data\Claims\Claims_Archive.NDF'
             , SIZE = 50MB
             , MAXSIZE = UNLIMITED
             , FILEGROWTH = 10MB )
    TO FILEGROUP Claims_Archive;

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
    CREATE PARTITION SCHEME PS_Claims_DATETIME_3Year AS PARTITION PF_Claims_DATETIME_3Year TO ( Claims_Archive
                                                                                              , [PRIMARY] );

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
