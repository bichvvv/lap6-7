USE Quanlibanhang
GO
--1.  Tạo thủ tục nhập liệu cho bảng Hangsx, với các tham biển truyền vào mahangsx, tenhang, diachi, sodt, email. Hãy kiểm tra xem tenhang đã tồn tại trước đó hay chưa? Nếu có rồi thì không cho nhập và đưa ra thông báo.

drop proc sp_InsertHangSX
CREATE PROCEDURE sp_InsertHangSX
    @mahangsx VARCHAR(50),
    @tenhang VARCHAR(50),
    @diachi VARCHAR(100),
    @sodt VARCHAR(20),
    @email VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT * FROM HangSX WHERE tenhang = @tenhang)
    BEGIN
        PRINT N'Tên hãng đã tồn tại, không thể thêm mới!'
        RETURN
    END

    INSERT INTO HangSX(mahangsx, tenhang, diachi, sodt, email)
    VALUES(@mahangsx, @tenhang, @diachi, @sodt, @email)

    PRINT N'Thêm mới thành công!'
END

EXEC sp_InsertHangSX 'HSX01', 'Iphone', 'Hà Nội', '0123456709', 'iphone@gmail.com'

--2. Tạo thủ tục nhập dữ liệu cho bảng sản phẩm với các tham biến truyền vào masp, tenhangsx, tensp, soluong, mausac, giaban, donvitinh, mota. Hãy kiểm tra xem nếu masp đã tồn tại thì cập nhật thông tin sản phẩm theo mã, ngược lại thêm mới sản phẩm vào bảng sanpham.
Drop proc sp_NhapSanPham
CREATE PROCEDURE sp_NhapSanPham
    @masp varchar(10),
    @tenhangsx varchar(50),
    @tensp varchar(50),
    @soluong int,
    @mausac varchar(20),
    @giaban decimal(18,2),
    @donvitinh varchar(10),
    @mota varchar(200)
AS
BEGIN
    IF EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        UPDATE Sanpham
        SET mahangsx = (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhangsx),
            tensp = @tensp,
            soluong = @soluong,
            mausac = @mausac,
            giaban = @giaban,
            donvitinh = @donvitinh,
            mota = @mota
        WHERE masp = @masp
    END
    ELSE
    BEGIN
        INSERT INTO Sanpham(masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhangsx), @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)
    END
END

EXEC sp_NhapSanPham @masp = 'SP001', @tenhangsx = 'Samsung', @tensp = 'Galaxy S21', @soluong = 100, @mausac = 'Xanh', @giaban = 20000000, @donvitinh = 'Cái', @mota = N'Điện thoại thông minh Samsung Galaxy S21'

--3.   Viết thủ tục xóa dữ liệu bảng hangsx với tham biến là tenhang. Nếu tenhang chưa có thì thông bảo, ngược lại xóa hạngsx với hãng bị xóa là tenhang. (Lưu ý: xóa hạngsx thì phải xóa các sản phẩm mà hangsx nảy cung ứng).
CREATE PROCEDURE DeleteHangsx
    @tenhang nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kiểm tra hãng sản xuất có tồn tại hay không
    IF NOT EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        PRINT N'Hãng sản xuất không tồn tại!'
    END
    ELSE
    BEGIN
        -- Xóa các sản phẩm liên quan đến hãng sản xuất
        DELETE FROM Sanpham WHERE mahangsx = (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang)
        
        -- Xóa hãng sản xuất
        DELETE FROM Hangsx WHERE tenhang = @tenhang
        
        PRINT N'Đã xóa hãng sản xuất ' + @tenhang + N' và các sản phẩm liên quan!'
    END
END

EXEC DeleteHangsx 'tenhang'
--4.Viết thủ tục nhập dữ liệu cho bảng nhân viên với các tham biến many, tennv, gioitinh, diachi, sodt, email, phong, và 1 biến cờ Flag. Nếu Flag = 0 thì cập nhật dữ liệu cho bảng nhân viên theo many, ngược lại thêm mới nhân viên này.
CREATE PROCEDURE sp_NhapNhanVien
	@manv INT,
	@tennv NVARCHAR(50),
	@gioitinh NVARCHAR(10),
	@diachi NVARCHAR(100),
	@sodt NVARCHAR(15),
	@email NVARCHAR(50),
	@phong NVARCHAR(50),
	@flag INT
AS
BEGIN
	IF (@flag = 0)
	BEGIN
		UPDATE Nhanvien
		SET tennv = @tennv,
			gioitinh = @gioitinh,
			diachi = @diachi,
			sodt = @sodt,
			email = @email,
			phong = @phong
		WHERE manv = @manv
	END
	ELSE
	BEGIN
		INSERT INTO Nhanvien(manv, tennv, gioitinh, diachi, sodt, email, phong)
		VALUES (@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong)
	END
END

EXEC sp_NhapNhanVien @manv = 1, @tennv = N'Nguyen Van A', @gioitinh = N'Nam', @diachi = N'Ha Noi', @sodt = N'0987654521', @email = N'abc@gmail.com', 
	@phong = N'Kinh doanh', @flag = 1

	 
--5.
-- Kiểm tra mã sản phẩm có tồn tại trong bảng sản phẩm không
SELECT @countMasp = COUNT(*) FROM Sanpham WHERE masp = @masp;
IF @countMasp = 0
BEGIN
    PRINT 'Mã sản phẩm không tồn tại trong bảng sản phẩm';
    RETURN;
END

-- Kiểm tra mã nhân viên có tồn tại trong bảng nhân viên không
SELECT @countManv = COUNT(*) FROM Nhanvien WHERE manv = @manv;
IF @countManv = 0
BEGIN
    PRINT 'Mã nhân viên không tồn tại trong bảng nhân viên';
    RETURN;
END

-- Kiểm tra số hóa đơn nhập đã tồn tại chưa
IF EXISTS(SELECT * FROM Nhap WHERE sohdn = @sohdn)
BEGIN
    UPDATE Nhap
    SET masp = @masp,
        manv = @manv,
        ngaynhap = @ngaynhap,
        soluongN = @soluongN,
        dongiaN = @dongiaN
    WHERE sohdn = @sohdn;
    PRINT 'Cập nhật thành công';
END
ELSE
BEGIN
    INSERT INTO Nhap(sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
    VALUES(@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN);
    PRINT 'Thêm mới thành công';
END
