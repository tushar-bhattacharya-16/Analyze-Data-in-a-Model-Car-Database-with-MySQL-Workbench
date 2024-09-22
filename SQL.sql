-- Q1
select * from warehouses;
-- Q2
select * from products;
-- Q3
select count(*) from products;
-- Q4
select productCode, count(warehouseCode) as warehouse from products group by productCode having count(warehouseCode) >1;
-- Q5
SELECT 
    p.warehouseCode, 
    w.warehouseName, 
    COUNT(productCode) AS total_product, 
    SUM(p.quantityInStock) AS total_stock 
FROM 
    products AS p 
JOIN 
    warehouses AS w ON p.warehouseCode = w.warehouseCode 
GROUP BY 
    p.warehouseCode, 
    w.warehouseName 
 LIMIT  0, 1000;
 -- Q6
 SELECT 
    p.warehouseCode, 
    w.warehouseName, 
    p.productLine, 
    COUNT(p.productCode) AS total_product, 
    SUM(p.quantityInStock) AS total_stock 
FROM 
    products AS p 
JOIN 
    warehouses AS w ON p.warehouseCode = w.warehouseCode 
GROUP BY 
    p.warehouseCode, 
    w.warehouseName, 
    p.productLine 
LIMIT 
    0, 1000;
-- Q7
SELECT products.productLine, count(orderdetails.productCode) AS no_of_sales
FROM products 
JOIN orderdetails 
ON products.productCode = orderdetails.productCode
GROUP By products.productLine
ORDER BY no_of_sales desc;
-- Q8 
CREATE TEMPORARY TABLE inventory_summary AS(
 SELECT
  p.warehouseCode AS warehouseCode,
  p.productCode AS productCode,
        p.productName AS productName,
  p.quantityInStock AS quantityInStock,
  SUM(od.quantityOrdered) AS total_ordered,
  p.quantityInStock - SUM(od.quantityOrdered) AS remaining_stock,
  CASE 
   WHEN (p.quantityInStock - SUM(od.quantityOrdered)) > (2 * SUM(od.quantityOrdered)) THEN 'Overstocked'
   WHEN (p.quantityInStock - SUM(od.quantityOrdered)) < 650 THEN 'Understocked'
   ELSE 'Well-Stocked'
  END AS inventory_status
 FROM products AS p
 JOIN orderdetails AS od ON p.productCode = od.productCode
 JOIN orders o ON od.orderNumber = o.orderNumber
 WHERE o.status IN ('Shipped', 'Resolved')
 GROUP BY 
  p.warehouseCode,
  p.productCode,
  p.quantityInStock
);
-- Q9
SELECT
    warehouseCode,
    inventory_status,
    COUNT(*) AS product_count
FROM inventory_summary
GROUP BY warehouseCode, inventory_status
order by warehouseCode;
-- Seems like warehouse b is having the highest overstocked product with total 29 products, while warehouse a and c having same 19 overstocked products.
SELECT
    warehouseCode,
    COUNT(*) as product_overstocked
FROM inventory_summary
WHERE inventory_status = 'Overstocked'
GROUP BY warehouseCode;
-- Q10
SELECT
p.productLine,
pl.textDescription AS productLineDescription,
SUM(p.quantityInStock) AS totalInventory,
SUM(od.quantityOrdered) AS totalSales,
SUM(od.priceEach * od.quantityOrdered) AS totalRevenue,
(SUM(od.quantityOrdered) / SUM(p.quantityInStock)) * 100 AS salesToInventoryPercentage
FROM

mintclassics.products AS p
LEFT JOIN
mintclassics.productlines AS pl ON p.productLine = pl.productLine
LEFT JOIN
mintclassics.orderdetails AS od ON p.productCode = od.productCode
GROUP BY
p.productLine, pl.textDescription
ORDER BY
salesToInventoryPercentage desc