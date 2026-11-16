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
 (@books,N'Sổ tay bìa cứng A5',N'Sổ tay giấy mịn phù hợp ghi chép hằng ngày.',65000,N'~/Content/images/products/so-tay-a5.jpg',60),
 (@books,N'Bộ bút gel 6 màu',N'Bút mực gel êm, nhiều màu cho học tập và văn phòng.',42000,N'~/Content/images/products/but-gel-6-mau.jpg',80),
 (@books,N'Sổ kế hoạch tuần',N'Sổ lên lịch, đặt mục tiêu và quản lý công việc.',98000,N'~/Content/images/products/so-ke-hoach-tuan.jpg',40),
 (@books,N'Bút máy tối giản',N'Thiết kế gọn nhẹ, phù hợp làm quà tặng.',155000,N'~/Content/images/products/but-may-toi-gian.jpg',25),
 (@tech,N'Chuột không dây',N'Chuột kết nối 2.4GHz, thiết kế công thái học.',239000,N'~/Content/images/products/chuot-khong-day.jpg',50),
 (@tech,N'Bàn phím cơ compact',N'Bàn phím nhỏ gọn, dùng cho làm việc và chơi game.',799000,N'~/Content/images/products/ban-phim-co-compact.jpg',22),
 (@tech,N'Tai nghe Bluetooth',N'Tai nghe di động, kết nối tiện lợi.',599000,N'~/Content/images/products/tai-nghe-bluetooth.jpg',35),
 (@tech,N'Đèn bàn LED USB',N'Điều chỉnh ánh sáng, phù hợp học tập.',289000,N'~/Content/images/products/den-ban-led-usb.jpg',26),
 (@fashion,N'Áo thun basic',N'Vải mềm, form thoải mái, dễ phối đồ.',179000,N'~/Content/images/products/ao-thun-basic.jpg',45),
 (@fashion,N'Áo khoác nhẹ',N'Thiết kế tối giản, dễ mặc hằng ngày.',490000,N'~/Content/images/products/ao-khoac-nhe.jpg',20),
 (@fashion,N'Túi tote canvas',N'Túi vải dày phù hợp đi học và đi làm.',129000,N'~/Content/images/products/tui-tote-canvas.jpg',38),
 (@fashion,N'Mũ lưỡi trai',N'Phụ kiện phong cách trẻ trung.',159000,N'~/Content/images/products/mu-luoi-trai.jpg',42),
 (@home,N'Bình nước giữ nhiệt',N'Bình đựng nước tiện dụng khi mang đi làm.',269000,N'~/Content/images/products/binh-nuoc-giu-nhiet.jpg',28),
 (@home,N'Ly sứ dáng tròn',N'Ly sứ thiết kế hiện đại.',119000,N'~/Content/images/products/ly-su-dang-tron.jpg',37),
 (@home,N'Khay đựng đồ gỗ',N'Khay sắp xếp bàn làm việc gọn gàng.',149000,N'~/Content/images/products/khay-dung-do-go.jpg',23),
 (@home,N'Hộp lưu trữ mini',N'Đựng phụ kiện nhỏ và vật dụng cá nhân.',89000,N'~/Content/images/products/hop-luu-tru-mini.jpg',34),
 (@accessory,N'Ví đựng thẻ',N'Ví mỏng nhẹ giữ thẻ và giấy tờ.',99000,N'~/Content/images/products/vi-dung-the.jpg',55),
 (@accessory,N'Dây đeo thẻ',N'Dây vải có móc cài chắc chắn.',45000,N'~/Content/images/products/day-deo-the.jpg',48),
 (@accessory,N'Giá đỡ điện thoại',N'Giá đỡ gấp gọn dành cho bàn làm việc.',79000,N'~/Content/images/products/gia-do-dien-thoai.jpg',36),
 (@accessory,N'Ốp lưng điện thoại',N'Ốp đơn giản chống trầy cho thiết bị.',69000,N'~/Content/images/products/op-lung-dien-thoai.jpg',50);
END;
GO
