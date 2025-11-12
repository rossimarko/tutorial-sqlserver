# Module 05: Statistics

## =Ö Overview

Statistics are critical for query performance. The SQL Server Query Optimizer uses statistics to estimate row counts and generate efficient execution plans. This module covers statistics architecture, automatic management, manual maintenance, and troubleshooting.

---

## <¯ Key Concepts

- **Statistics**: Histograms showing data distribution
- **Cardinality Estimation**: Query Optimizer's row count predictions
- **Auto-Create/Auto-Update**: Automatic statistics management
- **Stale Statistics**: Outdated statistics causing poor plans
- **SQL Server 2022**: Enhanced cardinality estimation, CE feedback

---

## Statistics Fundamentals

```sql
-- View statistics for a table
DBCC SHOW_STATISTICS('dbo.Orders', 'PK_Orders');

-- Check all statistics on a table
SELECT
    s.name AS statistics_name,
    s.auto_created,
    s.user_created,
    s.no_recompute,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.modification_counter AS modifications_since_update
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id = OBJECT_ID('dbo.Orders');

-- Check for stale statistics
SELECT
    OBJECT_NAME(s.object_id) AS table_name,
    s.name AS statistics_name,
    sp.last_updated,
    sp.rows,
    sp.modification_counter,
    CAST(sp.modification_counter * 100.0 / NULLIF(sp.rows, 0) AS DECIMAL(5,2)) AS pct_modified,
    CASE
        WHEN sp.modification_counter > sp.rows * 0.20 THEN '=4 Very stale'
        WHEN sp.modification_counter > sp.rows * 0.10 THEN '=á Stale'
        ELSE ' Fresh'
    END AS status
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id > 100
ORDER BY pct_modified DESC;
```

## Auto-Create and Auto-Update Statistics

```sql
-- Check database settings
SELECT
    name,
    is_auto_create_stats_on,
    is_auto_update_stats_on,
    is_auto_update_stats_async_on
FROM sys.databases
WHERE name = DB_NAME();

-- Recommended settings for OLTP
ALTER DATABASE ProductionDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE ProductionDB SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE ProductionDB SET AUTO_UPDATE_STATISTICS_ASYNC ON; -- Reduces blocking

-- SQL Server 2022: Auto create statistics for filtered indexes
ALTER DATABASE SCOPED CONFIGURATION SET AUTO_CREATE_STATISTICS = ON;
```

## Manual Statistics Maintenance

```sql
-- Update all statistics on a table (full scan)
UPDATE STATISTICS dbo.Orders WITH FULLSCAN;

-- Update specific statistics
UPDATE STATISTICS dbo.Orders PK_Orders WITH FULLSCAN;

-- Update all statistics in database
EXEC sp_updatestats; -- Uses sampling, not fullscan

-- Update with sample rate
UPDATE STATISTICS dbo.Orders WITH SAMPLE 50 PERCENT;

-- Maintenance script for all user tables
USE ProductionDB;
GO

DECLARE @TableName NVARCHAR(255);
DECLARE table_cursor CURSOR FOR
    SELECT QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
    FROM sys.tables;

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Updating statistics: ' + @TableName;
    EXEC('UPDATE STATISTICS ' + @TableName + ' WITH FULLSCAN');
    FETCH NEXT FROM table_cursor INTO @TableName;
END

CLOSE table_cursor;
DEALLOCATE table_cursor;
```

## Cardinality Estimation

```sql
-- Check cardinality estimator version
SELECT name, value, value_in_use
FROM sys.database_scoped_configurations
WHERE name = 'LEGACY_CARDINALITY_ESTIMATION';

-- Use SQL 2022 CE (default)
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;

-- Force legacy CE (SQL 2012 and earlier) for compatibility
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON;

-- Query level CE hint
SELECT * FROM dbo.Orders
WHERE OrderDate > '2023-01-01'
OPTION (USE HINT('FORCE_LEGACY_CARDINALITY_ESTIMATION'));

-- SQL 2022: CE feedback (automatic)
-- Optimizer learns from estimation errors and adjusts
```

## Troubleshooting Statistics Issues

```sql
-- Find queries with estimation errors
SELECT TOP 20
    qs.query_hash,
    qs.execution_count,
    qs.total_rows,
    qs.last_rows,
    qs.min_rows,
    qs.max_rows,
    qs.total_grant_kb / qs.execution_count AS avg_grant_kb,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE qs.last_rows > 0
ORDER BY ABS(qs.last_rows - (qs.total_rows / qs.execution_count)) DESC;

-- Check for missing statistics
SELECT
    OBJECT_NAME(object_id) AS table_name,
    column_id,
    name AS column_name
FROM sys.columns
WHERE object_id > 100
AND column_id NOT IN (
    SELECT sc.column_id
    FROM sys.stats s
    JOIN sys.stats_columns sc ON s.object_id = sc.object_id AND s.stats_id = sc.stats_id
    WHERE s.object_id = sys.columns.object_id
);
```

## Best Practices

**DO:**
-  Enable AUTO_CREATE_STATISTICS
-  Enable AUTO_UPDATE_STATISTICS
-  Use AUTO_UPDATE_STATISTICS_ASYNC for OLTP
-  Update statistics after large data loads
-  Monitor statistics age and staleness

**DON'T:**
- L Disable auto-update statistics
- L Use NO_RECOMPUTE on statistics
- L Ignore cardinality estimation warnings
- L Forget to update stats after index rebuilds

---

##  Module Completion Checklist

- [ ] Understand statistics and histograms
- [ ] Enable automatic statistics management
- [ ] Monitor and identify stale statistics
- [ ] Implement manual statistics update procedures
- [ ] Understand cardinality estimation

**Next Module:** [06 - Indexes](../06-indexes/)
