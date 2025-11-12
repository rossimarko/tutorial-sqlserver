# Module 18: Migrations & Deployments

## 📖 Overview

Database migrations, schema compare, CI/CD pipelines, zero-downtime deployments, and SQL Server Data Tools (SSDT).

---

## Database Migrations

```sql
-- Assessment for migration
-- Use Data Migration Assistant (DMA)
-- Download from: https://www.microsoft.com/en-us/download/details.aspx?id=53595

-- Migration methods:
-- 1. Backup/Restore (simplest)
BACKUP DATABASE SourceDB TO DISK = 'D:\Backups\SourceDB.bak';
RESTORE DATABASE TargetDB FROM DISK = 'D:\Backups\SourceDB.bak' WITH MOVE ...;

-- 2. Detach/Attach (requires downtime)
EXEC sp_detach_db 'SourceDB';
-- Copy files to new server
CREATE DATABASE TargetDB ON (FILENAME = 'D:\Data\SourceDB.mdf') FOR ATTACH;

-- 3. Always On AG (zero downtime)
-- 4. Log Shipping (minimal downtime)
-- 5. Replication (complex but minimal downtime)
```

## Schema Compare & Sync

```sql
-- Generate schema comparison script
-- Use Visual Studio SQL Server Data Tools (SSDT)
-- Or third-party tools: Redgate SQL Compare, ApexSQL Diff

-- Manual schema tracking
-- Store CREATE scripts in version control (Git)
```

## CI/CD Pipeline

```yaml
# Azure DevOps / GitHub Actions example
# .github/workflows/deploy-database.yml

name: Deploy Database
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run database migrations
        run: |
          sqlcmd -S ${{ secrets.SQL_SERVER }} -d ProductionDB -i migrations/001_AddCustomerTable.sql
```

## Zero-Downtime Deployment

```sql
-- Pattern: Expand-Contract

-- Phase 1: EXPAND (add new column)
ALTER TABLE dbo.Orders ADD NewColumn VARCHAR(100) NULL;
GO

-- Phase 2: Dual-write (application writes to both columns)
-- Deploy application version that writes to both OldColumn and NewColumn

-- Phase 3: Backfill data
UPDATE dbo.Orders SET NewColumn = OldColumn WHERE NewColumn IS NULL;

-- Phase 4: Switch reads to new column
-- Deploy application version that reads from NewColumn

-- Phase 5: CONTRACT (remove old column)
ALTER TABLE dbo.Orders DROP COLUMN OldColumn;
```

## SSDT (SQL Server Data Tools)

- ✅ Database projects in Visual Studio
- ✅ Schema compare and sync
- ✅ Publish profiles for different environments
- ✅ Pre/post deployment scripts
- ✅ Integration with version control

```xml
<!-- Example: SSDT publish profile -->
<Project>
  <PropertyGroup>
    <TargetConnectionString>Server=ProductionSQL;Database=ProductionDB</TargetConnectionString>
    <BlockOnPossibleDataLoss>True</BlockOnPossibleDataLoss>
    <BackupDatabaseBeforeChanges>True</BackupDatabaseBeforeChanges>
  </PropertyGroup>
</Project>
```

## Best Practices

- ✅ Version control all schema changes
- ✅ Test migrations on staging first
- ✅ Automate deployments with CI/CD
- ✅ Use state-based (SSDT) or migration-based (Flyway) approach
- ✅ Always have rollback plan
- ✅ Zero-downtime patterns for production

---

## ✅ Module Completion Checklist

- [ ] Understand migration strategies
- [ ] Implement schema version control
- [ ] Set up CI/CD pipeline
- [ ] Practice zero-downtime deployments
- [ ] Use SSDT for database projects

---

**🎉 Congratulations! You've completed all 18 modules!**

**You're now a SQL Server DBA expert!**
