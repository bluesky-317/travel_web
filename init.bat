@echo off
chcp 65001 >nul

:: var
set db_folder_name=mariadb-12.3.2-winx64
set passwd=
set venv_name=.venv

set "ROOT_DIR=%~dp0"
set "BACKEND_DIR=%ROOT_DIR%backend"

:: show info
echo ==============================
echo 當前目錄 : %ROOT_DIR%
if exist "%BACKEND_DIR%\%db_folder_name%\" (
    echo 目前資料庫位置 : %BACKEND_DIR%\%db_folder_name%
) else (
    echo mariadb 未存在於 %BACKEND_DIR%\%db_folder_name% 下，偵測失敗。
    goto END
)
echo ==============================
echo.

:: check 

echo (1/2) 檢查 python ... 
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_CMD=python"
    goto SHOW_VERSION
)
py --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_CMD=py"
    goto SHOW_VERSION
)

echo 找不到 Python (python 或 py 命令)！
goto END

:SHOW_VERSION
set /p="Python 版本: " <nul
%PY_CMD% --version
echo.

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
echo (1/3) 前端套件安裝中(會稍微有點久)....
call npm install
echo 套件安裝完成。
echo.

echo (2/3) 安裝 python 必要模組...
if not exist "%BACKEND_DIR%\%venv_name%" (
    python -m venv "%BACKEND_DIR%\%venv_name%"
    echo 虛擬環境建立成功。
) else (
    echo 虛擬環境已存在，跳過建立步驟。
)
"%BACKEND_DIR%\%venv_name%\Scripts\python.exe" -m pip install --upgrade pip
"%BACKEND_DIR%\%venv_name%\Scripts\pip.exe" install -r "%BACKEND_DIR%\requirements.txt"
echo 安裝完成。
echo.

:: check and init mariadb server
if not exist "%BACKEND_DIR%\%db_folder_name%\data" (
    "%BACKEND_DIR%\%db_folder_name%\bin\mariadb-install-db.exe" --datadir="%BACKEND_DIR%\%db_folder_name%\data"
)
"%BACKEND_DIR%\%db_folder_name%\bin\mariadb-admin.exe" -u root ping >nul 2>&1
if %errorlevel% neq 0 (
    echo 資料庫未啟動，啟動中....
    start "mariaDB server" "%BACKEND_DIR%\%db_folder_name%\bin\mysqld.exe" --console
    echo 啟動完成。
    echo.
)

echo (3/3) 建構資料庫
if "%passwd%"=="" (
    ("%BACKEND_DIR%\%db_folder_name%\bin\mariadb.exe" -u root < "%BACKEND_DIR%\schema.sql") > nul 2>&1 && echo 【schema.sql 成功】|| echo 【schema.sql 失敗】
    ("%BACKEND_DIR%\%db_folder_name%\bin\mariadb.exe" -u root < "%BACKEND_DIR%\data_setting.sql") > nul 2>&1 && echo 【data_setting.sql 成功】|| echo 【data_setting.sql 失敗】
) else (
    ("%BACKEND_DIR%\%db_folder_name%\bin\mariadb.exe" -u root -p"%passwd%" < "%BACKEND_DIR%\schema.sql") > nul 2>&1 && echo 【schema.sql 成功】|| echo 【schema.sql 失敗】
    ("%BACKEND_DIR%\%db_folder_name%\bin\mariadb.exe" -u root -p"%passwd%" < "%BACKEND_DIR%\data_setting.sql") > nul 2>&1 && echo 【data_setting.sql 成功】|| echo 【data_setting.sql 失敗】
)
echo 資料庫建構完成。
echo.

echo 初始化完成

:END
pause