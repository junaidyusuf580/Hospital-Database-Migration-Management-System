# Inventory & Supply Chain Management Dashboard code
# --------------------------------------------------#
# Imports Streamlit, Pandas, and custom database functions required for the application.
import streamlit as st
import pandas as pd
from functionUI import (
    connect_to_df,
    basic_information, get_additional_tables,get_categories, get_suppliers,
    Add_new_product, get_product_history,get_all_product, place_reorder,get_pending_reorder, received_orders)

# Create Sidebar Navigation Menu
st.sidebar.title("Inventory Management Dashboard")
option = st.sidebar.radio("Select Option:",["Basic Information","Operation Task"])

# Sets application title and connects Streamlit with MySQL database.
st.title("Inventory and Supply Chain Dashboard")
db=connect_to_df()
cursor=db.cursor(dictionary=True)

# Display Basic Dashboard Metrics
if option=="Basic Information":
    st.header("Basic Metrics")

    # Fetch Basic Information from Database
    get_basic=basic_information(cursor)

    # Create KPI Metric Columns
    cols=st.columns(3)
    keys= list(get_basic.keys())

    #Display KPI Values in Streamlit
    for i in range(3):
        cols[i].metric(label=keys[i], value=get_basic[keys[i]])

    cols= st.columns(3)
    for i in range(3,6):
        cols[i-3].metric(label=keys[i], value=get_basic[keys[i]])

    st.divider()

    # Shows supplier details, inventory data, and reorder reports.
    tables= get_additional_tables(cursor)
    for label,data in tables.items():
        st.header(label)
        df=pd.DataFrame(data)
        st.dataframe(df)

# Create Operational Task Section/ Allows user to choose inventory operation tasks.
elif option=="Operation Task":
    st.header("Operation Task")
    selected_task=st.selectbox("Select Operations",["Add new Product","Product History",
    "Place reorder","Received Reorder"])
    if selected_task== "Add new Product":
        st.header("Add new Product")

        # Fetch Categories and Suppliers
        categories=get_categories(cursor)
        suppliers=get_suppliers(cursor)

        # Add New Product Form
        with st.form("Add_product_form"):

            product_name=st.text_input("Product Name")
            product_category= st.selectbox("Category", categories)
            product_price=st.number_input("Price", min_value=0.00)
            product_stock=st.number_input("Stock Quantity", min_value=0, step=1)
            product_level=st.number_input("Reorder Level", min_value=0, step=1)

            suppliers_id=[s["supplier_id"] for s in suppliers]
            suppliers_name= [s["supplier_name"] for s in suppliers]

            selected_suppliers_id= st.selectbox("Suppliers",
            options= suppliers_id,
            format_func= lambda x:suppliers_name[suppliers_id.index(x)])

            # Submits new product data into database using stored procedure.
            submitted= st.form_submit_button("Add New Product")

            # Checks whether required fields are entered correctly.
            if submitted:
                if not product_name:
                    st.error("Product Name is required")
                else:
                    try:
                        Add_new_product(cursor,
                                        db,
                                        product_name,
                                        product_category,
                                        product_price,
                                        product_stock,
                                        product_level,
                                        selected_suppliers_id)

                        st.success(f"Product {product_name} added successfully")

                    except Exception as e:
                        st.error(f"Error adding the Product {e}")

    # Product Inventory History Section
    if selected_task== "Product History":
        st.header("Product Inventory History")

    # Fetch Product List from Database
        products= get_all_product(cursor)
        product_name= [p["product_name"] for p in products]
        product_id= [p["product_id"] for p in products]

        # Allows users to choose a product for inventory history analysis.
        selected_product_name=st.selectbox("Select an Product",options=product_name)

        # Display Product Inventory History
        if selected_product_name:
            select_product_id=product_id[product_name.index(selected_product_name)]
            history_data=get_product_history(cursor, select_product_id)

            if history_data:
                df=pd.DataFrame(history_data)
                st.dataframe(df)
            else:
                st.info("No history found for the product selected")


    # Create Reorder Placement Section
    if selected_task == "Place reorder":
        st.header("Place an Reorder")

        products = get_all_product(cursor)
        product_name = [p["product_name"] for p in products]
        product_id = [p["product_id"] for p in products]

        selected_product_name = st.selectbox("Select an Product", options=product_name)
        reorder_qty =st.number_input("Reorder Quantity", min_value=1, step=1)

        if st.button("Place Reorder"):
            if not selected_product_name:
                st.error("Product Name is required")
            elif reorder_qty <= 0:
                st.error("Reorder Quantity must be greater than 0")
            else:
                selected_product_id= product_id[product_name.index(selected_product_name)]
                try:
                    place_reorder(cursor,db,selected_product_id,reorder_qty)
                    st.success(f"Order Placed for {selected_product_name} with quantity {reorder_qty} placed successfully")
                except Exception as e:
                    st.error(f"Error placing reorder {e}")

    # Received Reorder Management Section
    elif selected_task == "Received Reorder":
        st.header("Received an order")

        # Fetch Pending Reorders
        pending_reorder=get_pending_reorder(cursor)

        if not pending_reorder:
            st.error("No pending reorders found")

        # Displays pending reorder list for user selection.
        else:
            reorder_ids=[r['reorder_id'] for r in pending_reorder]
            reorder_labels= [f"ID{r['reorder_id']} - {r['product_name']}" for r in pending_reorder]

           # Display Order Completion Message
            selected_label=st.selectbox("Select Reorder to mark as received",options =reorder_labels)

            # Handle Application Errors
            if selected_label:
                selected_reorder_id= reorder_ids[reorder_labels.index(selected_label)]

                if st.button("Mark as Received"):

                    try:
                        received_orders(cursor,db, selected_reorder_id)
                        st.success(f"Order Received for {selected_reorder_id} successfully")
                    except Exception as e:
                        st.error(f"Error marking order {e}")




            








                












