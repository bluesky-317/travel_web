"""
MariaDB connection helpers.
All queries use parameterised statements (%s placeholders) to prevent SQL injection.
"""
import os
import pymysql
import pymysql.cursors
from datetime import date, datetime, time, timedelta
from decimal import Decimal
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

_CONFIG = {
    "host":        os.getenv("DB_HOST", "localhost"),
    "port":        int(os.getenv("DB_PORT", "3306")),
    "user":        os.getenv("DB_USER", "root"),
    "password":    os.getenv("DB_PASSWORD", ""),
    "database":    os.getenv("DB_NAME", "travel_web"),
    "charset":     "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor,
    "autocommit":  True,
}


def _split_sql_script(script: str) -> list[str]:
    statements = []
    current = []
    for line in script.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        current.append(line)
        if stripped.endswith(";"):
            statements.append("\n".join(current).rstrip().rstrip(";"))
            current = []
    if current:
        statements.append("\n".join(current).rstrip().rstrip(";"))
    return statements


def _to_safe(row: dict | None) -> dict | None:
    """Convert DB driver scalar types into JSON-friendly Python values."""
    if row is None:
        return None
    safe = {}
    for k, v in row.items():
        if isinstance(v, (datetime, date, time)):
            safe[k] = v.isoformat()
        elif isinstance(v, timedelta):
            total_seconds = int(v.total_seconds())
            hours, rem = divmod(total_seconds, 3600)
            minutes, seconds = divmod(rem, 60)
            safe[k] = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        elif isinstance(v, Decimal):
            safe[k] = float(v)
        else:
            safe[k] = v
    return safe


class DatabaseClient:
    """Small MariaDB client wrapper used by services."""

    def __init__(self, config: dict):
        self.config = config

    def _conn(self):
        return pymysql.connect(**self.config)

    def _server_conn(self):
        config = {k: v for k, v in self.config.items() if k != "database"}
        return pymysql.connect(**config)

    def schema_ready(self, required_tables: tuple[str, ...]) -> bool:
        """Return True when the configured database contains every required table."""
        conn = self._server_conn()
        try:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT table_name
                       FROM information_schema.tables
                       WHERE table_schema=%s""",
                    (self.config["database"],),
                )
                existing = {row["table_name"] for row in cur.fetchall()}
                return all(table in existing for table in required_tables)
        finally:
            conn.close()

    def apply_schema_file(self, path: str) -> None:
        """Execute a SQL schema file against the server."""
        with open(path, encoding="utf-8") as f:
            statements = _split_sql_script(f.read())
        conn = self._server_conn()
        try:
            with conn.cursor() as cur:
                for statement in statements:
                    cur.execute(statement)
            conn.commit()
        finally:
            conn.close()

    def query(self, sql: str, params=None) -> list[dict]:
        """Execute a SELECT and return all rows."""
        conn = self._conn()
        try:
            with conn.cursor() as cur:
                cur.execute(sql, params)
                rows = cur.fetchall()
                return [_to_safe(r) for r in rows]
        finally:
            conn.close()

    def query_one(self, sql: str, params=None) -> dict | None:
        """Execute a SELECT and return the first row, or None."""
        rows = self.query(sql, params)
        return rows[0] if rows else None

    def execute(self, sql: str, params=None) -> int:
        """Execute an INSERT/UPDATE/DELETE and return lastrowid."""
        conn = self._conn()
        try:
            with conn.cursor() as cur:
                cur.execute(sql, params)
                conn.commit()
                return cur.lastrowid
        finally:
            conn.close()

    def execute_many(self, sql: str, params_list: list) -> None:
        """Execute the same statement with multiple param sets (batch insert)."""
        if not params_list:
            return
        conn = self._conn()
        try:
            with conn.cursor() as cur:
                cur.executemany(sql, params_list)
                conn.commit()
        finally:
            conn.close()


default_client = DatabaseClient(_CONFIG)


def schema_ready(required_tables: tuple[str, ...]) -> bool:
    return default_client.schema_ready(required_tables)


def apply_schema_file(path: str) -> None:
    default_client.apply_schema_file(path)


def query(sql: str, params=None) -> list[dict]:
    return default_client.query(sql, params)


def query_one(sql: str, params=None) -> dict | None:
    return default_client.query_one(sql, params)


def execute(sql: str, params=None) -> int:
    return default_client.execute(sql, params)


def execute_many(sql: str, params_list: list) -> None:
    default_client.execute_many(sql, params_list)
