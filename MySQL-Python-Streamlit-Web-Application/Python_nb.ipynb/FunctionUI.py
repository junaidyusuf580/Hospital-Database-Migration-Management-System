import mysql.connector

def connect_to_df():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="#Junaid@4712",
        database="userinterface")


def basic_information(cursor):
    queries = {
        "Total Suppliers": "select count(*) as Total_suppliers from suppliers",

        "Total Product": "select count(*) as Total_Product from products",

        "Total Categories": "Select count(distinct category) as Total_Category from products",

        "Total Sale Value(Last three month)": """select round(sum(abs(s.change_quantity)* p.price),2) as Total_Sales from stock_entries s
        join products p on p.product_id=s.product_id where change_type= "Sale" and entry_date>= 
        (select date_sub(max(se.entry_date), Interval 3 month) from stock_entries se)""",

        "Total Restock Value(Last three month)":"""select round(sum(abs(s.change_quantity) * p.price), 2) as Total_Sales from stock_entries s
        join products p on p.product_id = s.product_id where change_type = "Restock" and entry_date >=
        (select date_sub(max(se.entry_date), Interval 3 month) from stock_entries se)""",

        "Below Reorder & No pending order": """select count(*) from products where stock_quantity<reorder_level and product_id not in
        (select product_id from reorders where status="Pending")"""
    }

    result={}
    for label, query in queries.items():
        cursor.execute(query)
        row=cursor.fetchone()
        result[label]=list(row.values())[0]


    return result


def get_additional_tables(cursor):
    queries = {
        "Supplier Details": "select supplier_name, contact_name, email, phone from suppliers",
        "Product Detail with suppliers": """select p.product_name, p.stock_quantity, p.reorder_level, s.supplier_name
        from products p join suppliers s on p.supplier_id = s.supplier_id order by p.product_name""",
        "Product need reorder": """select product_id, product_name, stock_quantity, reorder_level
        from products where stock_quantity <= reorder_level"""}

    tables = {}
    for label, query in queries.items():
        cursor.execute(query)
        tables[label] = cursor.fetchall()

    return tables

def get_categories(cursor):
    cursor.execute("select distinct category from products order by category asc")
    rows=cursor.fetchall()
    return [row["category"] for row in rows]


def get_suppliers(cursor):
    cursor.execute("select supplier_id, supplier_name from suppliers order by supplier_name asc")
    return cursor.fetchall()

def Add_new_product(cursor, db, p_name, p_category, p_price, p_stock, p_reorder,  p_suppliers):
    proc_call="call AddNewProduct_id(%s, %s, %s, %s, %s, %s)"
    params= (p_name, p_category, p_price, p_reorder,  p_stock,  p_suppliers)
    cursor.execute(proc_call, params)
    db.commit()

def get_all_product(cursor):
    cursor.execute("select product_id, product_name from products order by product_name")
    rows=cursor.fetchall()
    return rows

def get_product_history(cursor, product_id):
    query=("select * from Inventory_history where product_id = %s order by record_date desc")
    cursor.execute(query, (product_id,))
    return cursor.fetchall()

def place_reorder(cursor, db, product_id, reorder_quantity):
    query= """
    Insert into reorders (reorder_id, product_id, reorder_quantity, reorder_date, status)
    select ifnull(max(reorder_id),0)+1, %s, %s, curdate(), "ordered" from reorders"""
    cursor.execute(query, (product_id, reorder_quantity,))
    db.commit()

def get_pending_reorder(cursor):
    cursor.execute("select r.reorder_id, p.product_name from reorders r join products p on r.product_id=p.product_id")
    cursor.fetchall()

def received_orders(cursor, db, reorder_id):
    cursor.callproc("Order_received",[reorder_id])
    db.commit()




