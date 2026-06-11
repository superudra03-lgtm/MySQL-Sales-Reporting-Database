USE SalesReporting;

# IR#1 Retail Account Executives in Northeast Region
SELECT e.empID, e.empname, r.Region, p.PosName
FROM slsemp e, region r, slspos p
WHERE e.RegionID = r.RegionID
  AND e.PosID    = p.PosID
  AND r.Region   = 'Northeast'
  AND p.PosName  = 'Retail Account Executive';
  

# IR#2 Full-time Retail Account Executives in Northeast
SELECT e.empID, e.empname, r.Region, p.PosName
FROM slsemp e, region r, slspos p
WHERE e.RegionID = r.RegionID
  AND e.PosID    = p.PosID
  AND r.Region   = 'Northeast'
  AND p.PosName  = 'Retail Account Executive'
  AND e.prtime   = 'No';
  

# IR#3 Count of Part-time vs Full-time Retail Account Executives by Region
SELECT r.Region,
       CASE WHEN e.prtime = 'Yes' THEN 'Part-Time'
            ELSE 'Full-Time' END AS employment_type,
       COUNT(e.empID) AS employee_count
FROM slsemp e, region r, slspos p
WHERE e.RegionID = r.RegionID
  AND e.PosID    = p.PosID
  AND p.PosName  = 'Retail Account Executive'
GROUP BY r.Region, employment_type
ORDER BY r.Region, employment_type;


# IR#4 Total Quantity Sold by Region and Position
SELECT r.Region,
       p.PosName,
       SUM(t.Qty) AS total_qty_sold
FROM region r, slspos p, slsemp e, slstranx t
WHERE e.RegionID = r.RegionID
  AND e.PosID    = p.PosID
  AND t.empID    = e.empID
GROUP BY r.Region, p.PosName
ORDER BY r.Region, p.PosName;


# IR#5 Add Total Sales Amount and Average Price per Unit
SELECT r.Region,
       p.PosName,
       SUM(t.Qty) AS total_qty_sold,
       SUM(t.Qty * t.UnitPrice) AS total_sales_amount,
       FORMAT(SUM(t.Qty * t.UnitPrice) / SUM(t.Qty), 2) AS avg_price_per_unit
FROM region r, slspos p, slsemp e, slstranx t
WHERE e.RegionID = r.RegionID
  AND e.PosID    = p.PosID
  AND t.empID    = e.empID
GROUP BY r.Region, p.PosName
ORDER BY r.Region, p.PosName;


# IR#6 Region and Position where Total Quantity < 500
SELECT r.Region,
       p.PosName,
       SUM(t.Qty) AS total_qty_sold
FROM region r, slspos p, slsemp e, slstranx t
WHERE e.RegionID = r.RegionID
  AND e.PosID    = p.PosID
  AND t.empID    = e.empID
GROUP BY r.Region, p.PosName
HAVING SUM(t.Qty) < 500
ORDER BY total_qty_sold ASC, r.Region, p.PosName;


# IR#7 Employees Selling More Than Average Quantity in a Single Day
SELECT DISTINCT e.empID, e.empname
FROM slsemp e,
     (SELECT t.empID, t.SalesDate, SUM(t.Qty) AS daily_qty
      FROM slstranx t
      GROUP BY t.empID, t.SalesDate) d
WHERE e.empID = d.empID
  AND d.daily_qty > (
        SELECT AVG(x.daily_qty)
        FROM (SELECT empID, SalesDate, SUM(Qty) AS daily_qty
              FROM slstranx
              GROUP BY empID, SalesDate) x
      )
ORDER BY e.empID;


# IR#8 Count Distinct Employees in Sales Transactions
SELECT COUNT(DISTINCT t.empID) AS distinct_employee_count
FROM slstranx t;


# IR#9 Total Quantity Sold per Product (Descending)
SELECT pr.Proddescr AS product,
       SUM(t.Qty)   AS total_qty_sold
FROM product pr, slstranx t
WHERE pr.ProdID = t.ProdID
GROUP BY pr.Proddescr
ORDER BY total_qty_sold DESC, product;


# IR#10 West Region Employees with No Sales Activity
SELECT e.empID, e.empname
FROM (slsemp e, region r)
LEFT OUTER JOIN slstranx t ON e.empID = t.empID
WHERE e.RegionID = r.RegionID
  AND r.Region   = 'West'
  AND t.empID IS NULL
ORDER BY e.empID;

