DROP DATABASE IF EXISTS db_hackathon;
CREATE DATABASE db_hackathon;
USE db_hackathon;

-- 1. Tạo bảng
CREATE TABLE Users(
	user_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE Categories(
	category_id VARCHAR(5) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Book(
	book_id VARCHAR(5) PRIMARY KEY,
    title VARCHAR(100) NOT NULL UNIQUE,
    category_id VARCHAR(5),
    FOREIGN KEY (category_id) REFERENCES Categories (category_id),
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE Borrows(
	borrow_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(5),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    book_id VARCHAR(5),
    FOREIGN KEY (book_id) REFERENCES Book(book_id),
    status VARCHAR(20) NOT NULL,
    borrow_date DATE NOT NULL
);

-- 2. Chèn dữ liệu
INSERT INTO Users VALUES
('U01','Nguyễn Văn An','a@m.com','0912345678'),
('U02','Trần Thị Bích','b@m.com','0923456789'),
('U03','Lê Hoàng Minh','mi@m.com','0934567890'),
('U04','Phạm Thu Hà','h@m.com','0945678901'),
('U05','Võ Quốc Huy','hu@gmail.com','0956789012'); 

INSERT INTO Categories VALUES
('C01','IT'),
('C02','Literature'),
('C03','Science'),
('C04','History');

INSERT INTO Book (book_id, title, category_id, price, stock) VALUES
('B01','Clean Code', 'C01', 250000.00, 10),
('B02','Design Pattern', 'C01', 300000.00, 5),
('B03','Tat Den', 'C02', 50000.00, 20),
('B04','Universe', 'C03', 150000.00, 8),
('B05','Sapiens', 'C04', 200000.00, 15);

INSERT INTO Borrows VALUES
(1,'U01','B01', 'Borrowing', '2025-10-01'),
(2,'U02','B03', 'Returned', '2025-10-02'),
(3,'U01','B02', 'Returned', '2025-10-03'),
(4,'U04','B05', 'Lost', '2025-10-04'),
(5,'U05','B01', 'Borrowing', '2025-10-05');

-- 3. Sách 'Sapiens' vừa được nhập thêm hàng, hãy tăng stock thêm 10 quyển và tăng price lên 5% 
UPDATE Book
SET price = price * 1.05,
	stock = stock + 10
WHERE title = 'Sapiens';

-- 4. Cập nhật số điện thoại của user có `user_id = 'U03'` thành `"0999999999"`. 
UPDATE Users
SET phone = '0999999999'
WHERE user_id = 'U03';

-- 5. Xóa tất cả các bản ghi mượn sách trong bảng Borrow có trạng thái là 'Returned' và mượn trước ngày '2025-10-03'. 
DELETE FROM Borrows
WHERE status = 'Returned' AND borrow_date < '2025-10-03';

-- 6. Liệt kê các sách gồm book_id, title, price có giá đền bù từ 100,000 đến 250,000 và đang có stock > 0.
SELECT book_id, title, price FROM Book
WHERE price BETWEEN 100000 AND 250000 AND stock > 0;

-- 7. Lấy thông tin full_name, email của những người dùng có họ là 'Nguyen'.
SELECT full_name, email FROM Users
WHERE full_name LIKE 'Nguyen%';

-- 8. Hiển thị danh sách mượn sách gồm borrow_id, user_id, borrow_date. Sắp xếp theo borrow_date giảm dần.
SELECT borrow_id, user_id, borrow_date FROM Borrows
ORDER BY borrow_date DESC;

-- 9. Lấy ra 3 sách có giá đền bù (price) đắt nhất trong thư viện. 
SELECT * FROM Book
ORDER BY price DESC
LIMIT 3;

-- 10. Hiển thị danh sách title, stock từ bảng Book, bỏ qua 2 sách đầu tiên và lấy 2 sách tiếp theo (Phân trang).
SELECT title, stock FROM Book
LIMIT 2 OFFSET 2;

-- 11. Hiển thị danh sách gồm: borrow_id, full_name (của user), title (của book) và borrow_date. Chỉ lấy những phiếu đang có trạng thái 'Borrowing'. 
SELECT br.borrow_id, u.full_name, b.title, br.borrow_date
FROM Borrows AS br
INNER JOIN Users AS u
ON br.user_id = u.user_id
INNER JOIN Book as b
ON br.book_id = b.book_id
WHERE br.status = 'Borrowing'
GROUP BY br.borrow_id, u.full_name, b.title, br.borrow_date;

-- 12. Liệt kê tất cả các Danh mục (Category) và tựa sách (title) thuộc danh mục đó. Hiển thị cả những danh mục chưa có cuốn sách nào. 
SELECT c.category_name, b.title 
FROM Book AS b
LEFT JOIN Categories AS c
ON b.category_id = c.category_id; -- Do không có dữ liệu nào NULL nên sẽ hiển thị tất cả
 
-- 13. Tính tổng số lượt mượn sách theo từng trạng thái (status). Kết quả gồm hai cột: status và Total_Borrows. 
SELECT status, COUNT(borrow_id) AS Total_Borrows
FROM Borrows
GROUP BY status;

-- 14. Thống kê số lượng sách mà mỗi người dùng đã mượn. Chỉ hiển thị tên người dùng (full_name) có từ 2 lượt mượn trở lên. 
SELECT u.full_name, COUNT(br.user_id) AS total
FROM Users AS u
INNER JOIN Borrows AS br
ON u.user_id = br.user_id
GROUP BY u.full_name
HAVING total >= 2;

-- 15. Lấy thông tin chi tiết các cuốn sách (book_id, title, price) có giá đền bù nhỏ hơn giá đền bù trung bình của tất cả các cuốn sách trong thư viện 
SELECT book_id, title, price FROM Book
WHERE price < (SELECT AVG(price) FROM Book);

-- 16. Hiển thị full_name và phone của những người dùng đã từng mượn cuốn sách có tên là 'Clean Code'.
SELECT u.full_name, b.title, u.phone
FROM Borrows AS br
INNER JOIN Users AS u
ON br.user_id = u.user_id
INNER JOIN Book as b
ON br.book_id = b.book_id
WHERE b.title = 'Clean Code';