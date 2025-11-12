-- Initial database setup for Docker environment
-- This script runs automatically when container starts for the first time

PRINT 'Setting up SQL Server 2022 tutorial environment...';

-- Configure server settings
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Max server memory (3.5 GB of 4 GB allocated to container)
EXEC sp_configure 'max server memory (MB)', 3584;
RECONFIGURE;

-- MAXDOP
EXEC sp_configure 'max degree of parallelism', 4;
RECONFIGURE;

-- Cost threshold for parallelism
EXEC sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;

-- Optimize for ad hoc workloads
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;

-- Backup compression default
EXEC sp_configure 'backup compression default', 1;
RECONFIGURE;

PRINT 'Server configuration complete!';

-- Create TutorialDB
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'TutorialDB')
BEGIN
    CREATE DATABASE TutorialDB;
    PRINT 'TutorialDB created successfully!';
END;

PRINT 'SQL Server 2022 tutorial environment ready!';
PRINT 'Connect using: Server=localhost,1433  User=sa  Password=YourStrong@Passw0rd';
