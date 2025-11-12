# Module 15: TempDB Optimization

## 📖 Overview

TempDB configuration, multiple files, contention issues, and best practices.

---

## TempDB Configuration

```sql
-- Check TempDB files
SELECT
    name,
    physical_name,
    size * 8 / 1024 AS size_mb,
    growth,
    is_percent_growth
FROM tempdb.sys.database_files;

-- Best practices:
-- ✅ Number of files = CPU cores (up to 8)
-- ✅ All files same size
-- ✅ Fixed growth (not percentage)
-- ✅ Separate drive for TempDB

-- Add TempDB files (SQL Server 2022 auto-configures during install)
ALTER DATABASE tempdb ADD FILE
(
    NAME = tempdev2,
    FILENAME = 'T:\SQLTemp\tempdb2.ndf',
    SIZE = 8GB,
    FILEGROWTH = 512MB
);

-- Resize existing files to match
ALTER DATABASE tempdb MODIFY FILE
(
    NAME = tempdev,
    SIZE = 8GB,
    FILEGROWTH = 512MB
);
```

## TempDB Contention

```sql
-- Check for PFS/SGAM contention
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
AND wait_type LIKE '%2:%' -- TempDB (database_id = 2)
ORDER BY wait_time_ms DESC;

-- Solutions:
-- ✅ Multiple TempDB files (1 per core, max 8)
-- ✅ Trace flag 1117 (proportional growth - default in SQL 2016+)
-- ✅ Trace flag 1118 (uniform extents - default in SQL 2016+)
```

**Next Module:** [16 - Security & Permissions](../16-security-permissions/)
