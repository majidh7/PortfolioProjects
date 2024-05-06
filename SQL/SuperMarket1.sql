-- Creating database:
CREATE DATABASE SuperMarket
ON
   (NAME = SMDF1, FILENAME = 'E:\Data\database\SuperMarket1.mdf', SIZE = 10MB, MAXSIZE = 100GB, FILEGROWTH = 20MB),
   (NAME = SMDF2, FILENAME = 'E:\Data\database\SuperMarket2.ndf', SIZE = 10MB, MAXSIZE = UNLIMITED, FILEGROWTH = 20MB)
LOG ON
   (NAME = SMLO1, FILENAME = 'E:\Data\database\SuperMarket1.ldf', SIZE = 100MB, MAXSIZE = 100GB, FILEGROWTH = 20MB),
   (NAME = SMLO2, FILENAME = 'E:\Data\database\SuperMarket2.ldf', SIZE = 50MB, MAXSIZE = 100GB, FILEGROWTH = 20MB);
GO

-- Use the database
USE Supermarket;
GO

-- Creating tables
CREATE TABLE Customers (
  CustomerID int IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
  Name nvarchar(50) NOT NULL,
  State Nvarchar(50) NOT NULL,
  City Nvarchar(50) NOT NULL,
  Phone nvarchar(15) NOT NULL,
  Email nvarchar(50) NOT NULL,
  Address nvarchar(100) NULL
);
GO

-- Creating Index for Customers table
CREATE INDEX idx_CustomerName ON Customers (Name);
GO

-------------------------------------------------------------
CREATE TABLE Employees (
  EmployeeID int IDENTITY(1,1) CONSTRAINT PK_Employees PRIMARY KEY,
  LastName nvarchar(30) NOT NULL,
  FirstName nvarchar(20) NOT NULL,
  Title nvarchar(50) NOT NULL,
  TittleOfCourtesy Nvarchar(5) NOT NULL,
  Birthdate datetime NOT NULL,
  Hiredate datetime NOT NULL,
  City nvarchar(30) NOT NULL,
  State nvarchar(20) NOT NULL,
  Address nvarchar(100) NOT NULL);
GO

-- Creating Index for Employees table
CREATE INDEX idx_EmployeeID ON Employees (EmployeeID);
GO

-------------------------------------------------------------
CREATE TABLE Products (
  ProductID int IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
  ProductName nvarchar(50) NOT NULL,
  Description nvarchar(200) NULL,
  Price decimal(18,2) NOT NULL,
  Quantity int NOT NULL
);
GO

--Creating Index for Products table
CREATE INDEX idx_ProductName ON Products (ProductName);
GO

-------------------------------------------------------------

CREATE TABLE Orders (
  OrderID int IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
  CustomerID int NOT NULL,
  EmployeeID int NOT NULL,
  OrderDate date NOT NULL,
  TotalAmount decimal(18,2) NOT NULL,
  CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
  CONSTRAINT FK_EmpoyeeID FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID)
);
GO

--Creating Index for Orders table
CREATE INDEX idx_OrderDate ON Orders (OrderDate);
GO

-------------------------------------------------------------

CREATE TABLE Payments (
  PaymentID int IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
  OrderID int NOT NULL,
  PaymentDate date NOT NULL,
  PaymentAmount decimal(18,2) NOT NULL,
  PaymentMethod nvarchar(20) CONSTRAINT CH_PaymentMethod CHECK (PaymentMethod IN ('Cash', 'Check', 'Bank Card')),
  CONSTRAINT FK_OrderI FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)
);
GO

--Creating Index for Payments table
CREATE INDEX idx_PaymentDate ON Payments (PaymentDate);
GO
-------------------------------------------------------------

CREATE TABLE OrderDetails (
  OrderID int,
  ProductID int,
  Quantity int NOT NULL,
  PRIMARY KEY (OrderID, ProductID),
  CONSTRAINT FK_OrderID FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
  CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);
GO

-------------------------------------------------------------

CREATE TABLE CustomerIdentifier (
  CustomerID int,
  CustomerEmail nvarchar(50) NOT NULL,
  CONSTRAINT FK_CI_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);
GO

-------------------------------------------------------------

-- Creating view for top selling products
DROP VIEW IF EXISTS Top_selling_Products

CREATE VIEW Top_selling_Products AS
SELECT TOP 20 P.ProductName, SUM(P.Quantity) AS TotalQuantity
FROM OrderDetails AS OD
JOIN Products AS P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalQuantity DESC;
GO


------------------------------
-- Creating view that compiles comprehensive profiles for each customer(Order history and contact info)
DROP VIEW IF EXISTS CustomersProfile

CREATE VIEW CustomersProfile AS
SELECT 
    C.CustomerID AS CustomerID, 
    C.Name AS CustomerName, 
    C.State, 
    C.City, 
    C.Phone, 
    C.Email, 
    C.Address,
    O.OrderID, 
    O.OrderDate, 
    O.TotalAmount
FROM Customers AS C
LEFT JOIN Orders AS O ON C.CustomerID = O.CustomerID;
GO

------------------------------
-- Creating view that shows the total sales each employee has made
DROP VIEW IF EXISTS EmployeeOrders 

CREATE VIEW EmployeeOrders AS 
SELECT
	E.EmployeeID,
	CONCAT(E.firstName, ' ', E.LastName) AS EmployeeName,
	(SELECT COUNT(O.OrderID) FROM Orders AS O WHERE o.EmployeeID = E.EmployeeID) AS OrderCount
FROM Employees AS E
GROUP BY E.EmployeeID, CONCAT(E.firstName, ' ', E.LastName);
GO

------------------------------
-- Creating view that analyzes sales trends for each product over time
DROP VIEW IF EXISTS TrendProducts

CREATE VIEW TrendProducts AS 
SELECT 
    P.ProductName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(OD.Quantity * P.Price) AS TotalSales
FROM Products AS P
JOIN OrderDetails AS OD ON P.ProductID = OD.ProductID
JOIN Orders AS O ON OD.OrderID = O.OrderID
GROUP BY P.ProductName, YEAR(O.OrderDate), MONTH(O.OrderDate);
GO
-------------------------------------------------------------


-- Creating STORED PROCEDURES for the database
/* Add new Customer */

CREATE PROCEDURE AddCustomer
    @Name NVARCHAR(50),
    @State NVARCHAR(50),
    @City NVARCHAR(50),
    @Phone NVARCHAR(15),
    @Email NVARCHAR(50),
    @Address NVARCHAR(100)
AS
BEGIN
    INSERT INTO Customers (Name, State, City, Phone, Email, Address)
    VALUES (@Name, @State, @City, @Phone, @Email, @Address);
END;

------------------------------
/* Update customer info */

CREATE PROCEDURE UpdateCustomer
	@CustomerID int,
	@Phone NVARCHAR(15),
	@Email NVARCHAR(50),
	@Address NVARCHAR(100)
AS
BEGIN
	UPDATE Customers
	SET PHONE = @Phone, Email = @Email, Address = @Address
	WHERE CustomerID = @CustomerID
END

------------------------------
/* Get new order */
CREATE PROCEDURE GetNewOrders
    @CustomerID INT
AS
BEGIN
    SELECT * FROM Orders
    WHERE CustomerID = @CustomerID;
END;

------------------------------
/* AddPayment */
CREATE PROCEDURE AddPayment
    @OrderID INT,
    @PaymentAmount DECIMAL(18, 2),
    @PaymentMethod NVARCHAR(20)
AS
BEGIN
    INSERT INTO Payments (OrderID, PaymentDate, PaymentAmount, PaymentMethod)
    VALUES (@OrderID, GETDATE(), @PaymentAmount, @PaymentMethod);
END;

-------------------------------------------------------------
-- Taking Backup from the database
BACKUP DATABASE SuperMarket
TO DISK = 'D:\\backup\\SuperMarket.bak'
WITH FORMAT,
MEDIANAME = 'SQLServerBackups',
NAME = 'Backup of SuperMarket';
GO
BACKUP LOG SuperMarket
TO DISK = 'E:\\backup\\SuperMarket_TailLog.trn'
WITH NORECOVERY;
GO


-------------------------------------------------------------
-- Inserting sample data into our database

INSERT INTO Customers 
(Name, State, City, Phone, Email, Address) VALUES 
('majid hasannejad', 'Tehran', 'Tahran', '09120000000', 'majidhasannejad@mailfa.com', 'Khalij Fars, Tehran'),
('mahdi hasani', 'Tehran', 'Tahran', '09121111111', 'mahdi@yahoo.com', 'Piruzi, Tehran'),
('shahin khodayi', 'Tehran', 'Tahran', '09122222222', 'shahin@hotmail.com', 'Tajrish, Tehran'),
('morteza karimi', 'Mashhad', 'Khorasan razavi', '09123333333', 'morteza@outlook.com', 'Emam reza, Mashhad'),
('ali alavi', 'Gilan', 'Rasht', '09124444444', 'ali@gmail.com', 'Shahrdari, Rasht');
GO

-------------------------------------------------------------
INSERT INTO Employees
(LastName, FirstName, Title, TittleOfCourtesy, BirthDate, HireDate, City, State, Address) VALUES
('Gholami','Sahra', 'CEO','Ms', '1990-01-01', '2010-01-01', 'Tehran', 'Tehran', 'Basij highway, Afsariye'),
('Mohammadi', 'Shahin', 'Sales Manager', 'Mr', '1895-02-02', '2020-02-02', 'Varamin', 'Tehran', 'Azadi st.'),
('Hashemi', 'Mahsa', 'Sales Manager', 'Mrs', '1999-03-03', '2022-03-03', 'Tehran', 'Tehran', 'Tehransar, Golha st.'),
('Alavi', 'Kamran', 'Vice President', 'Mr', '1989-04-04', '2005-04-04','Karaj', 'Alborz', 'Hesarak, Shohada st.'),
('Molayi', 'Zahra', 'Sales Representative', 'Mrs', '2000-05-05', '2019-05-05', 'Shahryar', 'Tehran', 'Shariati square'),
('Adham', 'Hamed', 'Sales Representative', 'Mr', '2001-06-06', '2023-06-06', 'Tehran', 'Tehran', 'Jordan');
GO

-------------------------------------------------------------
INSERT INTO Products (ProductName, Description, Price, Quantity) VALUES
('shir', 'shire mihan', 20000, 100),
('Tokhme morgh', '1 Shane Tokhme morgh', 100000, 50),
('Nan Tost', 'Toste 3nan' , 35000, 200),
('Chips', 'Chips chitoz', 20000, 80),
('Berenj', 'Berenj Hashemi', 120000, 60);
GO

-------------------------------------------------------------
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, TotalAmount) VALUES
(1, 6, '2023-03-01', 100000),
(2, 2, '2023-11-02', 200000),
(3, 5, '2023-08-03', 300000),
(4, 6, '2023-01-04', 400000),
(5, 5, '2023-11-01', 500000);
GO

-------------------------------------------------------------
INSERT INTO Payments (OrderID, PaymentDate, PaymentAmount, PaymentMethod) VALUES
(1, '2023-03-01', 1000000, 'Cash'),
(2, '2023-11-02', 2000000, 'Check'),
(3, '2023-08-03', 3000000, 'Cash'),
(4, '2023-01-04', 4000000, 'Bank Card'),
(5, '2023-11-01', 5000000, 'Bank Card'),
(3, '2023-10-06', 5000000, 'Bank Card'),
(2, '2023-01-07', 1000000, 'Cash');
GO

-------------------------------------------------------------
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(1, 4, 1),
(2, 2, 2),
(2, 3, 4),
(3, 1, 1),
(3, 5, 2),
(4, 4, 2),
(4, 5 ,1),
(5 ,3 ,2);
GO

-------------------------------------------------------------

INSERT INTO CustomerIdentifier (CustomerID, CustomerEmail) VALUES
(1, 'majid@gmail.com'),
(2, 'mahdi@yahoo.com'),
(3,'shahin@hotmail.com'),
(4, 'morteza@outlook.com'),
(5, 'ali@gmail.com');
GO