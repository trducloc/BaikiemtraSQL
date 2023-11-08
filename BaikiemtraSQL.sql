-- Tạo bảng Categories
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
);

INSERT INTO Categories (category_id, category_name) 
VALUES
(1, 'Điện thoại di động'),
(2, 'Máy tính xách tay'),
(3, 'Thiết bị gia dụng'),
(4, 'Thời trang'),
(5, 'Giày dép');

-- Tạo bảng Products
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

INSERT INTO Products (product_id, product_name, category_id, price) 
VALUES
(1, 'iPhone 13', 1, 999.99),
(2, 'MacBook Pro', 2, 1499.99),
(3, 'Smart TV', 3, 599.99),
(4, 'Áo sơ mi nam', 4, 39.99),
(5, 'Giày thể thao', 5, 79.99);

-- Tạo bảng Customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    email VARCHAR(255)
);

INSERT INTO Customers (customer_id, customer_name, email) 
VALUES
(1, 'Nguyễn Văn A', 'nva@example.com'),
(2, 'Trần Thị B', 'ttb@example.com'),
(3, 'Lê Văn C', 'lvc@example.com'),
(4, 'Phạm Thanh D', 'ptd@example.com'),
(5, 'Hồ Minh E', 'hme@example.com');

-- Tạo bảng Orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Orders (order_id, customer_id, order_date) 
VALUES
(101, 1, '2023-01-15'),
(102, 2, '2023-02-20'),
(103, 3, '2023-03-25'),
(104, 4, '2023-04-30'),
(105, 5, '2023-05-05');

-- Tạo bảng OrderDetails
CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO OrderDetails (order_detail_id, order_id, product_id, quantity) VALUES
(201, 101, 1, 2),
(202, 101, 3, 1),
(203, 102, 2, 1),
(204, 103, 4, 3),
(205, 104, 5, 2);

-- 1. Lấy thông tin tất cả các sản phẩm đã được đặt trong một đơn đặt hàng cụ thể.
SELECT O.order_id, P.product_name, OD.quantity
FROM Orders O
JOIN OrderDetails OD ON O.order_id = OD.order_id
JOIN Products P ON OD.product_id = P.product_id
WHERE O.order_id = 101;

-- 2. Tính tổng số tiền trong một đơn đặt hàng cụ thể.
SELECT O.order_id, SUM(P.price * OD.quantity) AS total_amount
FROM Orders O
JOIN OrderDetails OD ON O.order_id = OD.order_id
JOIN Products P ON OD.product_id = P.product_id
WHERE O.order_id = 101
GROUP BY O.order_id;

-- 3. Lấy danh sách các sản phẩm chưa có trong bất kỳ đơn đặt hàng nào.
SELECT P.product_id, P.product_name
FROM Products P
LEFT JOIN OrderDetails OD ON P.product_id = OD.product_id
WHERE OD.order_id IS NULL;

-- 4. Đếm số lượng sản phẩm trong mỗi danh mục. (category_name, total_products)
SELECT C.category_name, COUNT(P.product_id) AS total_products
FROM Categories C
LEFT JOIN Products P ON C.category_id = P.category_id
GROUP BY C.category_name;

-- 5. Tính tổng số lượng sản phẩm đã đặt bởi mỗi khách hàng (customer_name, total_ordered)
SELECT C.customer_name, COUNT(OD.order_detail_id) AS total_ordered
FROM Customers C
LEFT JOIN Orders O ON C.customer_id = O.customer_id
LEFT JOIN OrderDetails OD ON O.order_id = OD.order_id
GROUP BY C.customer_name;

-- 6. Lấy thông tin danh mục có nhiều sản phẩm nhất (category_name, product_count)
SELECT C.category_name, COUNT(P.product_id) AS product_count
FROM Categories C
LEFT JOIN Products P ON C.category_id = P.category_id
GROUP BY C.category_name
ORDER BY product_count DESC
LIMIT 1;

-- 7. Tính tổng số sản phẩm đã được đặt cho mỗi danh mục (category_name, total_ordered)
SELECT C.category_name, SUM(OD.quantity) AS total_ordered
FROM Categories C
LEFT JOIN Products P ON C.category_id = P.category_id
LEFT JOIN OrderDetails OD ON P.product_id = OD.product_id
GROUP BY C.category_name;

-- 8. Lấy thông tin về top 3 khách hàng có số lượng sản phẩm đặt hàng lớn nhất (customer_id, customer_name, total_ordered)
SELECT C.customer_id, C.customer_name, COUNT(OD.order_detail_id) AS total_ordered
FROM Customers C
LEFT JOIN Orders O ON C.customer_id = O.customer_id
LEFT JOIN OrderDetails OD ON O.order_id = OD.order_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_ordered DESC
LIMIT 3;

-- 9. Lấy thông tin về khách hàng đã đặt hàng nhiều hơn một lần trong khoảng thời gian cụ thể từ ngày A -> ngày B (customer_id, customer_name, total_orders)
SELECT C.customer_id, C.customer_name, COUNT(DISTINCT O.order_id) AS total_orders
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
WHERE O.order_date BETWEEN '2023-03-01' AND '2023-04-30'
GROUP BY C.customer_id, C.customer_name
HAVING total_orders > 1;

-- 10. Lấy thông tin về các sản phẩm đã được đặt hàng nhiều lần nhất và số lượng đơn đặt hàng tương ứng (product_id, product_name, total_ordered)
SELECT C.customer_id, C.customer_name, COUNT(DISTINCT O.order_id) AS total_orders
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
WHERE O.order_date BETWEEN '2023-03-01' AND '2023-04-30'
GROUP BY C.customer_id, C.customer_name
HAVING total_orders > 1;
