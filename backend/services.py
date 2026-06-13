import os
import uuid
from datetime import date

from fastapi import HTTPException

import database as db
from auth import PasswordService, SessionStore
from schemas import (
    AddItemBody,
    AttractionBody,
    ChangePasswordBody,
    CreateItineraryBody,
    PutItemsBody,
    RegisterBody,
    UpdateItemBody,
    UpdateItineraryBody,
    UpdateProfileBody,
)
from utils import CITY_NS_ORDER, fmt_time, json_text, norm_city, split_location


class SchemaService:
    REQUIRED_TABLES = ("users", "categories", "cities", "attractions", "itineraries", "itinerary_items")
    REMOVED_TABLES = (
        "user_roles",
        "towns",
        "tags",
        "attraction_tags",
        "attraction_descriptions",
        "user_favorites",
        "user_visited",
    )

    def has_columns(self, table: str, columns: tuple[str, ...]) -> bool:
        rows = db.query(
            """SELECT column_name
               FROM information_schema.columns
               WHERE table_schema=DATABASE() AND table_name=%s""",
            (table,),
        )
        existing = {row["column_name"] for row in rows}
        return all(col in existing for col in columns)

    def has_exact_columns(self, table: str, columns: tuple[str, ...]) -> bool:
        rows = db.query(
            """SELECT column_name
               FROM information_schema.columns
               WHERE table_schema=DATABASE() AND table_name=%s""",
            (table,),
        )
        return {row["column_name"] for row in rows} == set(columns)

    def has_removed_tables(self) -> bool:
        placeholders = ",".join(["%s"] * len(self.REMOVED_TABLES))
        rows = db.query(
            f"""SELECT table_name
                FROM information_schema.tables
                WHERE table_schema=DATABASE()
                  AND table_name IN ({placeholders})""",
            self.REMOVED_TABLES,
        )
        return bool(rows)

    def ensure(self) -> None:
        schema_ok = (
            db.schema_ready(self.REQUIRED_TABLES)
            and self.has_columns("users", ("role",))
            and self.has_exact_columns("attractions", (
                "attraction_id", "name", "category_id", "city_id", "address", "lat", "lon",
                "image_url", "description", "opening_hours", "ticket_info", "website_url",
                "rating", "phone", "source_updated_at", "is_deleted", "created_at", "updated_at",
            ))
            and self.has_columns("itinerary_items", ("day_index",))
            and not self.has_columns("itineraries", ("is_ai",))
            and not self.has_removed_tables()
        )
        if schema_ok:
            return
        schema_path = os.path.join(os.path.dirname(__file__), "schema.sql")
        db.apply_schema_file(schema_path)


class LookupService:
    def get_or_create_id(self, table: str, id_column: str, name: str | None) -> int | None:
        value = (name or "").strip()
        if not value:
            return None
        if table not in {"categories", "cities"}:
            raise ValueError("unsupported lookup table")
        db.execute(f"INSERT IGNORE INTO {table} (name) VALUES (%s)", (value,))
        row = db.query_one(f"SELECT {id_column} FROM {table} WHERE name=%s", (value,))
        return row[id_column] if row else None

    def category_id(self, name: str | None) -> int | None:
        return self.get_or_create_id("categories", "category_id", name)

    def city_id(self, name: str | None) -> int | None:
        return self.get_or_create_id("cities", "city_id", norm_city(name))


class UserService:
    def __init__(self, passwords: PasswordService, sessions: SessionStore):
        self.passwords = passwords
        self.sessions = sessions

    def seed_defaults(self) -> None:
        count = db.query_one("SELECT COUNT(*) AS cnt FROM users")["cnt"]
        if count:
            return
        defaults = [
            ("test@test.com", "test123", "測試用戶", "user"),
            ("admin@test.com", "admin123", "系統管理員", "admin"),
        ]
        for email, password, name, role in defaults:
            db.execute(
                "INSERT INTO users (email, password_hash, name, role) VALUES (%s,%s,%s,%s)",
                (email, self.passwords.hash(password), name, role),
            )

    def login(self, email: str, password: str) -> str:
        row = db.query_one("SELECT * FROM users WHERE email=%s", (email,))
        if not row or not self.passwords.verify(password, row["password_hash"]):
            raise HTTPException(status_code=401, detail="帳號或密碼錯誤")
        db.execute("UPDATE users SET login_time=NOW() WHERE user_id=%s", (row["user_id"],))
        return self.sessions.create({
            "id": str(row["user_id"]),
            "email": row["email"],
            "name": row["name"],
            "role": row["role"],
        })

    def register(self, body: RegisterBody) -> str:
        if db.query_one("SELECT user_id FROM users WHERE email=%s", (body.email,)):
            raise HTTPException(status_code=409, detail="此 Email 已被註冊")
        name = body.name or body.email.split("@")[0]
        user_id = db.execute(
            "INSERT INTO users (email, password_hash, name, role) VALUES (%s,%s,%s,'user')",
            (body.email, self.passwords.hash(body.password), name),
        )
        return self.sessions.create({"id": str(user_id), "email": body.email, "name": name, "role": "user"})

    def update_profile(self, body: UpdateProfileBody, current_user: dict, token: str | None) -> None:
        fields, params = [], []
        if body.name is not None:
            fields.append("name=%s")
            params.append(body.name)
        if body.email is not None:
            dup = db.query_one(
                "SELECT user_id FROM users WHERE email=%s AND user_id!=%s",
                (body.email, current_user["id"]),
            )
            if dup:
                raise HTTPException(status_code=409, detail="此 Email 已被使用")
            fields.append("email=%s")
            params.append(body.email)
        if not fields:
            raise HTTPException(status_code=400, detail="沒有需要更新的欄位")
        params.append(current_user["id"])
        db.execute(f"UPDATE users SET {', '.join(fields)} WHERE user_id=%s", params)
        if token:
            if body.name is not None:
                self.sessions.update_user(token, name=body.name)
            if body.email is not None:
                self.sessions.update_user(token, email=body.email)

    def change_password(self, body: ChangePasswordBody, current_user: dict) -> None:
        row = db.query_one("SELECT password_hash FROM users WHERE user_id=%s", (current_user["id"],))
        if not row or not self.passwords.verify(body.oldPassword, row["password_hash"]):
            raise HTTPException(status_code=400, detail="原密碼錯誤")
        db.execute(
            "UPDATE users SET password_hash=%s WHERE user_id=%s",
            (self.passwords.hash(body.newPassword), current_user["id"]),
        )

    def delete_account(self, user_id: str) -> None:
        db.execute("DELETE FROM users WHERE user_id=%s", (user_id,))
        self.sessions.remove_user_sessions(user_id)

    def list_users(self) -> list[dict]:
        return db.query(
            """SELECT user_id AS id, email, name, role, create_time, login_time
               FROM users
               ORDER BY user_id"""
        )

    def delete_user(self, user_id: str) -> None:
        row = db.query_one("SELECT role FROM users WHERE user_id=%s", (user_id,))
        if not row:
            raise HTTPException(status_code=404, detail="用戶不存在")
        if row["role"] == "admin":
            raise HTTPException(status_code=403, detail="不能刪除管理員")
        db.execute("DELETE FROM users WHERE user_id=%s", (user_id,))
        self.sessions.remove_user_sessions(str(user_id))


class AttractionService:
    def __init__(self, lookups: LookupService):
        self.lookups = lookups
        self.items: list[dict] = []
        self.item_map: dict[str, int] = {}

    def to_api(self, row: dict) -> dict:
        return {
            "id": row["attraction_id"],
            "name": row["name"],
            "category": row.get("category") or "",
            "city": row.get("city") or "",
            "location": row.get("location") or "",
            "imageUrl": row.get("image_url"),
            "description": row.get("description") or "",
            "lat": float(row["lat"]) if row.get("lat") is not None else None,
            "lon": float(row["lon"]) if row.get("lon") is not None else None,
            "openingHours": row.get("opening_hours"),
            "ticketInfo": row.get("ticket_info"),
            "rating": float(row["rating"]) if row.get("rating") is not None else None,
            "phone": row.get("phone"),
            "website": row.get("website_url"),
            "updatedAt": row.get("source_updated_at") or row.get("updated_at") or "",
        }

    def refresh(self) -> None:
        rows = db.query(
            """SELECT a.*, cat.name AS category, c.name AS city, a.address AS location
               FROM attractions a
               LEFT JOIN categories cat ON a.category_id = cat.category_id
               LEFT JOIN cities c ON a.city_id = c.city_id
               WHERE a.is_deleted = FALSE
               ORDER BY a.attraction_id"""
        )
        self.items = [self.to_api(row) for row in rows]
        self.item_map = {item["id"]: i for i, item in enumerate(self.items)}

    def list(self, q=None, cities=None, category=None, sort=None, page=None, page_size=10):
        result = [{**item} for item in self.items]
        if q:
            ql = q.lower()
            result = [
                item for item in result
                if ql in item["name"].lower() or ql in (item.get("location") or "").lower()
            ]
        if cities:
            city_set = {norm_city(c.strip()) for c in cities.split(",") if c.strip()}
            result = [item for item in result if norm_city(item.get("city")) in city_set]
        if category:
            result = [item for item in result if item.get("category") == category]

        if sort == "ns":
            result.sort(key=lambda a: CITY_NS_ORDER.get(norm_city(a.get("city")), 99))
        elif sort == "sn":
            result.sort(key=lambda a: CITY_NS_ORDER.get(norm_city(a.get("city")), 99), reverse=True)
        elif sort == "updated":
            result.sort(key=lambda a: a.get("updatedAt") or "", reverse=True)
        elif sort == "rating":
            result.sort(key=lambda a: a.get("rating") or 0, reverse=True)

        if page is not None:
            total = len(result)
            start = (page - 1) * page_size
            return {"items": result[start:start + page_size], "total": total}
        return result

    def get(self, attraction_id: str) -> dict:
        idx = self.item_map.get(attraction_id)
        if idx is None:
            raise HTTPException(status_code=404, detail="景點不存在")
        return self.items[idx]

    def create(self, body: AttractionBody) -> dict:
        new_id = str(uuid.uuid4())
        city = norm_city(body.city)
        if not city:
            city, _ = split_location(body.location)
        db.execute(
            """INSERT INTO attractions
               (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
                description, opening_hours, ticket_info, website_url,
                rating, phone, source_updated_at)
               VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NOW())""",
            (new_id, body.name, self.lookups.category_id(body.category), self.lookups.city_id(city),
             body.location, body.lat, body.lon, body.imageUrl, body.description,
             json_text(body.openingHours), json_text(body.ticketInfo), body.website,
             body.rating, body.phone),
        )
        self.refresh()
        return self.get(new_id)

    def update(self, attraction_id: str, body: AttractionBody) -> dict:
        self.get(attraction_id)
        city = norm_city(body.city)
        if not city:
            city, _ = split_location(body.location)
        db.execute(
            """UPDATE attractions
               SET name=%s, category_id=%s, city_id=%s, address=%s, lat=%s, lon=%s,
                   image_url=%s, description=%s, opening_hours=%s, ticket_info=%s,
                   website_url=%s, rating=%s, phone=%s,
                   source_updated_at=NOW()
               WHERE attraction_id=%s""",
            (body.name, self.lookups.category_id(body.category), self.lookups.city_id(city),
             body.location, body.lat, body.lon, body.imageUrl, body.description,
             json_text(body.openingHours), json_text(body.ticketInfo), body.website,
             body.rating, body.phone, attraction_id),
        )
        self.refresh()
        return self.get(attraction_id)

    def delete(self, attraction_id: str) -> None:
        self.get(attraction_id)
        db.execute("UPDATE attractions SET is_deleted=TRUE WHERE attraction_id=%s", (attraction_id,))
        self.refresh()


class ItineraryService:
    def load_items(self, itin_id: str, num_days: int) -> list:
        rows = db.query(
            """SELECT ii.item_id, ii.attraction_id, ii.day_index, ii.start_time,
                      ii.end_time, ii.note, ii.order_index,
                      a.name, a.address AS location, cat.name AS category, a.image_url, a.opening_hours,
                      a.ticket_info, a.rating
               FROM itinerary_items ii
               JOIN attractions a ON ii.attraction_id = a.attraction_id
               LEFT JOIN categories cat ON a.category_id = cat.category_id
               WHERE ii.itinerary_id = %s
               ORDER BY ii.day_index, ii.order_index""",
            (itin_id,),
        )
        days = [{"items": []} for _ in range(max(1, num_days))]
        for row in rows:
            day_idx = int(row.get("day_index") or 0)
            if not (0 <= day_idx < len(days)):
                day_idx = 0
            days[day_idx]["items"].append({
                "uid": row["item_id"],
                "attractionId": row["attraction_id"],
                "name": row.get("name") or "",
                "location": row.get("location") or "",
                "category": row.get("category") or "",
                "startTime": fmt_time(row.get("start_time")),
                "endTime": fmt_time(row.get("end_time")),
                "note": row.get("note") or "",
                "imageUrl": row.get("image_url"),
                "openingHours": row.get("opening_hours"),
                "ticketInfo": row.get("ticket_info"),
                "rating": float(row["rating"]) if row.get("rating") is not None else None,
            })
        return days

    def _owned_itinerary(self, itin_id: str, user_id: str) -> dict:
        row = db.query_one(
            "SELECT itinerary_id FROM itineraries WHERE itinerary_id=%s AND user_id=%s",
            (itin_id, user_id),
        )
        if not row:
            raise HTTPException(status_code=404, detail="行程不存在")
        return row

    def list_active(self, user_id: str) -> list[dict]:
        rows = db.query(
            "SELECT * FROM itineraries WHERE user_id=%s AND is_deleted=FALSE ORDER BY created_at DESC",
            (user_id,),
        )
        result = []
        for row in rows:
            sd = str(row["start_date"]) if row.get("start_date") else str(date.today())
            result.append({
                "id": row["itinerary_id"],
                "title": row["title"],
                "startDate": sd,
                "numDays": row["num_days"],
                "isDeleted": False,
                "days": self.load_items(row["itinerary_id"], row["num_days"]),
            })
        return result

    def list_trash(self, user_id: str) -> list[dict]:
        rows = db.query(
            "SELECT * FROM itineraries WHERE user_id=%s AND is_deleted=TRUE ORDER BY updated_at DESC",
            (user_id,),
        )
        return [{
            "id": row["itinerary_id"],
            "title": row["title"],
            "startDate": str(row["start_date"]) if row.get("start_date") else str(date.today()),
            "numDays": row["num_days"],
            "isDeleted": True,
            "days": [],
        } for row in rows]

    def current(self, user_id: str) -> dict:
        row = db.query_one(
            "SELECT * FROM itineraries WHERE user_id=%s AND is_deleted=FALSE ORDER BY updated_at DESC LIMIT 1",
            (user_id,),
        )
        if not row:
            return {"id": None, "items": []}
        items = db.query(
            """SELECT item_id, attraction_id, day_index, start_time, end_time, note, order_index
               FROM itinerary_items WHERE itinerary_id=%s ORDER BY day_index, order_index""",
            (row["itinerary_id"],),
        )
        return {"id": row["itinerary_id"], "items": items}

    def create(self, body: CreateItineraryBody, user_id: str) -> dict:
        itin_id = str(uuid.uuid4())
        db.execute(
            """INSERT INTO itineraries (itinerary_id, user_id, title, start_date, num_days)
               VALUES (%s,%s,%s,%s,%s)""",
            (itin_id, user_id, body.title, body.startDate, body.numDays),
        )
        return {
            "id": itin_id,
            "title": body.title,
            "startDate": body.startDate,
            "numDays": body.numDays,
            "isDeleted": False,
            "days": [{"items": []} for _ in range(body.numDays)],
        }

    def update(self, itin_id: str, body: UpdateItineraryBody, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        fields, params = [], []
        if body.title is not None:
            fields.append("title=%s")
            params.append(body.title)
        if body.startDate is not None:
            fields.append("start_date=%s")
            params.append(body.startDate)
        if body.numDays is not None:
            fields.append("num_days=%s")
            params.append(body.numDays)
        if fields:
            params.append(itin_id)
            db.execute(f"UPDATE itineraries SET {', '.join(fields)} WHERE itinerary_id=%s", params)

    def hard_delete(self, itin_id: str, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        db.execute("DELETE FROM itineraries WHERE itinerary_id=%s", (itin_id,))

    def soft_delete(self, itin_id: str, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        db.execute("UPDATE itineraries SET is_deleted=TRUE WHERE itinerary_id=%s", (itin_id,))

    def restore(self, itin_id: str, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        db.execute("UPDATE itineraries SET is_deleted=FALSE WHERE itinerary_id=%s", (itin_id,))

    def replace_items(self, itin_id: str, body: PutItemsBody, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        db.execute("DELETE FROM itinerary_items WHERE itinerary_id=%s", (itin_id,))
        for order_i, item in enumerate(body.items):
            db.execute(
                """INSERT INTO itinerary_items
                   (item_id, itinerary_id, attraction_id, day_index, start_time, end_time, note, order_index)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
                (item.uid, itin_id, item.attractionId, item.dayIndex,
                 item.startTime, item.endTime, item.note, order_i),
            )

    def add_item(self, itin_id: str, body: AddItemBody, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        max_order = db.query_one(
            "SELECT COALESCE(MAX(order_index), -1) AS max_order FROM itinerary_items WHERE itinerary_id=%s AND day_index=%s",
            (itin_id, body.dayIndex),
        )
        order_i = (max_order["max_order"] + 1) if max_order else 0
        db.execute(
            """INSERT INTO itinerary_items
               (item_id, itinerary_id, attraction_id, day_index, start_time, end_time, note, order_index)
               VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
            (body.uid, itin_id, body.attractionId, body.dayIndex,
             body.startTime, body.endTime, body.note, order_i),
        )

    def remove_item(self, itin_id: str, item_id: str, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        db.execute("DELETE FROM itinerary_items WHERE item_id=%s AND itinerary_id=%s", (item_id, itin_id))

    def update_item(self, itin_id: str, item_id: str, body: UpdateItemBody, user_id: str) -> None:
        self._owned_itinerary(itin_id, user_id)
        fields, params = [], []
        if body.startTime is not None:
            fields.append("start_time=%s")
            params.append(body.startTime)
        if body.endTime is not None:
            fields.append("end_time=%s")
            params.append(body.endTime)
        if body.note is not None:
            fields.append("note=%s")
            params.append(body.note)
        if body.dayIndex is not None:
            fields.append("day_index=%s")
            params.append(body.dayIndex)
        if body.orderIndex is not None:
            fields.append("order_index=%s")
            params.append(body.orderIndex)
        if fields:
            params.extend([item_id, itin_id])
            db.execute(
                f"UPDATE itinerary_items SET {', '.join(fields)} WHERE item_id=%s AND itinerary_id=%s",
                params,
            )
