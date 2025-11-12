# Module 11: Shrink Operations

## 📖 Overview

Why you should avoid shrinking databases, when it's acceptable, and better alternatives.

---

## Why Avoid Shrink

**Problems with SHRINKDATABASE/SHRINKFILE:**
- ❌ Causes massive index fragmentation
- ❌ Slows down performance significantly
- ❌ Database will grow back anyway
- ❌ Increases I/O and blocking

```sql
-- DON'T DO THIS:
DBCC SHRINKDATABASE(ProductionDB);
DBCC SHRINKFILE(ProductionDB_Data, 1000);
```

## When Shrink is Acceptable

**Only shrink when:**
1. One-time bulk delete (e.g., archival of old data)
2. Development/test environment
3. Followed by index rebuild

```sql
-- If you must shrink:
-- 1. Shrink file
DBCC SHRINKFILE(ProductionDB_Data, 10240); -- 10 GB

-- 2. IMMEDIATELY rebuild all indexes
ALTER INDEX ALL ON dbo.LargeTable REBUILD;

-- 3. Update statistics
UPDATE STATISTICS dbo.LargeTable WITH FULLSCAN;
```

## Better Alternatives

```sql
-- Alternative 1: Archive old data
DELETE FROM dbo.Orders WHERE OrderDate < '2020-01-01';

-- Alternative 2: Table partitioning (see Module 13)
-- Alternative 3: Proper initial sizing
-- Alternative 4: Implement data retention policies
```

**Next Module:** [12 - Monitoring & DMVs](../12-monitoring-dmvs/)
