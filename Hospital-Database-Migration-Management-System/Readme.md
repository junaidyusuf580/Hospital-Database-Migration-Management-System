![MySQL](https://img.shields.io/badge/MySQL-blue?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Type](https://img.shields.io/badge/Type-Database%20Migration-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

> A structured, secure, and scalable relational database system built to modernize hospital record-keeping — migrating from fragmented Excel files into an integrated MySQL environment.

---

# Table of Contents

- [Project Overview](#project-overview)
- [Business Problems Addressed](#business-problems-addressed)
- [Objectives](#objectives)
- [Database Schema](#database-schema)
- [Database Features](#database-features)
- [Key Features](#key-features)
- [Technical Skills](#technical-skills)
- [Setup Instructions](#setup-instructions)
- [Project Structure](#project-structure)
- [Stored Procedures & Triggers](#stored-procedures--triggers)
- [Data Migration Strategy](#data-migration-strategy)
- [Key Insights & Reports](#key-insights--reports)
- [Skills Learned](#skills-learned)
- [Security & Data Integrity](#security--data-integrity)
- [Future Improvements](#future-improvements)
- [Conclusion](#conclusion)
- [Author & Contact](#Author--Contact)

---

## Project Overview

This project focuses on migrating hospital data from Excel spreadsheets into a structured relational database management system using MySQL. The primary objective is to replace manual and scattered record-keeping processes with a centralized, secure, and scalable database solution.

The system is designed to manage essential hospital operations such as:

- Patient registration and management
- Doctor profiles and department assignments
- Appointment scheduling with conflict prevention
- Prescription and medication tracking
- Lab report management
- Billing and revenue reporting

This project showcases end-to-end database engineering — from schema design and data ingestion to automation via triggers and stored procedures.

---

## Business Problems Addressed

*Hospitals often face challenges while managing records manually or through spreadsheet-based systems. This project addresses the following problems:*

🔹 Data Redundancy

Duplicate records across Excel sheets lead to inconsistency and confusion.

🔹 Poor Data Integrity

Missing relationships between patients, doctors, and appointments increase errors.

🔹 Scheduling Conflicts

Manual appointment systems may result in double booking.

🔹 Security Risks

Sensitive patient data requires controlled access and proper authorization.

🔹 Difficult Reporting

Generating monthly revenue and departmental reports manually is time-consuming.

---

## Objectives

| ▶ | Objective | Status |
|---|-----------|--------|
| 1 | Design a normalized relational schema covering all hospital entities | Done |
| 2 | Introduce unique identifiers (PKs) for all tables | Done |
| 3 | Maintain data integrity using primary and foreign keys | Done |
| 4 | Validate data entries with CHECK constraints | Done |
| 5 | Prevent double-booking with a scheduling triggers | Done |
| 6 | Implement role-based patient data access via stored procedures | Done |
| 7 | Enable monthly departmental revenue reporting | Done |
| 8 | Convert unstructured Excel hospital data into a relational database | Done |

---

## Database Schema

The database `jkgroups` consists of **7 core tables**:

```bash
departments
    └── doctors (Department_id → FK)
            └── appointments (Doctor_id → FK)
                    ├── prescriptions (appointment_id → FK)
                    ├── labs          (appointment_id → FK)
                    └── bills         (appointment_id → FK)
patients
    └── appointments (patient_id → FK)

```
---

## Database Features

| Features | Glimps |
|---|---|
| Patient Management | Stores patient demographic and medical information securely. |
| Doctor & Department Management | Maintains doctor profiles and department associations. |
| Appointment Scheduling | Tracks appointments while preventing scheduling conflicts. |
| Prescription Tracking | Stores prescription records linked to appointments and doctors. |
| Billing System | Manages billing transactions and payment details. |
| Revenue Reporting | Generates monthly department-wise revenue analysis |
| Data Security | Implements role-based access control for secure handling of medical records. |

### Table Descriptions

| Table | Primary Key | Description |
|-------|-------------|-------------|
| `departments` | `Department_id` | Hospital departments (e.g., Cardiology, Neurology) |
| `doctors` | `Doctor_id` | Doctors with specialization, role, and department |
| `patients` | `patient_id` | Patient demographics and contact info |
| `appointments` | `appointment_id` | Scheduled visits linking patients to doctors |
| `prescriptions` | `PrescriptionID` | Medications prescribed per appointment |
| `labs` | `report_id` | Lab test results linked to appointments |
| `bills` | `Bill_id` | Financial records for each appointment |

### Entity-Relationship Summary

- A **Department** has many **Doctors**
- A **Doctor** handles many **Appointments**
- A **Patient** has many **Appointments**
- Each **Appointment** can have one **Bill**, one **Lab Report**, and multiple **Prescriptions**

---

## Key Features

### → Data Integrity
- Foreign key constraints across all related tables ensure no orphaned records
- `CHECK` constraints enforce valid values for `gender` (`m`, `f`, `o`) and appointment `status` (`scheduled`, `completed`, `cancelled`)
- `DEFAULT CURRENT_TIMESTAMP` on `Bills.billdate` and `Labs.Createdat` for automatic audit trails

### → Appointment Conflict Prevention
A `BEFORE INSERT` trigger (`Check_new_appointment`) prevents:
- Scheduling appointments in the **past**
- **Double-booking** a doctor who already has a `scheduled` appointment at the same time

### → Role-Based Access Control
The stored procedure `view_doctors_details` authenticates via `doctor_credentials` and returns patient data scoped by role:
- **Senior Doctors** — View all patients in their department
- **Junior Doctors** — View only their own patients

### → Monthly Revenue Reporting
The stored procedure `SP_MONTHLYREVENUE` aggregates billing data by department for a given month and year, enabling financial dashboards and audits.

### → Automated Data Migration
Dynamic SQL using `Information_Schema` and `GROUP_CONCAT` was used to programmatically discover and load columns from the flat `hospital_data` staging table into normalized tables — making the migration flexible and repeatable.

---

## Technical Skills

| Technology | Purpose |
|------------|---------|
| **MySQL** | Primary relational database engine |
| **SQL DDL** | Schema creation (CREATE TABLE, ALTER TABLE) |
| **SQL DML** | Data insertion and migration (INSERT INTO ... SELECT) |
| **Triggers** | Automated business rule enforcement |
| **Stored Procedures** | Role-based access control, revenue reporting |
| **Information_Schema** | Dynamic column discovery during migration |
| **Excel / CSV** | Source format for raw hospital data |

---

## Setup Instructions

### Prerequisites
- MySQL Server 8.0+ installed
- MySQL Workbench or any SQL client
- The flat `hospital_data` staging table imported from the source Excel file

### Step 1 — Create the Database

```sql
CREATE DATABASE jkgroups;
USE jkgroups;
```

### Step 2 — Run the Schema Script

Execute the DDL section of `Hospital-Database.sql` to create all 7 tables with constraints:

```bash
mysql -u root -p jkgroups < Hospital-Database.sql
```

Or paste and run the `CREATE TABLE` blocks in your SQL client.

### Step 3 — Import the Staging Table

Import your Excel source file as a flat table named `hospital_data` into the `jkgroups` database. Most SQL clients support CSV/Excel import wizards.

### Step 4 — Run Data Migration Queries

Execute the `INSERT INTO ... SELECT` blocks in sequence:

1. `departments`
2. `doctors`
3. `patients` *(includes `STR_TO_DATE` parsing and `ALTER TABLE` for phone column)*
4. `appointments`
5. `prescriptions`
6. `labs`
7. `bills`

### Step 5 — Create Trigger & Stored Procedures

Run the Trigger and Stored Procedure blocks at the end of the SQL file.

### Step 6 — Verify Data

```sql
SELECT * FROM departments;
SELECT * FROM doctors;
SELECT * FROM patients;
SELECT * FROM appointments;
SELECT * FROM bills;
```

---

## Project Structure

```bash
jkgroups-hospital-db/
│
├── Hospital-Database.sql    # Main SQL file: schema + migration + procedures
├── README.md                # Project documentation (this file)
└── data/
    └── hospital_data.csv    # Source data file (Excel export)
```

---

## Stored Procedures & Triggers

### Trigger — `Check_new_appointment`

```bash
-- Validate BEFORE INSERT on appointments
-- Rejects: past appointments, double-booked doctor slots
```

**Usage:** Automatically enforced on every `INSERT` into the `appointments` table.

### Stored Procedure — `view_doctors_details`

```sql
CALL view_doctors_details('doctor4', 'ic0pFSn0');
```

**Logic:** Looks up the doctor use credentials, determines their role (`Senior` / other), and returns patient data accordingly.

### Stored Procedure — `SP_MONTHLYREVENUE`

```sql
CALL SP_MONTHLYREVENUE(2024, 3);  -- Revenue for March 2024
```

**Returns:** Department name and total revenue for the specified month/year.

---

## Data Migration Strategy

The source data arrived as a **single flat Excel file** (`hospital_data`) with prefixed columns such as `Doctors.DoctorID`, `Patients.Name`, etc. The migration approach:

1. **Discover columns dynamically** using `Information_Schema.columns` with `LIKE 'entity.%'` filters
2. **Parse date formats** using `STR_TO_DATE()` to convert `dd-mm-yyyy` strings to proper `DATE`/`DATETIME` types
3. **Filter empty rows** using `WHERE column <> ''` and `WHERE TRIM(column) <> ''`
4. **Schema alterations** (e.g., `phone` column changed from `INT` to `VARCHAR(20)`) were applied before inserting data that could overflow integer bounds

---

## Key Insights & Reports

The database can generate reports such as:

- Monthly department revenue
- Doctor appointment statistics
- Patient visit history
- Billing summaries
- Frequently prescribed medicines
- Department performance analysis

---

## Skills Learned

**Through this project, the following skills were developed:**

_Database Skills_
- Relational Database Design
- Database Normalization
- ER Modeling
- SQL Query Writing
- Data Integrity Management

_Technical Skills_
- Data Migration
- Excel to MySQL Integration
- Report Generation
- Trigger & Stored Procedure Implementation

_Analytical Skills_
- Data Cleaning
- Structured Data Management
- Business Reporting
- Problem Solving

---

## Security & Data Integrity

The project ensures secure and reliable data management using:

- Role-based access control
- Referential integrity
- Unique identifiers
- Validation constraints
- Controlled data relationships

---
## Future Improvements

_Possible future enhancements include:_

- Integration with web applications_
- Real-time appointment booking system
- Dashboard visualization using Power BI or Tableau
- Patient portal implementation
- Cloud database deployment
- Backup and recovery automation

---

## Conclusion

*_This project demonstrates how relational database systems can transform traditional hospital record management into an efficient, secure, and scalable solution. By migrating Excel-based records into MySQL, the system improves operational efficiency, minimizes redundancy, and enables advanced reporting and analytics for hospital management._*

---

## Author
>Mohd Junaid
_Aspiring Data Analyst | SQL & Database Enthusiast._

---

*If you found this project useful, feel free to star the repository.*
😊😊😊

