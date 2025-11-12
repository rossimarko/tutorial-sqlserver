# Sample Databases

Pre-configured databases for practice and testing.

---

## TutorialDB - General Practice Database

### Setup Script

```sql
-- File: setup-tutorialdb.sql
CREATE DATABASE TutorialDB;
GO

USE TutorialDB;
GO

-- Customers table
CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Country NVARCHAR(50),
    CreatedDate DATETIME2 DEFAULT SYSDATETIME()
);

-- Orders table
CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2 DEFAULT SYSDATETIME(),
    TotalAmount DECIMAL(19,4),
    Status NVARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);

-- OrderDetails table
CREATE TABLE dbo.OrderDetails
(
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT,
    UnitPrice DECIMAL(19,4),
    FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
);

-- Products table
CREATE TABLE dbo.Products
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50),
    Price DECIMAL(19,4),
    StockQuantity INT
);

-- Create indexes
CREATE INDEX IX_Orders_CustomerID ON dbo.Orders(CustomerID);
CREATE INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate);
CREATE INDEX IX_OrderDetails_OrderID ON dbo.OrderDetails(OrderID);
CREATE INDEX IX_OrderDetails_ProductID ON dbo.OrderDetails(ProductID);

-- Insert sample data
INSERT INTO dbo.Customers (CustomerName, Email, Country)
VALUES
    ('John Smith', 'john@example.com', 'USA'),
    ('Jane Doe', 'jane@example.com', 'Canada'),
    ('Bob Johnson', 'bob@example.com', 'UK'),
    ('Alice Williams', 'alice@example.com', 'USA');

INSERT INTO dbo.Products (ProductName, Category, Price, StockQuantity)
VALUES
    ('Laptop', 'Electronics', 999.99, 50),
    ('Mouse', 'Electronics', 29.99, 200),
    ('Keyboard', 'Electronics', 79.99, 150),
    ('Monitor', 'Electronics', 299.99, 75);

INSERT INTO dbo.Orders (CustomerID, OrderDate, TotalAmount, Status)
VALUES
    (1, '2023-01-15', 1099.98, 'Completed'),
    (2, '2023-02-20', 329.98, 'Completed'),
    (1, '2023-03-10', 79.99, 'Pending'),
    (3, '2023-03-25', 599.97, 'Completed');

PRINT 'TutorialDB created successfully!';
```

---

## PerformanceTestDB - Large Dataset for Performance Tuning

```sql
-- File: setup-performancetestdb.sql
CREATE DATABASE PerformanceTestDB;
GO

USE PerformanceTestDB;
GO

-- Large table for performance testing
CREATE TABLE dbo.LargeTable
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    DateColumn DATE,
    StatusCode INT,
    Amount DECIMAL(19,4),
    Description NVARCHAR(100),
    CreatedDate DATETIME2 DEFAULT SYSDATETIME()
);

-- Generate 1 million rows
;WITH Numbers AS
(
    SELECT TOP 1000000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS num
    FROM sys.all_columns a CROSS JOIN sys.all_columns b
)
INSERT INTO dbo.LargeTable (DateColumn, StatusCode, Amount, Description)
SELECT
    DATEADD(DAY, num % 365, '2023-01-01'),
    num % 10,
    CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(19,4)),
    'Description ' + CAST(num AS VARCHAR)
FROM Numbers;

PRINT 'PerformanceTestDB with 1M rows created successfully!';
```

---

## HATestDB - High Availability Testing

```sql
-- File: setup-hatestdb.sql
CREATE DATABASE HATestDB;
GO

ALTER DATABASE HATestDB SET RECOVERY FULL;
GO

-- Take initial backup to establish log chain
BACKUP DATABASE HATestDB TO DISK = 'NUL';
GO

PRINT 'HATestDB ready for Always On AG configuration';
```

---

## Usage Instructions

1. **Run setup scripts** in SQL Server Management Studio
2. **Modify as needed** for your learning objectives
3. **Practice techniques** from the tutorials
4. **Reset databases** by dropping and recreating

```sql
-- Reset database
DROP DATABASE IF EXISTS TutorialDB;
-- Then run setup script again
```

---

## Sample Queries for Practice

```sql
-- Practice index tuning
SELECT *
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate > '2023-01-01';

-- Practice aggregations
SELECT
    c.Country,
    COUNT(*) AS OrderCount,
    SUM(o.TotalAmount) AS TotalRevenue
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Country;

-- Practice window functions
SELECT
    OrderID,
    OrderDate,
    TotalAmount,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS OrderNumber,
    SUM(TotalAmount) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RunningTotal
FROM dbo.Orders;
```
