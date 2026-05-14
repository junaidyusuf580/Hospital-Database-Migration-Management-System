# 📦 Inventory & Supply Chain Management Dashboard

> A full-stack, Python-powered web application built with **Streamlit** and **MySQL** that enables non-technical users to manage inventory, track stock, and automate supply chain operations — all without writing a single SQL query.

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Objectives](#-objectives)
- [Live Demo Preview](#-live-demo-preview)
- [Tech Stack](#-tech-stack)
- [Project Architecture](#-project-architecture)
- [Database Schema](#-database-schema)
- [Key Features](#-key-features)
- [Setup & Installation](#-setup--installation)
- [Configuration](#-configuration)
- [Usage Guide](#-usage-guide)
- [File Structure](#-file-structure)
- [SQL Objects Reference](#-sql-objects-reference)
- [Skills Learned](#-skills-learned)
- [Known Issues & Improvements](#-known-issues--improvements)
- [Author](#-author)

---

## 🧩 Project Overview

This project demonstrates the integration of a **relational MySQL database** with a **Python Streamlit frontend** to deliver a real-world inventory management system. Users can monitor key business metrics, add products, track inventory history, place reorders, and mark shipments as received — all through an intuitive point-and-click interface.

The system is modeled on how businesses in retail, warehousing, and e-commerce manage their stock and supplier relationships. It bridges the gap between raw database operations and accessible, user-friendly tooling.

---

## 🎯 Objectives

- Design and implement a normalized relational database for inventory and supply chain data.
- Build stored procedures and views to encapsulate complex business logic at the database layer.
- Develop a clean, interactive Streamlit frontend that connects to the database in real time.
- Enable non-technical stakeholders to perform critical operational tasks without SQL knowledge.
- Demonstrate a multi-layered, production-style application architecture.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Python · Streamlit · Pandas |
| **Backend / Database** | MySQL 8.x |
| **DB Connector** | `mysql-connector-python` |
| **Database Objects** | Tables · Views · Stored Procedures |
| **Language** | Python 3.x · SQL |
| **IDE / Tools** | VS Code · MySQL Workbench |

---

## 🏗 Project Architecture

```
┌─────────────────────────────────────────────────┐
│              Streamlit Web Interface             │
│  ┌─────────────────┐   ┌──────────────────────┐ │
│  │  Basic Info Tab  │   │  Operations Task Tab  │ │
│  │  - KPI Metrics   │   │  - Add Product        │ │
│  │  - Supplier List │   │  - Product History    │ │
│  │  - Reorder Alert │   │  - Place Reorder      │ │
│  └────────┬─────────┘   │  - Receive Order      │ │
│           │             └──────────┬────────────┘ │
└───────────┼──────────────────────┼───────────────┘
            │    functionUI.py      │
            │  (DB abstraction layer│
            ▼                       ▼
┌─────────────────────────────────────────────────┐
│                  MySQL Database                  │
│  Tables: products, suppliers, shipments,         │
│          stock_entries, reorders                 │
│  Views:  Inventory_history                       │
│  Procs:  AddNewProduct_id, Order_received        │
└─────────────────────────────────────────────────┘
```

---

## 🗄 Database Schema

The database (`userinterface`) is built around five core tables:

| Table | Description |
|---|---|
| `products` | Stores product details: name, category, price, stock, reorder level, supplier |
| `suppliers` | Supplier contact information |
| `shipments` | Records of goods received from suppliers |
| `stock_entries` | Logs every stock movement — sales, restocks |
| `reorders` | Tracks reorder requests and their status (Ordered → Received) |

**Views:**

| View | Description |
|---|---|
| `Inventory_history` | Unified view joining shipments and stock entries per product for a full audit trail |

---

## ✨ Key Features

### 📊 Basic Information Dashboard
- **6 real-time KPI metrics** displayed in card format:
  - Total Suppliers
  - Total Products
  - Total Categories
  - Total Sale Value (last 3 months)
  - Total Restock Value (last 3 months)
  - Products below reorder level with no pending order
- **Supplier details** table
- **Product–Supplier mapping** table
- **Reorder alert list** — products at or below their reorder threshold

### ⚙️ Operational Tasks
- **Add New Product** — form-driven entry that inserts records across `products`, `shipments`, and `stock_entries` atomically via a stored procedure
- **Product History** — per-product audit trail pulled from the `Inventory_history` view
- **Place Reorder** — one-click reorder submission with quantity input
- **Receive Reorder** — marks a pending order as received, updates stock quantity, and logs the shipment and stock entry — all in a single database transaction

---

## 🚀 Setup & Installation

### Prerequisites

- Python 3.8 or higher
- MySQL Server 8.x
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

1. Open **MySQL Workbench** or your preferred MySQL client.
2. Run the full script in `Webapp_Mysql_query.sql`:

```sql
-- This creates the database, tables, views, and stored procedures
source Webapp_Mysql_query.sql;
```

> ⚠️ Make sure your MySQL server is running before executing the script.

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

> 🔒 **Security Note:** Do not commit credentials to version control. Use environment variables or a `.env` file in production. See [Configuration](#-configuration) below.

### Step 5 — Run the Application

```bash
streamlit run App_file.py
```

The app will open in your browser at `http://localhost:8501`.

---

## ⚙️ Configuration

For a more secure setup, use environment variables to manage your database credentials:

```python
import os

def connect_to_df():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "userinterface")
    )
```

Then set them in your terminal before running:

```bash
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=your_password
export DB_NAME=userinterface
streamlit run App_file.py
```

---

## 📖 Usage Guide

| Sidebar Option | Available Task | Description |
|---|---|---|
| Basic Information | — | View KPI metrics, supplier info, product–supplier links, and reorder alerts |
| Operation Task | Add New Product | Add a product with name, category, price, stock, reorder level, and supplier |
| Operation Task | Product History | Select any product to view its full shipment and stock-movement history |
| Operation Task | Place Reorder | Select a product and enter quantity to submit a reorder request |
| Operation Task | Received Reorder | Select a pending reorder to mark it received and auto-update stock |

---

## 📁 File Structure

```
inventory-dashboard/
│
├── App_file.py              # Main Streamlit application — UI logic & routing
├── functionUI.py            # Database abstraction layer — all query functions
├── Webapp_Mysql_query.sql   # Full SQL setup: tables, views, stored procedures
└── README.md                # Project documentation
```

---

## 🗂 SQL Objects Reference

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
| Sales value (last 3 months) | `SUM(change_quantity * price)` on `stock_entries` filtered by `change_type = 'Sale'` |
| Products needing reorder | `stock_quantity <= reorder_level` with no `Pending` entry in `reorders` |
| Product–Supplier mapping | `JOIN` between `products` and `suppliers` |

---

## 📚 Skills Learned

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

**Systems Thinking**
- Modeling real-world business workflows as database transactions
- Building tools accessible to non-technical end users
- Understanding the role of backend constraints (procedures, transactions) in ensuring data consistency

---

## 🐛 Known Issues & Improvements

| Issue | Status | Suggested Fix |
|---|---|---|
| DB credentials hardcoded in `functionUI.py` | Open | Use `os.getenv()` or `python-dotenv` |
| `get_pending_reorder` returns `None` (missing `return` statement) | Bug | Add `return cursor.fetchall()` |
| `place_reorder` sets status as `"ordered"` but procedure checks `"Pending"` | Bug | Standardize to `"Pending"` in both places |
| No authentication or user roles | Open | Add Streamlit session state login |
| DB connection not closed after use | Open | Use `try/finally` or context manager |
| No pagination for large DataFrames | Open | Add `st.dataframe` with row limit |

---

## 👤 Author

**Muhammad Junaid**
Aspiring Data Analyst | Python · SQL · Streamlit

---

## 📄 License

This project is intended for educational and portfolio purposes.

---

> _"The goal was to build something that feels like enterprise software but is accessible enough for anyone to use — that's what this project delivers."_
