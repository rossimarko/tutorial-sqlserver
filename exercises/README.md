# Hands-On Exercises

Progressive exercises from beginner to expert level.

---

## Beginner Exercises

### Exercise 1: Configure New Instance
**Objective:** Set up a production-ready SQL Server instance

**Tasks:**
1. Configure max server memory (assume 64 GB server)
2. Set MAXDOP to 8
3. Set cost threshold for parallelism to 50
4. Enable backup compression
5. Verify configuration

**Solution:** See [Module 01](../01-installation-configuration/)

### Exercise 2: Create Production Database
**Objective:** Create a database with proper file management

**Tasks:**
1. Create database with separate data and log files
2. Set up filegroups for tables and indexes
3. Configure appropriate autogrowth
4. Enable Accelerated Database Recovery
5. Set FULL recovery model

**Solution:** See [Module 02](../02-database-creation/)

---

## Intermediate Exercises

### Exercise 3: Performance Tuning Challenge
**Objective:** Optimize a slow-running query

**Scenario:** Query takes 30 seconds, uses table scans

**Tasks:**
1. Capture execution plan
2. Identify missing indexes
3. Create appropriate indexes
4. Measure improvement
5. Document before/after metrics

**Solution:** See [Module 06](../06-indexes/) and [Module 07](../07-execution-plans/)

### Exercise 4: Index Maintenance
**Objective:** Implement index maintenance strategy

**Tasks:**
1. Check fragmentation on all indexes
2. Create maintenance script (REORGANIZE < 30%, REBUILD > 30%)
3. Schedule via SQL Agent job
4. Update statistics after maintenance
5. Monitor execution time

**Solution:** See [Module 09](../09-index-maintenance/)

---

## Advanced Exercises

### Exercise 5: High Availability Setup
**Objective:** Configure Always On Availability Group

**Tasks:**
1. Set up Windows Server Failover Cluster
2. Enable Always On on both nodes
3. Create availability group with synchronous commit
4. Test failover
5. Monitor synchronization health

**Solution:** See [Module 17](../17-high-availability/)

### Exercise 6: Troubleshooting Production Issue
**Objective:** Diagnose and resolve blocking

**Scenario:** Application experiencing timeouts

**Tasks:**
1. Identify blocking sessions
2. Analyze blocking queries
3. Determine root cause
4. Implement solution (indexing, isolation level, query optimization)
5. Prevent recurrence

**Solution:** See [Module 14](../14-locking-blocking/) and [Module 12](../12-monitoring-dmvs/)

---

## Expert Exercises

### Exercise 7: Zero-Downtime Schema Change
**Objective:** Deploy schema change without downtime

**Tasks:**
1. Plan expand-contract deployment
2. Add new column (nullable)
3. Dual-write to old and new column
4. Backfill data
5. Switch application to new column
6. Remove old column

**Solution:** See [Module 18](../18-migrations-deployments/)

### Exercise 8: Performance Crisis Response
**Objective:** Respond to production performance degradation

**Scenario:** Server CPU at 100%, queries timing out

**Tasks:**
1. Identify top CPU consumers (DMVs)
2. Check for parameter sniffing
3. Check for missing/stale statistics
4. Check for blocking
5. Implement immediate fixes
6. Plan long-term improvements

**Solution:** Combine knowledge from [Module 05](../05-statistics/), [Module 08](../08-query-optimization/), [Module 12](../12-monitoring-dmvs/)

---

## Practice Scenarios

### Scenario 1: New Application Launch
**Context:** New e-commerce application launching next week

**Your Tasks:**
- Design database schema
- Set up indexes
- Configure backup strategy
- Implement monitoring
- Plan for scale

### Scenario 2: Legacy System Migration
**Context:** Migrate from SQL Server 2012 to 2022

**Your Tasks:**
- Assessment with DMA
- Test compatibility
- Plan migration approach
- Execute migration
- Validate and optimize

### Scenario 3: Performance Degradation
**Context:** Reports running slower over time

**Your Tasks:**
- Identify root cause
- Check index fragmentation
- Check statistics
- Review query plans
- Implement fixes

---

## Additional Resources

- 📖 Practice on [SQL Server sample databases](../sample-databases/)
- 🔧 Use [utility scripts](../scripts/) for diagnostics
- 🐳 Set up [Docker environment](../docker-setup/) for safe testing
