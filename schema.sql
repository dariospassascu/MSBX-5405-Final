-- ============================================================
-- MariaDB Schema Creation Script - Single Database, No Prefixes
-- Drop and recreate all tables for easy schema modifications
-- ============================================================

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS `payroll_system` 
    DEFAULT CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE `payroll_system`;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS `PayrollEarning`;
DROP TABLE IF EXISTS `PayrollRecord`;
DROP TABLE IF EXISTS `PayrollPeriod`;
DROP TABLE IF EXISTS `PayPlanElement`;
DROP TABLE IF EXISTS `PlanElement`;
DROP TABLE IF EXISTS `PayPlan`;
DROP TABLE IF EXISTS `WriterSalesByCategory`;
DROP TABLE IF EXISTS `TechSalesByCategory`;
DROP TABLE IF EXISTS `Category`;
DROP TABLE IF EXISTS `Timesheet`;
DROP TABLE IF EXISTS `Employee`;
DROP TABLE IF EXISTS `Position`;
DROP TABLE IF EXISTS `Store`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- CORE / DIMENSION TABLES
-- ============================================================

-- Store: canonical store list
CREATE TABLE `Store`(
    `StoreID`         INT            NOT NULL,
    `PosID`           INT            NOT NULL,
    `Nickname`        VARCHAR(100)   NULL,
    `AddressLine`     VARCHAR(255)   NULL,
    `City`            VARCHAR(100)   NULL,
    `StateProvince`   VARCHAR(50)    NULL,
    `PostalCode`      VARCHAR(20)    NULL,
    `ManagerCode`     VARCHAR(50)    NULL,
    `District`        VARCHAR(50)    NULL,
    `AthenaStartDate` DATE           NULL,
    `Bays`            SMALLINT       NULL,
    CONSTRAINT `PK_Store` PRIMARY KEY (`StoreID`),
    CONSTRAINT `UQ_Store_PosID` UNIQUE (`PosID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Position: job role (Manager, Service Advisor, Tech, etc.)
CREATE TABLE `Position`(
    `PositionID`   INT AUTO_INCREMENT NOT NULL,
    `PositionName` VARCHAR(100)        NOT NULL,
    CONSTRAINT `PK_Position` PRIMARY KEY (`PositionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Employee: canonical employee entity
CREATE TABLE `Employee`(
    `EmployeeID` INT         NOT NULL,
    `FirstName`  VARCHAR(50) NOT NULL,
    `MiddleName` VARCHAR(50) NULL,
    `LastName`   VARCHAR(50) NOT NULL,
    `PositionID` INT         NOT NULL,
    `Active`     BOOLEAN     NOT NULL DEFAULT 1,
    `CreatedAt`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `PK_Employee` PRIMARY KEY (`EmployeeID`),
    CONSTRAINT `FK_Employee_Position` FOREIGN KEY (`PositionID`)
        REFERENCES `Position`(`PositionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- POS SOURCE TABLES
-- ============================================================

-- Timesheet: raw clock data
CREATE TABLE `Timesheet`(
    `TimesheetID`    BIGINT       NOT NULL,
    `StoreID`        INT          NOT NULL,
    `EmployeeID`     INT          NOT NULL,
    `TimeIn`         DATETIME     NOT NULL,
    `TimeOut`        DATETIME     NULL,
    `ClockOutReason` VARCHAR(20)  NULL,
    `TotalHours`     DECIMAL(6,2) NULL,
    `CreatedAt`      DATETIME     NOT NULL,
    CONSTRAINT `PK_Timesheet` PRIMARY KEY (`TimesheetID`),
    CONSTRAINT `FK_Timesheet_Store` FOREIGN KEY (`StoreID`)
        REFERENCES `Store`(`StoreID`),
    CONSTRAINT `FK_Timesheet_Employee` FOREIGN KEY (`EmployeeID`)
        REFERENCES `Employee`(`EmployeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Category: POS category master
CREATE TABLE `Category`(
    `CategoryCode`        VARCHAR(50)  NOT NULL,
    `CategoryDescription` VARCHAR(255) NULL,
    `CreatedAt`           DATETIME(6)  NOT NULL,
    CONSTRAINT `PK_Category` PRIMARY KEY (`CategoryCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Tech sales by category
CREATE TABLE `TechSalesByCategory`(
    `StoreID`           INT            NOT NULL,
    `Date`              DATE           NOT NULL,
    `EmployeeID`        INT            NOT NULL,
    `CategoryCode`      VARCHAR(15)    NOT NULL,
    `LaborJobs`         SMALLINT       NOT NULL,
    `LaborHours`        DECIMAL(8,2)   NOT NULL,
    `LaborCharge`       DECIMAL(19,4)  NOT NULL,
    `LaborDiscount`     DECIMAL(19,4)  NOT NULL,
    `LaborCost`         DECIMAL(19,4)  NOT NULL,
    `PartsCharge`       DECIMAL(19,4)  NOT NULL,
    `PartsFees`         DECIMAL(19,4)  NOT NULL,
    `PartsDiscount`     DECIMAL(19,4)  NOT NULL,
    `PartsCost`         DECIMAL(19,4)  NOT NULL,
    `TotalCost`         DECIMAL(19,4)  AS (`LaborCost` + `PartsCost`) STORED,
    `TotalSales`        DECIMAL(19,4)  AS (((`LaborCharge` + `PartsCharge`) + `PartsFees`) - (`LaborDiscount` + `PartsDiscount`)) STORED,
    `TotalGrossProfit`  DECIMAL(19,4)  AS ((((`LaborCharge` + `PartsCharge`) + `PartsFees`) - (`LaborDiscount` + `PartsDiscount`)) - (`LaborCost` + `PartsCost`)) STORED,
    CONSTRAINT `PK_TechSalesByCategory` PRIMARY KEY (`StoreID`, `Date`, `EmployeeID`, `CategoryCode`),
    CONSTRAINT `FK_TechSales_Store` FOREIGN KEY (`StoreID`)
        REFERENCES `Store`(`StoreID`),
    CONSTRAINT `FK_TechSales_Employee` FOREIGN KEY (`EmployeeID`)
        REFERENCES `Employee`(`EmployeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Writer sales by category
CREATE TABLE `WriterSalesByCategory`(
    `StoreID`          INT            NOT NULL,
    `Date`             DATE           NOT NULL,
    `EmployeeID`       INT            NOT NULL,
    `CategoryCode`     VARCHAR(50)    NOT NULL,
    `LaborJobs`        SMALLINT       NULL,
    `LaborHours`       DECIMAL(8,2)   NULL,
    `LaborCharge`      DECIMAL(19,4)  NULL,
    `LaborDiscount`    DECIMAL(19,4)  NULL,
    `LaborCost`        DECIMAL(19,4)  NULL,
    `PartsCharge`      DECIMAL(19,4)  NULL,
    `PartsFees`        DECIMAL(19,4)  NULL,
    `PartsDiscount`    DECIMAL(19,4)  NULL,
    `PartsCost`        DECIMAL(19,4)  NULL,
    `TotalCost`        DECIMAL(19,4)  AS (`LaborCost` + `PartsCost`) STORED,
    `TotalSales`       DECIMAL(19,4)  AS (((`LaborCharge` + `PartsCharge`) + `PartsFees`) - (`LaborDiscount` + `PartsDiscount`)) STORED,
    `TotalGrossProfit` DECIMAL(19,4)  AS ((((`LaborCharge` + `PartsCharge`) + `PartsFees`) - (`LaborDiscount` + `PartsDiscount`)) - (`LaborCost` + `PartsCost`)) STORED,
    CONSTRAINT `PK_WriterSalesByCategory` PRIMARY KEY (`StoreID`, `Date`, `EmployeeID`, `CategoryCode`),
    CONSTRAINT `FK_WriterSales_Store` FOREIGN KEY (`StoreID`)
        REFERENCES `Store`(`StoreID`),
    CONSTRAINT `FK_WriterSales_Employee` FOREIGN KEY (`EmployeeID`)
        REFERENCES `Employee`(`EmployeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- PAYROLL DOMAIN TABLES
-- ============================================================

-- Pay plan definition (Hourly, Salary + Store GP, etc.)
CREATE TABLE `PayPlan`(
    `PlanID`         INT AUTO_INCREMENT NOT NULL,
    `PlanName`       VARCHAR(100)       NOT NULL,
    `OvertimeExempt` BOOLEAN            NOT NULL DEFAULT 0,
    CONSTRAINT `PK_PayPlan` PRIMARY KEY (`PlanID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Pay elements that make up a plan (Regular Pay, OT, Commission, Spiffs, etc.)
CREATE TABLE `PlanElement`(
    `ElementID`   INT AUTO_INCREMENT NOT NULL,
    `ElementName` VARCHAR(50)        NOT NULL,
    `Description` VARCHAR(200)       NULL,
    CONSTRAINT `PK_PlanElement` PRIMARY KEY (`ElementID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Bridge: which elements are used by which plan
CREATE TABLE `PayPlanElement`(
    `PlanID`    INT NOT NULL,
    `ElementID` INT NOT NULL,
    CONSTRAINT `PK_PayPlanElement` PRIMARY KEY (`PlanID`, `ElementID`),
    CONSTRAINT `FK_PayPlanElement_PayPlan` FOREIGN KEY (`PlanID`)
        REFERENCES `PayPlan`(`PlanID`),
    CONSTRAINT `FK_PayPlanElement_PlanElement` FOREIGN KEY (`ElementID`)
        REFERENCES `PlanElement`(`ElementID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Payroll period (weekly, bi-weekly, etc.)
CREATE TABLE `PayrollPeriod`(
    `PeriodID`    INT AUTO_INCREMENT NOT NULL,
    `PeriodStart` DATE               NOT NULL,
    `PeriodEnd`   DATE               NOT NULL,
    CONSTRAINT `PK_PayrollPeriod` PRIMARY KEY (`PeriodID`),
    CONSTRAINT `CK_PayrollPeriod_Dates` CHECK (`PeriodEnd` >= `PeriodStart`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Payroll record header: one row per employee per period
CREATE TABLE `PayrollRecord`(
    `RecordID`          INT AUTO_INCREMENT NOT NULL,
    `PeriodID`          INT          NOT NULL,
    `StoreID`           INT          NOT NULL,
    `EmployeeID`        INT          NOT NULL,
    `PositionID`        INT          NOT NULL,
    `PlanID`            INT          NOT NULL,
    `TotalHours`        DECIMAL(6,2) NULL,
    `TotalCompensation` DECIMAL(19,4) NULL,
    `CreatedAt`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `PK_PayrollRecord` PRIMARY KEY (`RecordID`),
    CONSTRAINT `FK_PayrollRecord_Period` FOREIGN KEY (`PeriodID`)
        REFERENCES `PayrollPeriod`(`PeriodID`),
    CONSTRAINT `FK_PayrollRecord_Store` FOREIGN KEY (`StoreID`)
        REFERENCES `Store`(`StoreID`),
    CONSTRAINT `FK_PayrollRecord_Employee` FOREIGN KEY (`EmployeeID`)
        REFERENCES `Employee`(`EmployeeID`),
    CONSTRAINT `FK_PayrollRecord_Position` FOREIGN KEY (`PositionID`)
        REFERENCES `Position`(`PositionID`),
    CONSTRAINT `FK_PayrollRecord_PayPlan` FOREIGN KEY (`PlanID`)
        REFERENCES `PayPlan`(`PlanID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Payroll earnings line items: one row per Record + Element
CREATE TABLE `PayrollEarning`(
    `RecordID`  INT            NOT NULL,
    `ElementID` INT            NOT NULL,
    `Hours`     DECIMAL(6,2)   NULL,
    `Quantity`  DECIMAL(10,2)  NULL,
    `Amount`    DECIMAL(19,4)  NOT NULL,
    CONSTRAINT `PK_PayrollEarning` PRIMARY KEY (`RecordID`, `ElementID`),
    CONSTRAINT `FK_PayrollEarning_Record` FOREIGN KEY (`RecordID`)
        REFERENCES `PayrollRecord`(`RecordID`),
    CONSTRAINT `FK_PayrollEarning_Element` FOREIGN KEY (`ElementID`)
        REFERENCES `PlanElement`(`ElementID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
