# Module 12: Monitoring & DMVs

## 📖 Overview

Dynamic Management Views (DMVs) for performance monitoring, wait statistics, blocking detection, and proactive monitoring.

---

## Wait Statistics

```sql
-- Top wait types
SELECT TOP 20
    wait_type,
    wait_time_ms / 1000.0 / 60 AS wait_time_minutes,
    waiting_tasks_count,
    wait_time_ms / waiting_tasks_count AS avg_wait_ms,
    CASE wait_type
        WHEN 'CXPACKET' THEN 'Parallelism coordination'
        WHEN 'PAGEIOLATCH_SH' THEN 'Reading data from disk'
        WHEN 'LCK_M_X' THEN 'Exclusive lock wait'
        WHEN 'WRITELOG' THEN 'Transaction log writes'
        ELSE wait_type
    END AS description
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE',
    'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH',
    'WAITFOR', 'LOGMGR_QUEUE', 'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH',
    'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT',
    'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT',
    'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'
)
ORDER BY wait_time_ms DESC;

-- Reset wait stats (after investigating issue)
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
```

## Blocking Detection

```sql
-- Find blocking sessions
SELECT
    blocking.session_id AS blocking_session,
    blocked.session_id AS blocked_session,
    blocked_sql.text AS blocked_text,
    blocking_sql.text AS blocking_text,
    blocked.wait_time / 1000 AS wait_time_seconds,
    blocked.wait_type
FROM sys.dm_exec_requests blocked
INNER JOIN sys.dm_exec_requests blocking ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle) blocked_sql
CROSS APPLY sys.dm_exec_sql_text(blocking.sql_handle) blocking_sql
WHERE blocked.blocking_session_id > 0;

-- Kill blocking session (use cautiously!)
-- KILL 123;
```

## Performance Monitoring

```sql
-- Top CPU queries
SELECT TOP 10
    total_worker_time / execution_count AS avg_cpu_time,
    total_worker_time,
    execution_count,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_worker_time DESC;

-- Top I/O queries
SELECT TOP 10
    (total_logical_reads + total_logical_writes) / execution_count AS avg_io,
    total_logical_reads,
    total_logical_writes,
    execution_count,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY avg_io DESC;
```

## Monitoring Checklist

- ✅ Monitor wait statistics daily
- ✅ Track blocking sessions
- ✅ Identify top resource consumers
- ✅ Check error log for issues
- ✅ Monitor disk space
- ✅ Review backup status

**Next Module:** [13 - Table Partitioning](../13-table-partitioning/)

---

**🎉 Congratulations! You've completed Section 3: Maintenance & Monitoring!**
