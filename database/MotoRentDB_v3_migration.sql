-- =============================================
-- MOTORENT v3 - Migration Script
-- New features: Return Inspection (photo/video evidence), Damage Fines,
--               Complaints, Reviews integration, Order Rejection with reason,
--               CCCD photo upload for contracts, Account lock for unpaid fines
-- =============================================

USE MotoRentDB;
GO

-- =============================================
-- 1. ADD rejectReason column to RentalOrders
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('RentalOrders') AND name = 'rejectReason')
BEGIN
    ALTER TABLE RentalOrders ADD rejectReason NVARCHAR(500) NULL;
END
GO

-- =============================================
-- 2. ADD customerIdCardImage to RentalContracts (CCCD photo URL)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('RentalContracts') AND name = 'customerIdCardImage')
BEGIN
    ALTER TABLE RentalContracts ADD customerIdCardImage NVARCHAR(500) NULL;
END
GO

-- =============================================
-- 3. TABLE: ReturnInspections
-- Customer submits photo/video evidence when returning bike
-- Staff reviews and approves or issues a fine
-- =============================================
IF OBJECT_ID('ReturnInspections', 'U') IS NOT NULL DROP TABLE ReturnInspections;
GO

CREATE TABLE ReturnInspections (
    inspectionId    INT IDENTITY(1,1) PRIMARY KEY,
    orderId         INT NOT NULL UNIQUE,
    -- Customer-submitted evidence
    photoUrl1       NVARCHAR(500),           -- Required photo 1
    photoUrl2       NVARCHAR(500),           -- Required photo 2
    photoUrl3       NVARCHAR(500),           -- Optional photo 3
    videoUrl        NVARCHAR(500),           -- Optional video URL
    customerNotes   NVARCHAR(1000),          -- Customer description of condition
    submittedAt     DATETIME DEFAULT GETDATE(),
    -- Staff review
    staffId         INT NULL,
    staffNotes      NVARCHAR(1000),          -- Staff inspection notes
    condition       NVARCHAR(20) DEFAULT 'Pending', -- Pending, Good, Damaged
    -- Fine details (if damaged)
    fineAmount      DECIMAL(10,2) DEFAULT 0,
    fineReason      NVARCHAR(500),
    fineStatus      NVARCHAR(20) DEFAULT 'None', -- None, Pending, Paid, Overdue
    fineIssuedAt    DATETIME NULL,
    fineDeadline    DATETIME NULL,           -- 48 hours from fineIssuedAt
    finePaidAt      DATETIME NULL,
    -- Metadata
    reviewedAt      DATETIME NULL,
    createdAt       DATETIME DEFAULT GETDATE(),
    updatedAt       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Inspections_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId),
    CONSTRAINT FK_Inspections_Staff FOREIGN KEY (staffId) REFERENCES Users(userId),
    CONSTRAINT CK_Inspection_Condition CHECK (condition IN ('Pending', 'Good', 'Damaged')),
    CONSTRAINT CK_Inspection_FineStatus CHECK (fineStatus IN ('None', 'Pending', 'Paid', 'Overdue', 'Waived'))
);
GO

-- =============================================
-- 4. TABLE: Complaints
-- Customer can file a complaint about fines or service
-- =============================================
IF OBJECT_ID('Complaints', 'U') IS NOT NULL DROP TABLE Complaints;
GO

CREATE TABLE Complaints (
    complaintId     INT IDENTITY(1,1) PRIMARY KEY,
    orderId         INT NOT NULL,
    userId          INT NOT NULL,
    subject         NVARCHAR(200) NOT NULL,
    description     NVARCHAR(MAX) NOT NULL,
    status          NVARCHAR(20) DEFAULT 'Open', -- Open, InProgress, Resolved, Rejected
    adminResponse   NVARCHAR(MAX),
    resolvedAt      DATETIME NULL,
    resolvedBy      INT NULL,
    createdAt       DATETIME DEFAULT GETDATE(),
    updatedAt       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Complaints_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId),
    CONSTRAINT FK_Complaints_Users FOREIGN KEY (userId) REFERENCES Users(userId),
    CONSTRAINT FK_Complaints_ResolvedBy FOREIGN KEY (resolvedBy) REFERENCES Users(userId),
    CONSTRAINT CK_Complaints_Status CHECK (status IN ('Open', 'InProgress', 'Resolved', 'Rejected'))
);
GO

-- =============================================
-- 5. Update RentalOrders status constraint to add 'Fined'
-- =============================================
ALTER TABLE RentalOrders DROP CONSTRAINT CK_RentalOrders_Status;
GO
ALTER TABLE RentalOrders ADD CONSTRAINT CK_RentalOrders_Status 
    CHECK (status IN ('Pending', 'Confirmed', 'Renting', 'Received', 'Returned', 'Fined', 'Completed', 'Cancelled'));
GO

-- =============================================
-- 6. Update WalletTransactions type constraint to add 'Fine'
-- =============================================
ALTER TABLE WalletTransactions DROP CONSTRAINT CK_WalletTx_Type;
GO
ALTER TABLE WalletTransactions ADD CONSTRAINT CK_WalletTx_Type 
    CHECK (type IN ('TopUp', 'Payment', 'Refund', 'Fine'));
GO

-- =============================================
-- 6. INDEXES for new tables
-- =============================================
CREATE INDEX IX_Inspections_OrderId ON ReturnInspections(orderId);
CREATE INDEX IX_Inspections_FineStatus ON ReturnInspections(fineStatus);
CREATE INDEX IX_Inspections_FineDeadline ON ReturnInspections(fineDeadline);
CREATE INDEX IX_Complaints_OrderId ON Complaints(orderId);
CREATE INDEX IX_Complaints_UserId ON Complaints(userId);
CREATE INDEX IX_Complaints_Status ON Complaints(status);
GO

-- =============================================
-- 8. TABLE: OverduePenalties
-- Tracks overdue rental fees ($10/day late)
-- =============================================
IF OBJECT_ID('OverduePenalties', 'U') IS NOT NULL DROP TABLE OverduePenalties;
GO

CREATE TABLE OverduePenalties (
    penaltyId       INT IDENTITY(1,1) PRIMARY KEY,
    orderId         INT NOT NULL UNIQUE,
    userId          INT NOT NULL,
    overdueDays     INT NOT NULL DEFAULT 0,
    dailyRate       DECIMAL(10,2) NOT NULL DEFAULT 10.00,
    totalPenalty    DECIMAL(10,2) NOT NULL DEFAULT 0,
    status          NVARCHAR(20) DEFAULT 'Pending', -- Pending, Paid, Waived
    issuedAt        DATETIME DEFAULT GETDATE(),
    paidAt          DATETIME NULL,
    createdAt       DATETIME DEFAULT GETDATE(),
    updatedAt       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_OverduePenalties_Orders FOREIGN KEY (orderId) REFERENCES RentalOrders(orderId),
    CONSTRAINT FK_OverduePenalties_Users FOREIGN KEY (userId) REFERENCES Users(userId),
    CONSTRAINT CK_OverduePenalty_Status CHECK (status IN ('Pending', 'Paid', 'Waived'))
);
GO

CREATE INDEX IX_OverduePenalties_OrderId ON OverduePenalties(orderId);
CREATE INDEX IX_OverduePenalties_UserId ON OverduePenalties(userId);
CREATE INDEX IX_OverduePenalties_Status ON OverduePenalties(status);
GO

-- =============================================
-- 9. Update WalletTransactions type constraint to add 'OverdueFee'
-- =============================================
ALTER TABLE WalletTransactions DROP CONSTRAINT CK_WalletTx_Type;
GO
ALTER TABLE WalletTransactions ADD CONSTRAINT CK_WalletTx_Type
    CHECK (type IN ('TopUp', 'Payment', 'Refund', 'Fine', 'OverdueFee'));
GO

PRINT 'MotoRentDB v3 migration completed successfully!';
GO
