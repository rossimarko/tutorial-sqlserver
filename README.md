# SQL Server DBA Comprehensive Tutorial

> **Modern SQL Server Database Administration Guide** - From fundamentals to advanced topics, focusing on SQL Server 2022+ best practices.

## 🎯 Overview

This repository provides a structured, hands-on learning path for SQL Server Database Administrators. Each module includes theory, practical T-SQL examples, performance comparisons, anti-patterns, DMV queries, and real-world scenarios.

## 🚀 Quick Start

### Prerequisites
- SQL Server 2022+ (or use provided Docker setup)
- SQL Server Management Studio (SSMS) 19+
- Basic T-SQL knowledge

### Setup Environment
```bash
# Using Docker (recommended for practice)
docker-compose up -d
```

See [Docker Setup Guide](./docker-setup/README.md) for detailed instructions.

---

## 📚 Learning Path

### **SECTION 1: FUNDAMENTALS**

Build a solid foundation in SQL Server architecture and core DBA responsibilities.

| Module | Topic | Key Concepts |
|--------|-------|--------------|
| [01](./01-installation-configuration/) | **Installation & Configuration** | Instance setup, memory config, CPU settings, sp_configure |
| [02](./02-database-creation/) | **Database Creation** | File management, filegroups, autogrowth, best practices |
| [03](./03-transaction-logs/) | **Transaction Logs** | Log architecture, VLFs, log management, truncation |
| [04](./04-backup-restore/) | **Backup & Restore** | Recovery models, backup strategies, point-in-time recovery |

**Estimated Time:** 8-10 hours

---

### **SECTION 2: PERFORMANCE FOUNDATIONS**

Master the core concepts that drive SQL Server performance.

| Module | Topic | Key Concepts |
|--------|-------|--------------|
| [05](./05-statistics/) | **Statistics** | Auto-update, histograms, cardinality estimation, maintenance |
| [06](./06-indexes/) | **Indexes** | Clustered, non-clustered, included columns, filtered, columnstore |
| [07](./07-execution-plans/) | **Execution Plans** | Reading plans, operators, costs, Query Store, Live Query Stats |
| [08](./08-query-optimization/) | **Query Optimization** | Joins, parameter sniffing, plan guides, hints, IQP features |

**Estimated Time:** 12-15 hours

---

### **SECTION 3: MAINTENANCE & MONITORING**

Learn proactive database maintenance and monitoring strategies.

| Module | Topic | Key Concepts |
|--------|-------|--------------|
| [09](./09-index-maintenance/) | **Index Maintenance** | Reorg vs rebuild, online operations, fill factor, resumable |
| [10](./10-data-maintenance/) | **Data Maintenance** | DBCC CHECKDB, consistency checks, update statistics jobs |
| [11](./11-shrink-operations/) | **Shrink Operations** | Why to avoid, alternatives, proper database sizing |
| [12](./12-monitoring-dmvs/) | **Monitoring & DMVs** | Performance DMVs, wait statistics, blocking detection |

**Estimated Time:** 10-12 hours

---

### **SECTION 4: ADVANCED TOPICS**

Deep dive into enterprise-level features and architecture.

| Module | Topic | Key Concepts |
|--------|-------|--------------|
| [13](./13-table-partitioning/) | **Table Partitioning** | Partition functions, schemes, sliding window, switch operations |
| [14](./14-locking-blocking/) | **Locking & Blocking** | Isolation levels, deadlocks, lock escalation, snapshot isolation |
| [15](./15-tempdb-optimization/) | **TempDB Optimization** | Multiple files, configuration, contention, system page latch |
| [16](./16-security-permissions/) | **Security & Permissions** | Roles, row-level security, Always Encrypted, auditing |
| [17](./17-high-availability/) | **High Availability** | Always On AG, failover clustering, log shipping, distributed AG |
| [18](./18-migrations-deployments/) | **Migrations & Deployments** | Schema compare, CI/CD, zero-downtime releases, SSDT |

**Estimated Time:** 20-25 hours

---

## 🛠️ Additional Resources

### [📝 Exercises](./exercises/)
Progressive hands-on labs with step-by-step solutions:
- **Beginner:** Basic administration tasks
- **Intermediate:** Performance tuning challenges
- **Advanced:** Complex troubleshooting scenarios
- **Expert:** Production-like incident response

### [🔧 Scripts](./scripts/)
Production-ready utility scripts:
- **Monitoring:** Wait stats, blocking, performance metrics
- **Maintenance:** Index optimization, statistics updates
- **Automation:** SQL Agent jobs, maintenance plans
- **Troubleshooting:** Quick diagnostic queries

### [🗄️ Sample Databases](./sample-databases/)
Pre-configured databases for practice:
- **TutorialDB:** General practice database
- **PerformanceTestDB:** Large dataset for performance tuning
- **HATestDB:** High availability scenarios

---

## 🎓 Learning Approach

Each module follows a consistent structure:

1. **📖 Theory** - Concise conceptual overview with diagrams
2. **💻 T-SQL Examples** - Practical code you can run
3. **📊 Performance Comparisons** - Before/after metrics
4. **⚠️ Anti-Patterns** - Common mistakes to avoid
5. **🔍 Monitoring Queries** - DMV queries for production
6. **🌐 Real-World Scenarios** - Actual DBA situations

---

## 🔥 Modern Features Covered

This tutorial emphasizes SQL Server 2022+ features:

- ✅ **Intelligent Query Processing (IQP)** - Adaptive joins, batch mode, memory grant feedback
- ✅ **Query Store** - Query performance tracking and regression detection
- ✅ **Automatic Tuning** - Automatic plan correction
- ✅ **In-Memory OLTP** - Memory-optimized tables and procedures
- ✅ **JSON Support** - Native JSON functions and indexing
- ✅ **Temporal Tables** - System-versioned tables for auditing
- ✅ **Resumable Operations** - Index rebuild/create, online operations
- ✅ **Accelerated Database Recovery (ADR)** - Faster recovery times
- ✅ **Parameter Sensitive Plan (PSP)** - Multiple plans per query
- ✅ **Degrees of Parallelism (DOP) Feedback** - Automatic parallelism tuning

---

## 📖 Recommended Reading Order

### For Complete Beginners
Follow the sections in order: 1 → 2 → 3 → 4

### For Developers Transitioning to DBA
Start with: 02, 03, 06, 07, 08, then fill in gaps

### For Performance Tuning Focus
Jump to: Section 2 (05-08), then 09, 12, 14

### For High Availability Specialists
Review: 04, 13, 15, 17, 18

---

## 🐳 Docker Environment

Quick setup for a complete SQL Server 2022 practice environment:

```bash
cd docker-setup
docker-compose up -d

# Connect to SQL Server
Server: localhost,1433
User: sa
Password: YourStrong@Passw0rd
```

Includes:
- SQL Server 2022 Developer Edition
- Pre-configured memory and CPU settings
- Sample databases loaded
- SQL Agent enabled

---

## 📊 Performance Testing

All performance examples include:
- ✅ Actual execution plans
- ✅ SET STATISTICS IO/TIME output
- ✅ Wait statistics analysis
- ✅ DMV query results
- ✅ Query Store metrics

---

## 🤝 Contributing

This is a learning resource. Suggestions for improvements are welcome!

---

## 📋 Module Completion Checklist

Track your progress:

**Section 1: Fundamentals**
- [ ] 01 - Installation & Configuration
- [ ] 02 - Database Creation
- [ ] 03 - Transaction Logs
- [ ] 04 - Backup & Restore

**Section 2: Performance Foundations**
- [ ] 05 - Statistics
- [ ] 06 - Indexes
- [ ] 07 - Execution Plans
- [ ] 08 - Query Optimization

**Section 3: Maintenance & Monitoring**
- [ ] 09 - Index Maintenance
- [ ] 10 - Data Maintenance
- [ ] 11 - Shrink Operations
- [ ] 12 - Monitoring & DMVs

**Section 4: Advanced Topics**
- [ ] 13 - Table Partitioning
- [ ] 14 - Locking & Blocking
- [ ] 15 - TempDB Optimization
- [ ] 16 - Security & Permissions
- [ ] 17 - High Availability
- [ ] 18 - Migrations & Deployments

**Practical Experience**
- [ ] Completed beginner exercises
- [ ] Completed intermediate exercises
- [ ] Completed advanced exercises
- [ ] Built a monitoring solution
- [ ] Performed performance tuning exercise
- [ ] Configured high availability setup

---

## 📞 Support & Community

- 📖 Official Docs: [Microsoft SQL Server Documentation](https://learn.microsoft.com/en-us/sql/)
- 💬 Questions: Open an issue in this repository
- 🐛 Found a bug in examples? Please report it!

---

## ⚖️ License

MIT License - Free to use for learning purposes.

---

## 🎯 Next Steps

1. Set up your environment using Docker
2. Start with [Module 01 - Installation & Configuration](./01-installation-configuration/)
3. Complete exercises after each module
4. Build your own monitoring and maintenance scripts
5. Practice on sample databases before production!

**Happy Learning! 🚀**
