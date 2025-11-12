# Module 13: Table Partitioning

## 📖 Overview

Table partitioning for very large tables (VLDBs), partition functions, schemes, sliding window pattern, and partition switching.

---

## Partitioning Basics

```sql
-- Step 1: Create partition function (defines ranges)
CREATE PARTITION FUNCTION PF_OrderDate (DATE)
AS RANGE RIGHT FOR VALUES
('2023-01-01', '2023-04-01', '2023-07-01', '2023-10-01'); -- Quarterly partitions

-- Step 2: Create partition scheme (maps to filegroups)
CREATE PARTITION SCHEME PS_OrderDate
AS PARTITION PF_OrderDate
ALL TO ([PRIMARY]); -- Or specific filegroups

-- Step 3: Create partitioned table
CREATE TABLE dbo.Orders_Partitioned
(
    OrderID INT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT,
    TotalAmount DECIMAL(19,4),
    CONSTRAINT PK_Orders_Partitioned PRIMARY KEY (OrderID, OrderDate)
) ON PS_OrderDate(OrderDate);

-- Check partition distribution
SELECT
    $PARTITION.PF_OrderDate(OrderDate) AS partition_number,
    MIN(OrderDate) AS min_date,
    MAX(OrderDate) AS max_date,
    COUNT(*) AS row_count
FROM dbo.Orders_Partitioned
GROUP BY $PARTITION.PF_OrderDate(OrderDate)
ORDER BY partition_number;
```

## Sliding Window Pattern

```sql
-- Archive old partition (fast, metadata-only operation)
-- Step 1: Create staging table with same schema
CREATE TABLE dbo.Orders_Archive
(
    OrderID INT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT,
    TotalAmount DECIMAL(19,4),
    CONSTRAINT PK_Orders_Archive PRIMARY KEY (OrderID, OrderDate)
) ON [PRIMARY];

-- Step 2: Switch partition to staging table
ALTER TABLE dbo.Orders_Partitioned
SWITCH PARTITION 1 TO dbo.Orders_Archive;

-- Step 3: Drop old range, add new range
ALTER PARTITION FUNCTION PF_OrderDate()
MERGE RANGE ('2023-01-01'); -- Remove oldest

ALTER PARTITION FUNCTION PF_OrderDate()
SPLIT RANGE ('2024-01-01'); -- Add newest
```

## Benefits

- ✅ Fast archival (partition switching)
- ✅ Parallel query execution per partition
- ✅ Faster index maintenance (per partition)
- ✅ Better manageability for VLDBs
- ⚠️ Requires Enterprise Edition (Standard: limited)

**Next Module:** [14 - Locking & Blocking](../14-locking-blocking/)
