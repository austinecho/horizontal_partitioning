/*----------------------------------------------------------------------------------
 INSTRUCTIONS 
------------------------------------------------------------------------------------
1. Check EchoTrak replication is working (Replication Monitor tracer)
2. Pause replication (Stop Synchronizing in Replication Monitor)
3. Run "PART 1" of the script
4. Start Snapshot Agent in Replication Monitor and wait until it completed
5. Resume replication (Start Synchronizing in Replication Monitor)
6. Wait until snapshot for 3 articles is delivered and check tracer
7. Run "PART 2" of the script
----------------------------------------------------------------------------------*/

-- PART 1
USE [EchoTrak]
GO

DECLARE @subscriber sysname

SET @subscriber = 
	CASE @@SERVERNAME
		WHEN 'QA1-DB01' THEN 'QA1-DB02.qa.echogl.net'
		WHEN 'QA2-DB01' THEN 'QA2-DB02.qa.echogl.net'
		WHEN 'QA3-DB01' THEN 'QA3-DB02.qa.echogl.net'
		WHEN 'QA4-DB01' THEN 'QA4-DB02.qa.echogl.net'
		WHEN 'DB01VPRD' THEN 'DB02VPRD'
	END

SELECT @subscriber as [Subscriber Server]

IF @subscriber IS NULL
BEGIN
	PRINT 'ERROR: Wrong environment or SQL Server.';
	RETURN;
END;

-- publication
EXEC sp_changepublication @publication = 'PublicationEchoTrak', @property = 'allow_anonymous', @value = 'false'
EXEC sp_changepublication @publication = 'PublicationEchoTrak', @property = 'immediate_sync', @value = 'false'
-- Make sure the DDL changes are carried over
EXEC sp_changepublication @publication = 'PublicationEchoTrak', @property = 'replicate_ddl', @value = '1'

-- article
EXEC sp_addarticle @publication = N'PublicationEchoTrak', @article = N'dbo.tblLoadCustomer', @source_owner = N'dbo', @source_object = N'tblLoadCustomer', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'truncate', @schema_option = 0x000000000803109F, @identityrangemanagementoption = N'manual', @destination_table = N'tblLoadCustomer', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dbotblLoadCustomer]', @del_cmd = N'CALL [sp_MSdel_dbotblLoadCustomer]', @upd_cmd = N'SCALL [sp_MSupd_dbotblLoadCustomer]', @force_invalidate_snapshot = 1
EXEC sp_addsubscription @publication = N'PublicationEchoTrak', @subscriber = @subscriber, @destination_db = N'EchoTrak', @subscription_type = N'Push', @sync_type = N'automatic', @article = N'dbo.tblLoadCustomer', @subscriber_type = 0, @reserved='Internal'

EXEC sp_addarticle @publication = N'PublicationEchoTrak', @article = N'dbo.tblLoadStop', @source_owner = N'dbo', @source_object = N'tblLoadStop', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'truncate', @schema_option = 0x000000000803109F, @identityrangemanagementoption = N'manual', @destination_table = N'tblLoadStop', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dbotblLoadStop]', @del_cmd = N'CALL [sp_MSdel_dbotblLoadStop]', @upd_cmd = N'SCALL [sp_MSupd_dbotblLoadStop]', @force_invalidate_snapshot = 1
EXEC sp_addsubscription @publication = N'PublicationEchoTrak', @subscriber = @subscriber, @destination_db = N'EchoTrak', @subscription_type = N'Push', @sync_type = N'automatic', @article = N'dbo.tblLoadStop', @subscriber_type = 0, @reserved='Internal'




/*
-- PART 2
-- publication
EXEC sp_changepublication @publication = 'PublicationEchoTrak', @property = 'immediate_sync', @value = 'true'
EXEC sp_changepublication @publication = 'PublicationEchoTrak', @property = 'allow_anonymous', @value = 'true'
 --Make sure the DDL changes are not carried over
EXEC sp_changepublication @publication = 'PublicationEchoTrak', @property = 'replicate_ddl', @value = '0'
*/

GO