-- ============================================================
-- AthenaIQ Payroll System - Report Queries
-- ============================================================
-- Database: payroll_system
-- Purpose: Demonstrate key reporting capabilities for payroll
--          management and labor cost analysis
-- ============================================================

-- ============================================================
-- QUERY 1: Payroll Period Summary by Employee
-- ============================================================
-- Purpose: Master payroll report showing total compensation,
--          hours, position, and pay plan for each employee
--          in a specific payroll period
-- Business Value: Primary report for processing paychecks
--                 and verifying payroll totals
-- ============================================================

SELECT 
    s.Nickname AS Store,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    pos.PositionName,
    pp.PlanName AS PayPlan,
    pr.TotalHours,
    pr.TotalCompensation,
    ROUND(pr.TotalCompensation / pr.TotalHours, 2) AS EffectiveHourlyRate
FROM 
    PayrollRecord pr
    INNER JOIN Employee e ON pr.EmployeeID = e.EmployeeID
    INNER JOIN Position pos ON pr.PositionID = pos.PositionID
    INNER JOIN Store s ON pr.StoreID = s.StoreID
    INNER JOIN PayPlan pp ON pr.PlanID = pp.PlanID
WHERE 
    pr.PeriodID = 1  -- Filter for specific payroll period
ORDER BY 
    s.Nickname, e.LastName, e.FirstName;


-- ============================================================
-- QUERY 2: Earnings Breakdown by Pay Element
-- ============================================================
-- Purpose: Detailed breakdown showing how each employee's
--          compensation is composed (regular pay, OT,
--          commissions, spiffs, etc.)
-- Business Value: Helps managers understand pay composition
--                 and identify optimization opportunities
-- ============================================================

SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    pos.PositionName,
    pe.ElementName AS PayElement,
    earn.Amount,
    ROUND((earn.Amount / pr.TotalCompensation) * 100, 1) AS PercentOfTotal
FROM 
    PayrollEarning earn
    INNER JOIN PayrollRecord pr ON earn.RecordID = pr.RecordID
    INNER JOIN PlanElement pe ON earn.ElementID = pe.ElementID
    INNER JOIN Employee e ON pr.EmployeeID = e.EmployeeID
    INNER JOIN Position pos ON pr.PositionID = pos.PositionID
WHERE 
    pr.PeriodID = 1  -- Filter for specific payroll period
ORDER BY 
    e.LastName, e.FirstName, earn.Amount DESC;


-- ============================================================
-- QUERY 3: Pay Plan Performance Analysis
-- ============================================================
-- Purpose: Compare compensation and efficiency across
--          different pay plan types
-- Business Value: Strategic insights for evaluating and
--                 optimizing compensation structures
-- ============================================================

SELECT 
    pp.PlanName,
    COUNT(pr.EmployeeID) AS EmployeeCount,
    ROUND(AVG(pr.TotalHours), 2) AS AvgHoursWorked,
    ROUND(AVG(pr.TotalCompensation), 2) AS AvgCompensation,
    ROUND(SUM(pr.TotalCompensation), 2) AS TotalCompensation
FROM 
    PayrollRecord pr
    INNER JOIN PayPlan pp ON pr.PlanID = pp.PlanID
WHERE 
    pr.PeriodID = 1  -- Filter for specific payroll period
GROUP BY 
    pp.PlanName
ORDER BY 
    TotalCompensation DESC;


-- ============================================================
-- QUERY 4: Technician Sales Performance by Category
-- ============================================================
-- Purpose: Show each technician's sales broken down by service
--          category to identify specialties and performance
-- Business Value: Helps management understand which technicians
--                 excel at which services, supports training
--                 decisions and work assignment optimization
-- ============================================================

SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS TechnicianName,
    c.CategoryDescription AS ServiceCategory,
    SUM(ts.LaborJobs) AS TotalJobs,
    ROUND(SUM(ts.TotalSales), 2) AS TotalSales,
    ROUND(SUM(ts.TotalGrossProfit), 2) AS TotalGrossProfit
FROM 
    TechSalesByCategory ts
    INNER JOIN Employee e ON ts.EmployeeID = e.EmployeeID
    INNER JOIN Category c ON ts.CategoryCode = c.CategoryCode
WHERE 
    ts.Date BETWEEN '2025-09-08' AND '2025-09-14'  -- Payroll period
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName, 
    c.CategoryCode, c.CategoryDescription
ORDER BY 
    e.LastName, TotalSales DESC;


-- ============================================================
-- QUERY 5: Service Advisor Sales Performance by Category
-- ============================================================
-- Purpose: Show each service advisor's and manager's sales by
--          category to track who is selling what services
-- Business Value: Identifies top performers in specific service
--                 categories, reveals commission opportunities,
--                 supports targeted sales training
-- ============================================================

SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS AdvisorName,
    pos.PositionName,
    c.CategoryDescription AS ServiceCategory,
    SUM(ws.LaborJobs) AS TotalJobsSold,
    ROUND(SUM(ws.TotalSales), 2) AS TotalSales,
    ROUND(SUM(ws.TotalGrossProfit), 2) AS TotalGrossProfit
FROM 
    WriterSalesByCategory ws
    INNER JOIN Employee e ON ws.EmployeeID = e.EmployeeID
    INNER JOIN Position pos ON e.PositionID = pos.PositionID
    INNER JOIN Category c ON ws.CategoryCode = c.CategoryCode
WHERE 
    ws.Date BETWEEN '2025-09-08' AND '2025-09-14'  -- Payroll period
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName,
    pos.PositionName, c.CategoryCode, c.CategoryDescription
ORDER BY 
    e.LastName, TotalSales DESC;
