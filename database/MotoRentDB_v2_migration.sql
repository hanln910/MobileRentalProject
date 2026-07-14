-- =============================================
-- MOTORENT v2 - Migration Script
-- New features: Wallet, Digital Contract, Email Notification, Received Status
-- =============================================

USE MotoRentDB;
GO

-- =============================================
-- 1. UPDATE RentalOrders status constraint to add 'Received'
-- New workflow: Pending -> Confirmed -> Renting -> Received -> Returned -> Cancelled
-- =============================================
ALTER TABLE RentalOrders DROP CONSTRAINT CK_RentalOrders_Status;
GO

ALTER TABLE RentalOrders ADD CONSTRAINT CK_RentalOrders_Status 
    CHECK (status IN ('Pending', 'Confirmed', 'Renting', 'Received', 'Returned', 'Cancelled'));
GO

-- =============================================
-- 2. TABLE: Wallets
-- Each customer has one wallet for payments
-- =============================================
IF OBJECT_ID('WalletTransactions', 'U') IS NOT NULL DROP TABLE WalletTransactions;
IF OBJECT_ID('Wallets', 'U') IS NOT NULL DROP TABLE Wallets;
GO

CREATE TABLE Wallets (
    walletId    INT IDENTITY(1,1) PRIMARY KEY,
    userId      INT NOT NULL UNIQUE,
    balance     DECIMAL(12,2) DEFAULT 0.00,
    createdAt   DATETIME DEFAULT GETDATE(),
    updatedAt   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Wallets_Users FOREIGN KEY (userId) REFERENCES Users(userId),
    CONSTRAINT CK_Wallets_Balance CHECK (balance >= 0)
);
GO

-- =============================================
-- 3. TABLE: WalletTransactions
-- Track all wallet top-ups and payments
-- =============================================
CREATE TABLE WalletTransactions (
    transactionId   INT IDENTITY(1,1) PRIMARY KEY,
    walletId        INT NOT NULL,
    type            NVARCHAR(20) NOT NULL, -- TopUp, Payment, Refund
    amount          DECIMAL(12,2) NOT NULL,
    description     NVARCHAR(500),
    orderId         INT NULL, -- linked order for Payment/Refund
    balanceAfter    DECIMAL(12,2) NOT NULL,
    createdAt       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_WalletTx_Wallets FOREIGN KEY (walletId) REFERENCES Wallets(walletId),
    CONSTRAINT FK_WalletTx_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId),
    CONSTRAINT CK_WalletTx_Type CHECK (type IN ('TopUp', 'Payment', 'Refund'))
);
GO

-- =============================================
-- 4. TABLE: RentalContracts
-- Digital contract signed when order is confirmed
-- =============================================
IF OBJECT_ID('RentalContracts', 'U') IS NOT NULL DROP TABLE RentalContracts;
GO

CREATE TABLE RentalContracts (
    contractId      INT IDENTITY(1,1) PRIMARY KEY,
    orderId         INT NOT NULL UNIQUE,
    -- Customer identification info (for security)
    customerIdCard  NVARCHAR(50) NOT NULL,       -- ID card / CCCD number
    customerDOB     DATE,                         -- Date of birth
    emergencyName   NVARCHAR(100) NOT NULL,       -- Emergency contact name
    emergencyPhone  NVARCHAR(20) NOT NULL,        -- Emergency contact phone
    emergencyRelation NVARCHAR(50),               -- Relationship
    -- Contract terms
    depositAmount   DECIMAL(10,2) DEFAULT 0,      -- Security deposit
    terms           NVARCHAR(MAX),                -- Contract terms & conditions
    -- Signatures
    customerSigned  BIT DEFAULT 0,
    customerSignedAt DATETIME,
    staffSigned     BIT DEFAULT 0,
    staffSignedAt   DATETIME,
    staffId         INT NULL,
    -- Metadata
    status          NVARCHAR(20) DEFAULT 'Draft', -- Draft, Signed, Completed, Voided
    createdAt       DATETIME DEFAULT GETDATE(),
    updatedAt       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Contracts_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId),
    CONSTRAINT FK_Contracts_Staff FOREIGN KEY (staffId) REFERENCES Users(userId),
    CONSTRAINT CK_Contracts_Status CHECK (status IN ('Draft', 'Signed', 'Completed', 'Voided'))
);
GO

-- =============================================
-- 5. INDEXES for new tables
-- =============================================
CREATE INDEX IX_Wallets_UserId ON Wallets(userId);
CREATE INDEX IX_WalletTx_WalletId ON WalletTransactions(walletId);
CREATE INDEX IX_WalletTx_OrderId ON WalletTransactions(orderId);
CREATE INDEX IX_WalletTx_CreatedAt ON WalletTransactions(createdAt DESC);
CREATE INDEX IX_Contracts_OrderId ON RentalContracts(orderId);
CREATE INDEX IX_RentalOrders_CreatedAt ON RentalOrders(createdAt DESC);
GO

-- =============================================
-- 6. SAMPLE DATA for Wallets
-- =============================================

-- Create wallets for all existing customers
INSERT INTO Wallets (userId, balance) VALUES (2, 500.00);  -- John Doe
INSERT INTO Wallets (userId, balance) VALUES (3, 300.00);  -- Sarah Smith
INSERT INTO Wallets (userId, balance) VALUES (5, 200.00);  -- Bob Jones

-- Sample wallet transactions
INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter)
VALUES (1, 'TopUp', 700.00, 'Initial top-up via Bank Transfer', NULL, 700.00);

INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter)
VALUES (1, 'Payment', 135.00, 'Payment for Order #ORD-0001', 1, 565.00);

INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter)
VALUES (1, 'Payment', 180.00, 'Payment for Order #ORD-0002', 2, 385.00);

INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter)
VALUES (2, 'TopUp', 300.00, 'Initial top-up via Bank Transfer', NULL, 300.00);

INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter)
VALUES (3, 'TopUp', 200.00, 'Initial top-up via Bank Transfer', NULL, 200.00);

GO

PRINT 'MotoRentDB v2 migration completed successfully!';
GO
