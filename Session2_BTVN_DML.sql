-- 1. Báo cáo tổng doanh thu từng đơn hàng
SELECT o.*, sum(od.Price*od.Quantity) as total_benefit
	FROM orders o
    INNER JOIN orderdetails od ON od.OrderID = o.OrderID
    GROUP BY o.OrderID
;

-- 2. Báo cáo số lượng sản phẩm đã bán theo danh mục
SELECT c.CategoryName, sum(Quantity) as total_products_sold
	FROM categories c
    LEFT JOIN products p ON p.CategoryID = c.CategoryID 
    LEFT JOIN orderdetails od ON od.ProductID = p.ProductID
	GROUP BY c.CategoryName
    ORDER BY total_products_sold DESC
;

-- 3. Báo cáo danh sách khách hàng và số lượng đơn hàng mỗi khách hàng đã đặt
SELECT cus.*, count(o.CustomerID) as total_orders
	FROM customers cus
    LEFT JOIN orders o ON o.CustomerID = cus.CustomerID
    GROUP BY cus.CustomerID
;

-- 4. Báo cáo tỷ lệ đơn hàng đã giao thành công
SELECT o.Status, (count(o.Status)/sum(o.OrderID))*100 as total_completed_rate
	FROM orders o
    WHERE o.Status = 'Delivered'
    GROUP BY o.Status
;

-- 5. Báo cáo đánh giá sản phẩm và điểm đánh giá trung bình cho mỗi sản phẩm
SELECT p.ProductID,p.ProductName, avg(rw.Rating) as AVG_rating,
		(SELECT count(rw.Rating) FROM reviews rw WHERE rw.Rating = 5 and rw.ProductID = p.ProductID ) as rating_5,
		(SELECT count(rw.Rating) FROM reviews rw WHERE rw.Rating = 4 and rw.ProductID = p.ProductID ) as rating_4,
		(SELECT count(rw.Rating) FROM reviews rw WHERE rw.Rating = 3 and rw.ProductID = p.ProductID ) as rating_3,
		(SELECT count(rw.Rating) FROM reviews rw WHERE rw.Rating = 2 and rw.ProductID = p.ProductID ) as rating_2,
		(SELECT count(rw.Rating) FROM reviews rw WHERE rw.Rating = 1 and rw.ProductID = p.ProductID ) as rating_1
	FROM products p
	LEFT JOIN reviews rw ON rw.ProductID = p.ProductID
	GROUP BY p.ProductID
;

-- 6. Liệt kê các sản phẩm được đặt hàng nhiều nhất
SELECT p.*, sum(od.quantity) as total_orders
		FROM products p 
		INNER JOIN orderdetails od ON od.ProductID = p.ProductID
        GROUP BY p.ProductID
        HAVING sum(od.Quantity) = (SELECT max(total_ordered) FROM
																(SELECT p.*,sum(od.Quantity) as total_ordered
																		FROM products p 
																		INNER JOIN orderdetails od ON od.ProductID = p.ProductID
																		GROUP BY p.ProductID) as p)
;

-- 7. Tìm kiếm sản phẩm dựa trên mức đánh giá trung bình
SELECT p.ProductID, p.ProductName, rw.Rating
	FROM products p
    INNER JOIN reviews rw ON rw.ProductID = p.ProductID
    INNER JOIN (SELECT p.ProductID,p.ProductName, avg(rw.Rating) as Avg_rating
							FROM products p
							LEFT JOIN reviews rw ON rw.ProductID = p.ProductID
							GROUP BY p.ProductID) as avg_rate ON avg_rate.ProductID = p.ProductID
    WHERE rw.Rating > avg_rate.Avg_rating
;

-- 8. Tìm khách hàng có đơn hàng có giá trị cao nhất
SELECT cus.*, tbl_benefit.total_benefit
	FROM customers cus
	INNER JOIN (SELECT o.*, sum(od.Price*od.Quantity) as total_benefit
					FROM orders o
					INNER JOIN orderdetails od ON od.OrderID = o.OrderID
					GROUP BY o.OrderID) as tbl_benefit ON cus.CustomerID = tbl_benefit.CustomerID
WHERE tbl_benefit.total_benefit = (SELECT max(total_benefit) FROM (SELECT o.*, sum(od.Price*od.Quantity) as total_benefit
																		FROM orders o
																		INNER JOIN orderdetails od ON od.OrderID = o.OrderID
																		GROUP BY o.OrderID) as tbl_benefit)
;

-- 9. Tổng doanh thu từng tháng trong năm
SELECT month(o.OrderDate) as Tháng, sum(tbl_benefit.total_benefit) as Tổng_doanh_thu
	FROM orders o
    INNER JOIN (SELECT o.*, sum(od.Price*od.Quantity) as total_benefit
				FROM orders o
				INNER JOIN orderdetails od ON od.OrderID = o.OrderID
				GROUP BY o.OrderID) as tbl_benefit ON tbl_benefit.OrderId = o.OrderId
	GROUP BY Tháng
	ORDER BY Tháng ASC
;