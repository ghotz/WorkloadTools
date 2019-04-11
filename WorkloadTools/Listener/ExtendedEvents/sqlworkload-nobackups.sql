-- IMPORTANT NOTE!
-- Normally Workloadtools adds filters specified in the JSON config file (e.g. on database name)
-- by replacing the {0} token in the session definition file; however, since it creates also the
-- WHERE clause in the replacement string, it can't be used in the following scenario i.e. you
-- will have to add any other custom filter directly as a predicate below in the WHERE clause.

CREATE EVENT SESSION [sqlworkload] ON {1}
ADD EVENT sqlserver.attention (
	ACTION(	
		package0.event_sequence, 
		sqlserver.client_app_name, 
		sqlserver.client_hostname, 
		sqlserver.database_id, 
		sqlserver.database_name, 
		sqlserver.{2}, 
		sqlserver.session_id, 
		sqlserver.sql_text
	)
),
ADD EVENT sqlserver.rpc_completed (
	SET collect_data_stream = (0),
	collect_output_parameters = (1),
	collect_statement = (1) 
	ACTION(
		package0.event_sequence, 
		sqlserver.client_app_name, 
		sqlserver.client_hostname, 
		sqlserver.database_id, 
		sqlserver.database_name, 
		sqlserver.{2}, 
		sqlserver.session_id
	) 
	WHERE (NOT [sqlserver].[like_i_sql_unicode_string]([statement],N'%backup database%')
	       AND NOT [sqlserver].[like_i_sql_unicode_string]([statement],N'%backup log%')
		   AND NOT [sqlserver].[like_i_sql_unicode_string]([statement],N'%DatabaseBackup%')
		   )
),
ADD EVENT sqlserver.sql_batch_completed (
	SET collect_batch_text = (1) 
	ACTION(
		package0.event_sequence, 
		sqlserver.client_app_name, 
		sqlserver.client_hostname, 
		sqlserver.database_id, 
		sqlserver.database_name, 
		sqlserver.{2}, 
		sqlserver.session_id
	) 
	WHERE (NOT [sqlserver].[like_i_sql_unicode_string]([batch_text],N'%backup database%')
		   AND NOT [sqlserver].[like_i_sql_unicode_string]([batch_text],N'%backup log%')
		   AND NOT [sqlserver].[like_i_sql_unicode_string]([batch_text],N'%DatabaseBackup%')
		   )
),
ADD EVENT sqlserver.user_event(
	ACTION(
		package0.event_sequence, 
		sqlserver.client_app_name, 
		sqlserver.client_hostname, 
		sqlserver.database_id, 
		sqlserver.database_name, 
		sqlserver.{2}, 
		sqlserver.session_id
	) 
    WHERE [sqlserver].[like_i_sql_unicode_string]([user_info],N'WorkloadTools%')
)
WITH (
	MAX_MEMORY = 40960 KB,
	EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY = 30 SECONDS,
	MAX_EVENT_SIZE = 0 KB,
	MEMORY_PARTITION_MODE = PER_CPU,
	TRACK_CAUSALITY = OFF,
	STARTUP_STATE = OFF
);


ALTER EVENT SESSION [sqlworkload] ON {1} STATE = START;