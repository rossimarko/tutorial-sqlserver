# Module 10: Data Maintenance

## 📖 Overview

Database consistency checks (DBCC CHECKDB), corruption detection, update statistics jobs, and proactive data maintenance strategies.

---

## DBCC CHECKDB

```sql
-- Full database consistency check
DBCC CHECKDB('ProductionDB') WITH NO_INFOMSGS, ALL_ERRORMSGS;

-- Physical check only (faster)
DBCC CHECKDB('ProductionDB') WITH PHYSICAL_ONLY, NO_INFOMSGS;

-- Schedule CHECKDB weekly
-- Use maintenance plans or SQL Agent jobs

-- Check last CHECKDB execution
DBCC DBINFO('ProductionDB') WITH TABLERESULTS;
```

## Update Statistics

```sql
-- Update all statistics with full scan
UPDATE STATISTICS dbo.Orders WITH FULLSCAN;

-- Auto-update settings
ALTER DATABASE ProductionDB SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE ProductionDB SET AUTO_UPDATE_STATISTICS_ASYNC ON;

-- sp_updatestats (all tables, sampled)
EXEC sp_updatestats;
```

## Best Practices

- ✅ Run DBCC CHECKDB weekly
- ✅ Enable AUTO_UPDATE_STATISTICS
- ✅ Update statistics after index maintenance
- ✅ Monitor for corruption
- ✅ Test restores regularly

**Next Module:** [11 - Shrink Operations](../11-shrink-operations/)
