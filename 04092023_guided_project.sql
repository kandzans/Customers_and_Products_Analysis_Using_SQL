/*

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+Guided Project: Customers and Products Analysis Using SQL +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Introduction:

Within the scope of this project, SQL is used to analyze the scale car model database.
The project revolves around three central questions, which are:

Question 1: Which products should we order more of or less of?
Question 2: How should we tailor marketing and communication strategies to customer behaviors?
Question 3: How much can we spend on acquiring new customers?

There are 8 tables within the database's structure:

1) Customers
Description: Stores information about the customers who have made purchaces
Columns: customerNumber (PK), customerName, contactLastName, contactFirstName, phone, addressLine1, addressLine2,  city, state, postalCode, country, salesRepEmployeeNumber (FK), creditLimit

2) Employess
Description: Stores details about the employees working at the Classic Model Cars company
Columns: employeeNumber (PK), lastName, firstName, extension, email, officeCode (FK), reportsTo (FK)

3) Offices
Description: Includes information about the  Classic Model Cars company offices
Columns: officeCode(PK), city, phone, addressLine1, addressLine2, state, country, postalCode, territory

4) Orderdetails
Description: Contains information about orders, their quantity and price 
Columns: orderNumber(PK), productCode(PK),  quantityOrdered,  priceEach,  orderLineNumber

5) Orders
Description: Stores information about customer  orders and their status 
Columns: orderNumber(PK), orderDate, requiredDate, shippedDate, status, comments, customerNumber(FK)

6) Payments 
Description: Includes information about customer made payments
Columns: customerNumber(PK), checkNumber(PK), paymentDate, amount

7) productlines
Description: Stores information about product lines
Columns: productLine(PK), textDescription, htmlDescription, image

8) products
Description: Includes information about products available for sale to customers 
Columns: productCode(PK), productName, productLine(FK), productScale, productVendor, productDescription, quantityInStock, buyPrice, MSRP

 -- Below are the SQL queries designed for analyzing the database

*/

-- Screen 3: Scale Model Cars Database
-- Write a query to display table names, number of attributes and rows of the tables
SELECT 'Customers' AS table_name, 
			13 AS number_of_attributes,
			COUNT(*) AS number_of_rows 
   FROM Customers
   
UNION ALL

SELECT 'Products', 9, COUNT(*) FROM Products

 UNION ALL

 SELECT 'ProductLines', 4, COUNT(*)  FROM ProductLines

 UNION ALL

SELECT 'Orders', 7, COUNT(*) FROM Orders

UNION ALL

SELECT 'OrderDetails', 5, COUNT(*) FROM OrderDetails

UNION ALL

SELECT 'Payments', 4, COUNT(*) FROM Payments

UNION ALL

SELECT 'Employees', 8, COUNT(*) FROM Employees

UNION ALL

SELECT 'Offices', 9, COUNT(*) FROM Offices;

-- Screen 4: Question 1: Which Products Should We Order More of or Less of?
-- Write a query to compute the low stock for each product using a correlated subquery.
SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                             FROM products p
                                            WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10;
 
-- Write a query to compute the product performance for each product.
SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS product_performance
  FROM orderdetails od
 GROUP BY productCode 
 ORDER BY product_performance DESC
 LIMIT 10;

-- Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using the IN operator.
WITH 

low_stock_table AS (
SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0/(SELECT quantityInStock
                                           FROM products p
                                          WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10
)

SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS product_performance
  FROM orderdetails od
 WHERE productCode IN (SELECT productCode
                         FROM low_stock_table)
 GROUP BY productCode 
 ORDER BY product_performance DESC
 LIMIT 10;

-- Screen 5: Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
-- Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place.
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit_from_customer
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber;

  -- Screen 6: Finding the VIP and Less Engaged Customers
  -- Write a query to find the top five VIP customers.
WITH 

profit_from_customer AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT contactLastName, contactFirstName, city, country, pc.profit
  FROM customers c
  JOIN profit_from_customer pc
    ON pc.customerNumber = c.customerNumber
 ORDER BY pc.profit DESC
 LIMIT 5;

 -- Write a query to find the top five least-engaged customers.
WITH profit_from_customer AS (

SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders o
  JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
  JOIN products p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
 )
  
SELECT contactLastName, contactFirstName, city, country, pc.profit
  FROM customers c
  JOIN profit_from_customer pc
    ON c.customerNumber = pc.customerNumber
 ORDER BY profit 
 LIMIT 5;

 -- Screen 7: Question 3: How Much Can We Spend on Acquiring New Customers?
 -- Write a query to compute the average of customer profits using the CTE on the previous screen.
WITH 

profit_from_customer AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT AVG(pc.profit) AS average_of_customer_profit
  FROM profit_from_customer pc;

/*

Conclusion:

Question 1: Which products should we order more of or less of?

After assessing low-stock products and product performance data, it was identified that the classic cars product line should be restocked more often.
This assumption has been based on the highest-performing product data where classic cars emerged 6 out of 10 times.

Question 2: How should we tailor marketing and communication strategies to customer behaviors?

After reviewing top and least-engaged customers, it is crucial to keep all customers and try to expand sales.
For the ones that give the most profit, a loyalty program establishment should be considered. It could include priority assistance, discounts, and special events.
Meanwhile, a questionnaire to acquire feedback on current cooperation should be established for those who have been less engaged.
It can be an online survey and would give first insight results before making the next steps for a tailored campaign.

Question 3: How much can we spend on acquiring new customers?

The average amount of money generated (customer lifetime value) by a customer is $ 39,040. This implies that a new customer generates a profit equal to the previously mentioned amount.
This data empowers us to approximate the budget for acquiring new clients before taking further actions. 
The more new customers are found, the higher the will be profit, so it is worth investing in marketing-related activities.

/*