from typing import Optional, Union

from pydantic import BaseModel


class LoginBody(BaseModel):
    email: str
    password: str


class RegisterBody(BaseModel):
    email: str
    password: str
    name: Optional[str] = None


class UpdateProfileBody(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None


class ChangePasswordBody(BaseModel):
    oldPassword: str
    newPassword: str


class CreateItineraryBody(BaseModel):
    title: str = "我的旅程"
    startDate: str
    numDays: int = 1


class UpdateItineraryBody(BaseModel):
    title: Optional[str] = None
    startDate: Optional[str] = None
    numDays: Optional[int] = None


class ItineraryItemInput(BaseModel):
    uid: str
    attractionId: str
    dayIndex: int
    startTime: str
    endTime: str
    note: str = ""


class PutItemsBody(BaseModel):
    items: list[ItineraryItemInput]


class AttractionBody(BaseModel):
    name: str
    city: Optional[str] = None
    location: str
    category: Optional[str] = None
    imageUrl: Optional[str] = None
    description: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    openingHours: Optional[Union[str, dict]] = None
    ticketInfo: Optional[Union[str, dict]] = None
    rating: Optional[float] = None
    phone: Optional[str] = None
    website: Optional[str] = None
