Create database userinterface;
use userinterface;

-- 1 Total Suppliers;
select * from suppliers; 
select count(*) as Total_suppliers from suppliers;

-- 2 Total Product;
select count(*) as Total_Product from products;

-- 3 Total Categories;
Select count(distinct category) as Total_Category from products;


-- 4 Total Sales for last three months
select round(sum(abs(s.change_quantity)* p.price),2) as Total_Sales from stock_entries s
join products p on p.product_id=s.product_id where change_type= 'Sale'
and entry_date>=
(
select date_sub(max(s.entry_date), Interval 1 year) from stock_entries s
);


-- 5 Total restock value made in last 3 months (quantity* price)
select round(sum(abs(s.change_quantity)* p.price),2) as Total_Sales from stock_entries s
join products p on p.product_id=s.product_id where change_type= "Restock"
and entry_date>=
(
select date_sub(max(se.entry_date), Interval 3 month) from stock_entries se
);

-- 6 Below Reorder & No pending order
select count(*) from products where stock_quantity<reorder_level 
and product_id not in
(
select product_id from reorders where status="Pending"
);

-- 7 Supplier Details
select supplier_name, contact_name, email, phone from suppliers;

-- 8 Product Detail with suppliers 
select p.product_name, p.stock_quantity, p.reorder_level, s.supplier_name from products p 
join suppliers s on p.supplier_id=s.supplier_id order by p.product_name;

-- 9 Product needing reorder
select product_id, product_name, stock_quantity, reorder_level from products where stock_quantity<=reorder_level;

-- 10 Create new procedure for add new product
delimiter $$

Create procedure AddNewProduct_id(
	in p_name varchar(255),
	in p_category varchar(100),
	in p_price decimal(10,2),
	in p_stock int,
	in p_reorder int,
	in p_suppliers int
)
begin
	declare new_product_id int;
    declare new_shipment_id int;
    declare new_entry_id int;
    
	-- make changes in product table
    select IFNULL(MAX(product_id),0)+1 into new_product_id from products;
    
    insert into products(product_id, product_name, category, price, stock_quantity, reorder_level, supplier_id)
    values (new_product_id, p_name, p_category, p_price, p_stock, p_reorder, p_suppliers);
    
    -- make changes in shipment_table
	select ifnull(max(shipment_id),0)+1 into new_shipment_id from shipments;
    
    insert into shipments(shipment_id , product_id , supplier_id , quantity_received, shipment_date)
    values (new_shipment_id, new_product_id, p_suppliers, p_stock, curdate());
    
    -- make changes in new_entry_id table
	select ifnull(max(entry_id),0)+1 into new_entry_id from stock_entries;
	
	insert into stock_entries(entry_id , product_id , change_quantity , change_type , entry_date)
    values (new_entry_id, new_product_id, p_stock, 'Restock', curdate());

End$$
Delimiter;


-- 11 Product History [Finding Shipment , Sales , Purchase]

create or replace view Inventory_history as
select
ph.product_id,
ph.record_type,
ph.record_date,
ph.change_type,
ph.Quantity,
pr.supplier_id
from
(
select product_id, 
"Shipment" as record_type,
quantity_received as Quantity, 
shipment_date as record_date,
null as change_type
from shipments

union all

select product_id,
"Stock_entry" as record_type,
change_quantity as Quantity,
entry_date as record_date,
change_type
from stock_entries) ph
join products pr on pr.product_id=ph.product_id;

--
-- check the detail using Inventory_history table
select * from 
Inventory_history
where product_id =123 order by record_date desc;


------------------------------------------------------------------------------------------------
-- 13 Place order
Insert into reorders (reorder_id, product_id, reorder_quantity, reorder_date, status)
select ifnull(max(reorder_id),0)+1, 101, 100, curdate(), "ordered" from reorders;


-- 14 Received order

delimiter $$

create procedure Order_received(in in_order_id int)
Begin
declare prod_id int;
declare qty int;
declare sup_id int;
declare new_shipment_id int;
declare new_entry_id int;

Start transaction;

-- Get product & quantity
select product_id, reorder_quantity into prod_id, qty from 
reorders where reorder_id=in_order_id;

-- get supplier_id from product
select supplier_id into sup_id from products
where product_id= prod_id;

 -- Update reorder status
update reorders
SET status= "Received"
where reorder_id=in_order_id;
-- update quantity in product table
update products
set stock_quantity = stock_quantity + qty
where product_id= prod_id;

-- Generates the next shipment ID.
select max(shipment_id)+1 into new_shipment_id from shipments;

-- Logs the shipment details with today’s date.
insert  into shipments(shipment_id, product_id, supplier_id, quantity_received, shipment_date)
values (new_shipment_id, prod_id, sup_id, qty, curdate());

-- Generates the next entry_id ID.
select max(entry_id)+1 into new_entry_id from stock_entries;

-- Insert record into restck
insert  into stock_entries(entry_id, product_id, change_quantity, change_type, entry_date)
values(new_entry_id, prod_id, qty, "Restock", curdate());

commit;
End$$

delimiter;

-- End --









    
 




 
 