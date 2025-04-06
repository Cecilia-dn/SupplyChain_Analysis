


# Total orders over time
CREATE VIEW view_total_orders_over_time AS
SELECT 
    DATE_FORMAT(p.date, '%Y, %M') AS time,
    -- DATE_FORMAT(p.date, '') AS month,
    SUM(o.Quantity_Ordered) AS total_quantity_ordered
FROM  products p 
JOIN orders o ON p.Supplier_ID = o.Supplier_ID
GROUP BY time;
-- ORDER BY total_quantity_ordered DESC;

CREATE VIEW z_total_orders_over_time AS
SELECT 
    YEAR(p.date) AS year, 
    MONTH(p.date) AS month_number,  
   CONCAT(YEAR(p.date), '  ', MONTHNAME(p.date)) AS month_year, 
    SUM(o.Quantity_Ordered) AS total_quantity_ordered
FROM products p 
JOIN orders o ON p.Supplier_ID = o.Supplier_ID
GROUP BY year, month_number, month_year;

CREATE VIEW view_total_orders_over_time AS
SELECT 
    YEAR(p.date) AS year, 
    MONTH(p.date) AS month_number,  
    DATE_FORMAT(p.date, '%Y, %M') AS month_year, 
    SUM(o.Quantity_Ordered) AS total_quantity_ordered
FROM products p 
JOIN orders o ON p.Supplier_ID = o.Supplier_ID
GROUP BY year, month_number, month_year;


CREATE VIEW view_total_orders_over_time AS
SELECT 
    YEAR(p.date) AS year, 
    MONTH(p.date) AS month_number,  
    CONCAT(YEAR(p.date), '  ', LPAD(MONTH(p.date), 2, '0'), ' - ', MONTHNAME(p.date)) AS month_year, 
    SUM(o.Quantity_Ordered) AS total_quantity_ordered
FROM products p 
JOIN orders o ON p.Supplier_ID = o.Supplier_ID
GROUP BY year, month_number, month_year
ORDER BY year, month_number;




#count of total orders by month
CREATE VIEW count_of_orders_over_time AS
SELECT DATE_FORMAT(p.date, '%Y-%m') AS month, 
	COUNT(o.Order_ID) AS total_orders  
FROM products p
JOIN orders  o 
	ON p.Supplier_ID = o.Supplier_ID
GROUP BY month
ORDER BY total_orders DESC;

# supplier with the highest rating
SELECT Supplier_ID, AVG(Rating) AS avg_rating
FROM suppliers
GROUP BY Supplier_ID
ORDER BY avg_rating DESC;

SELECT Supplier_ID, Company, AVG(Rating) AS avg_rating
FROM suppliers
GROUP BY Supplier_ID, Company
ORDER BY avg_rating DESC;

# suppliers with most orders
CREATE VIEW  SupplierswiththeMostOrders AS 
SELECT s.Supplier_ID, COUNT(distinct o.Order_ID) AS Total_Orders
FROM orders o
JOIN suppliers s ON o.Supplier_ID = s.Supplier_ID
GROUP BY s.Supplier_ID
ORDER BY Total_Orders DESC;


#product in demand based on the month
SELECT p.ProductName, 
DATE_FORMAT(p.date, '%M') AS month, 
COUNT(o.Order_ID) AS order_count  
FROM products p
JOIN orders  o 
	ON p.Supplier_ID = o.Supplier_ID 
GROUP BY p.ProductName, month  
ORDER BY order_count   ASC;

SELECT p.ProductName, 
DATE_FORMAT(p.date, '%M') AS month, 
SUM(o.Quantity_Ordered) AS total_order
FROM products p
JOIN orders  o 
	ON p.Supplier_ID = o.Supplier_ID 
GROUP BY p.ProductName, month  
ORDER BY total_order   ASC;

SELECT * 
FROM products p
JOIN suppliers s
	ON p.Supplier_ID = s.Supplier_ID;
    
# total order for each product for each company
SELECT s.Company, 
	s.ProductName, 
	SUM(o.Quantity_Ordered) AS order_total
FROM suppliers s
JOIN orders o
	on s.Supplier_ID = o.Supplier_ID
GROUP BY Company, ProductName;

SELECT s.Company, 
	s.ProductName, 
	COUNT(o.Order_ID) AS order_count
FROM suppliers s
JOIN orders o
	on s.Supplier_ID = o.Supplier_ID
GROUP BY Company, ProductName;

#  Suppliers with the Shortest Lead Times
CREATE VIEW suppliers_shortest_leadtime AS
SELECT 
    s.Supplier_ID, 
    AVG(p.Lead_Time_Days) AS avg_lead_time
FROM suppliers s
JOIN products p ON s.Supplier_ID = p.Supplier_ID
GROUP BY s.Supplier_ID
ORDER BY avg_lead_time ASC
LIMIT 10;
  
  
# Most Ordered Products
CREATE VIEW most_ordered_products AS
SELECT 
    ProductName, 
    SUM(Quantity_Ordered) AS total_quantity
FROM orders
GROUP BY ProductName
ORDER BY total_quantity DESC;


# predicts when a product will run out of stock.
CREATE VIEW reorder_prediction AS 
SELECT 
    p.ProductName, 
    p.Stock_Level, 
    p.weekly_usage, 
    p.Lead_Time_Days, 
    (p.Stock_Level / p.weekly_usage) AS weeks_of_stock_left,
    DATE_ADD(CURDATE(), INTERVAL (p.Stock_Level / p.weekly_usage) * 7 DAY) AS predicted_reorder_date
FROM products p
WHERE (p.Stock_Level / p.weekly_usage) <= p.Lead_Time_Days;

# supplier performance based on the company and total orders
CREATE VIEW supplier_performance_by_company_totalorders AS
SELECT 
    s.Supplier_ID, 
    s.Company, 
    AVG(s.Rating) AS Avg_Rating,
    SUM(o.Quantity_Ordered) AS Total_Orders
FROM suppliers s
JOIN orders o ON s.Supplier_ID = o.Supplier_ID
GROUP BY s.Supplier_ID, s.Company;

# supplier performance based on the  total orders
CREATE VIEW supplier_performance_based_on_totalorders AS
SELECT 
    s.Supplier_ID,
    AVG(s.Rating) AS Avg_Rating,
    SUM(o.Quantity_Ordered) AS Total_Orders
FROM suppliers s
JOIN orders o ON s.Supplier_ID = o.Supplier_ID
GROUP BY s.Supplier_ID;


CREATE VIEW track_stock_levels AS
SELECT 
    p.ProductName, 
    p.Stock_level, 
    p.Reorder_Level, 
    p.Supplier_ID,
    p.Lead_Time_Days, 
    ((p.Stock_level - p.Reorder_Level) / (p.weekly_usage)) AS stockweeks, 
    (p.Lead_Time_Days / 7) AS LeadTime_Weeks,
    CASE 
        WHEN ((p.Stock_level - p.Reorder_Level) / (p.weekly_usage)) < (p.Lead_Time_Days / 7) 
        THEN 'Reorder'
        ELSE 'Sufficient Stock' 
    END AS status
FROM products p;
    
# Total_revenue
CREATE VIEW total_revenue AS 
SELECT 
    o.Order_ID,
    s.Company,
    o.ProductName,
    p.Unit_Price,
    o.Quantity_Ordered,
    (p.Unit_Price * o.Quantity_Ordered) AS Total_Revenue
FROM orders o
JOIN products p ON o.ProductName = p.ProductName
JOIN suppliers s ON o.Supplier_ID = s.Supplier_ID;

CREATE VIEW view_revenue_trend AS
SELECT 
    DATE_FORMAT(p.date, '%Y-%m') AS month, 
    SUM(o.Quantity_Ordered * p.Unit_Price) AS total_revenue
FROM orders o
JOIN products p ON o.ProductName = p.ProductName
GROUP BY month
ORDER BY month;



