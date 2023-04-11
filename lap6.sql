USE Quanlibanhang
GO

	
CREATE FUNCTION fn_thongtintheohang (@tenhang NVARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT sp.masp, sp.tensp, sp.soluong, sp.mausac, sp.giaban, sp.donvitinh, sp.mota, hsx.tenhang
    FROM Sanpham sp
    INNER JOIN Hangsx hsx ON sp.mahangsx = hsx.mahangsx
    WHERE hsx.tenhang = @tenhang
)
SELECT * FROM fn_thongtintheohang('Samsung')

--2 hãy vueets hàm đưa ra danh sách các sản phẩm và hãng sản xuất tương ứng đã được nhập từ ngày x đến ngày y, với x,y được nhập từ bàn phím
CREATE FUNCTION fn_DSspvaHangsx (@ngayx NVARCHAR(10), @ngayy NVARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT sp.tensp, hsx.Tenhang, n.soluongN, n.dongiaN
    FROM Sanpham sp
    INNER JOIN Hangsx hsx ON sp.mahangsx = hsx.mahangsx
    INNER JOIN Nhap n ON sp.masp = n.masp
    WHERE n.ngaynhap BETWEEN @ngayx AND @ngayy
)
SELECT * FROM fn_DSspvaHangsx('2019-03-05', '2020-06-18')

--3 hãy xây dựng hàm đưa ra ds các sp và 1 lựa chọn, nếu lựa chọn =0 thì đưa ra ds có  soluong =0, ngược lại lựa chọn =1 thì đưa ra ds có sluong >0
CREATE FUNCTION fn_GetProductByManufacturer(@manufacturer NVARCHAR(50), @option INT)
RETURNS TABLE
AS
RETURN
    SELECT sp.masp, sp.tensp, sp.soluong
    FROM Sanpham sp
    INNER JOIN Hangsx hs ON sp.mahangsx = hs.mahangsx
    WHERE hs.Tenhang = @manufacturer AND (@option = 0 AND sp.soluong = 0 OR @option = 1 AND sp.soluong > 0)

SELECT *FROM fn_GetProductByManufacturer('Samsung', 1)

--4 hãy xây dựng hàm đưa ra ds các nhân viên có tên phòng nhập từ bàn phím
drop function fn_DanhSachNhanVienTheoPhong
CREATE FUNCTION fn_DanhSachNhanVienTheoPhong(@tenPhong NVARCHAR(50))
RETURNS TABLE
AS
RETURN 
(
    SELECT *
    FROM Nhanvien
    WHERE phong = @tenPhong
)

SELECT * FROM fn_DanhSachNhanVienTheoPhong('Kế toán')

--5 hãy xây dựng hàm đưa ra ds các hãng sx có địa chỉ nhập từ bàn phím(lưu ý _dùng hàm like để lọc)
CREATE FUNCTION DanhSachHangSX ( @diachi NVARCHAR(100) )
RETURNS TABLE
AS
RETURN
    SELECT tenhang, diachi, sodt, email
    FROM Hangsx
    WHERE diachi LIKE '%' + @diachi + '%';

SELECT * FROM DanhSachHangSX('KOREA');

--6 Hãy viết hàm đưa ra danh sách các sản phẩm và hãng sản xuất tương ứng đã được xuất từ năm x đến năm y, với x,y nhập từ bàn phím.
CREATE FUNCTION danh_sach_sp_hangsx_xuat_namxy(@namx int, @namy int)
RETURNS TABLE
AS
RETURN
    SELECT s.tensp, h.tenhang0
    FROM Sanpham s 
    JOIN Hangsx h ON s.mahangsx = h.mahangsx
    JOIN Xuat x ON s.masp = x.masp
    WHERE YEAR(x.ngayxuat) BETWEEN @namx AND @namy;

SELECT * FROM danh_sach_sp_hangsx_xuat_namxy('2019', '2020')

--7. Hãy xây dựng hàm đưa ra danh sách các sản phẩm theo hãng sản xuất và 1 lựa chọn, nếu lựa chọn = 0 thì đưa ra danh sách các sản phẩm đã được nhập, ngược lại lựa chọn =1 thì đưa ra danh sách các sản phẩm đã được xuất.


--8. Hãy xây dựng hàm đưa ra ds các nhân viên đã nhập hàng vào ngày được đưa  từ vào phím
CREATE FUNCTION fn_NhanVienNhapHang(@ngayNhap DATE)
RETURNS TABLE
AS
RETURN
SELECT DISTINCT NV.manv, NV.tennv, NV.diachi, NV.sodt, NV.email, NV.phong
FROM Nhap N
JOIN Nhanvien NV ON N.manv = NV.manv
WHERE N.ngaynhap = @ngayNhap

SELECT * FROM fn_NhanVienNhapHang('2020-05-17')