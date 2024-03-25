-- Get all columns from the tables Customers, Orders and Suppliers
SELECT *
FROM Customers;
GO

SELECT *
FROM Orders;
GO

SELECT *
FROM Suppliers;
GO

--------------------------------------------------------------
 -- Get all Customers alphabetically, by Country and name
SELECT CompanyName
FROM Customers
GROUP BY CompanyName, Country;
GO
--------------------------------------------------------------
--  Get all Orders by date
SELECT *
FROM Orders
ORDER BY OrderDate;
GO
--------------------------------------------------------------
-- Get the count of all Orders made during 1997
SELECT *
FROM Orders
WHERE YEAR(OrderDate) = '1997';
GO
--------------------------------------------------------------
-- Get the names of all the contact persons where the person is a manager, alphabetically
SELECT ContactName
FROM Customers
WHERE ContactTitle LIKE '%Manager%'
ORDER BY ContactName;
GO

--------------------------------------------------------------
-- Get all orders placed on the 19th of May, 1997
SELECT *
FROM Orders
WHERE OrderDate = '1997-05-19';
GO

--------------------------------------------------------------
-- Create a report for all the orders of 1996 and their Customers
SELECT *
FROM Orders AS O
JOIN Customers AS C
ON O.CustomerID = C.CustomerID
WHERE YEAR(O.OrderDate) = '1996';
GO

--------------------------------------------------------------
-- Create a report that shows the number of employees and customers from each city that has employees in it
SELECT COUNT(DISTINCT E.EmployeeID) AS Number_Of_Employees, COUNT(DISTINCT C.CustomerID) AS Number_Of_Customers, E.City
FROM Employees AS E
LEFT JOIN Customers AS C
ON E.City = c.City
GROUP BY E.City;
GO

--------------------------------------------------------------
-- Create a report that shows the number of employees and customers from each city that has customers in it
SELECT COUNT(DISTINCT E.EmployeeID) AS Number_Of_Employees, COUNT(DISTINCT C.CustomerID) AS Number_Of_Customers, C.city 
FROM Employees AS E
RIGHT JOIN Customers AS C
ON C.City = E.City
GROUP BY C.City;
GO

--------------------------------------------------------------
-- Create a report that shows the number of employees and customers from each city
SELECT C.City, E.City, COUNT(DISTINCT E.EmployeeID), COUNT(DISTINCT C.CustomerID)
FROM Employees AS E
FULL JOIN Customers AS C
ON C.City = E.City
GROUP BY C.City, E.City;
GO

--------------------------------------------------------------
-- Create a report that shows the order ids and the associated employee names for orders that shipped after the required date
SELECT OrderID, CONCAT(E.FirstName, ' ', E.LastName) AS EmployeeName
FROM Orders AS O
JOIN Employees AS E
ON o.EmployeeID = E.EmployeeID
WHERE O.RequiredDate < O.ShippedDate;
GO

--------------------------------------------------------------
-- Create a report that shows the total quantity of products ordered. Only show records for products for which the quantity ordered is fewer than 200
SELECT SUM(OD.Quantity) AS Total, P.ProductName
FROM [Order Details] AS OD
JOIN Products AS P
ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
HAVING SUM(OD.Quantity) < 200;
GO

--------------------------------------------------------------
-- Create a report that shows the total number of orders by Customer since December 31,  1996. The report should only return rows for which the total number of orders is greater than 15
SELECT COUNT(OrderID) AS Total, CustomerID
FROM Orders
WHERE OrderDate > '1996-12-31'
GROUP BY CustomerID
HAVING COUNT(OrderID) > 15;
GO

--------------------------------------------------------------
-- What were our total revenues in 1997
SELECT SUM((OD.UnitPrice)* OD.Quantity * (1.0 - OD.Discount)) AS Revenue
FROM Orders AS O
JOIN [Order Details] AS OD
ON O.OrderID = OD.OrderID
WHERE YEAR(O.OrderDate) = '1997';
GO

--------------------------------------------------------------
-- What is the total amount each customer has payed us so far
SELECT SUM((OD.UnitPrice)* OD.Quantity * (1.0 - OD.Discount)) AS Revenue, C.CompanyName
FROM Orders AS O
JOIN [Order Details] AS OD
ON O.OrderID = OD.OrderID
JOIN Customers AS C
ON O.CustomerID = C.CustomerID
GROUP BY C.CompanyName
ORDER BY Revenue

--------------------------------------------------------------
-- Find the 10 top selling products
SELECT TOP 10 WITH TIES SUM((OD.UnitPrice)* OD.Quantity * (1.0 - OD.Discount)) AS Sales, p.ProductName
FROM Products AS P
JOIN [Order Details] AS OD
ON OD.ProductID = P.ProductID
GROUP BY p.ProductName
ORDER BY Sales desc

--------------------------------------------------------------
-- Create a view with total revenues per customer
CREATE VIEW REV_PER_CUS AS
SELECT C.CustomerID, C.CompanyName, SUM((OD.UnitPrice)* OD.Quantity * (1.0 - OD.Discount)) as Revenue
FROM Orders AS O
JOIN Customers AS C
ON O.CustomerID = C.CustomerID
JOIN [Order Details] od
ON od.OrderID = o.OrderID
GROUP BY C.CustomerID, C.CompanyName;
GO

--------------------------------------------------------------
-- Which UK Customers have payed us more than 1000 dollars
SELECT SUM((OD.UnitPrice)* OD.Quantity * (1.0 - OD.Discount)) as Revenue, C.CompanyName, C.Country
FROM Customers AS C
JOIN Orders AS O
ON O.CustomerID = C.CustomerID
JOIN [Order Details] AS OD
ON OD.OrderID = O.OrderID
WHERE C.Country = 'UK'
GROUP BY C.CompanyName, C.Country
HAVING SUM((OD.UnitPrice)* OD.Quantity * (1.0 - OD.Discount)) > 1000