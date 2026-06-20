import os
import uuid
from datetime import date, datetime, time

from fastapi import HTTPException
from sqlalchemy import asc, delete, desc, func, insert, or_, select, update
from sqlalchemy.dialects.mysql import insert as mysql_insert
from sqlalchemy.orm import Session, aliased

import database as db
from auth import PasswordService, SessionStore
from models import Attraction, Category, City, Itinerary, ItineraryItem, User
from schemas import (
    AttractionBody,
    ChangePasswordBody,
    CreateItineraryBody,
    PutItemsBody,
    RegisterBody,
    UpdateItineraryBody,
    UpdateProfileBody,
)
from utils import fmt_time, json_text, norm_city, split_location


ATTRACTION_REQUIRED_COLUMNS = (
    "attraction_id", "name", "category_id", "city_id", "address", "lat", "lon",
    "image_url", "description", "opening_hours", "ticket_info", "website_url",
    "rating", "phone", "source_updated_at", "is_deleted", "created_at", "updated_at",
)


def _iso(value) -> str | None:
    if value is None:
        return None
    if isinstance(value, (datetime, date, time)):
        return value.isoformat()
    return str(value)


class SchemaService:
    REQUIRED_TABLES = ("User", "Category", "City", "Attraction", "Itinerary", "ItineraryItem")
    REMOVED_TABLES = (
        # Historical tables removed in earlier refactors.
        "user_roles",
        "towns",
        "tags",
        "attraction_tags",
        "attraction_descriptions",
        "user_favorites",
        "user_visited",
        # Legacy plural PascalCase tables superseded by singular names.
        "users",
        "categories",
        "cities",
        "attractions",
        "itineraries",
        "itineraryitems",
    )

    def ensure(self) -> None:
        tables = db.get_tables()
        has_required = all(t.lower() in tables for t in self.REQUIRED_TABLES)
        schema_ok = (
            has_required
            and "role" in db.get_columns("User")
            and db.get_columns("Attraction") == set(ATTRACTION_REQUIRED_COLUMNS)
            and "day_index" in db.get_columns("ItineraryItem")
            and "is_ai" not in db.get_columns("Itinerary")
            and not any(t.lower() in tables for t in self.REMOVED_TABLES)
        )
        if schema_ok:
            return
        schema_path = os.path.join(os.path.dirname(__file__), "schema.sql")
        db.apply_schema_file(schema_path)


class LookupService:
    """Helpers for category/city upserts. Called from inside an existing session."""

    def category_id(self, session: Session, name: str | None) -> int | None:
        return self._upsert(session, Category, "category_id", name)

    def city_id(self, session: Session, name: str | None) -> int | None:
        return self._upsert(session, City, "city_id", norm_city(name))

    def _upsert(self, session: Session, model, id_col: str, value: str | None) -> int | None:
        value = (value or "").strip()
        if not value:
            return None
        # MariaDB INSERT IGNORE keeps existing rows and is race-safe.
        session.execute(mysql_insert(model).values(name=value).prefix_with("IGNORE"))
        row_id = session.execute(
            select(getattr(model, id_col)).where(model.name == value)
        ).scalar_one_or_none()
        return row_id


class UserService:
    def __init__(self, passwords: PasswordService, sessions: SessionStore):
        self.passwords = passwords
        self.sessions = sessions

    def seed_defaults(self) -> None:
        with db.session_scope() as session:
            count = session.execute(select(func.count()).select_from(User)).scalar_one()
            if count:
                return
            session.add_all([
                User(
                    email="test@test.com",
                    password_hash=self.passwords.hash("test123"),
                    name="測試用戶",
                    role="user",
                ),
                User(
                    email="admin@test.com",
                    password_hash=self.passwords.hash("admin123"),
                    name="系統管理員",
                    role="admin",
                ),
            ])

    def login(self, email: str, password: str) -> str:
        with db.session_scope() as session:
            user = session.execute(
                select(User).where(User.email == email)
            ).scalar_one_or_none()
            if not user or not self.passwords.verify(password, user.password_hash):
                raise HTTPException(status_code=401, detail="帳號或密碼錯誤")
            session.execute(
                update(User)
                .where(User.user_id == user.user_id)
                .values(login_time=func.now())
            )
            return self.sessions.create({
                "id": str(user.user_id),
                "email": user.email,
                "name": user.name,
                "role": user.role,
            })

    def register(self, body: RegisterBody) -> str:
        with db.session_scope() as session:
            exists = session.execute(
                select(User.user_id).where(User.email == body.email)
            ).scalar_one_or_none()
            if exists:
                raise HTTPException(status_code=409, detail="此 Email 已被註冊")
            name = body.name or body.email.split("@")[0]
            user = User(
                email=body.email,
                password_hash=self.passwords.hash(body.password),
                name=name,
                role="user",
            )
            session.add(user)
            session.flush()
            user_id = user.user_id
        return self.sessions.create({
            "id": str(user_id),
            "email": body.email,
            "name": name,
            "role": "user",
        })

    def update_profile(self, body: UpdateProfileBody, current_user: dict, token: str | None) -> None:
        values: dict = {}
        with db.session_scope() as session:
            if body.email is not None:
                dup = session.execute(
                    select(User.user_id)
                    .where(User.email == body.email, User.user_id != int(current_user["id"]))
                ).scalar_one_or_none()
                if dup:
                    raise HTTPException(status_code=409, detail="此 Email 已被使用")
                values["email"] = body.email
            if body.name is not None:
                values["name"] = body.name
            if not values:
                raise HTTPException(status_code=400, detail="沒有需要更新的欄位")
            session.execute(
                update(User).where(User.user_id == int(current_user["id"])).values(**values)
            )
        if token:
            if body.name is not None:
                self.sessions.update_user(token, name=body.name)
            if body.email is not None:
                self.sessions.update_user(token, email=body.email)

    def change_password(self, body: ChangePasswordBody, current_user: dict) -> None:
        with db.session_scope() as session:
            hashed = session.execute(
                select(User.password_hash).where(User.user_id == int(current_user["id"]))
            ).scalar_one_or_none()
            if not hashed or not self.passwords.verify(body.oldPassword, hashed):
                raise HTTPException(status_code=400, detail="原密碼錯誤")
            session.execute(
                update(User)
                .where(User.user_id == int(current_user["id"]))
                .values(password_hash=self.passwords.hash(body.newPassword))
            )

    def delete_account(self, user_id: str) -> None:
        with db.session_scope() as session:
            session.execute(delete(User).where(User.user_id == int(user_id)))
        self.sessions.remove_user_sessions(user_id)

    def list_users(self) -> list[dict]:
        with db.session_scope() as session:
            rows = session.execute(
                select(
                    User.user_id,
                    User.email,
                    User.name,
                    User.role,
                    User.create_time,
                    User.login_time,
                ).order_by(User.user_id)
            ).all()
        return [{
            "id": row.user_id,
            "email": row.email,
            "name": row.name,
            "role": row.role,
            "create_time": _iso(row.create_time),
            "login_time": _iso(row.login_time),
        } for row in rows]

    def delete_user(self, user_id: str) -> None:
        with db.session_scope() as session:
            role = session.execute(
                select(User.role).where(User.user_id == int(user_id))
            ).scalar_one_or_none()
            if role is None:
                raise HTTPException(status_code=404, detail="用戶不存在")
            if role == "admin":
                raise HTTPException(status_code=403, detail="不能刪除管理員")
            session.execute(delete(User).where(User.user_id == int(user_id)))
        self.sessions.remove_user_sessions(str(user_id))


class AttractionService:
    SORT_KEYS = {
        # 由北向南：緯度由大到小（北部緯度較高）
        "ns": (Attraction.lat.is_(None), desc(Attraction.lat), Attraction.attraction_id),
        # 由南向北：緯度由小到大
        "sn": (Attraction.lat.is_(None), asc(Attraction.lat), Attraction.attraction_id),
        "updated": (
            Attraction.source_updated_at.is_(None),
            desc(Attraction.source_updated_at),
            Attraction.attraction_id,
        ),
        "rating": (
            Attraction.rating.is_(None),
            desc(Attraction.rating),
            Attraction.attraction_id,
        ),
    }
    DEFAULT_ORDER = (Attraction.attraction_id,)

    def __init__(self, lookups: LookupService):
        self.lookups = lookups

    def _row_to_api(self, attraction: Attraction, category_name: str | None, city_name: str | None) -> dict:
        updated_at = attraction.source_updated_at or attraction.updated_at
        return {
            "id": attraction.attraction_id,
            "name": attraction.name,
            "category": category_name or "",
            "city": city_name or "",
            "location": attraction.address or "",
            "imageUrl": attraction.image_url,
            "description": attraction.description or "",
            "lat": float(attraction.lat) if attraction.lat is not None else None,
            "lon": float(attraction.lon) if attraction.lon is not None else None,
            "openingHours": attraction.opening_hours,
            "ticketInfo": attraction.ticket_info,
            "rating": float(attraction.rating) if attraction.rating is not None else None,
            "phone": attraction.phone,
            "website": attraction.website_url,
            "updatedAt": _iso(updated_at) or "",
        }

    def _base_select(self):
        cat = aliased(Category)
        city = aliased(City)
        stmt = (
            select(Attraction, cat.name, city.name)
            .outerjoin(cat, Attraction.category_id == cat.category_id)
            .outerjoin(city, Attraction.city_id == city.city_id)
        )
        return stmt, cat, city

    def _apply_filters(self, stmt, cat, city, q, cities, category):
        stmt = stmt.where(Attraction.is_deleted.is_(False))
        if q:
            like = f"%{q}%"
            stmt = stmt.where(or_(Attraction.name.like(like), Attraction.address.like(like)))
        if cities:
            city_list = [norm_city(c.strip()) for c in cities.split(",") if c.strip()]
            if city_list:
                stmt = stmt.where(city.name.in_(city_list))
        if category:
            stmt = stmt.where(cat.name == category)
        return stmt

    def list(self, q=None, cities=None, category=None, sort=None, page=None, page_size=10):
        with db.session_scope() as session:
            stmt, cat, city = self._base_select()
            stmt = self._apply_filters(stmt, cat, city, q, cities, category)
            order = self.SORT_KEYS.get(sort, self.DEFAULT_ORDER)
            stmt = stmt.order_by(*order)

            if page is not None:
                count_stmt, c_cat, c_city = self._base_select()
                count_stmt = self._apply_filters(count_stmt, c_cat, c_city, q, cities, category)
                count_stmt = select(func.count()).select_from(count_stmt.subquery())
                total = session.execute(count_stmt).scalar_one()
                offset = (page - 1) * page_size
                rows = session.execute(stmt.limit(page_size).offset(offset)).all()
                return {
                    "items": [self._row_to_api(r[0], r[1], r[2]) for r in rows],
                    "total": total,
                }

            rows = session.execute(stmt).all()
            return [self._row_to_api(r[0], r[1], r[2]) for r in rows]

    def get(self, attraction_id: str) -> dict:
        with db.session_scope() as session:
            stmt, cat, city = self._base_select()
            stmt = stmt.where(
                Attraction.attraction_id == attraction_id,
                Attraction.is_deleted.is_(False),
            )
            row = session.execute(stmt).first()
            if not row:
                raise HTTPException(status_code=404, detail="景點不存在")
            return self._row_to_api(row[0], row[1], row[2])

    def _build_attraction_values(self, session: Session, body: AttractionBody) -> dict:
        city_name = norm_city(body.city)
        if not city_name:
            city_name, _ = split_location(body.location)
        return {
            "name": body.name,
            "category_id": self.lookups.category_id(session, body.category),
            "city_id": self.lookups.city_id(session, city_name),
            "address": body.location,
            "lat": body.lat,
            "lon": body.lon,
            "image_url": body.imageUrl,
            "description": body.description,
            "opening_hours": json_text(body.openingHours),
            "ticket_info": json_text(body.ticketInfo),
            "website_url": body.website,
            "rating": body.rating,
            "phone": body.phone,
            "source_updated_at": func.now(),
        }

    def create(self, body: AttractionBody) -> dict:
        new_id = str(uuid.uuid4())
        with db.session_scope() as session:
            session.execute(
                insert(Attraction).values(
                    attraction_id=new_id,
                    **self._build_attraction_values(session, body),
                )
            )
        return self.get(new_id)

    def update(self, attraction_id: str, body: AttractionBody) -> dict:
        with db.session_scope() as session:
            exists = session.execute(
                select(Attraction.attraction_id).where(
                    Attraction.attraction_id == attraction_id,
                    Attraction.is_deleted.is_(False),
                )
            ).scalar_one_or_none()
            if not exists:
                raise HTTPException(status_code=404, detail="景點不存在")
            session.execute(
                update(Attraction)
                .where(Attraction.attraction_id == attraction_id)
                .values(**self._build_attraction_values(session, body))
            )
        return self.get(attraction_id)

    def delete(self, attraction_id: str) -> None:
        with db.session_scope() as session:
            result = session.execute(
                update(Attraction)
                .where(
                    Attraction.attraction_id == attraction_id,
                    Attraction.is_deleted.is_(False),
                )
                .values(is_deleted=True)
            )
            if result.rowcount == 0:
                raise HTTPException(status_code=404, detail="景點不存在")


class ItineraryService:
    def _load_items_for_itinerary(self, session: Session, itin_id: str, num_days: int) -> list:
        stmt = (
            select(
                ItineraryItem.itinerary_item_id,
                ItineraryItem.attraction_id,
                ItineraryItem.day_index,
                ItineraryItem.start_time,
                ItineraryItem.end_time,
                ItineraryItem.note,
                ItineraryItem.order_index,
                Attraction.name,
                Attraction.address,
                Category.name.label("category_name"),
                Attraction.image_url,
                Attraction.opening_hours,
                Attraction.ticket_info,
                Attraction.rating,
            )
            .join(Attraction, ItineraryItem.attraction_id == Attraction.attraction_id)
            .outerjoin(Category, Attraction.category_id == Category.category_id)
            .where(ItineraryItem.itinerary_id == itin_id)
            .order_by(ItineraryItem.day_index, ItineraryItem.order_index)
        )
        rows = session.execute(stmt).all()
        days = [{"items": []} for _ in range(max(1, num_days))]
        for row in rows:
            day_idx = int(row.day_index or 0)
            if not (0 <= day_idx < len(days)):
                day_idx = 0
            days[day_idx]["items"].append({
                "uid": row.itinerary_item_id,
                "attractionId": row.attraction_id,
                "name": row.name or "",
                "location": row.address or "",
                "category": row.category_name or "",
                "startTime": fmt_time(row.start_time),
                "endTime": fmt_time(row.end_time),
                "note": row.note or "",
                "imageUrl": row.image_url,
                "openingHours": row.opening_hours,
                "ticketInfo": row.ticket_info,
                "rating": float(row.rating) if row.rating is not None else None,
            })
        return days

    def _ensure_owned(self, session: Session, itin_id: str, user_id: str) -> None:
        owned = session.execute(
            select(Itinerary.itinerary_id).where(
                Itinerary.itinerary_id == itin_id,
                Itinerary.user_id == int(user_id),
            )
        ).scalar_one_or_none()
        if not owned:
            raise HTTPException(status_code=404, detail="行程不存在")

    def _itinerary_summary(self, session: Session, itin: Itinerary, *, with_items: bool) -> dict:
        return {
            "id": itin.itinerary_id,
            "title": itin.title,
            "startDate": itin.start_date.isoformat() if itin.start_date else date.today().isoformat(),
            "numDays": itin.num_days,
            "isDeleted": bool(itin.is_deleted),
            "days": self._load_items_for_itinerary(session, itin.itinerary_id, itin.num_days) if with_items else [],
        }

    def list_active(self, user_id: str) -> list[dict]:
        with db.session_scope() as session:
            itineraries = session.execute(
                select(Itinerary)
                .where(
                    Itinerary.user_id == int(user_id),
                    Itinerary.is_deleted.is_(False),
                )
                .order_by(desc(Itinerary.created_at))
            ).scalars().all()
            return [self._itinerary_summary(session, itin, with_items=True) for itin in itineraries]

    def list_trash(self, user_id: str) -> list[dict]:
        with db.session_scope() as session:
            rows = session.execute(
                select(Itinerary)
                .where(
                    Itinerary.user_id == int(user_id),
                    Itinerary.is_deleted.is_(True),
                )
                .order_by(desc(Itinerary.updated_at))
            ).scalars().all()
            return [self._itinerary_summary(session, itin, with_items=False) for itin in rows]

    def create(self, body: CreateItineraryBody, user_id: str) -> dict:
        itin_id = str(uuid.uuid4())
        with db.session_scope() as session:
            session.add(Itinerary(
                itinerary_id=itin_id,
                user_id=int(user_id),
                title=body.title,
                start_date=date.fromisoformat(body.startDate) if body.startDate else None,
                num_days=body.numDays,
            ))
        return {
            "id": itin_id,
            "title": body.title,
            "startDate": body.startDate,
            "numDays": body.numDays,
            "isDeleted": False,
            "days": [{"items": []} for _ in range(body.numDays)],
        }

    def update(self, itin_id: str, body: UpdateItineraryBody, user_id: str) -> None:
        with db.session_scope() as session:
            self._ensure_owned(session, itin_id, user_id)
            values: dict = {}
            if body.title is not None:
                values["title"] = body.title
            if body.startDate is not None:
                values["start_date"] = date.fromisoformat(body.startDate) if body.startDate else None
            if body.numDays is not None:
                values["num_days"] = body.numDays
            if values:
                session.execute(
                    update(Itinerary).where(Itinerary.itinerary_id == itin_id).values(**values)
                )

    def hard_delete(self, itin_id: str, user_id: str) -> None:
        with db.session_scope() as session:
            self._ensure_owned(session, itin_id, user_id)
            session.execute(delete(Itinerary).where(Itinerary.itinerary_id == itin_id))

    def soft_delete(self, itin_id: str, user_id: str) -> None:
        with db.session_scope() as session:
            self._ensure_owned(session, itin_id, user_id)
            session.execute(
                update(Itinerary).where(Itinerary.itinerary_id == itin_id).values(is_deleted=True)
            )

    def restore(self, itin_id: str, user_id: str) -> None:
        with db.session_scope() as session:
            self._ensure_owned(session, itin_id, user_id)
            session.execute(
                update(Itinerary).where(Itinerary.itinerary_id == itin_id).values(is_deleted=False)
            )

    def replace_items(self, itin_id: str, body: PutItemsBody, user_id: str) -> None:
        with db.session_scope() as session:
            self._ensure_owned(session, itin_id, user_id)
            session.execute(
                delete(ItineraryItem).where(ItineraryItem.itinerary_id == itin_id)
            )
            payload = [{
                "itinerary_item_id": item.uid,
                "itinerary_id": itin_id,
                "attraction_id": item.attractionId,
                "day_index": item.dayIndex,
                "start_time": item.startTime,
                "end_time": item.endTime,
                "note": item.note,
                "order_index": order_i,
            } for order_i, item in enumerate(body.items)]
            if payload:
                session.execute(insert(ItineraryItem), payload)
