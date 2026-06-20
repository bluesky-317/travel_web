## 安裝說明

### 前置條件
電腦需已安裝 `python` 和 `npm` 套件。

### 安裝步驟

#### mariaDB 安裝
到 [mariaDB](https://mariadb.org/download/?t=mariadb&p=mariadb&r=12.3.2&os=windows&cpu=x86_64&pkg=msi&mirror=xtom_hk) 下載 `12.3.2` 版本的 zip 檔案(Portable)，並將檔案解壓縮後放置到 `backend` 資料夾底下。

> 操作 mariaDB 相關的指令都必須進入 `mariadb-12.3.2-winx64/bin` 底下才能使用。

> 執行 `mysql -u root -p` 指令可以進入資料庫CLI。

#### 前後端安裝
* 前端

    1. 執行 `npm install` 安裝。

* 後端

    1. 執行 `cd backend` 進入 `backend` 資料夾。
    2. 執行 `pip install -r requirements.txt`。 (python 版本建議 3.10)
    3. 執行 `cd mariadb-12.3.2-winx64\bin && mariadb-install-db.exe --datadir=..\data` 初始化資料庫。
    4. 進入資料庫CLI中執行 `SOURCE <專案根目錄>/backend/schema.sql;`。(建立資料表)
    5. 進入資料庫CLI中執行 `SOURCE <專案根目錄>/backend/data_setting.sql;`。(加入資料)

* 配置檔

    在 `專案根目錄`、`backend` 資料夾底下的 `.env` 可調整。


### 如何啟動
要讓網頁運行必須要將 `vite`、`mariaDB Server`、`python api server` 啟動。

依序執行下面指令
```cmd
npm run dev
mysqld --console
uvicorn main:app --reload
```

啟動完成後，即可在 `http://localhost:5173/` 看見網站。