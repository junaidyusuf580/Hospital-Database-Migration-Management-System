# Inventory & Supply Chain Management Dashboard

> A full-stack, Python-powered web application built with **Streamlit** and **MySQL** that enables non-technical users to manage inventory, track stock, and automate supply chain operations — all without writing a single SQL query.

---

## Table of Contents

- [Project Overview](#-project-overview)
- [Project Objectives](#-project-objectives)
- [System Architecture](#-system-architecture)
- [Project Architecture](#-project-architecture)
- [Database Schema](#-database-schema)
- [Key Features](#-key-features)
- [Setup & Installation](#-setup--installation)
- [Configuration](#-configuration)
- [Usage Guide](#-usage-guide)
- [Project Structure](#-Project-structure)
- [SQL Objects Reference](#-sql-objects-reference)
- [Skills Learned](#-skills-learned)
- [What Makes This Project Advanced](#-what-makes-this-project-advanced)
- [Suggested Future Improvements](#-Suggested-Future-Improvements-)
- [Author](#-author)

---

## Project Overview

**This project focuses on building an end-to-end Inventory Management Dashboard using:**

- MySQL as the backend database
- Python as the business logic layer
- Streamlit as the frontend web interface

**The application allows users to:**

- View inventory insights
- Add new products
- Track inventory history
- Manage reorder operations
- Monitor supplier information
- Display business KPIs in real time

The project is designed especially for **non-technical users**, enabling them to interact with the database using a clean graphical interface instead of SQL queries.

---

## Project Objectives

- Build an inventory management system
- Connect MySQL database with Python applications
- Create interactive dashboards using Streamlit
- Implement business logic using SQL procedures and functions
- Automate inventory and reorder workflows
- Allow non-technical users to manage operational data easily
- Demonstrate full-stack data application development

---

## System Architecture

| Layer | Technology |
|---|---|
| **Frontend** | Python · Streamlit · Pandas |
| **Backend / Database** | MySQL |
| **DB Connector** | `mysql-connector-python` |
| **Database Objects** | Tables · Views · Stored Procedures |
| **Tools** | Python . SQL |
| **IDE / Tools** | VS Code · MySQL Workbench |

---

## Project Architecture

| Layer | Component | Features / Description |
|---|---|---|
| Frontend | Streamlit Web Interface | User interface for inventory management system |
| Frontend Module | Basic Info Tab | KPI Metrics, Supplier List, Reorder Alert |
| Frontend Module | Operations Task Tab | Add Product, Product History, Place Reorder, Receive Order |
| Backend Layer | `functionUI.py` | Database abstraction layer connecting Streamlit and MySQL |
| Database | MySQL Database | Stores and manages inventory data |
| Database Tables | Tables | `products`, `suppliers`, `shipments`, `stock_entries`, `reorders` |
| Database Views | Views | `Inventory_history` |
| Database Procedures | Stored Procedures | `Add New-Product_id`, `Order_received` |


---

## Database Schema

The database (`userinterface`) is built around five core tables:

| Table | Description |
|---|---|
| `products` | Stores product details: name, category, price, stock, reorder level, supplier |
| `suppliers` | Supplier contact information |
| `shipments` | Records of goods received from suppliers |
| `stock_entries` | Logs every stock movement — sales, restocks, entry-date |
| `reorders` | Tracks reorder requests and their status (Ordered →Pending →Received) |

**Views:**

| View | Description |
|---|---|
| `Inventory_history` | Created a unified inventory view by joining shipments and stock_entries tables to provide complete product movement history and audit tracking |

---

## Key Features

### Basic Information Dashboard(`streamlit`)
- **6 real-time KPI metrics** displayed in card format:
  - Total Suppliers
  - Total Products
  - Total Categories
  - Total Sale Value (last one year)
  - Total Restock Value (last 3 months)
  - Products below reorder level with no pending order
- **Supplier details** table
- **Product–Supplier mapping** table
- **Reorder alert list** — products at or below their reorder threshold

### Operational Tasks(`streamlit`)
- **Add New Product** — form-driven entry that inserts records across `products`, `shipments`, and `stock_entries` atomically via a stored procedure
- **Product History** — per-product audit trail pulled from the `Inventory_history` view
- **Place Reorder** — one-click reorder submission with quantity input
- **Receive Reorder** — marks a pending order as received, updates stock quantity, and logs the shipment and stock entry — all in a single database transaction

---

## Setup & Installation

### Prerequisites

- Python 
- MySQL Server 
- pip

### Step 1 — Clone the Repository

```bash
git clone https://github.com/your-username/inventory-dashboard.git
cd inventory-dashboard
```

### Step 2 — Install Python Dependencies

```bash
pip install streamlit mysql-connector-python pandas
```

### Step 3 — Set Up the MySQL Database

1. Open **MySQL Workbench** 
2. Run the full script in `Webapp_Mysql_query.sql`(MySql file):

```sql
-- This creates the database, tables, views, and stored procedures
source Webapp_Mysql_query.sql;
```

### Step 4 — Configure Database Credentials

Open `functionUI.py` and update the connection settings with your credentials:

```python
def connect_to_df():
    return mysql.connector.connect(
        host="localhost",
        user="your_mysql_username",
        password="your_mysql_password",
        database="userinterface"
    )
```

### Step 5 — Run the Application

```bash
streamlit run App_file.py
```

The app will open in your browser at `http://localhost:8501`.

---

## Usage Guide(`streamlit`)

| Sidebar Option | Available Task | Description |
|---|---|---|
| `Basic Information` | KPI | View KPI metrics, supplier info, product–supplier links, and reorder alerts |
| `Operation Task` | Add New Product | Add a product with name, category, price, stock, reorder level, and supplier |
| Operation Task | Product History | Select any product to view its full shipment and stock-movement history |
| Operation Task | Place Reorder | Select a product and enter quantity to submit a reorder request |
| Operation Task | Received Reorder | Select a pending reorder to mark it received and auto-update stock |

---

## Project Structure

project-folder/
│
├── App.file.py                  # Streamlit frontend application
├── functionUI.py                # Database utility functions
├── Webapp Mysql query.sql       # SQL database scripts
├── Interactive_Dashboard.ipynb  # Analysis notebook
├── requirements.txt
└── README.md

---

## SQL Objects Reference

### Stored Procedures

| Procedure | Purpose |
|---|---|
| `AddNewProduct_id` | Inserts a new product and initializes shipment and stock entry records atomically |
| `Order_received` | Marks a reorder as received, updates product stock, and logs shipment and stock entry within a transaction |

### Views

| View | Purpose |
|---|---|
| `Inventory_history` | Unified product timeline — combines shipment records and stock entries for any product |

### Key Queries

| Metric | SQL Approach |
|---|---|
| Sales value (last one year) | `SUM(change_quantity * price)` on `stock_entries` filtered by `change_type = 'Sale'` |
| Products needing reorder | `stock_quantity <= reorder_level` with no `Pending` entry in `reorders` |
| Product–Supplier mapping | `JOIN` between `products` and `suppliers` |

---

## Skills Learned

**Database Design & SQL**
- Designing a normalized relational schema across 5 tables
- Writing complex multi-table `JOIN` queries and aggregate functions
- Building database views for reusable reporting logic
- Implementing stored procedures with transactions (`START TRANSACTION`, `COMMIT`) for data integrity
- Using `IFNULL(MAX(id), 0) + 1` for safe auto-increment alternatives

**Python & Streamlit**
- Connecting Python to MySQL using `mysql-connector-python`
- Separating UI logic (`App_file.py`) from database logic (`functionUI.py`) for clean architecture
- Building interactive forms, selectboxes, and metric cards with Streamlit
- Handling exceptions gracefully and displaying user-friendly error messages
- Displaying query results as interactive Pandas DataFrames

**Data Analytics Skills**
- KPI Reporting
- Operational Dashboarding
- Business Metrics Analysis

**Streamlit Skills**
- Interactive UI Development
- Forms and Inputs
- Dynamic Data Display
- Dashboard Design

## Learning Outcomes

By completing this project, you will understand:

- How Python connects with MySQL
- How Streamlit builds interactive dashboards
- How SQL procedures automate workflows
- How inventory systems operate in businesses
- How to build data-driven business applications

---

## What Makes This Project Advanced

* Combines frontend + backend + database systems
* Uses real business workflows
* Implements stored procedures and SQL logic
* Demonstrates full-stack data application development
* Supports non-technical business users
* Simulates enterprise inventory management systems

---

## Suggested Future Improvements

- User authentication system
- Role-based access control
- Email alerts for low stock
- Export reports to Excel/PDF
- Real-time analytics charts
- Cloud deployment (AWS/Azure)
- API integration

---

## Author

**Mohd Junaid**
Aspiring Data Analyst | Python · SQL · Streamlit

> _"The goal was to build something that feels like enterprise software but is accessible enough for anyone to use — that's what this project delivers."_


---



