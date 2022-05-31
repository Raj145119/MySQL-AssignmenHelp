-- hw5.sql
--   your name 
-- 1  Mapping of production to warehouse tables and columns
--
--  your answer here 

-- Answer =>
/* 
NOTE: These are the actual transformations, and do not include the same data column in 
different tables (for example, LINE_ITEM.Quantity appears as product_sales.Quantity,
but there is no change either in the column name or data type).
*/
PRODUCT.ProductDescription -> product.producttype

PRODUCT.ProductDescription -> product.productname

(CUSTOMER.LastName +', '+CUSTOMER.FirstName) -> customer.customername

CUSTOMER.EmailAddress -> customer.emaildomain

CUSTOMER.Phone -> customer.phoneareacode

(LINE_ITEM.Quantity * LINE_ITEM.UnitPrice) -> product_sales.total


-- 2 Load data for table sales_for_rfm  
insert 4; 

 Answer => 
1	3	VB001	1	7.99	7.99
1	3	VK001	1	14.95	14.95
5	6	BK002	1	24.95	24.95
5	7	BK002	1	24.95	24.95
5	7	VK003	1	19.95	19.95
5	7	VK004	1	24.95	24.95
6	9	BK001	1	24.95	24.95
6	9	VB001	1	7.99	7.99
6	9	VK001	1	14.95	14.95

7	11	VK004	2	24.95	49.90
8	1	BK001	1	24.95	24.95
/* INSERT INTO product_sales VALUES(1, 3, 'VK001', 1, 14.95, 14.95);        */

/* INSERT INTO product_sales VALUES(1, 3, 'VB001', 1, 7.99, 7.99);*/

INSERT INTO sales_for_rfm VALUES(1, 3, 35000, 22.94);


/* INSERT INTO product_sales VALUES(2, 4, 'VK001', 1, 14.95, 14.95);        */

/* INSERT INTO product_sales VALUES(2, 4, 'VB001', 1, 7.99, 7.99);          */

/* INSERT INTO product_sales VALUES(2, 4, 'BK001', 1, 24.95, 24.95);        */

INSERT INTO sales_for_rfm VALUES(2, 4, 35001, 47.89);


/* INSERT INTO product_sales VALUES(3, 7, 'VK004', 1, 24.95, 24.95);*/

INSERT INTO sales_for_rfm VALUES(3, 7, 35002, 24.95);


/* INSERT INTO product_sales VALUES(6, 7, 'BK001', 1, 24.95, 24.95); */

/* INSERT INTO product_sales VALUES(6, 7, 'BK002', 1, 24.95, 24.95); */

/* INSERT INTO product_sales VALUES(6, 7, 'VK003', 1, 19.95, 19.95); */

/* INSERT INTO product_sales VALUES(6, 7, 'VK004', 1, 24.95, 24.95); */

INSERT INTO sales_for_rfm VALUES(6, 7, 35005, 94.80);


/* INSERT INTO product_sales VALUES(8, 11, 'VK003', 2, 19.95, 39.90); */

/* INSERT INTO product_sales VALUES(8, 11, 'VB003', 2, 9.99, 19.98); */

/* INSERT INTO product_sales VALUES(8, 11, 'VK004', 2, 24.95, 49.90); */

INSERT INTO sales_for_rfm VALUES(8, 11, 35007, 109.78);


/* INSERT INTO product_sales VALUES(7, 5, 'BK001', 1, 24.95, 24.95); */

/* INSERT INTO product_sales VALUES(7, 5, 'VK001', 1, 14.95, 14.95); */

/* INSERT INTO product_sales VALUES(7, 5, 'VB001', 1, 7.99, 7.99); */

INSERT INTO sales_for_rfm VALUES(7, 5, 35008, 47.89);



-- 3  create view of total dollar amount of each product for each year 
create view ; 

CREATE VIEW HSDDWproductDollarSalesView AS
SELECT c.customerid, c.customername, c.city, 
p.productnumber, p.productname,
t.year,t.quartertext, 
SUM(ps.total) AS TotalDollarAmount
 FROM customer c, product_sales ps, product p,
      timeline t
WHERE c.customerid = ps.customerid 
      AND p.productnumber = ps.productnumber
      AND t.timeid = ps.timeid
GROUP BY c.customerid, c.customername, c.city, 
         p.productnumber, p.productname, 
         t.quartertext, t.year;
		 
-- See SQL Query Result 

SELECT * FROM HSDDWproductDollarSalesView
ORDER BY customername, year, quartertext;



-- 4  populate the product_sales table with the new payment_id column.
insert 6; 

--Answer => 

/*	We will also need to modify the product_sales  fact table by
 adding a payment_type_id column and a foreign key constraint. 
 This column will first be set to NULL, but after it is populated, 
 it will have to be reset to NOT NULL.*/
 
ALTER TABLE product_sales ADD payment_type_id Int NULL;

ALTER TABLE  product_sales ADD CONSTRAINT  PAY_TYPE_FK FOREIGN KEY (payment_type_id) 
REFERENCES payment_type(payment_type_id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


--Now, we need to know what PaymentType was made for each Sale in the HSDDW

INSERT INTO product_sales VALUES(1, 3, 'VK001', 1, 14.95, 14.95);

INSERT INTO product_sales VALUES(1, 3, 'VB001', 1, 7.99, 7.99);

/* Note that each comment includes both the InvoiceNumber and the TimeID number. As InvoiceNumbers do not appear in product_sales,
 we will use the TimeID values for our UPDATE statements. 
 We will need to use these annotations together with the results of the query matching InvoiceNumber 
 and PaymentType to modify each line of the file as follows: */

INSERT INTO product_sales VALUES(2, 3, 'VK001', 1, 14.95, 14.95);

INSERT INTO product_sales VALUES(2, 3, 'VB001', 1, 7.99, 7.99);

--  Becomes:

UPDATE product_sales SET Payment_type_id = 1

WHERE timeid = 1

AND customerid = 3

AND productnumber = 'VK001';


UPDATE product_sales SET payment_type_id = 1

WHERE timeid = 2

AND customerid = 3

AND productnumber = 'VB001';

-- SQL views needed to return the PaymentType attribute

CREATE VIEW HSDDWProductDollarSalesPaymentTypeView AS

SELECT C.customerid, C.customername, C.city,

PT.payment_type,

P.productnumber, P.productname,

SUM(PS.total) AS TotalDollarSales

FROM customer C, product_sales PS,

product P, payment_type PT

WHERE C.customerid = PS.customerid

AND P.productnumber = PS.productnumber

AND PT.payment_type_id = PS.payment_type_id

GROUP BY C.customerid, C.customername, C.city,

P.productnumber, P.productnumber, PT.payment_type;

SELECT * FROM HSDDWProductDollarSalesPaymentTypeView;


