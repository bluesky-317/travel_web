"""
SQLAlchemy ORM models mapping the existing MariaDB schema.

Python attribute names follow PEP 8 (snake_case); the underlying DB column
names are PascalCase as declared in schema.sql. The two are bridged here by
giving mapped_column() an explicit column name argument.
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
    __tablename__ = "Users"

    user_id: Mapped[int] = mapped_column(
        "UserId", Integer, primary_key=True, autoincrement=True
    )
    email: Mapped[str] = mapped_column(
        "Email", String(255), unique=True, nullable=False
    )
    password_hash: Mapped[str] = mapped_column(
        "PasswordHash", String(255), nullable=False
    )
    name: Mapped[str] = mapped_column("Name", String(100), nullable=False)
    role: Mapped[str] = mapped_column(
        "Role", String(30), nullable=False, default="user"
    )
    create_time: Mapped[datetime] = mapped_column(
        "CreateTime",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    login_time: Mapped[Optional[datetime]] = mapped_column(
        "LoginTime", DateTime, nullable=True
    )


class Category(Base):
    __tablename__ = "Categories"

    category_id: Mapped[int] = mapped_column(
        "CategoryId", Integer, primary_key=True, autoincrement=True
    )
    name: Mapped[str] = mapped_column(
        "Name", String(100), unique=True, nullable=False
    )


class City(Base):
    __tablename__ = "Cities"

    city_id: Mapped[int] = mapped_column(
        "CityId", Integer, primary_key=True, autoincrement=True
    )
    name: Mapped[str] = mapped_column(
        "Name", String(50), unique=True, nullable=False
    )


class Attraction(Base):
    __tablename__ = "Attractions"

    attraction_id: Mapped[str] = mapped_column(
        "AttractionId", String(80), primary_key=True
    )
    name: Mapped[str] = mapped_column("Name", String(255), nullable=False)
    category_id: Mapped[Optional[int]] = mapped_column(
        "CategoryId",
        ForeignKey("Categories.CategoryId", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    city_id: Mapped[Optional[int]] = mapped_column(
        "CityId",
        ForeignKey("Cities.CityId", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    address: Mapped[Optional[str]] = mapped_column(
        "Address", String(255), nullable=True
    )
    lat: Mapped[Optional[Decimal]] = mapped_column(
        "Lat", Numeric(10, 7), nullable=True
    )
    lon: Mapped[Optional[Decimal]] = mapped_column(
        "Lon", Numeric(11, 7), nullable=True
    )
    image_url: Mapped[Optional[str]] = mapped_column("ImageUrl", Text, nullable=True)
    description: Mapped[Optional[str]] = mapped_column(
        "Description", Text, nullable=True
    )
    opening_hours: Mapped[Optional[str]] = mapped_column(
        "OpeningHours", Text, nullable=True
    )
    ticket_info: Mapped[Optional[str]] = mapped_column(
        "TicketInfo", Text, nullable=True
    )
    website_url: Mapped[Optional[str]] = mapped_column(
        "WebsiteUrl", Text, nullable=True
    )
    rating: Mapped[Optional[Decimal]] = mapped_column(
        "Rating", Numeric(3, 1), nullable=True
    )
    phone: Mapped[Optional[str]] = mapped_column(
        "Phone", String(100), nullable=True
    )
    source_updated_at: Mapped[Optional[datetime]] = mapped_column(
        "SourceUpdatedAt", DateTime, nullable=True
    )
    is_deleted: Mapped[bool] = mapped_column(
        "IsDeleted", Boolean, nullable=False, default=False
    )
    created_at: Mapped[datetime] = mapped_column(
        "CreatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        "UpdatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )

    category: Mapped[Optional["Category"]] = relationship(lazy="raise")
    city: Mapped[Optional["City"]] = relationship(lazy="raise")


class Itinerary(Base):
    __tablename__ = "Itineraries"

    itinerary_id: Mapped[str] = mapped_column(
        "ItineraryId", String(36), primary_key=True
    )
    user_id: Mapped[int] = mapped_column(
        "UserId",
        ForeignKey("Users.UserId", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    title: Mapped[str] = mapped_column(
        "Title", String(255), nullable=False, default="我的旅程"
    )
    start_date: Mapped[Optional[date]] = mapped_column(
        "StartDate", Date, nullable=True
    )
    num_days: Mapped[int] = mapped_column(
        "NumDays", Integer, nullable=False, default=1
    )
    is_deleted: Mapped[bool] = mapped_column(
        "IsDeleted", Boolean, nullable=False, default=False
    )
    created_at: Mapped[datetime] = mapped_column(
        "CreatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        "UpdatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )


class ItineraryItem(Base):
    __tablename__ = "ItineraryItems"

    item_id: Mapped[str] = mapped_column("ItemId", String(36), primary_key=True)
    itinerary_id: Mapped[str] = mapped_column(
        "ItineraryId",
        ForeignKey("Itineraries.ItineraryId", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    attraction_id: Mapped[str] = mapped_column(
        "AttractionId",
        ForeignKey("Attractions.AttractionId", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    day_index: Mapped[int] = mapped_column(
        "DayIndex", Integer, nullable=False, default=0
    )
    start_time: Mapped[Optional[time]] = mapped_column(
        "StartTime", Time, nullable=True
    )
    end_time: Mapped[Optional[time]] = mapped_column(
        "EndTime", Time, nullable=True
    )
    note: Mapped[Optional[str]] = mapped_column("Note", Text, nullable=True)
    order_index: Mapped[int] = mapped_column(
        "OrderIndex", Integer, nullable=False, default=0
    )
    created_at: Mapped[datetime] = mapped_column(
        "CreatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        "UpdatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )
