# Project Foundation
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

