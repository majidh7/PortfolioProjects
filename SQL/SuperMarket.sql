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
USE supermarket;
GO

-- Creating tables
CREATE TABLE Customers (
  CustomerID int IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
  CustomerName nvarchar(50) NOT NULL,
  CustomerPhone nvarchar(15) NOT NULL,
  CustomerEmail nvarchar(50) NOT NULL,
  CustomerAddress nvarchar(100) NULL
);
GO
-- Creating Index for Customers table
CREATE INDEX idx_CustomerName ON Customers (CustomerName);
GO

-------------------------------------------------------------


CREATE TABLE Inventory (
  ProductID int IDENTITY(1,1) CONSTRAINT PK_Inventory PRIMARY KEY,
  ProductName nvarchar(50) NOT NULL,
  ProductDescription nvarchar(200) NULL,
  ProductPrice decimal(18,2) NOT NULL,
  ProductQuantity int NOT NULL
);
GO
--Creating Index for Inventory table
CREATE INDEX idx_ProductName ON Inventory (ProductName);
GO

-------------------------------------------------------------

CREATE TABLE Orders (
  OrderID int IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
  CustomerID int NOT NULL,
  OrderDate date NOT NULL,
  TotalAmount decimal(18,2) NOT NULL,
  CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
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
  CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Inventory (ProductID)
);
GO

-------------------------------------------------------------

CREATE TABLE CustomerIdentifier (
  CustomerID int,
  CustomerEmail nvarchar(50) NOT NULL,
  CONSTRAINT FK_CI_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);
GO

