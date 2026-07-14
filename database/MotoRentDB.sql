-- =============================================
-- MOTORENT - Motorbike Rental Management System
-- Database: SQL Server
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'MotoRentDB')
BEGIN
    CREATE DATABASE MotoRentDB;
END
GO

USE MotoRentDB;
GO

-- =============================================
-- DROP TABLES (if exist) in correct order
-- =============================================
IF OBJECT_ID('Reviews', 'U') IS NOT NULL DROP TABLE Reviews;
IF OBJECT_ID('Payments', 'U') IS NOT NULL DROP TABLE Payments;
IF OBJECT_ID('RentalOrderDetails', 'U') IS NOT NULL DROP TABLE RentalOrderDetails;
IF OBJECT_ID('RentalOrders', 'U') IS NOT NULL DROP TABLE RentalOrders;
IF OBJECT_ID('MotorbikeImages', 'U') IS NOT NULL DROP TABLE MotorbikeImages;
IF OBJECT_ID('Motorbikes', 'U') IS NOT NULL DROP TABLE Motorbikes;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Brands', 'U') IS NOT NULL DROP TABLE Brands;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
IF OBJECT_ID('Roles', 'U') IS NOT NULL DROP TABLE Roles;
GO

-- =============================================
-- TABLE: Roles
-- =============================================
CREATE TABLE Roles (
    roleId      INT IDENTITY(1,1) PRIMARY KEY,
    roleName    NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(255),
    createdAt   DATETIME DEFAULT GETDATE()
);

-- =============================================
-- TABLE: Users
-- =============================================
CREATE TABLE Users (
    userId      INT IDENTITY(1,1) PRIMARY KEY,
    fullName    NVARCHAR(100) NOT NULL,
    email       NVARCHAR(150) NOT NULL UNIQUE,
    phone       NVARCHAR(20),
    password    NVARCHAR(255) NOT NULL,
    address     NVARCHAR(255),
    avatar      NVARCHAR(500),
    roleId      INT NOT NULL DEFAULT 2,
    isActive    BIT DEFAULT 1,
    createdAt   DATETIME DEFAULT GETDATE(),
    updatedAt   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (roleId) REFERENCES Roles(roleId)
);

-- =============================================
-- TABLE: Categories
-- =============================================
CREATE TABLE Categories (
    categoryId   INT IDENTITY(1,1) PRIMARY KEY,
    categoryName NVARCHAR(100) NOT NULL UNIQUE,
    description  NVARCHAR(255),
    createdAt    DATETIME DEFAULT GETDATE()
);

-- =============================================
-- TABLE: Brands
-- =============================================
CREATE TABLE Brands (
    brandId    INT IDENTITY(1,1) PRIMARY KEY,
    brandName  NVARCHAR(100) NOT NULL UNIQUE,
    logo       NVARCHAR(500),
    createdAt  DATETIME DEFAULT GETDATE()
);

-- =============================================
-- TABLE: Motorbikes
-- =============================================
CREATE TABLE Motorbikes (
    motorbikeId  INT IDENTITY(1,1) PRIMARY KEY,
    name         NVARCHAR(150) NOT NULL,
    brandId      INT NOT NULL,
    categoryId   INT NOT NULL,
    year         INT,
    pricePerDay  DECIMAL(10,2) NOT NULL,
    description  NVARCHAR(MAX),
    status       NVARCHAR(20) DEFAULT 'Available', -- Available, Rented, Maintenance
    imageUrl     NVARCHAR(500),
    createdAt    DATETIME DEFAULT GETDATE(),
    updatedAt    DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Motorbikes_Brands FOREIGN KEY (brandId) REFERENCES Brands(brandId),
    CONSTRAINT FK_Motorbikes_Categories FOREIGN KEY (categoryId) REFERENCES Categories(categoryId),
    CONSTRAINT CK_Motorbikes_Status CHECK (status IN ('Available', 'Rented', 'Maintenance'))
);

-- =============================================
-- TABLE: MotorbikeImages
-- =============================================
CREATE TABLE MotorbikeImages (
    imageId     INT IDENTITY(1,1) PRIMARY KEY,
    motorbikeId INT NOT NULL,
    imageUrl    NVARCHAR(500) NOT NULL,
    isPrimary   BIT DEFAULT 0,
    createdAt   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_MotorbikeImages_Motorbikes FOREIGN KEY (motorbikeId) REFERENCES Motorbikes(motorbikeId) ON DELETE CASCADE
);

-- =============================================
-- TABLE: RentalOrders
-- =============================================
CREATE TABLE RentalOrders (
    orderId     INT IDENTITY(1,1) PRIMARY KEY,
    userId      INT NOT NULL,
    orderDate   DATETIME DEFAULT GETDATE(),
    totalAmount DECIMAL(10,2) DEFAULT 0,
    status      NVARCHAR(20) DEFAULT 'Pending', -- Pending, Confirmed, Renting, Returned, Cancelled
    notes       NVARCHAR(500),
    createdAt   DATETIME DEFAULT GETDATE(),
    updatedAt   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_RentalOrders_Users FOREIGN KEY (userId) REFERENCES Users(userId),
    CONSTRAINT CK_RentalOrders_Status CHECK (status IN ('Pending', 'Confirmed', 'Renting', 'Returned', 'Cancelled'))
);

-- =============================================
-- TABLE: RentalOrderDetails
-- =============================================
CREATE TABLE RentalOrderDetails (
    detailId    INT IDENTITY(1,1) PRIMARY KEY,
    orderId     INT NOT NULL,
    motorbikeId INT NOT NULL,
    rentalDate  DATE NOT NULL,
    returnDate  DATE NOT NULL,
    totalDays   INT NOT NULL,
    pricePerDay DECIMAL(10,2) NOT NULL,
    subTotal    DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Motorbikes FOREIGN KEY (motorbikeId) REFERENCES Motorbikes(motorbikeId)
);

-- =============================================
-- TABLE: Payments
-- =============================================
CREATE TABLE Payments (
    paymentId     INT IDENTITY(1,1) PRIMARY KEY,
    orderId       INT NOT NULL UNIQUE,
    amount        DECIMAL(10,2) NOT NULL,
    paymentMethod NVARCHAR(50) DEFAULT 'Cash', -- Cash, Credit Card, Bank Transfer
    paymentDate   DATETIME DEFAULT GETDATE(),
    status        NVARCHAR(20) DEFAULT 'Pending', -- Pending, Completed, Refunded
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId),
    CONSTRAINT CK_Payments_Status CHECK (status IN ('Pending', 'Completed', 'Refunded'))
);

-- =============================================
-- TABLE: Reviews
-- =============================================
CREATE TABLE Reviews (
    reviewId    INT IDENTITY(1,1) PRIMARY KEY,
    userId      INT NOT NULL,
    motorbikeId INT NOT NULL,
    orderId     INT NOT NULL,
    rating      INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment     NVARCHAR(1000),
    createdAt   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Reviews_Users FOREIGN KEY (userId) REFERENCES Users(userId),
    CONSTRAINT FK_Reviews_Motorbikes FOREIGN KEY (motorbikeId) REFERENCES Motorbikes(motorbikeId),
    CONSTRAINT FK_Reviews_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId)
);

-- =============================================
-- INDEXES
-- =============================================
CREATE INDEX IX_Users_Email ON Users(email);
CREATE INDEX IX_Users_RoleId ON Users(roleId);
CREATE INDEX IX_Motorbikes_BrandId ON Motorbikes(brandId);
CREATE INDEX IX_Motorbikes_CategoryId ON Motorbikes(categoryId);
CREATE INDEX IX_Motorbikes_Status ON Motorbikes(status);
CREATE INDEX IX_RentalOrders_UserId ON RentalOrders(userId);
CREATE INDEX IX_RentalOrders_Status ON RentalOrders(status);
CREATE INDEX IX_OrderDetails_OrderId ON RentalOrderDetails(orderId);
CREATE INDEX IX_OrderDetails_MotorbikeId ON RentalOrderDetails(motorbikeId);
CREATE INDEX IX_Reviews_MotorbikeId ON Reviews(motorbikeId);
CREATE INDEX IX_Reviews_UserId ON Reviews(userId);

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Roles
INSERT INTO Roles (roleName, description) VALUES ('Admin', 'System Administrator');
INSERT INTO Roles (roleName, description) VALUES ('Customer', 'Registered Customer');
INSERT INTO Roles (roleName, description) VALUES ('Staff', 'Store Staff');

-- Users (password = '123456' - in production, use hashed passwords)
INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive)
VALUES ('Admin User', 'admin@motorent.com', '0123456789', '123456', '123 Admin Street', 1, 1);

INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive)
VALUES ('John Doe', 'john@gmail.com', '0987654321', '123456', '456 Customer Ave', 2, 1);

INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive)
VALUES ('Sarah Smith', 'sarah@gmail.com', '0912345678', '123456', '789 Customer Blvd', 2, 1);

INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive)
VALUES ('Staff Member', 'staff@motorent.com', '0934567890', '123456', '321 Staff Road', 3, 1);

INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive)
VALUES ('Bob Jones', 'bob@gmail.com', '0945678901', '123456', '654 Customer Lane', 2, 1);

-- Categories
INSERT INTO Categories (categoryName, description) VALUES ('Sport', 'High-performance sport bikes');
INSERT INTO Categories (categoryName, description) VALUES ('Cruiser', 'Comfortable cruiser motorcycles');
INSERT INTO Categories (categoryName, description) VALUES ('Scooter', 'Easy-to-ride scooters');
INSERT INTO Categories (categoryName, description) VALUES ('Off-Road', 'Adventure and off-road bikes');
INSERT INTO Categories (categoryName, description) VALUES ('Touring', 'Long-distance touring motorcycles');

-- Brands
INSERT INTO Brands (brandName) VALUES ('Honda');
INSERT INTO Brands (brandName) VALUES ('Yamaha');
INSERT INTO Brands (brandName) VALUES ('Kawasaki');
INSERT INTO Brands (brandName) VALUES ('Ducati');
INSERT INTO Brands (brandName) VALUES ('Harley Davidson');
INSERT INTO Brands (brandName) VALUES ('Vespa');

-- Motorbikes
INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('CBR600RR', 1, 1, 2023, 45.00, 'The Honda CBR600RR is a 599cc sport bike known for incredible handling, powerful engine, and sleek aerodynamic design.', 'Available',
'https://images.unsplash.com/photo-1568772585407-9361f9bf3c87?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('YZF-R1', 2, 1, 2023, 60.00, 'The Yamaha YZF-R1 is a high-performance supersport bike with crossplane crankshaft technology.', 'Available',
'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('Ninja 400', 3, 1, 2023, 35.00, 'The Kawasaki Ninja 400 is a lightweight sportbike perfect for beginners and experienced riders alike.', 'Rented',
'https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('Panigale V4', 4, 1, 2024, 120.00, 'The Ducati Panigale V4 represents the pinnacle of Ducati sportbike engineering and performance.', 'Available',
'https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('Iron 883', 5, 2, 2023, 80.00, 'The Harley Davidson Iron 883 is an iconic cruiser with raw, stripped-down styling.', 'Available',
'https://images.unsplash.com/photo-1558980394-4c7c9299fe96?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('Sprint 150', 6, 3, 2023, 25.00, 'The Vespa Sprint 150 is a stylish and practical scooter for city commuting.', 'Maintenance',
'https://images.unsplash.com/photo-1622185135505-2d795003994a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('CRF300L', 1, 4, 2023, 40.00, 'The Honda CRF300L is a versatile dual-sport motorcycle for both on and off-road adventures.', 'Available',
'https://images.unsplash.com/photo-1609630875171-b1321377ee65?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl)
VALUES ('MT-07', 2, 1, 2024, 50.00, 'The Yamaha MT-07 is a versatile naked bike with a smooth twin-cylinder engine.', 'Available',
'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');

-- MotorbikeImages
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (1, 'https://images.unsplash.com/photo-1568772585407-9361f9bf3c87?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 1);
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (1, 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 0);
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (2, 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 1);
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (3, 'https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 1);
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (4, 'https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 1);
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (5, 'https://images.unsplash.com/photo-1558980394-4c7c9299fe96?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 1);
INSERT INTO MotorbikeImages (motorbikeId, imageUrl, isPrimary) VALUES (6, 'https://images.unsplash.com/photo-1622185135505-2d795003994a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 1);

-- RentalOrders
INSERT INTO RentalOrders (userId, orderDate, totalAmount, status)
VALUES (2, '2026-10-15', 135.00, 'Renting');

INSERT INTO RentalOrders (userId, orderDate, totalAmount, status)
VALUES (2, '2026-09-02', 180.00, 'Returned');

INSERT INTO RentalOrders (userId, orderDate, totalAmount, status)
VALUES (2, '2026-08-10', 70.00, 'Returned');

INSERT INTO RentalOrders (userId, orderDate, totalAmount, status)
VALUES (3, '2026-10-20', 90.00, 'Pending');

INSERT INTO RentalOrders (userId, orderDate, totalAmount, status)
VALUES (5, '2026-10-19', 120.00, 'Confirmed');

-- RentalOrderDetails
INSERT INTO RentalOrderDetails (orderId, motorbikeId, rentalDate, returnDate, totalDays, pricePerDay, subTotal)
VALUES (1, 1, '2026-10-15', '2026-10-18', 3, 45.00, 135.00);

INSERT INTO RentalOrderDetails (orderId, motorbikeId, rentalDate, returnDate, totalDays, pricePerDay, subTotal)
VALUES (2, 2, '2026-09-02', '2026-09-05', 3, 60.00, 180.00);

INSERT INTO RentalOrderDetails (orderId, motorbikeId, rentalDate, returnDate, totalDays, pricePerDay, subTotal)
VALUES (3, 3, '2026-08-10', '2026-08-12', 2, 35.00, 70.00);

INSERT INTO RentalOrderDetails (orderId, motorbikeId, rentalDate, returnDate, totalDays, pricePerDay, subTotal)
VALUES (4, 1, '2026-10-20', '2026-10-22', 2, 45.00, 90.00);

INSERT INTO RentalOrderDetails (orderId, motorbikeId, rentalDate, returnDate, totalDays, pricePerDay, subTotal)
VALUES (5, 2, '2026-10-19', '2026-10-21', 2, 60.00, 120.00);

-- Payments
INSERT INTO Payments (orderId, amount, paymentMethod, status)
VALUES (1, 135.00, 'Credit Card', 'Completed');

INSERT INTO Payments (orderId, amount, paymentMethod, status)
VALUES (2, 180.00, 'Cash', 'Completed');

INSERT INTO Payments (orderId, amount, paymentMethod, status)
VALUES (3, 70.00, 'Bank Transfer', 'Completed');

-- Reviews
INSERT INTO Reviews (userId, motorbikeId, orderId, rating, comment)
VALUES (2, 2, 2, 5, 'Incredible bike! Very fast and handles like a dream. The rental process was easy.');

INSERT INTO Reviews (userId, motorbikeId, orderId, rating, comment)
VALUES (2, 3, 3, 4, 'Great bike for beginners. Very comfortable and affordable.');

INSERT INTO Reviews (userId, motorbikeId, orderId, rating, comment)
VALUES (3, 1, 4, 5, 'Amazing experience! The bike was in perfect condition.');

GO

PRINT 'MotoRentDB database created successfully with sample data!';
GO
