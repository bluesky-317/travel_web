@echo off
chcp 65001 >nul

:: var
set db_name=mariadb-12.3.2-winx64
set venv_name=.venv

:: show info
echo ==============================
cd /d "%~dp0"
echo 當前目錄 : %cd%
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
if exist "%cd%\backend\%venv_name%\Scripts\python.exe" (
    echo 找到 venv
) else (
    echo 找不到 venv
    goto END
)

:: launch
echo 開始啟動....
start "Frontend " /d "%cd%" cmd /c "npm run dev"
start "MariaDB" /d "%cd%\backend" "%db_name%\bin\mysqld.exe" --console
start "Backend (Uvicorn)" /d "%cd%\backend" "%venv_name%\Scripts\uvicorn.exe" main:app --reload
echo 啟動完畢


:END
pause