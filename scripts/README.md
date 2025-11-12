# Utility Scripts

Production-ready scripts for monitoring, maintenance, and troubleshooting.

---

## Monitoring Scripts

### 1. Performance Health Check
```sql
-- File: performance-health-check.sql
-- Comprehensive performance diagnostics

-- CPU Usage
SELECT TOP 10
    total_worker_time / execution_count AS avg_cpu_time,
    execution_count,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_worker_time DESC;

-- Memory Usage
SELECT
    (physical_memory_in_use_kb / 1024) AS sql_memory_used_mb,
    (locked_page_allocations_kb / 1024) AS locked_pages_mb,
    (total_virtual_address_space_kb / 1024) AS virtual_address_space_mb
FROM sys.dm_os_process_memory;

-- Wait Statistics
SELECT TOP 20
    wait_type,
    wait_time_ms / 1000.0 / 60 AS wait_time_minutes,
    waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE '%SLEEP%'
ORDER BY wait_time_ms DESC;
```

### 2. Blocking Detection
```sql
-- File: find-blocking.sql
SELECT
    blocking.session_id AS blocking_session,
    blocked.session_id AS blocked_session,
    blocked_sql.text AS blocked_text,
    blocking_sql.text AS blocking_text,
    blocked.wait_time / 1000 AS wait_time_seconds
FROM sys.dm_exec_requests blocked
INNER JOIN sys.dm_exec_requests blocking ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle) blocked_sql
CROSS APPLY sys.dm_exec_sql_text(blocking.sql_handle) blocking_sql;
```

### 3. Index Fragmentation Report
```sql
-- File: index-fragmentation-report.sql
SELECT
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 10 THEN 'REORGANIZE'
        ELSE 'NO ACTION'
    END AS recommendation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

---

## Maintenance Scripts

### 4. Index Maintenance
```sql
-- File: index-maintenance.sql
-- Auto-rebuild/reorganize based on fragmentation
DECLARE @SQL NVARCHAR(MAX);
DECLARE @FragThreshold FLOAT = 30.0;

DECLARE index_cursor CURSOR FOR
    SELECT
        'ALTER INDEX [' + i.name + '] ON [' + OBJECT_SCHEMA_NAME(ips.object_id) + '].[' + OBJECT_NAME(ips.object_id) + '] ' +
        CASE
            WHEN ips.avg_fragmentation_in_percent >= @FragThreshold THEN 'REBUILD WITH (ONLINE = ON)'
            ELSE 'REORGANIZE'
        END
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
    WHERE ips.avg_fragmentation_in_percent > 10
    AND ips.page_count > 1000;

OPEN index_cursor;
FETCH NEXT FROM index_cursor INTO @SQL;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @SQL;
    EXEC sp_executesql @SQL;
    FETCH NEXT FROM index_cursor INTO @SQL;
END;

CLOSE index_cursor;
DEALLOCATE index_cursor;

EXEC sp_updatestats;
```

### 5. Update Statistics
```sql
-- File: update-statistics.sql
EXEC sp_MSforeachtable 'UPDATE STATISTICS ? WITH FULLSCAN';
```

### 6. Backup All Databases
```sql
-- File: backup-all-user-databases.sql
DECLARE @name NVARCHAR(128);
DECLARE @path NVARCHAR(256) = 'D:\Backups\';
DECLARE @fileName NVARCHAR(256);
DECLARE @date NVARCHAR(20) = CONVERT(NVARCHAR, GETDATE(), 112);

DECLARE db_cursor CURSOR FOR
    SELECT name FROM sys.databases
    WHERE database_id > 4 AND state = 0;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @name;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @fileName = @path + @name + '_Full_' + @date + '.bak';
    BACKUP DATABASE @name TO DISK = @fileName WITH COMPRESSION, INIT;
    PRINT 'Backed up: ' + @name;
    FETCH NEXT FROM db_cursor INTO @name;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```

---

## Troubleshooting Scripts

### 7. Find Missing Indexes
```sql
-- File: find-missing-indexes.sql
SELECT TOP 20
    OBJECT_NAME(d.object_id) AS table_name,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    s.user_seeks + s.user_scans AS total_reads,
    s.avg_user_impact,
    'CREATE INDEX IX_' + OBJECT_NAME(d.object_id) + '_Missing ON ' +
    d.statement + ' (' + ISNULL(d.equality_columns,'') +
    ISNULL(d.inequality_columns,'') + ')' +
    ISNULL(' INCLUDE (' + d.included_columns + ')', '') AS create_index_statement
FROM sys.dm_db_missing_index_details d
JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle
WHERE d.database_id = DB_ID()
ORDER BY s.avg_user_impact DESC;
```

### 8. Find Unused Indexes
```sql
-- File: find-unused-indexes.sql
SELECT
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
    'DROP INDEX [' + i.name + '] ON [' + OBJECT_SCHEMA_NAME(i.object_id) + '].[' + OBJECT_NAME(i.object_id) + ']' AS drop_statement
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE i.type_desc = 'NONCLUSTERED'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
AND (s.user_seeks + s.user_scans + s.user_lookups = 0 OR s.index_id IS NULL)
AND s.user_updates > 0
ORDER BY s.user_updates DESC;
```

### 9. Check VLF Count
```sql
-- File: check-vlf-count.sql
SELECT
    DB_NAME(database_id) AS database_name,
    COUNT(*) AS vlf_count,
    CASE
        WHEN COUNT(*) > 1000 THEN 'CRITICAL'
        WHEN COUNT(*) > 500 THEN 'WARNING'
        ELSE 'OK'
    END AS status
FROM sys.dm_db_log_info(NULL)
GROUP BY database_id
ORDER BY vlf_count DESC;
```

### 10. Space Usage Report
```sql
-- File: database-space-usage.sql
SELECT
    DB_NAME(database_id) AS database_name,
    type_desc AS file_type,
    name AS logical_name,
    physical_name,
    (size * 8.0 / 1024) AS size_mb,
    (size * 8.0 / 1024 / 1024) AS size_gb,
    CASE is_percent_growth
        WHEN 1 THEN CAST(growth AS VARCHAR) + '%'
        ELSE CAST(growth * 8 / 1024 AS VARCHAR) + ' MB'
    END AS growth_setting
FROM sys.master_files
ORDER BY database_id, file_id;
```

---

## Quick Reference Commands

```sql
-- Kill blocking session
-- KILL session_id;  -- Replace 'session_id' with the actual session ID to terminate

-- Clear plan cache
-- DBCC FREEPROCCACHE;

-- Clear wait stats
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

-- Check database integrity
DBCC CHECKDB('DatabaseName') WITH NO_INFOMSGS;

-- Shrink log file (use cautiously!)
-- DBCC SHRINKFILE(LogFileName, TargetSizeMB);
```

---

## Automation

These scripts can be scheduled via:
- **SQL Server Agent Jobs** (recommended)
- **Windows Task Scheduler**
- **PowerShell scripts**
- **Azure Automation**
