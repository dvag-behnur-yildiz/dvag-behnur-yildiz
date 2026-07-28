SQL- Lernnotizen:

Compound operator: +=
Not Equal oeprator: <>
IS NOT !=
Primary Keys may not have NULL fields.

Data types :
VARCHAR
TEXT
CHAR
INT, SMALLINT

! TIMESTAMP is not a data type.

SELECT city, city_code FROM Customers;

-- liefert all different values from Country column in the costumer table
-- would return all values in the Country column, including duplicates values
select distinct Country from Customer;

-- returns the number of different countries in the customers table
select count(distinct country) from Customers;

-- WHERE clause to filter records that meet a specified condition
select * from Customers
where country = 'Mexico';

-- ORDER BY sorts records in ascending or descending order
-- from highest to lowest price
select * from Products ORDER BY Price DESC;

-- alphabetically by the column City
select * from Customers
ORDER BY city;

-- and reserved sorted:
select * from Customers
ORDER BY city DESC;

-- select all records from the 'Customers' table, sorted the result alpabecitally, first by the column 'Country', then 'City'
select * from Customers
ORDER BY Country, City;

-- without the sorting ASC/DESC ist the default worth: ASC
-- 'AND' und'OR' Operators can be combined.

-- WHERE NOT Condition
select * from Customers
WHERE NOT City = 'Berlin';

-- WHERE ... NOT LIKE
select * from Customers
WHERE CustomerName NOT LIKE 'A%';

--WHERE ... NOT BETWEEN
select * from Customers
WHERE CustomerID NOT BETWEEN 10 AND 50;

-- NOT IN
select * from Customers WHERE City NOT IN ('Paris', 'London');

-- Purpose of INSERT INTO is the adding new records to a table

INSERT INTO Customers (CustomerName, City, Country)
VALUES ('Cardinal', 'Stavanger', 'Norway');

insert into Customers (CustomerName, Address, City, PostalCode, Country)
values ('Hekkan Burger', 'Gateveien 15', 'Sandnes', '4306', 'Norway');
insert into table (value1), (value2), (value3);

-- IS NULL
-- a field with no value (NULL). You test for NULL values in SQL per IS NULL operator

select * from Customers Where Address IS NULL;

-- IS NOT NULL
select * from Customers
where PostalCode IS NOT NULL;

-- UPDATE
-- purpose of the SQL Update statement is modifying existing records in a table

-- UPDATE SET
update Customers
set City = 'Oslo';

update Customers
set City = 'Istanbul',
Country = 'Turkiye'
where CustomerID = 32;

-- DELETE FROM : to delete existing records from a table
delete from Customers
where City = 'Moscow';

-- delete all records from the Customers table (table has not been deleted)
delete from Customers;

-- select the first 5 records from Customers table
delete top 5 * from Customers;

select * FROM Customers
ORDER BY CustomerName DESC
LIMIT 3;

-- MIN() - returns the smallest value of the selected column
-- MAX() - returns the highest value of the selected column
select min(price)
from Products;

-- AS is used to be give a column a descriptive name
-- COUNT() : Returns the number of rows that match a specified criterion

select count(*) from Products
where Price = 18;

-- Distinct keyword can be used to ignore duplicates

-- SUM() returns the total sum of a numeric column
select sum(Price)
from Products;

-- AVG() returns average value of a numeric column. Null worths have been ignored.
select avg(Prices)
from Products;

-- the underscore sign (_) represents any single character
-- the % represents zero or any character.

--second letter is 'a':
SELECT * FROM Customers
WHERE City LIKE '_a%';

-- LIKE '[af]%' -- starts with a or z 
SELECT * FROM Customers
WHERE City LIKE '[acs]%';

-- NOT LIKE '[!af]%' -- starts neither with a nor f
SELECT * FROM Customers
WHERE City LIKE '[!acs]%';

-- RANGE : starts with any character from a until f
SELECT * FROM Customers
WHERE City LIKE '[a-f]%';

-- IN operator
select * from Customers where Country in ('Germany', 'UK');

-- NOT IN operator
select * from Customers where Country NOT in ('Germany', 'UK');

-- WHERE ... BETWEEN
select * from Products
where Price Between 10 and 20;

select * from Products
where Price Between 'Apple' and 'Orange';

-- SQL statement creates an alias for the CustomerID column as 'ID'
select CustomerID AS ID from Customers;
select CustomerID AS [Customer ID] from Customers; 

-- JOIN combines rows from two or more tables based on a related column
-- LEFT JOIN : All records from the left table and matched records from the right table
-- In some databases LEFT JOIN is called LEFT OUTER JOIN
select from Orders
LEFT JOIN Customers
ON Orders.CustomerID = Customers.CustomerID;

-- INNER JOIN returns only the matching rows between tables based on a common column, excluding non-matching rows.
select * from Orders
INNER JOIN Customers
ON Orders.CustomerID = Customers.CustomerID;

-- FULL OUTER JOIN / FULL JOIN includes matching rows as well as non-matching rows from one or both tables.

-- for joining the Products and Categories tables on CategoryID
SELECT * FROM Products
INNER JOIN Categories 
ON Products.CategoryID = Categories.CategoryID;

-- RIGHT JOIN - Returns all records from the right table and matching records from the left table
-- RIGHT JOIN == RIGHT OUTER JOIN

-- SELF JOIN -- creats new table with the same table
SELECT A.CustomerName, B.CustomerName
FROM Customers A, Customers B
WHERE A.City = B.City;

-- UNION - To combine the result-sets of two or more SELECT statements
-- UNION removes duplicates by default, while UNION ALL includes all rows (with duplicated)

SELECT count(CustomerID), Country
FROM Customers group by country;

##########################
## Examples for GROUP BY:
1. List the number of customers in each country, ordered by the country with the most customers first.
select count(CustomerID), Country
From Customers
GROUP BY Country
ORDER BY (Count(CustomerID) DESC);

-- the primary purpose of the GROUP BY statement is grouping rows with the same values into summary rows
-- Use the ORDER BY clause after the GROUP BY clause for sorting the results.
-- HAVING BY : To filter groups based on an aggregate condition after grouping
-- DIFFERENCES BETW. WHERE AND GROUP BY : The WHERE clause filters rows; the HAVING clause filters groups
-- Returns TRUE if all subquery values meet the condition

2. SQL query correctly filters groups where the total number of orders is greater than 100

SELECT CustomerID, COUNT(OrderID)
FROM Orders
GROUP BY CustomerID
HAVING COUNT(OrderID) > 100;


3. SELECT Employees.LastName, COUNT(Orders.OrderID) AS NumberOfOrders
   FROM (Orders INNER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID)
   GROUP BY LastName
   HAVING COUNT(Orders.OrderID) > 10;
   
4. SELECT SupplierName FROM Suppliers
 WHERE EXISTS (SELECT ProductName FROM Products WHERE Products.SupplierID = Suppliers.supplierID AND Price < 20); 
 
5. returns 1 (True) if any values meet the condition
SELECT * FROM Products
WHERE ProductID = ANY
(SELECT ProductID FROM OrderDetails);

SELECT ProductName FROM Products
WHERE ProductID  
(SELECT ProductID = ANY
FROM OrderDetails
WHERE Quantity > 10);

6. returns 1 (True) if all values meet the condition  
SELECT ProductName FROM Products
WHERE ProductID = ALL
(SELECT ProductID FROM OrderDetails);

SELECT ProductName
FROM Products
WHERE ProductID  
(SELECT ProductID = ALL
FROM OrderDetails
WHERE Quantity = 10);

7. Copy all rows from Customers into the CustomerBackup Table:
SELECT * INTO CustomersBackup FROM Customers;

8. SELECT Customers.CustomerName, Orders.OrderID INTO CustomersOrderBackup FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

##########################

-- INSERT INTO 
INSERT INTO Customers (CustomerName, City)
SELECT SupplierName, City FROM Suppliers;

