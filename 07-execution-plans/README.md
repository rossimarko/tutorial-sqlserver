# Module 07: Execution Plans

## =Ö Overview

Execution plans show how SQL Server executes queries. Reading and understanding plans is essential for performance tuning. This module covers plan operators, Query Store, and SQL Server 2022 intelligent query processing features.

---

## Getting Execution Plans

```sql
-- Estimated execution plan (doesn't run query)
SET SHOWPLAN_XML ON;
GO
SELECT * FROM dbo.Orders WHERE CustomerID = 100;
GO
SET SHOWPLAN_XML OFF;
GO

-- Actual execution plan (runs query)
SET STATISTICS XML ON;
GO
SELECT * FROM dbo.Orders WHERE CustomerID = 100;
GO
SET STATISTICS XML OFF;
GO

-- In SSMS: Ctrl+L (Estimated), Ctrl+M (Actual - toggle on/off)

-- Include actual execution plan with query
SELECT * FROM dbo.Orders WHERE CustomerID = 100
OPTION (RECOMPILE, MAXDOP 1);
```

## Reading Execution Plans

**Key Metrics:**
- **Estimated Rows vs Actual Rows** - Cardinality estimation accuracy
- **Operator Cost** - Relative cost (% of query)
- **I/O Statistics** - Logical reads, physical reads
- **Warnings** - Yellow exclamation marks indicate issues

**Common Operators:**

| Operator | Type | Description | Cost |
|----------|------|-------------|------|
| **Clustered Index Scan** | Scan | Read entire table | High |
| **Index Seek** | Seek | Efficient lookup | Low |
| **Key Lookup** | Lookup | Fetch missing columns | Medium |
| **Nested Loops** | Join | Small result sets | Low-Medium |
| **Hash Match** | Join | Large result sets | Medium-High |
| **Sort** | Sort | Ordering data | High |
| **Table Spool** | Spool | Temporary storage | High |

```sql
-- Include query execution statistics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '2023-01-01';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/* Output example:
Table 'Orders'. Scan count 1, logical reads 1250...
Table 'Customers'. Scan count 1, logical reads 25...
SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 156 ms.
*/
```

## Query Store

**SQL Server 2022 Query Store enhancements:**
- Query Store for secondary replicas
- Query Store hints
- Query Store support for In-Memory OLTP

```sql
-- Enable Query Store
ALTER DATABASE ProductionDB SET QUERY_STORE = ON
(
    OPERATION_MODE = READ_WRITE,
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);

-- Check Query Store configuration
SELECT
    actual_state_desc,
    readonly_reason,
    current_storage_size_mb,
    max_storage_size_mb,
    query_capture_mode_desc
FROM sys.database_query_store_options;

-- Top 10 queries by duration
SELECT TOP 10
    q.query_id,
    qt.query_sql_text,
    rs.count_executions,
    rs.avg_duration / 1000 AS avg_duration_ms,
    rs.last_execution_time
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
ORDER BY rs.avg_duration DESC;

-- Find regressed queries
SELECT
    q.query_id,
    qt.query_sql_text,
    p.plan_id,
    rs.last_execution_time,
    rs.avg_duration / 1000 AS avg_duration_ms,
    rs.avg_logical_io_reads
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE rs.last_execution_time > DATEADD(HOUR, -24, GETDATE())
AND rs.avg_duration >
    (SELECT AVG(avg_duration) * 2
     FROM sys.query_store_runtime_stats
     WHERE plan_id = p.plan_id);

-- Force a specific plan (SQL 2022)
EXEC sp_query_store_force_plan @query_id = 123, @plan_id = 456;

-- SQL 2022: Query Store hints
EXEC sp_query_store_set_hints @query_id = 123, @hints = N'OPTION(RECOMPILE)';
```

## Intelligent Query Processing (IQP)

**SQL Server 2022 IQP Features:**

```sql
-- 1. Parameter Sensitive Plan (PSP) Optimization
-- Automatically creates multiple plans for different parameter values

-- 2. Memory Grant Feedback
-- Adjusts memory grants based on actual usage

-- 3. Degree of Parallelism (DOP) Feedback
-- Adjusts parallelism based on wait times

-- 4. Cardinality Estimation (CE) Feedback
-- Learns from estimation errors

-- Enable IQP features (default in SQL 2022, compat level 160)
ALTER DATABASE ProductionDB SET COMPATIBILITY_LEVEL = 160;

-- Check IQP usage
SELECT
    q.query_id,
    qt.query_sql_text,
    qp.query_plan,
    TRY_CAST(qp.query_plan AS XML).value(
        '(//StmtSimple/@StatementOptmLevel)[1]', 'VARCHAR(50)') AS opt_level
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan qp ON q.query_id = qp.query_id
WHERE qt.query_sql_text LIKE '%YourQuery%';
```

## Plan Cache

```sql
-- View cached plans
SELECT
    cp.objtype,
    cp.cacheobjtype,
    cp.size_in_bytes / 1024 AS size_kb,
    cp.usecounts,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS query_text,
    qp.query_plan
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
LEFT JOIN sys.dm_exec_query_stats qs ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE st.text NOT LIKE '%dm_exec_cached_plans%'
ORDER BY cp.usecounts DESC;

-- Clear plan cache (use cautiously!)
-- DBCC FREEPROCCACHE; -- Clears all
-- DBCC FREEPROCCACHE (plan_handle); -- Clear specific plan

-- Clear Query Store
-- ALTER DATABASE ProductionDB SET QUERY_STORE CLEAR;
```

## Common Plan Issues

**1. Missing Index (Table Scan)**
```sql
-- Bad: Table scan
SELECT * FROM dbo.LargeTable WHERE FilterColumn = 'Value';
-- Creates table scan operator, high cost

-- Fix: Create index
CREATE INDEX IX_LargeTable_FilterColumn ON dbo.LargeTable(FilterColumn);
```

**2. Key Lookup (Expensive Lookups)**
```sql
-- Bad: Index seek + key lookups
SELECT Column1, Column2, Column3, Column4
FROM dbo.Orders
WHERE CustomerID = 100;
-- Index seek on CustomerID, then lookup for Column2, Column3, Column4

-- Fix: Covering index
CREATE INDEX IX_Orders_CustomerID_Covering
ON dbo.Orders(CustomerID) INCLUDE (Column2, Column3, Column4);
```

**3. Implicit Conversion**
```sql
-- Bad: Implicit conversion (index not used)
SELECT * FROM dbo.Orders
WHERE OrderID = '12345'; -- OrderID is INT, parameter is VARCHAR

-- Fix: Use correct data type
SELECT * FROM dbo.Orders
WHERE OrderID = 12345;
```

**4. Parameter Sniffing**
```sql
-- Problem: Plan optimized for first execution parameter
CREATE PROCEDURE GetOrdersByCustomer @CustomerID INT
AS
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID;

-- Solutions:
-- Option 1: OPTION (RECOMPILE)
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID
OPTION (RECOMPILE);

-- Option 2: OPTION (OPTIMIZE FOR)
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID
OPTION (OPTIMIZE FOR (@CustomerID = 1000));

-- Option 3: Local variable (disables parameter sniffing)
DECLARE @LocalCustomerID INT = @CustomerID;
SELECT * FROM dbo.Orders WHERE CustomerID = @LocalCustomerID;

-- Option 4: SQL 2022 PSP (automatic)
-- Enabled by default with compat level 160
```

---

##  Module Completion Checklist

- [ ] Read and understand execution plans
- [ ] Identify common operators and costs
- [ ] Enable and use Query Store
- [ ] Understand IQP features in SQL 2022
- [ ] Recognize and fix common plan issues
- [ ] Use plan forcing when appropriate

**Next Module:** [08 - Query Optimization](../08-query-optimization/)
