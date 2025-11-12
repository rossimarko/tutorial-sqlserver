# Module 09: Index Maintenance

## 📖 Overview

Index maintenance is critical for optimal performance. This module covers fragmentation, reorganize vs rebuild, online operations, fill factor, and SQL Server 2022 resumable index operations.

---

## Index Fragmentation

```sql
-- Check fragmentation for all indexes
SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) + '.' + OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    ips.avg_page_space_used_in_percent,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 1000 THEN 'REORGANIZE'
        ELSE 'NO ACTION'
    END AS recommendation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

## Reorganize vs Rebuild

```sql
-- REORGANIZE (online, minimal logging)
ALTER INDEX IX_Orders_CustomerID ON dbo.Orders REORGANIZE;

-- REBUILD ONLINE (Enterprise Edition)
ALTER INDEX IX_Orders_CustomerID ON dbo.Orders
REBUILD WITH (ONLINE = ON, MAXDOP = 4);

-- SQL 2022: Resumable index rebuild
ALTER INDEX IX_Orders_CustomerID ON dbo.Orders
REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAX_DURATION = 60);
```

## Fill Factor & Best Practices

```sql
-- Set fill factor (90% full, 10% free)
CREATE INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate)
WITH (FILLFACTOR = 90);

-- Index maintenance schedule:
--  Reorganize: 10-30% fragmentation
--  Rebuild: > 30% fragmentation
--  Use ONLINE=ON for production
```

**Next Module:** [10 - Data Maintenance](../10-data-maintenance/)
