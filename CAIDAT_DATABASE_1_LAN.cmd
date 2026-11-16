@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
echo Installing or updating MyStore in (localdb)\MSSQLLocalDB...
echo No existing MyStore database or records will be deleted by this script.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CAIDAT_DATABASE_1_LAN.ps1"
if errorlevel 1 (
  echo.
  echo Database setup has an error. Please capture the message above.
  pause
  exit /b 1
)
echo.
echo Done. Open MyStore_MVC5_Full.sln in Visual Studio 2022, restore NuGet, then F5.
pause
