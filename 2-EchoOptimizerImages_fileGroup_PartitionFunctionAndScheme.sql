/*
DataTeam
EDIStaging Partitioning

Add Partition Function | Add Partition Scheme
Run in DB01VPRD Equivilant 

--DEV: 2YearMin = 20150701, 2MonthMin = 20170715 (Estimate to match data quality)
--QA: (TBD)
--PROD: (TBD)

--Approximate Rule
SELECT CAST(DATEADD(MM,-24, GETDATE()) AS DATE)
SELECT CAST(DATEADD(MM,-2, GETDATE()) AS DATE)

--PROD (based on HPSDM EDIStaging start date)
SELECT CAST(DATEADD(MM,-24, '07/15/2017 00:00:00.000') AS DATE) AS TwoYearsPrior
SELECT CAST(DATEADD(MM,-2, '07/15/2017 00:00:00.000') AS DATE) AS TwoMonthsPrior
*/


USE [EDIStaging]

BEGIN

--EDI DB01VPRD

--ADD FILE GROUP

IF (SELECT @@SERVERNAME) = 'DB01VPRD'
	BEGIN
		PRINT 'Run in Environment DB01VPRD'
		--PROD --Note: N:\Data\EDIStaging.MDF --PRIMARY
		ALTER DATABASE [EDIStaging] ADD FILEGROUP [EDIStaging_Archive]
		ALTER DATABASE EDIStaging ADD FILE (name='EDIStaging_Archive', FILENAME = N'N:\Data\EDIStaging_Archive.NDF', SIZE = 60GB , MAXSIZE = UNLIMITED, FILEGROWTH = 10GB) TO FILEGROUP [EDIStaging_Archive]
		PRINT 'Filegroup added'
	END
ELSE
IF (SELECT @@SERVERNAME) = 'QA1-DB01'
	BEGIN
		PRINT 'Run in Environment QA1-DB01'
		--QA1 --Note: N:\Data\EDIStaging.MDF --PRIMARY
		ALTER DATABASE [EDIStaging] ADD FILEGROUP [EDIStaging_Archive]
		ALTER DATABASE EDIStaging ADD FILE (name='EDIStaging_Archive', FILENAME = N'N:\Data\EDIStaging_Archive.NDF', SIZE = 60GB , MAXSIZE = UNLIMITED, FILEGROWTH = 10GB) TO FILEGROUP [EDIStaging_Archive]
		PRINT 'Filegroup added'
	END
ELSE
IF (SELECT @@SERVERNAME) = 'DATATEAM4-DB01\DB01'
	BEGIN
		PRINT 'Run in Environment DATATEAM4-DB01\DB01'
		--DEV DT4 --Note: D:\Data\EDIStaging\EDIStaging_Primary.mdf --PRIMARY
		ALTER DATABASE [EDIStaging] ADD FILEGROUP [EDIStaging_Archive]
		ALTER DATABASE EDIStaging ADD FILE (name='EDIStaging_Archive', FILENAME = N'D:\Data\EDIStaging\EDIStaging_Archive.ndf', SIZE = 10GB , MAXSIZE = UNLIMITED, FILEGROWTH = 10GB) TO FILEGROUP [EDIStaging_Archive]
		PRINT 'Filegroup added'
	END
ELSE
	BEGIN PRINT 'Server name not found' END

--ADD PARTITION FUNCTION AND SCHEME 

IF (SELECT @@SERVERNAME) = 'DB01VPRD'
	BEGIN
		PRINT 'Run in Environment DB01VPRD'
		--PROD

		--[PARTITION FUNCTION]
		--DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2YearMin' ) )
		BEGIN
			CREATE PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin (DATETIME) --2YearsFromGETDATE()
			AS RANGE LEFT FOR VALUES ('2015-07-15 00:00:00.000')
		END

		--DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2MonthMin' ) )
		BEGIN
		CREATE PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin (DATETIME) --2MonthsFromGETDATE()
		AS RANGE LEFT FOR VALUES ('2017-05-15 00:00:00.000')
		END

		--[PARTITION SCHEME]
		--DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2YearMin' ) )
		BEGIN
			CREATE PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
			AS PARTITION PF_EDIStaging_DATETIME_2YearMin TO ([EDIStaging_Archive],[PRIMARY]) 
		END

		--DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2MonthMin' ) )
		BEGIN
			CREATE PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
			AS PARTITION PF_EDIStaging_DATETIME_2MonthMin TO ([EDIStaging_Archive],[PRIMARY]) 
		END

		PRINT 'Partition added'
	END
ELSE
IF (SELECT @@SERVERNAME) = 'QA1-DB01'
	BEGIN
		PRINT 'Run in Environment QA1-DB01'
		--QA1

		--[PARTITION FUNCTION]
		--DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2YearMin' ) )
		BEGIN
			CREATE PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin (DATETIME) --2YearsFromGETDATE()
			AS RANGE LEFT FOR VALUES ('2015-07-01 00:00:00.000')
		END

		--DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2MonthMin' ) )
		BEGIN
		CREATE PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin (DATETIME) --2MonthsFromGETDATE()
		AS RANGE LEFT FOR VALUES ('2015-07-15 00:00:00.000')
		END

		--[PARTITION SCHEME]
		--DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2YearMin' ) )
		BEGIN
			CREATE PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
			AS PARTITION PF_EDIStaging_DATETIME_2YearMin TO ([EDIStaging_Archive],[PRIMARY]) 
		END

		--DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2MonthMin' ) )
		BEGIN
			CREATE PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
			AS PARTITION PF_EDIStaging_DATETIME_2MonthMin TO ([EDIStaging_Archive],[PRIMARY]) 
		END
		
		PRINT 'Partition added'
	END
ELSE
IF (SELECT @@SERVERNAME) = 'DATATEAM4-DB01\DB01'
	BEGIN
		PRINT 'Run in Environment DATATEAM4-DB01\DB01'
		--DEV DT4

		--[PARTITION FUNCTION]
		--DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2YearMin' ) )
		BEGIN
			CREATE PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin (DATETIME) --2YearsFromGETDATE()
			AS RANGE LEFT FOR VALUES ('2015-07-01 00:00:00.000')
		END

		--DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2MonthMin' ) )
		BEGIN
		CREATE PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin (DATETIME) --2MonthsFromGETDATE()
		AS RANGE LEFT FOR VALUES ('2015-07-15 00:00:00.000')
		END

		--[PARTITION SCHEME]
		--DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2YearMin' ) )
		BEGIN
			CREATE PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
			AS PARTITION PF_EDIStaging_DATETIME_2YearMin TO ([EDIStaging_Archive],[PRIMARY]) 
		END

		--DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
		IF(NOT EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2MonthMin' ) )
		BEGIN
			CREATE PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
			AS PARTITION PF_EDIStaging_DATETIME_2MonthMin TO ([EDIStaging_Archive],[PRIMARY]) 
		END

		PRINT 'Partition added'
	END
ELSE
	BEGIN PRINT 'Server name not found' END

END



--Cleanup (Note: This cannot be run if indexes or tables are using the PF/PS - Those dependancies must be removed first)
/*
DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2YearMin
GO
DROP PARTITION SCHEME PS_EDIStaging_DATETIME_2MonthMin
GO
DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2YearMin
GO
DROP PARTITION FUNCTION PF_EDIStaging_DATETIME_2MonthMin
*/

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2YearMin'
SELECT * FROM sys.partition_functions WHERE name = 'PF_EDIStaging_DATETIME_2MonthMin'
SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2YearMin'
SELECT * FROM sys.partition_schemes WHERE name = 'PS_EDIStaging_DATETIME_2MonthMin'
*/