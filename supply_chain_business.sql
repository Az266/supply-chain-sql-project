

  --                     DESCRIPTION:                            --     
 /* Title : Supply chain database 
 * This projects shows how products are moved from the supplier to warehouse to the customer 
 * It monitors delivery perfomance and delays
 * Track which supliers provide which product
 *
 >> IMPORTANCE: Managing supply chains is essential for reducing business costs,
 * improving delivery speed and meeting customer satisfaction and need.
 * 
 *AIM: The aim of the project is to design  and implement a sql database that models supply chain systm 
 *and allow analaysis of supply performace and cost.
 * 
 * >> Utilsing output:  By using these data, business can identify  delivery delays,
 *  to reduce cost, improve supplier perfomace  and prevent faults.
 * 
 * >> Normalisation: 
 *  This database is normalised to 3NF (Third Normal Form):
 *  - 1NF: All columns contain atomic values
 *  - One example: each product in products table is stored separately 
 *  
 *  - 2NF: No partial dependencies

 *  - 3NF: No transitive dependencies, non-key columns depend solely only on the primary key
 *   no A → B → C relationships.
* 
 */

--  Create database
CREATE DATABASE supply_chain;

USE supply_chain;


/*  Creating table  */

/* TABLE 1.  Supplier table :
 * >> Purpose:
 * - Stores information about all the suppliers 
 * - Each supplier must have a unique email
 * - Supplier name and email cannot be NULL
 * >> Relationships:
 * - One supplier can have many products (1-*)
 * - supplier_id is primark key (must be unique) 
 * - supplier_id is refrenced as foriegn key by products table
 * >> Normalisation  
 * - 1nf, 2nf and 3nf:
 * 
*/


CREATE TABLE supplier (
supplier_id INT  AUTO_INCREMENT  PRIMARY KEY,
supplier_name VARCHAR(255) NOT NULL ,
email  VARCHAR(255) UNIQUE NOT NULL ,
phone_number  VARCHAR(19)

);



/*2. Products table 
 * >> Purpose: 
 * - Stores informaiton on each products 
 * >> Relationships:
 * - 1 to many 
 * refrences forgein key supplier as each prodcut id belongs to one suppliers.
 * price int can improve it to decimal(10,2)  
 * NOT NULL: each is required  must have an atomic value 
 * 
 * >> Normaionsion:
 * - 1nf -2NF 3-NF
 * 
*/
CREATE TABLE products (
product_name VARCHAR(255) NOT NULL,  -- what is the product name?
product_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL, 
price DECIMAL (10,2) NOT NULL,  -- price of the product
supplier_id INT NOT NULL,
FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
 -- Forign key, which supplier provides the product 

);


/*  Table: warehouse
 * Purpose: stores warehouse location where products are held
 * Relationships:
 * 1 warehouse can have many deliveries (1 to *)
 *  location id (primary key ) is refrence by delvierys table (forign-key)
 */
CREATE TABLE warehouse(
location_id  INT PRIMARY KEY AUTO_INCREMENT NOT NULL, 
location_name VARCHAR(255) NOT NULL  -- what is the warehouse name? 
);


/*  TABLE : deliveries
 * >> Purpose: 
 * - Tracks each shipement from warehouse
 *>> Relationships:
 * - Many deliveries can have 1 product(many-to-1)
 * - Many deliveres can come from 1 warehouse (many-to-1)
 * sent_time is when shipement left the warehouse
 * deliver_time is null until confirms delivered
 * Improvements: I can improve this table making it more normalised if i put quantity and deliever_cost into a separate table.
 */

CREATE TABLE deliveries (
delivery_id INT AUTO_INCREMENT PRIMARY KEY,  -- UNIQUE delivery id - hence primary key
location_id INT NOT NULL, -- which  warehouse product was sent from 
product_id INT NOT NULL, -- which product that was delivers, FOREIGN KEY 
delivery_time DATE , -- was the product delviered
sent_time DATE,-- when the product was sent 
quantity INT NOT NULL CHECK( quantity>0),  --  overal amount delivered must be positive
delivery_cost INT, -- how much it cost for delivery
FOREIGN KEY (location_id) REFERENCES warehouse(location_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);


--  INSERTING DATA INTO EACH TABLE --




-- Insert values  8 suppliers 
INSERT INTO supplier(supplier_name, email, phone_number) VALUES 
('Apple Supplier', 'apple@supply.com', '01147777777'),
('Samsung Supplier', 'Samsung@supply.com', '02247777777'),
('Sony Supplier', 'Sony@supply.com', '03347777777'),
('Stationery Supplier', 'Stationery@supply.com', '04447777777'),
('Book Supplier', 'Book@supply.com', '05547777777'),
('School Supplier', 'School@supply.com', '06647777777'),
('Everyday Supplier', 'Everyday@supply.com', '07747777777'),
('Electronic Supplier', 'Electronic@supply.com', '08847777777');




-- ADDED 8 products 
INSERT INTO products (supplier_id, product_name, price) VALUES
(1, 'Macbook', 1000),
(2, 'samsung mobile', 1200),
(3, 'Nintendo', 400),
(4, 'stationary pack', 30),
(5, 'Book pack', 50),
(6, 'school pack', 200),
(7, 'Backpack', 34),
(8, 'Monitor', 1000);

-- ADDED 8 WAREHOUSE 
INSERT INTO warehouse ( location_name) VALUES
('Amazon warehouse'),
('Reading warehouse'),
('Manchester warehouse'),
('Bristol warehouse'),
('Birmingham warehouse'),
('London warehouse'),
('Leicester  warehouse'),
('Liverpool  warehouse');



INSERT INTO  deliveries(location_id,product_id,  delivery_time, sent_time, quantity, delivery_cost) VALUES
(1, 1, '2026-04-21', '2026-04-15', 50, 200), -- 6 day
(1, 6, '2026-04-27', '2026-04-22', 40, 150), -- 5 day
(1, 3, NULL, '2026-04-25', 30, 120), -- still in delievery
(2, 2, '2026-04-20', '2026-04-19', 30, 120), 
(3, 3, '2026-04-22', '2026-04-20', 20, 100), 
(4, 4, '2026-04-20', '2026-04-19', 70, 79), -- 1 day
(5, 5, '2026-04-21', '2026-04-20', 25, 64), -- 1 day
(7, 7, '2026-04-20', '2026-04-19', 80, 73); 







--  I was working on 2 sepearte files, hence this allowed me to use the correct database.
USE supply_chain;


-- ---------- VIEW
/**
 * Issue: Initally I was repeating  DATEDIFF(delivery_time, sent_time)  in previous queries INCLUDING trial and error
 * Solution: I created VIEW so i dont have to write datediff in every query
 * Outcome: able to use the alias remove repetition  easier 
 */
CREATE VIEW delivery_days_view AS
SELECT 
    delivery_id,
    DATEDIFF(delivery_time, sent_time) AS delivery_days
FROM deliveries
WHERE delivery_time IS NOT NULL;


--  DELIMITER --
/*
 --  This function is called in retirval 5 therefore must be run prior
 -- PURPOSE: Catergorises prodcuts by price. 
 */

DELIMITER // 
CREATE FUNCTION product_price_cat(price INT)
 RETURNS varchar(35)
 DETERMINISTIC
 BEGIN
	 IF price <100 THEN
	  RETURN 'cheap-expense';
	  
	 ELSEIF price < 500 THEN
        RETURN 'Moderate-expense';
    ELSE
        RETURN 'Expensive';
    END IF;
END //
DELIMITER ;



/************************
 * Retrivals 
 **********************/

--  QUERY 1 Retrival 1.
-- All products from products table from the most expensive to least EXPENSIVE 
-- Question answered:  What are our most expensive/ valuable products?
-- DATA SHOWS: HIGHEST- COST value product samsung and macbook and monitor

SELECT *
FROM products
ORDER BY price DESC;


/* QUERY 2: Retrival 2.
-- Which products are under £100, and which is the cheapest?
-- Question answered: "Which budget products should we market?"
-- DATA: statinaory pack price 30 backpack price 32 book pack price 50 
 */

SELECT * 
FROM products 
WHERE 
     price <100
ORDER BY price ASC;


/* Retrivals 3.
-- All deliveres that is still pending currenlty at null
-- Questions: which products are still in delivery?
-- Importance : Differentiate pending items vs delivered 

*/

SELECT * 
FROM deliveries
WHERE delivery_time IS NULL
ORDER BY sent_time ASC;

/***  Retrival 4. 
-- Purpose: How long it took for products to be delivered  for those that are not NULL 
-- Utilised:  VIEW TABLE to avoid reptition
-- Question : Which products were delivered the fastest?

-- DATA SHOWS:
-- Samsung mobile, stationery pack, Book pack, and Backpack were delivered the fastest in 1 day.
-- Nintendo took 2 days, school pack took 5 days, and Macbook took the longest at 6 days.
-- This shows that delivery times varies across products.
-- It helps identify fast and slow deliveries for performance monitoring.
*/

SELECT 
     d.delivery_id AS Delivery_ID, 
     p.product_name AS Product_Name,
     v.delivery_days AS Delivery_Days
FROM deliveries d
INNER JOIN products p
     ON d.product_id = p.product_id
INNER JOIN delivery_days_view v
     ON d.delivery_id = v.delivery_id
ORDER BY Delivery_Days ASC;

/* Retrival 5. 
 
-- Catergoriesed products in price 
-- call Function product_price_cat: Catergoriesed as cheap-expense, moderate-expense, expensive
-- inner join
-- to get supplier name
-- product and suplier join 

-- question: 
-- What price catergory does each product fall into?

-- - Helps identify budget vs expensive suppliers
 --- Useful for supplier evaluation and product planning in  a more user-friendly way 
 
 */

SELECT 
     p.product_name AS Product_Name, 
     s.supplier_name AS Supplier_Name,
     product_price_cat(p.price) AS Price_Category
FROM products p
INNER JOIN supplier s
     ON p.supplier_id = s.supplier_id;

/******
 * Purpose:
 * Which warehouse sent which product and quantity?
 * Inner joins: 
 * -- Connect deliveries FK product_id TO products PK product_id --> in order to get product name  
 * -- Connect deliveries FK location_id TO warehouse PK location_id --> in order to get warehouse name
 * 
 * WHY Importance : 
 * Idenfity warehouse may require more resources they could be underperforming or due to  resource allocation and logistics planning
 * 
 * DATA SHOWS: 
 * Higher quantity in delviery does not result to slower delviery 
 * - backpack  took 1 day despite having highest quanity 
 * -Amazon warehouse has the slowest deliveries in this dataset, taking 5 to 6 days
 
 * Other factors like warehouse location may be more important. 
 * 
 * MYSELF: initially I didnt have view but I added it later 
 *
 *********/
SELECT 
     d.delivery_id AS Delivery_ID, 
     d.quantity AS Quantity_sold, 
     p.product_name AS Product_Name, 
     w.location_name AS Warehouse_Name,
     v.delivery_days AS Delivery_Days
     
FROM deliveries d
INNER JOIN products p
     ON d.product_id = p.product_id
INNER JOIN warehouse w
     ON d.location_id = w.location_id
INNER JOIN delivery_days_view v
     ON d.delivery_id = v.delivery_id
ORDER BY d.quantity DESC;







-- --------------------AGGRAGATE -------------------------


/* PURPOSE: Average delivery days
 * WHY Importance : 
 * Track delivery time it takes based on all suppliers, set customer expectations
 * Excludes NULL (pending) deliveries 
 * DATA SHOWS:
 *  ON avergae delivery time for all supply is 2.4 days
 * ASK? how can we impove this
 * */

SELECT 
      AVG(DATEDIFF(delivery_time, sent_time)) AS average_days
FROM deliveries
WHERE delivery_time 
     IS NOT NULL;

/* PURPOSE: Average delivery cost per shipment
 * IMPORTANCE : Budget planning and cost monitoring */
SELECT 
   AVG(delivery_cost) AS avergae_cost_delviery
FROM deliveries;



/*Query
 * Purpose: Total delievered quantity per product 
 * Inner join:  
 * Connect deliveries FK product_id TO products PK product_id --> in order to get product name  
 * I can remove product id for  usability 
 * 
 * WHY Importance:
 * - Company should know which product is delivered most customer consumption
 * - which products customers purchase 
 * 
 * DATA SHOWS:
 * - Back pack has the most delviered item book pack has the loweest 
 */
SELECT 
     d.product_id AS Product_ID,
     p.product_name AS Product_Name, 
     SUM(d.quantity) AS Total_Products_Delivered
FROM deliveries d
INNER JOIN products p
     ON d.product_id = p.product_id
GROUP BY d.product_id, p.product_name;




-- Delete delivery_time if its before sent_time
DELETE FROM deliveries
WHERE delivery_time < sent_time;

/********
 * QUERY purpose: 
 *  TO  see how long it takes for products to be delviered from supplier 
 *  EVALUATE which supplier takes longest in delivery 
 * 
 * 
 * 1. AVG time it take for delivery  per product
 * 2. Excludes pending deliveries (not null)
 * 3.inner join:  
 * 1. gets delivery (FK) to product (PK product_id)  gets product names
 * 2. connects products fk supplier_id to supplier PK supplier_id  to get supplier name 
 
 */
--  RELATION TO PREVIOUS QUERY:
-- The previous query calculates the overall average delivery time for all suppliers (which was about 2.4 days)
-- This query breaks that average down by product and supplier
-- DATA SHOWS:
-- from here it shows that some suppliers deliver faster than others.
-- Samsung, Stationery, Book, and Everyday suppliers deliver 1 day (fastest)
-- School and Apple suppliers = 5–6 days (slowest)


SELECT 
     p.product_name,
     s.supplier_name,
     AVG(DATEDIFF(delivery_time, sent_time)) AS average_days
FROM deliveries d
INNER JOIN products p
     ON d.product_id = p.product_id
INNER JOIN supplier s
     ON p.supplier_id = s.supplier_id
WHERE delivery_time IS NOT NULL
GROUP BY p.product_name, s.supplier_name
ORDER BY average_days ASC;


-- Delievry cost  by supplier 
/****
 * QUERY purpose:
 * Cost of delivery for each supplier 
 * 
 * Inner join:
 * 1. gets delivery (FK product_id)  to product (PK product_id) – gets product name
 * 2. gets product  (FK supplier_id)  to supplier (PK supplier_id) – gets supplier name 
 * 3. Order by:  cost DESC high-to-low

 * DATA SHOWS: 
 * SOME suppliers have higher delviery cost despite simialir quantity e.g. apple and school
 * E.g. everyday supplier delievers at a lower cost 
 * next step: Investigate why certain suppliers have higher delivery costs
 */
SELECT 
     s.supplier_name AS Supplier, 
     d.quantity AS Quantity, 
     d.delivery_cost AS Delivery
FROM deliveries d
INNER JOIN products p
     ON d.product_id = p.product_id
INNER JOIN supplier s
     ON p.supplier_id = s.supplier_id
ORDER BY
      d.delivery_cost DESC;


 -- case -- -------------------------------------------- CASE QUERY ------------------------------------------------
/* 
 * Utilises the view delivery_days_view  gives the id and dats
 * CASE checks delivery_days and returns:  Fast delivery ,average delivery, slow delievery
 * Categorise the  delivery speed using the delivery_days_view
 */

SELECT 
    delivery_days,
    CASE 
        WHEN delivery_days <= 2 THEN 'Fast delivery'
        WHEN delivery_days <= 4 THEN 'average delivery '
        ELSE 'slow delievery '
    END AS delivery_status
FROM delivery_days_view;






/*
 * FINDING:
 * FROM this project we are able to identify that some suppliers deliver products faster in comaprions to others.
 * We found that number of delivery quantity doesnt  results to later delviery dates.
 * However, late delivery can be due to location as there is a correlation  where amazon warehouse has the latest delivery time.
 * NEXT STEP:
 * Investigate warehouse locations .
 * Solutions: If location is a key influence to late delivery time, we can implement strategies to improve delivery.
 */






