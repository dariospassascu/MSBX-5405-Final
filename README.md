# MSBX 5405 Final
The purpose of this repo is for MSBX 5405 final project

## Requirements
The following scripts are meant to be run on a local instance of MariaDB 

## Getting Started
1. Run `schema.sql`
2. Run `data.sql`
3. Use `queries.sql`

`queries.sql` contains the 5 quieries necessary for the project. Each query is meant to answer a business question. 

# AthenaIQ Payroll System - Query Descriptions

## Query 1: Payroll Period Summary by Employee

**Purpose:** For a given payroll period, show each employee's total compensation, hours worked, position, store, and pay plan. This is the master payroll report that would be used to process actual paychecks.

**Business Value:** Provides the weekly/bi-weekly payroll summary needed to issue payments and verify totals before submitting to payroll processing. Replaces the manual spreadsheet process mentioned in our proposal.

---

## Query 2: Earnings Breakdown by Pay Element

**Purpose:** For a specific payroll period, show each employee with a detailed breakdown of their earnings by pay element (regular hours, overtime, commissions, spiffs, etc.), including what percentage each element represents of their total compensation.

**Business Value:** Allows managers to understand the composition of each employee's pay and identify opportunities for optimization. Shows how the "base wage + commission component" structure works for technicians and service advisors mentioned in our proposal.

---

## Query 3: Pay Plan Performance Analysis

**Purpose:** Compare average compensation, total hours worked, and total compensation across different pay plan types for a given period. Groups employees by their pay plan to show which compensation structures cost the most and employ the most people.

**Business Value:** Helps AthenaIQ and store owners evaluate which compensation structures are most cost-effective and attractive to employees. Critical for strategic decisions about expanding or modifying pay plans across stores. Supports the "predictive decision-making" capability mentioned in our proposal.

---

## Query 4: Technician Sales Performance by Category

**Purpose:** Show each technician's sales performance broken down by service category (Brakes, Tires, Oil Changes, etc.) for a given payroll period, including total jobs completed, total sales, and gross profit.

**Business Value:** Identifies which technicians excel at which services, helping management make better work assignment and training decisions. Shows how sales data integrates with payroll to drive flat-rate pay and performance bonuses.

---

## Query 5: Service Advisor Sales Performance by Category

**Purpose:** Show each service advisor's and manager's sales broken down by service category for a given payroll period, including total jobs sold, total sales, and gross profit generated.

**Business Value:** **This is our killer feature!** Directly solves the problem in our proposal where "commission data must be manually extracted from an outdated sales reporting system." This query automates the entire commission tracking process by category, with zero manual extraction required. Service advisors can instantly see what they're selling and their commission potential.

---

## Connection to Our Proposal

Each query directly addresses problems mentioned in our project proposal:

- **Query 1** → Eliminates manual spreadsheets that require multiple labor hours
- **Query 2** → Shows complex compensation structures work accurately (no more manual errors)
- **Query 3** → Enables predictive decision-making and strategic planning
- **Query 4** → Demonstrates sales data integration with payroll system
- **Query 5** → **Automates commission extraction** (our biggest pain point!)

---

## Technical Complexity

All queries demonstrate:
- Multiple table JOINs (3-5 tables)
- Aggregate functions (SUM, AVG, COUNT, ROUND)
- GROUP BY clauses
- Calculated columns (percentages, rates)
- Date filtering (BETWEEN clause)
- String concatenation (CONCAT)

This matches the complexity level of the harder homework problems (Q19-30) while solving real business problems.
