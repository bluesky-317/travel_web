from typing import Optional

from fastapi import APIRouter, Depends
from fastapi.security import HTTPAuthorizationCredentials

from auth import AuthDependencies
from schemas import (
    AttractionBody,
    ChangePasswordBody,
    CreateItineraryBody,
    LoginBody,
    PutItemsBody,
    RegisterBody,
    UpdateItineraryBody,
    UpdateProfileBody,
)
from services import AttractionService, ItineraryService, UserService


def create_router(
    auth: AuthDependencies,
    users: UserService,
    attractions: AttractionService,
    itineraries: ItineraryService,
) -> APIRouter:
    router = APIRouter()

    @router.post("/login")
    def login(body: LoginBody):
        token = users.login(body.email, body.password)
        return {"data": {"token": token}}

    @router.post("/register")
    def register(body: RegisterBody):
        token = users.register(body)
        return {"data": {"token": token}}

    @router.get("/me")
    def get_me(current_user: dict = Depends(auth.current_user)):
        return {"data": current_user}

    @router.patch("/me")
    def update_profile(
        body: UpdateProfileBody,
        current_user: dict = Depends(auth.current_user),
        credentials: Optional[HTTPAuthorizationCredentials] = Depends(auth.security),
    ):
        token = credentials.credentials if credentials else None
        users.update_profile(body, current_user, token)
        return {"data": {"message": "已更新"}}

    @router.put("/me/password")
    def change_password(body: ChangePasswordBody, current_user: dict = Depends(auth.current_user)):
        users.change_password(body, current_user)
        return {"data": {"message": "密碼已更新"}}

    @router.delete("/me")
    def delete_account(current_user: dict = Depends(auth.current_user)):
        users.delete_account(current_user["id"])
        return {"data": {"message": "帳號已刪除"}}

    @router.get("/attractions")
    def list_attractions(
        q: Optional[str] = None,
        cities: Optional[str] = None,
        category: Optional[str] = None,
        sort: Optional[str] = None,
        page: Optional[int] = None,
        page_size: int = 10,
    ):
        return {"data": attractions.list(q, cities, category, sort, page, page_size)}

    @router.get("/attractions/{attraction_id}")
    def get_attraction(attraction_id: str):
        return {"data": attractions.get(attraction_id)}

    @router.post("/attractions")
    def create_attraction(body: AttractionBody, current_user: dict = Depends(auth.current_user)):
        auth.require_admin(current_user)
        return {"data": attractions.create(body)}

    @router.put("/attractions/{attraction_id}")
    def update_attraction(
        attraction_id: str,
        body: AttractionBody,
        current_user: dict = Depends(auth.current_user),
    ):
        auth.require_admin(current_user)
        return {"data": attractions.update(attraction_id, body)}

    @router.delete("/attractions/{attraction_id}")
    def delete_attraction(attraction_id: str, current_user: dict = Depends(auth.current_user)):
        auth.require_admin(current_user)
        attractions.delete(attraction_id)
        return {"data": {"message": "已刪除"}}

    @router.get("/itineraries")
    def list_itineraries(current_user: dict = Depends(auth.current_user)):
        return {"data": itineraries.list_active(current_user["id"])}

    @router.get("/itineraries/trash")
    def list_itineraries_trash(current_user: dict = Depends(auth.current_user)):
        return {"data": itineraries.list_trash(current_user["id"])}

    @router.post("/itineraries")
    def create_itinerary(body: CreateItineraryBody, current_user: dict = Depends(auth.current_user)):
        return {"data": itineraries.create(body, current_user["id"])}

    @router.patch("/itineraries/{itin_id}")
    def update_itinerary(
        itin_id: str,
        body: UpdateItineraryBody,
        current_user: dict = Depends(auth.current_user),
    ):
        itineraries.update(itin_id, body, current_user["id"])
        return {"data": {"message": "已更新"}}

    @router.delete("/itineraries/{itin_id}/permanent")
    def hard_delete_itinerary(itin_id: str, current_user: dict = Depends(auth.current_user)):
        itineraries.hard_delete(itin_id, current_user["id"])
        return {"data": {"message": "已永久刪除"}}

    @router.delete("/itineraries/{itin_id}")
    def soft_delete_itinerary(itin_id: str, current_user: dict = Depends(auth.current_user)):
        itineraries.soft_delete(itin_id, current_user["id"])
        return {"data": {"message": "已移至垃圾桶"}}

    @router.post("/itineraries/{itin_id}/restore")
    def restore_itinerary(itin_id: str, current_user: dict = Depends(auth.current_user)):
        itineraries.restore(itin_id, current_user["id"])
        return {"data": {"message": "已還原"}}

    @router.put("/itineraries/{itin_id}/items")
    def put_itinerary_items(
        itin_id: str,
        body: PutItemsBody,
        current_user: dict = Depends(auth.current_user),
    ):
        itineraries.replace_items(itin_id, body, current_user["id"])
        return {"data": {"message": "已更新"}}

    @router.get("/admin/users")
    def list_users(current_user: dict = Depends(auth.current_user)):
        auth.require_admin(current_user)
        return {"data": users.list_users()}

    @router.delete("/admin/users/{user_id}")
    def delete_user(user_id: str, current_user: dict = Depends(auth.current_user)):
        auth.require_admin(current_user)
        users.delete_user(user_id)
        return {"data": {"message": "已刪除"}}

    return router
