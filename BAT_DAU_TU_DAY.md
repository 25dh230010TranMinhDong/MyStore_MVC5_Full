# HUONG DAN CUC NGAN — MY STORE VISUAL STUDIO 2022

Da thiet lap san database server theo hinh ban gui: `(localdb)\MSSQLLocalDB`.

## Chay nhanh tren may ban

1. Giai nen `MyStore_VisualStudio_LocalDB_DaSua.zip` (KHONG mo truc tiep trong ZIP).
2. Mo thu muc `MyStore_MVC5_Full`.
3. **Nhap dup** file `CAIDAT_DATABASE_1_LAN.cmd`. Neu Windows can quyen, chon cho phep chay file tu nguon ma ban tin cay. Cho toi dong **SUCCESS - Database MyStore is ready**. Script tu chay ca 2 file SQL va GIU NGUYEN du lieu MyStore hien tai.
4. Nhap dup file `MyStore_MVC5_Full.sln` de mo trong Visual Studio 2022.
5. Chuot phai Solution → Restore NuGet Packages (can Internet).
6. Chuot phai project `MyStore.Web` → Set as Startup Project.
7. Build → Rebuild Solution → F5 (IIS Express).

## Neu muon chay SQL thu cong trong Visual Studio

1. View → SQL Server Object Explorer → connect `(localdb)\MSSQLLocalDB`.
2. Right-click database `MyStore` → New Query (neu chua co MyStore: right-click vao server → New Query).
3. Mo `Database/00_CHAY_1_FILE_SQL.sql`, copy toan bo, dan vao query, Execute (Ctrl+Shift+E).
4. Refresh database `MyStore` → Tables; thu lai website.

## Neu van bi loi

- `Cannot open database MyStore` / `SqlException`: kiem tra script cai dat co dong **SUCCESS** va connection string trong `MyStore.Web/Web.config` la `(localdb)\MSSQLLocalDB`.
- `SQL ERROR` khi chay `.cmd`: chup ro thong bao loi va gui lai. KHONG xoa database MyStore de thu sua loi.
- Loi Build/Compile: mo **View → Error List**, gui anh hien dau tien.
- Neu Visual Studio khong mo project: su dung VS2022 va cai ASP.NET and web development + .NET Framework 4.8 Targeting Pack.

## Gioi han chua duoc kiem thu

Bo file da duoc doi sang LocalDB va kiem tra tinh file cau hinh. Khong co Windows Visual Studio/SQL Server trong moi truong tao file nen **chua the xac nhan build/F5 thanh cong tren may ban**.
