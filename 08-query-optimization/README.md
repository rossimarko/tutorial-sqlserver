# Module 08: Query Optimization

## =Ö Overview

Advanced query optimization techniques including joins, subqueries, CTEs, parameter sniffing, plan guides, and query hints.

---

## Join Optimization

```sql
-- Nested Loops (best for small result sets)
SELECT o.OrderID, c.CustomerName
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderID = 12345;
-- Optimizer chooses Nested Loops for single row lookup

-- Hash Match (best for large result sets)
SELECT o.OrderID, c.CustomerName
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID;
-- Optimizer chooses Hash Match for full table join

-- Merge Join (best for sorted data)
SELECT o.OrderID, p.ProductName
FROM dbo.Orders o
INNER JOIN dbo.OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN dbo.Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderID;
-- Optimizer may choose Merge Join if data is already sorted

-- Force specific join type (when optimizer is wrong)
SELECT o.OrderID, c.CustomerName
FROM dbo.Orders o
INNER LOOP JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
OPTION (MAXDOP 1);
-- INNER LOOP JOIN, INNER HASH JOIN, INNER MERGE JOIN
```

## Subqueries vs JOINs

```sql
-- Subquery (can be slow)
SELECT OrderID, TotalAmount
FROM dbo.Orders
WHERE CustomerID IN (SELECT CustomerID FROM dbo.Customers WHERE Country = 'USA');

-- JOIN (usually faster)
SELECT o.OrderID, o.TotalAmount
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA';

-- EXISTS vs IN
-- EXISTS (better for large tables)
SELECT o.OrderID
FROM dbo.Orders o
WHERE EXISTS (SELECT 1 FROM dbo.OrderDetails od WHERE od.OrderID = o.OrderID);

-- IN (better for small subquery result sets)
SELECT o.OrderID
FROM dbo.Orders o
WHERE o.CustomerID IN (SELECT CustomerID FROM dbo.VIPCustomers);
```

## CTEs and Temp Tables

```sql
-- CTE (good for readability, executed inline)
WITH CustomerOrders AS
(
    SELECT CustomerID, COUNT(*) AS OrderCount
    FROM dbo.Orders
    GROUP BY CustomerID
)
SELECT c.CustomerName, co.OrderCount
FROM dbo.Customers c
JOIN CustomerOrders co ON c.CustomerID = co.CustomerID;

-- Temp table (better for large intermediate results)
SELECT CustomerID, COUNT(*) AS OrderCount
INTO #CustomerOrders
FROM dbo.Orders
GROUP BY CustomerID;

CREATE INDEX IX_CustomerOrders ON #CustomerOrders(CustomerID);

SELECT c.CustomerName, co.OrderCount
FROM dbo.Customers c
JOIN #CustomerOrders co ON c.CustomerID = co.CustomerID;

DROP TABLE #CustomerOrders;

-- Table variable (best for small datasets < 100 rows)
DECLARE @RecentOrders TABLE (OrderID INT, OrderDate DATE);
INSERT INTO @RecentOrders
SELECT TOP 10 OrderID, OrderDate FROM dbo.Orders ORDER BY OrderDate DESC;

SELECT * FROM @RecentOrders;
```

## Parameter Sniffing

```sql
-- Problem: First execution parameter shapes plan
CREATE PROCEDURE GetOrders @CustomerID INT
AS
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID;

-- Solution 1: OPTION (RECOMPILE)
CREATE PROCEDURE GetOrders @CustomerID INT
AS
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID
OPTION (RECOMPILE);

-- Solution 2: OPTION (OPTIMIZE FOR)
CREATE PROCEDURE GetOrders @CustomerID INT
AS
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID
OPTION (OPTIMIZE FOR (@CustomerID = 1000)); -- Typical value

-- Solution 3: OPTION (OPTIMIZE FOR UNKNOWN)
CREATE PROCEDURE GetOrders @CustomerID INT
AS
SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID
OPTION (OPTIMIZE FOR UNKNOWN);

-- Solution 4: Local variable (disables parameter sniffing)
CREATE PROCEDURE GetOrders @CustomerID INT
AS
BEGIN
    DECLARE @LocalCustomerID INT = @CustomerID;
    SELECT * FROM dbo.Orders WHERE CustomerID = @LocalCustomerID;
END;

-- SQL 2022: Parameter Sensitive Plan (PSP) - Automatic!
-- Database compat level 160 enables PSP
ALTER DATABASE ProductionDB SET COMPATIBILITY_LEVEL = 160;
```

## Plan Guides

```sql
-- Create plan guide to apply hints without modifying code
EXEC sp_create_plan_guide
    @name = N'PlanGuide_GetOrders',
    @stmt = N'SELECT * FROM dbo.Orders WHERE CustomerID = @CustomerID',
    @type = N'OBJECT',
    @module_or_batch = N'dbo.GetOrders',
    @params = NULL,
    @hints = N'OPTION (RECOMPILE)';

-- View plan guides
SELECT * FROM sys.plan_guides;

-- Drop plan guide
EXEC sp_control_plan_guide N'DROP', N'PlanGuide_GetOrders';

-- SQL 2022: Query Store Hints (better alternative)
EXEC sp_query_store_set_hints @query_id = 123, @hints = N'OPTION(MAXDOP 4, RECOMPILE)';
```

## Query Hints

```sql
-- RECOMPILE (create new plan each execution)
SELECT * FROM dbo.Orders WHERE OrderDate > @Date
OPTION (RECOMPILE);

-- MAXDOP (limit parallelism)
SELECT * FROM dbo.LargeTable
OPTION (MAXDOP 4);

-- FORCE ORDER (use join order as written)
SELECT o.OrderID, c.CustomerName
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
OPTION (FORCE ORDER);

-- USE HINT (SQL 2016+)
SELECT * FROM dbo.Orders
OPTION (USE HINT('FORCE_LEGACY_CARDINALITY_ESTIMATION'));

-- Multiple hints
SELECT * FROM dbo.Orders
WHERE CustomerID = @CustomerID
OPTION (RECOMPILE, MAXDOP 1, OPTIMIZE FOR (@CustomerID = 100));
```

## Index Hints

```sql
-- Force index use (when optimizer chooses wrong index)
SELECT * FROM dbo.Orders WITH (INDEX(IX_Orders_OrderDate))
WHERE OrderDate > '2023-01-01';

-- Prevent index use
SELECT * FROM dbo.Orders WITH (INDEX(0)) -- Heap/Clustered only
WHERE OrderDate > '2023-01-01';

-- NOLOCK (read uncommitted - use cautiously!)
SELECT * FROM dbo.Orders WITH (NOLOCK)
WHERE CustomerID = 100;
```

## Set-Based vs Cursor/Loop

```sql
-- BAD: Cursor (row-by-row processing)
DECLARE @OrderID INT;
DECLARE order_cursor CURSOR FOR SELECT OrderID FROM dbo.Orders;
OPEN order_cursor;
FETCH NEXT FROM order_cursor INTO @OrderID;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE dbo.Orders SET ProcessedFlag = 1 WHERE OrderID = @OrderID;
    FETCH NEXT FROM order_cursor INTO @OrderID;
END;
CLOSE order_cursor;
DEALLOCATE order_cursor;

-- GOOD: Set-based operation
UPDATE dbo.Orders SET ProcessedFlag = 1;

-- When cursor is necessary, use FAST_FORWARD
DECLARE order_cursor CURSOR FAST_FORWARD FOR
    SELECT OrderID FROM dbo.Orders;
```

## SQL 2022 Features

```sql
-- 1. Approximate Percentile (fast, approximate)
SELECT
    CustomerID,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TotalAmount) AS MedianAmount,
    APPROX_PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY TotalAmount) AS P95Amount
FROM dbo.Orders
GROUP BY CustomerID;

-- 2. GREATEST/LEAST functions
SELECT
    OrderID,
    GREATEST(ShippingCost, HandlingCost, TaxAmount) AS HighestCost,
    LEAST(DiscountAmount, CouponAmount) AS LowestDiscount
FROM dbo.Orders;

-- 3. WINDOW aggregate function improvements
SELECT
    OrderID,
    OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER (
        PARTITION BY YEAR(OrderDate), MONTH(OrderDate)
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM dbo.Orders;
```

---

##  Module Completion Checklist

- [ ] Optimize JOIN strategies
- [ ] Use appropriate subquery techniques
- [ ] Understand parameter sniffing and solutions
- [ ] Implement plan guides and query hints
- [ ] Write set-based queries instead of cursors
- [ ] Leverage SQL 2022 optimization features

**Next Module:** [09 - Index Maintenance](../09-index-maintenance/)

---

**<‰ Congratulations! You've completed Section 2: Performance Foundations!**
