@echo off
chcp 65001 >nul

:: var
set db_name=mariadb-12.3.2-winx64
set passwd=
set venv_name=.venv

:: show info
echo ==============================
cd /d "%~dp0"
echo 當前目錄 : %cd%
echo 目前資料庫位置 : %db_name%
echo ==============================
echo.

:: check 
echo (1/2) 檢查 python ... 
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set /p="Python 版本: " <nul
    python --version
    echo.
) else (
    echo 找不到 Python！
    goto END
)

echo (2/2) 檢查 npm ...
cmd /c npm -v >nul 2>&1
if %errorlevel% equ 0 (
    set /p="npm 版本: " <nul
    cmd /c npm -v
    echo.
) else (
    echo 找不到 npm！
    goto END
)

echo 檢查完成。
echo.


:: init
echo 0/3 finish.
echo 前端套件安裝中....
call npm install
echo 套件安裝完成。

echo 1/3 finish.

echo 切換路徑...
cd backend
echo 當前路徑 : %cd%

echo 安裝 python 必要模組...
if not exist "%venv_name%" (
    python -m venv %venv_name%
    echo 虛擬環境建立成功。
) else (
    echo 虛擬環境已存在，跳過建立步驟。
)
"%cd%\%venv_name%\Scripts\python.exe" -m pip install --upgrade pip
"%cd%\%venv_name%\Scripts\pip.exe" install -r requirements.txt
echo 安裝完成。

echo 2/3 finish.
echo 建構資料庫
if "%passwd%"=="" (
    "%db_name%\bin\mariadb.exe" -u root < schema.sql
    "%db_name%\bin\mariadb.exe" -u root < data_setting.sql
) else (
    "%db_name%\bin\mariadb.exe" -u root -p"%passwd%" < schema.sql
    "%db_name%\bin\mariadb.exe" -u root -p"%passwd%" < data_setting.sql
)
echo 資料庫建構完成。

echo 3/3 finish.
echo 初始化完成


:END
pause