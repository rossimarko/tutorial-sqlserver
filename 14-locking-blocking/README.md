# Module 14: Locking & Blocking

## 📖 Overview

Lock types, isolation levels, deadlocks, lock escalation, and snapshot isolation.

---

## Isolation Levels

```sql
-- READ UNCOMMITTED (dirty reads allowed)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM dbo.Orders; -- Can read uncommitted data

-- READ COMMITTED (default, no dirty reads)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- REPEATABLE READ (no non-repeatable reads)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SERIALIZABLE (no phantom reads)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SNAPSHOT (row versioning, no blocking)
ALTER DATABASE ProductionDB SET ALLOW_SNAPSHOT_ISOLATION ON;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

-- READ COMMITTED SNAPSHOT (row versioning for READ COMMITTED)
ALTER DATABASE ProductionDB SET READ_COMMITTED_SNAPSHOT ON;
```

## Deadlocks

```sql
-- Find deadlocks
SELECT
    XDL.query('.') AS deadlock_graph
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_sessions s
    JOIN sys.dm_xe_session_targets t ON s.address = t.event_session_address
    WHERE s.name = 'system_health'
) AS data
CROSS APPLY target_data.nodes('//RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData(XDL);

-- Prevent deadlocks:
-- ✅ Access objects in same order
-- ✅ Keep transactions short
-- ✅ Use appropriate isolation level
-- ✅ Add indexes to reduce locking
```

## Lock Monitoring

```sql
-- Current locks
SELECT
    tl.resource_type,
    tl.resource_database_id,
    tl.resource_associated_entity_id,
    tl.request_mode,
    tl.request_status,
    tl.request_session_id
FROM sys.dm_tran_locks tl
WHERE tl.resource_database_id = DB_ID();

-- Blocking chains
EXEC sp_who2;
```

**Next Module:** [15 - TempDB Optimization](../15-tempdb-optimization/)
