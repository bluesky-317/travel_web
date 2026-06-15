"""
SQLAlchemy engine + session factories.

All ORM queries built via SQLAlchemy expression language are automatically
parameterised and benefit from SQLAlchemy's compiled-statement cache, which
plays the same SQL-injection-prevention role as a server-side prepared
statement at the application layer.
"""
import os
from contextlib import contextmanager
from typing import Iterator

from dotenv import load_dotenv
from sqlalchemy import URL, create_engine, inspect, text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from models import Base  # noqa: F401  (registers metadata)

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))


DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_NAME = os.getenv("DB_NAME", "TravelDB")


def _make_url(database: str | None) -> URL:
    return URL.create(
        drivername="mysql+pymysql",
        username=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        database=database,
        query={"charset": "utf8mb4"},
    )


engine: Engine = create_engine(
    _make_url(DB_NAME),
    pool_pre_ping=True,
    pool_recycle=3600,
    future=True,
)

# Server-level engine (no database) for schema bootstrap.
server_engine: Engine = create_engine(
    _make_url(None),
    pool_pre_ping=True,
    future=True,
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


@contextmanager
def session_scope() -> Iterator[Session]:
    """Open a session, commit on success, rollback on error."""
    session = SessionLocal()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


def _split_sql_script(script: str) -> list[str]:
    statements: list[str] = []
    current: list[str] = []
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


def get_columns(table: str) -> set[str]:
    """Return column names for a table. Lookup is case-insensitive."""
    inspector = inspect(server_engine)
    try:
        return {col["name"] for col in inspector.get_columns(table, schema=DB_NAME)}
    except Exception:
        try:
            return {col["name"] for col in inspector.get_columns(table.lower(), schema=DB_NAME)}
        except Exception:
            return set()


def get_tables() -> set[str]:
    """Return the set of existing table names, normalised to lowercase."""
    inspector = inspect(server_engine)
    try:
        return {t.lower() for t in inspector.get_table_names(schema=DB_NAME)}
    except Exception:
        return set()


def apply_schema_file(path: str) -> None:
    """Execute a SQL schema file through the server-level engine."""
    with open(path, encoding="utf-8") as f:
        statements = _split_sql_script(f.read())
    with server_engine.begin() as conn:
        for statement in statements:
            conn.execute(text(statement))
