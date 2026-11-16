-- MY STORE LOCALDB: TOAN BO TAO DB + BANG + DU LIEU MAU (1 FILE)
-- Neu da co MyStore, khong xoa database hay du lieu cu.

-- MyStore MVC5 / EF6 - script tao/cap nhat DB da kiem tra cau truc.
-- Co the chay tren MyStore da co, KHONG XOA du lieu hien tai.
-- Chay bang CAIDAT_DATABASE_1_LAN.cmd (LocalDB) hoac VS SQL Server Object Explorer.
-- Script KHONG DROP DATABASE/TABLE va co the chay lai neu da co DB MyStore.
IF DB_ID(N'MyStore') IS NULL EXEC(N'CREATE DATABASE [MyStore]');
GO
USE MyStore;
GO
IF OBJECT_ID(N'dbo.[User]', N'U') IS NULL
BEGIN
CREATE TABLE dbo.[User] (
  Username NVARCHAR(255) NOT NULL PRIMARY KEY,
  [Password] NVARCHAR(256) NOT NULL,
  UserRole NCHAR(1) NOT NULL CHECK (UserRole IN ('A','C'))
);
END;
GO
IF OBJECT_ID(N'dbo.Customer', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Customer (
  CustomerID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  CustomerName NVARCHAR(120) NOT NULL,
  CustomerPhone NVARCHAR(15) NOT NULL,
  CustomerEmail NVARCHAR(MAX) NULL,
  CustomerAddress NVARCHAR(MAX) NULL,
  Username NVARCHAR(255) NOT NULL REFERENCES dbo.[User](Username)
);
END;
GO
IF OBJECT_ID(N'dbo.Category', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Category (
  CategoryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  CategoryName NVARCHAR(120) NOT NULL
);
END;
GO
IF OBJECT_ID(N'dbo.Product', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Product (
  ProductID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  CategoryID INT NOT NULL REFERENCES dbo.Category(CategoryID),
  ProductName NVARCHAR(160) NOT NULL,
  ProductDecription NVARCHAR(MAX) NOT NULL, -- Tên cột typo theo Database2024.txt
  ProductPrice DECIMAL(18,2) NOT NULL,
  ProductImage NVARCHAR(MAX) NULL,
  StockQuantity INT NOT NULL CONSTRAINT DF_Product_Stock DEFAULT (20),
  CONSTRAINT CK_Product_Stock CHECK (StockQuantity>=0),
  CONSTRAINT CK_Product_Price CHECK (ProductPrice>=0)
);
END;
GO
IF OBJECT_ID(N'dbo.[Order]', N'U') IS NULL
BEGIN
CREATE TABLE dbo.[Order] (
  OrderID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  CustomerID INT NOT NULL REFERENCES dbo.Customer(CustomerID),
  OrderDate DATE NOT NULL,
  TotalAmount DECIMAL(18,2) NOT NULL,
  PaymentStatus NVARCHAR(30) NULL,
  ShippingAddress NVARCHAR(400) NOT NULL,
  DeliveryMethod NVARCHAR(30) NOT NULL CONSTRAINT DF_Order_Delivery DEFAULT ('Standard'),
  PaymentMethod NVARCHAR(30) NOT NULL CONSTRAINT DF_Order_Payment DEFAULT ('COD'),
  OrderStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_Order_Status DEFAULT ('Pending')
);
END;
GO
IF OBJECT_ID(N'dbo.OrderDetail', N'U') IS NULL
BEGIN
CREATE TABLE dbo.OrderDetail (
  ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  ProductID INT NOT NULL REFERENCES dbo.Product(ProductID),
  OrderID INT NOT NULL REFERENCES dbo.[Order](OrderID),
  Quantity INT NOT NULL,
  UnitPrice DECIMAL(18,2) NOT NULL,
  TotalPrice AS (Quantity * UnitPrice) PERSISTED,
  CONSTRAINT CK_OrderDetail_Quantity CHECK (Quantity>0)
);
END;
GO
-- Idempotent updates: hỗ trợ bảng có sẵn được tạo từ Database2024.txt.
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.[User]') AND name = N'Password' AND max_length < 512)
  ALTER TABLE dbo.[User] ALTER COLUMN [Password] NVARCHAR(256) NOT NULL;
GO
IF OBJECT_ID(N'dbo.Product', N'U') IS NOT NULL AND COL_LENGTH('dbo.Product','StockQuantity') IS NULL
  ALTER TABLE dbo.Product ADD StockQuantity INT NOT NULL CONSTRAINT DF_Product_Stock_Upgrade DEFAULT (20) WITH VALUES;
GO
IF OBJECT_ID(N'dbo.[Order]', N'U') IS NOT NULL AND COL_LENGTH('dbo.[Order]','AddressDelivery') IS NOT NULL
   AND COL_LENGTH('dbo.[Order]','ShippingAddress') IS NULL
  EXEC sp_rename 'dbo.[Order].AddressDelivery','ShippingAddress','COLUMN';
GO
IF OBJECT_ID(N'dbo.[Order]', N'U') IS NOT NULL AND COL_LENGTH('dbo.[Order]','DeliveryMethod') IS NULL
  ALTER TABLE dbo.[Order] ADD DeliveryMethod NVARCHAR(30) NOT NULL CONSTRAINT DF_Order_Delivery_Upgrade DEFAULT ('Standard') WITH VALUES;
GO
IF OBJECT_ID(N'dbo.[Order]', N'U') IS NOT NULL AND COL_LENGTH('dbo.[Order]','PaymentMethod') IS NULL
  ALTER TABLE dbo.[Order] ADD PaymentMethod NVARCHAR(30) NOT NULL CONSTRAINT DF_Order_Payment_Upgrade DEFAULT ('COD') WITH VALUES;
GO
IF OBJECT_ID(N'dbo.[Order]', N'U') IS NOT NULL AND COL_LENGTH('dbo.[Order]','OrderStatus') IS NULL
  ALTER TABLE dbo.[Order] ADD OrderStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_Order_Status_Upgrade DEFAULT ('Pending') WITH VALUES;
GO
IF OBJECT_ID(N'dbo.OrderDetail', N'U') IS NOT NULL AND COL_LENGTH('dbo.OrderDetail','TotalPrice') IS NULL
  ALTER TABLE dbo.OrderDetail ADD TotalPrice AS (Quantity * UnitPrice) PERSISTED;
GO
-- Tài khoản đăng nhập đăng ký bằng website (PBKDF2). KHÔNG chèn mật khẩu plain text vào SQL.
-- Tạo admin đầu tiên: Đăng ký 1 tài khoản từ giao diện web, sau đó chạy:
-- UPDATE dbo.[User] SET UserRole='A' WHERE Username=N'TEN_DANG_NHAP_CUA_BAN';

GO

-- ==================== DU LIEU MAU ====================
-- Chay sau 01_Create_MyStore.sql. Co the chay lai, khong tu dong xoa du lieu.
USE MyStore;
GO
-- Them tung danh muc thieu; KHONG chen trung khi chay lai.
IF NOT EXISTS (SELECT 1 FROM dbo.Category WHERE CategoryName=N'Sách & Văn phòng phẩm')
  INSERT INTO dbo.Category (CategoryName) VALUES (N'Sách & Văn phòng phẩm');
IF NOT EXISTS (SELECT 1 FROM dbo.Category WHERE CategoryName=N'Thiết bị điện tử')
  INSERT INTO dbo.Category (CategoryName) VALUES (N'Thiết bị điện tử');
IF NOT EXISTS (SELECT 1 FROM dbo.Category WHERE CategoryName=N'Thời trang')
  INSERT INTO dbo.Category (CategoryName) VALUES (N'Thời trang');
IF NOT EXISTS (SELECT 1 FROM dbo.Category WHERE CategoryName=N'Đồ gia dụng')
  INSERT INTO dbo.Category (CategoryName) VALUES (N'Đồ gia dụng');
IF NOT EXISTS (SELECT 1 FROM dbo.Category WHERE CategoryName=N'Phụ kiện')
  INSERT INTO dbo.Category (CategoryName) VALUES (N'Phụ kiện');
GO
IF NOT EXISTS(SELECT 1 FROM dbo.Product)
BEGIN
 DECLARE @books INT=(SELECT TOP 1 CategoryID FROM dbo.Category WHERE CategoryName=N'Sách & Văn phòng phẩm');
 DECLARE @tech INT=(SELECT TOP 1 CategoryID FROM dbo.Category WHERE CategoryName=N'Thiết bị điện tử');
 DECLARE @fashion INT=(SELECT TOP 1 CategoryID FROM dbo.Category WHERE CategoryName=N'Thời trang');
 DECLARE @home INT=(SELECT TOP 1 CategoryID FROM dbo.Category WHERE CategoryName=N'Đồ gia dụng');
 DECLARE @accessory INT=(SELECT TOP 1 CategoryID FROM dbo.Category WHERE CategoryName=N'Phụ kiện');
 INSERT INTO dbo.Product(CategoryID,ProductName,ProductDecription,ProductPrice,ProductImage,StockQuantity) VALUES
 (@books,N'Sổ tay bìa cứng A5',N'Sổ tay giấy mịn phù hợp ghi chép hằng ngày.',65000,NULL,60),
 (@books,N'Bộ bút gel 6 màu',N'Bút mực gel êm, nhiều màu cho học tập và văn phòng.',42000,NULL,80),
 (@books,N'Sổ kế hoạch tuần',N'Sổ lên lịch, đặt mục tiêu và quản lý công việc.',98000,NULL,40),
 (@books,N'Bút máy tối giản',N'Thiết kế gọn nhẹ, phù hợp làm quà tặng.',155000,NULL,25),
 (@tech,N'Chuột không dây',N'Chuột kết nối 2.4GHz, thiết kế công thái học.',239000,NULL,50),
 (@tech,N'Bàn phím cơ compact',N'Bàn phím nhỏ gọn, dùng cho làm việc và chơi game.',799000,NULL,22),
 (@tech,N'Tai nghe Bluetooth',N'Tai nghe di động, kết nối tiện lợi.',599000,NULL,35),
 (@tech,N'Đèn bàn LED USB',N'Điều chỉnh ánh sáng, phù hợp học tập.',289000,NULL,26),
 (@fashion,N'Áo thun basic',N'Vải mềm, form thoải mái, dễ phối đồ.',179000,NULL,45),
 (@fashion,N'Áo khoác nhẹ',N'Thiết kế tối giản, dễ mặc hằng ngày.',490000,NULL,20),
 (@fashion,N'Túi tote canvas',N'Túi vải dày phù hợp đi học và đi làm.',129000,NULL,38),
 (@fashion,N'Mũ lưỡi trai',N'Phụ kiện phong cách trẻ trung.',159000,NULL,42),
 (@home,N'Bình nước giữ nhiệt',N'Bình đựng nước tiện dụng khi mang đi làm.',269000,NULL,28),
 (@home,N'Ly sứ dáng tròn',N'Ly sứ thiết kế hiện đại.',119000,NULL,37),
 (@home,N'Khay đựng đồ gỗ',N'Khay sắp xếp bàn làm việc gọn gàng.',149000,NULL,23),
 (@home,N'Hộp lưu trữ mini',N'Đựng phụ kiện nhỏ và vật dụng cá nhân.',89000,NULL,34),
 (@accessory,N'Ví đựng thẻ',N'Ví mỏng nhẹ giữ thẻ và giấy tờ.',99000,NULL,55),
 (@accessory,N'Dây đeo thẻ',N'Dây vải có móc cài chắc chắn.',45000,NULL,48),
 (@accessory,N'Giá đỡ điện thoại',N'Giá đỡ gấp gọn dành cho bàn làm việc.',79000,NULL,36),
 (@accessory,N'Ốp lưng điện thoại',N'Ốp đơn giản chống trầy cho thiết bị.',69000,NULL,50);
END;
GO
