@echo off
chcp 65001 >nul

:: var
set db_folder_name=mariadb-12.3.2-winx64
set venv_name=.venv

set backend_port=8000
set frontend_port=5173

set "ROOT_DIR=%~dp0"
set "BACKEND_DIR=%ROOT_DIR%backend"

:: show info
echo ==============================
echo 專案根目錄 : %ROOT_DIR%
echo 後端目錄   : %BACKEND_DIR%
echo ==============================
echo.

:: check
echo (1/2) 檢查 npm ...
cmd /c npm -v >nul 2>&1
if %errorlevel% equ 0 (
    set /p="npm 版本: " <nul
    cmd /c npm -v
    echo.
) else (
    echo 找不到 npm！
    goto END
)

echo (2/2) 檢查 venv ...
if exist "%BACKEND_DIR%\%venv_name%\Scripts\python.exe" (
    echo 找到 venv
) else (
    echo 找不到 venv
    goto END
)
echo.

:: launch
echo 開始啟動....
"%BACKEND_DIR%\%db_folder_name%\bin\mariadb-admin.exe" -u root ping >nul 2>&1
if %errorlevel% equ 0 (
    echo [ok] MariaDB 運作中
) else (
    echo 資料庫未啟動，啟動中....
    start "mariaDB server" "%BACKEND_DIR%\%db_folder_name%\bin\mysqld.exe" --console
    echo 啟動完成。
    echo.
)

curl -s -I http://127.0.0.1:%backend_port%/ >nul 2>&1
if %errorlevel% equ 0 (
    echo [ok] Backend 運作中
) else (
    echo 等待 Backend 啟動...
    start "Backend (Uvicorn)" /d "%BACKEND_DIR%" "%BACKEND_DIR%\%venv_name%\Scripts\uvicorn.exe" main:app --reload
    echo 啟動完畢。
    echo.
)

curl -s -I http://127.0.0.1:%frontend_port%/ >nul 2>&1
if %errorlevel% equ 0 (
    echo [ok] Frontend 運作中
) else (
    echo 等待 Frontend 啟動...
    start "Frontend" /d "%ROOT_DIR%" cmd /c "npm run dev"
    echo 啟動完畢。
    echo.
)

echo 全數啟動完畢

:END
pause