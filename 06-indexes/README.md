# Module 06: Indexes

## =Ö Overview

Indexes are the most important tool for query performance. This module covers clustered indexes, non-clustered indexes, included columns, filtered indexes, columnstore indexes, and SQL Server 2022 enhancements.

---

## Index Types

| Index Type | Structure | Use Case | Limitations |
|------------|-----------|----------|-------------|
| **Clustered** | B-tree, data sorted | Primary key, range queries | 1 per table |
| **Non-Clustered** | B-tree, points to data | Lookups, covering | Max 999 per table |
| **Columnstore** | Column-based compression | Analytics, DW | Different syntax |
| **Filtered** | Index with WHERE clause | Sparse columns | Requires predicates |
| **Full-Text** | Inverted index | Text search | Special syntax |

---

## Clustered Indexes

```sql
-- Create clustered index (usually on primary key)
CREATE CLUSTERED INDEX CIX_Orders_OrderID
ON dbo.Orders(OrderID);

-- Check clustered index
SELECT
    OBJECT_NAME(object_id) AS table_name,
    name AS index_name,
    type_desc,
    is_unique,
    fill_factor
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Orders')
AND type_desc = 'CLUSTERED';

-- Heap vs Clustered comparison
-- Heap (no clustered index):
--    Fast inserts
--   L Slow scans
--   L Forwarded records
-- Clustered:
--    Fast range queries
--    Ordered data
--   L Slower inserts (due to ordering)
```

## Non-Clustered Indexes

```sql
-- Basic non-clustered index
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON dbo.Orders(CustomerID);

-- Covering index with INCLUDE
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_Covering
ON dbo.Orders(CustomerID)
INCLUDE (OrderDate, TotalAmount);

-- Composite index
CREATE NONCLUSTERED INDEX IX_Orders_Date_Customer
ON dbo.Orders(OrderDate, CustomerID);

-- Index with filter
CREATE NONCLUSTERED INDEX IX_Orders_ActiveOnly
ON dbo.Orders(OrderDate)
WHERE Status = 'Active'; -- Only indexes active orders

-- Check index usage
SELECT
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
    s.user_seeks + s.user_scans + s.user_lookups AS total_reads,
    CASE
        WHEN s.user_updates > (s.user_seeks + s.user_scans + s.user_lookups) * 10
            THEN '  More writes than reads'
        ELSE ' Good'
    END AS assessment
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
ORDER BY total_reads DESC;
```

## Columnstore Indexes

```sql
-- Clustered columnstore (replaces clustered index)
CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales
ON dbo.FactSales;

-- Non-clustered columnstore (with rowstore table)
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders
ON dbo.Orders(OrderDate, CustomerID, TotalAmount);

-- Check columnstore compression
SELECT
    OBJECT_NAME(object_id) AS table_name,
    SUM(size_in_bytes) / 1024 / 1024 AS size_mb,
    SUM(size_in_bytes) / 1024 / 1024 / COUNT(DISTINCT partition_number) AS avg_partition_mb
FROM sys.column_store_segments
WHERE object_id = OBJECT_ID('dbo.FactSales')
GROUP BY object_id;

-- SQL 2022: Ordered clustered columnstore
CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales_Ordered
ON dbo.FactSales
ORDER (OrderDate);
```

## Missing Index DMVs

```sql
-- Find missing indexes
SELECT TOP 20
    OBJECT_NAME(d.object_id) AS table_name,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    s.user_seeks,
    s.user_scans,
    s.avg_user_impact,
    s.avg_total_user_cost,
    (s.user_seeks + s.user_scans) * s.avg_total_user_cost * s.avg_user_impact AS improvement_score
FROM sys.dm_db_missing_index_details d
JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle
WHERE d.database_id = DB_ID()
ORDER BY improvement_score DESC;

-- Generate CREATE INDEX statements
SELECT
    'CREATE NONCLUSTERED INDEX IX_' +
    OBJECT_NAME(d.object_id) + '_' +
    REPLACE(REPLACE(REPLACE(ISNULL(d.equality_columns,'') + ISNULL(d.inequality_columns,''), '[', ''), ']', ''), ',', '_') +
    ' ON ' + d.statement +
    ' (' + ISNULL(d.equality_columns,'') + ISNULL(d.inequality_columns, '') + ')' +
    ISNULL(' INCLUDE (' + d.included_columns + ')', '') + ';' AS create_index_statement
FROM sys.dm_db_missing_index_details d
WHERE d.database_id = DB_ID();
```

## Index Fragmentation

```sql
-- Check index fragmentation
SELECT
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000
            THEN '=4 Rebuild'
        WHEN ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 1000
            THEN '=á Reorganize'
        ELSE ' Good'
    END AS recommendation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

## Best Practices

**Index Design:**
-  Clustered index on sequential key (e.g., INT IDENTITY)
-  Non-clustered indexes on frequently filtered columns
-  Use INCLUDE for covering indexes
-  Filtered indexes for sparse data
- L Avoid over-indexing (too many indexes)
- L Don't index low-selectivity columns

**Columnstore:**
-  Use for fact tables in data warehouses
-  Use for analytics workloads
-  Batch size should be > 102,400 rows
- L Not ideal for OLTP with frequent updates

---

##  Module Completion Checklist

- [ ] Understand clustered vs non-clustered indexes
- [ ] Create covering indexes with INCLUDE
- [ ] Implement filtered indexes
- [ ] Use columnstore for analytics
- [ ] Monitor missing and unused indexes
- [ ] Check and address fragmentation

**Next Module:** [07 - Execution Plans](../07-execution-plans/)
