# Module 17: High Availability

## 📖 Overview

Always On Availability Groups, failover clustering, log shipping, and distributed availability groups.

---

## Always On Availability Groups (AG)

```sql
-- Prerequisites:
-- ✅ Windows Server Failover Clustering (WSFC)
-- ✅ SQL Server Enterprise Edition
-- ✅ FULL recovery model
-- ✅ Backup taken

-- Enable Always On
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'hadr enabled', 1;
RECONFIGURE;
-- Restart SQL Server service

-- Create availability group
CREATE AVAILABILITY GROUP AG_Production
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY)
FOR DATABASE ProductionDB
REPLICA ON
'SQL01' WITH (
    ENDPOINT_URL = 'TCP://SQL01.domain.com:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    FAILOVER_MODE = AUTOMATIC,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)
),
'SQL02' WITH (
    ENDPOINT_URL = 'TCP://SQL02.domain.com:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    FAILOVER_MODE = AUTOMATIC,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)
),
'SQL03' WITH (
    ENDPOINT_URL = 'TCP://SQL03.domain.com:5022',
    AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)
);

-- Monitor AG health
SELECT
    ag.name AS ag_name,
    ar.replica_server_name,
    ar.availability_mode_desc,
    ar.failover_mode_desc,
    ars.role_desc,
    ars.synchronization_health_desc
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states ars ON ar.replica_id = ars.replica_id;
```

## Failover Clustering

- ✅ Shared storage (SAN)
- ✅ Automatic failover
- ✅ Requires Windows Server Failover Clustering
- ⚠️ Downtime during failover (30-60 seconds)

## Log Shipping

```sql
-- Simple HA solution (lower cost than AG)
-- ✅ Works with Standard Edition
-- ✅ Multiple secondary servers
-- ⚠️ Manual failover
-- ⚠️ Data loss possible (RPO = log backup frequency)

-- Setup log shipping via SSMS or T-SQL
```

## SQL Server 2022 Enhancements

- ✅ Contained Availability Groups
- ✅ Distributed AG improvements
- ✅ AG on Kubernetes
- ✅ Link feature for Azure SQL Managed Instance

**Next Module:** [18 - Migrations & Deployments](../18-migrations-deployments/)
