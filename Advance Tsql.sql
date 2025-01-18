ADVANCE TSQL


--1. STORED PROCEDURE

--2. USE DYNAMIC SQL WITH EXEC AND SP-EXECUTE-SQL

--3. CREATE USER-DEFINED FUNCTIONS
	--INLINE TABLE-VALUED FUNCTIONS
CREATE FUNCTION SalesLT.ProductsListPrice(@cost money)  
RETURNS TABLE  
AS  
RETURN  
    SELECT ProductID, Name, ListPrice  
    FROM SalesLT.Product  
    WHERE ListPrice > @cost;

When the table-valued function is run with a value for the parameter, then all products with a unit price more than this value will be returned.

The following code uses the table-valued function in place of a table.

SELECT Name, ListPrice  
FROM SalesLT.ProductsListPrice(500);

	--MULTI-STATEMENT TABLE-VALUED FUNCTIONS
--Unlike the inline TVF, a multi-statement table-valued function (MSTVF) can have more than one statement and has different syntax requirements.

--Notice how in the following code, we use a BEGIN/END in addition to RETURN:

CREATE FUNCTION Sales.mstvf_OrderStatus ()
RETURNS
@Results TABLE
     ( CustomerID int, OrderDate datetime )
AS
BEGIN
     INSERT INTO @Results
     SELECT SC.CustomerID, OrderDate
     FROM Sales.Customer AS SC
     INNER JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
     WHERE Status >= 5
 RETURN;
END;

--Once created, you reference the MSTVF in place of a table just like with the previous inline function above.
-- You can also reference the output in the FROM clause and join it with other tables.

SELECT *
FROM Sales.mstvf_OrderStatus();


--4. Scalar user-defined functions
--A scalar user-defined function returns only one value unlike table-valued functions and therefore is often used for simple, frequent statements.

--Here's an example to get the product list price for a specific product on a certain day:


CREATE FUNCTION dbo.ufn_GetProductListPrice
(@ProductID [int], @OrderDate [datetime])
RETURNS [money] 
AS 
BEGIN
    DECLARE @ListPrice money;
        SELECT @ListPrice = plph.[ListPrice]
        FROM [Production].[Product] p 
        INNER JOIN [Production].[ProductListPriceHistory] plph 
        ON p.[ProductID] = plph.[ProductID] 
            AND p.[ProductID] = @ProductID 
            AND StartDate = @OrderDate
    RETURN @ListPrice;
END;
GO

---For this function, both parameters must be provided to get the value.
-- Depending on the function, you can list the function in the SELECT statement in a more complex query.

SELECT dbo.ufn_GetProductListPrice (707, '2011-05-31')

/*Bind function to referenced objects
SCHEMABINDING is optional when creating the function. When you specify SCHEMABINDING, it binds the function to the referenced objects, and then objects can't be modified without also modifying the function. The function must first be modified or dropped to remove dependencies before modifying the object.

SCHEMABINDING is removed if any of the following occur:

The function is dropped
The function is modified with ALTER statement without specifying SCHEMABINDING
*/


/*Summary
Completed
100 XP
3 minutes
As demonstrated in this module, stored procedures offer several benefits including:

Code reuse
Security
Quality improvements
Performance improvements
Reduced maintenance
In this module, you've learned how to:

Execute stored procedures.
Pass parameters to procedures.
Create simple stored procedures using a SELECT statement.
Construct and execute dynamic SQL with EXEC and sp_executesql.
Create simple user-defined functions and write queries against them.
