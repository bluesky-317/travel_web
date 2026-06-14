"""
SQLAlchemy ORM models mapping the existing MariaDB schema.

Table names use UpperCamelCase singular nouns (e.g. ``User``); column names
use snake_case. Python attribute names and DB column names are intentionally
identical, so ``mapped_column`` no longer needs an explicit column-name
argument.
"""
from datetime import date, datetime, time
from decimal import Decimal
from typing import Optional

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    Time,
    func,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "User"

    user_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    role: Mapped[str] = mapped_column(String(30), nullable=False, default="user")
    create_time: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    login_time: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)


class Category(Base):
    __tablename__ = "Category"

    category_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True
    )
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)


class City(Base):
    __tablename__ = "City"

    city_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True
    )
    name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)


class Attraction(Base):
    __tablename__ = "Attraction"

    attraction_id: Mapped[str] = mapped_column(String(80), primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    category_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("Category.category_id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    city_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("City.city_id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    address: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    lat: Mapped[Optional[Decimal]] = mapped_column(Numeric(10, 7), nullable=True)
    lon: Mapped[Optional[Decimal]] = mapped_column(Numeric(11, 7), nullable=True)
    image_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    opening_hours: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    ticket_info: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    website_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    rating: Mapped[Optional[Decimal]] = mapped_column(Numeric(3, 1), nullable=True)
    phone: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    source_updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime, nullable=True
    )
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )

    category: Mapped[Optional["Category"]] = relationship(lazy="raise")
    city: Mapped[Optional["City"]] = relationship(lazy="raise")


class Itinerary(Base):
    __tablename__ = "Itinerary"

    itinerary_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[int] = mapped_column(
        ForeignKey("User.user_id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    title: Mapped[str] = mapped_column(
        String(255), nullable=False, default="我的旅程"
    )
    start_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    num_days: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )


class ItineraryItem(Base):
    __tablename__ = "ItineraryItem"

    itinerary_item_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    itinerary_id: Mapped[str] = mapped_column(
        ForeignKey("Itinerary.itinerary_id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    attraction_id: Mapped[str] = mapped_column(
        ForeignKey("Attraction.attraction_id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    day_index: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    start_time: Mapped[Optional[time]] = mapped_column(Time, nullable=True)
    end_time: Mapped[Optional[time]] = mapped_column(Time, nullable=True)
    note: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    order_index: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )
