# Module 16: Security & Permissions

## 📖 Overview

SQL Server security model, roles, row-level security, Always Encrypted, and auditing.

---

## Authentication & Authorization

```sql
-- Create SQL login
CREATE LOGIN AppUser WITH PASSWORD = 'StrongPassword123!';

-- Create database user
USE ProductionDB;
CREATE USER AppUser FOR LOGIN AppUser;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON dbo.Orders TO AppUser;

-- Database roles
ALTER ROLE db_datareader ADD MEMBER AppUser; -- Read all tables
ALTER ROLE db_datawriter ADD MEMBER AppUser; -- Write all tables
```

## Row-Level Security (RLS)

```sql
-- Create security predicate
CREATE FUNCTION dbo.fn_SecurityPredicate(@UserID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS result
WHERE @UserID = CAST(SESSION_CONTEXT(N'UserID') AS INT);
GO

-- Create security policy
CREATE SECURITY POLICY dbo.OrdersSecurityPolicy
ADD FILTER PREDICATE dbo.fn_SecurityPredicate(UserID)
ON dbo.Orders
WITH (STATE = ON);
GO

-- Set user context
EXEC sp_set_session_context @key = N'UserID', @value = 123;

-- User can only see their own orders
SELECT * FROM dbo.Orders; -- Filtered automatically
```

## Always Encrypted

```sql
-- Encrypt sensitive columns
ALTER TABLE dbo.Customers
ADD SSN VARBINARY(MAX) ENCRYPTED WITH (
    COLUMN_ENCRYPTION_KEY = CEK_Auto,
    ENCRYPTION_TYPE = DETERMINISTIC,
    ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
);
```

## SQL Server Audit

```sql
-- Create server audit
CREATE SERVER AUDIT ProductionAudit
TO FILE (FILEPATH = 'D:\SQLAudit\')
WITH (ON_FAILURE = CONTINUE);
GO

-- Create database audit specification
CREATE DATABASE AUDIT SPECIFICATION ProductionDB_Audit
FOR SERVER AUDIT ProductionAudit
ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.SensitiveTable BY public);
GO

-- Enable audit
ALTER SERVER AUDIT ProductionAudit WITH (STATE = ON);
ALTER DATABASE AUDIT SPECIFICATION ProductionDB_Audit WITH (STATE = ON);

-- Query audit logs
SELECT
    event_time,
    action_id,
    succeeded,
    database_name,
    schema_name,
    object_name,
    statement
FROM sys.fn_get_audit_file('D:\SQLAudit\*', DEFAULT, DEFAULT);
```

**Next Module:** [17 - High Availability](../17-high-availability/)
