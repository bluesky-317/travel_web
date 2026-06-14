from fastapi import FastAPI, Request
from fastapi.exceptions import HTTPException as FastAPIHTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from auth import AuthDependencies, PasswordService, SessionStore
from routes import create_router
from services import (
    AttractionService,
    ItineraryService,
    LookupService,
    SchemaService,
    UserService,
)


class BackendApplication:
    def __init__(self):
        self.app = FastAPI()
        self.schema = SchemaService()
        self.sessions = SessionStore()
        self.passwords = PasswordService()
        self.auth = AuthDependencies(self.sessions)
        self.lookups = LookupService()
        self.users = UserService(self.passwords, self.sessions)
        self.attractions = AttractionService(self.lookups)
        self.itineraries = ItineraryService()
        self._configure()

    def _configure(self) -> None:
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["http://localhost:5173", "http://localhost:3000"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        self.app.add_exception_handler(FastAPIHTTPException, self.http_exception_handler)
        self.app.include_router(create_router(self.auth, self.users, self.attractions, self.itineraries))
        self.app.on_event("startup")(self.startup)

    async def http_exception_handler(self, request: Request, exc: FastAPIHTTPException):
        return JSONResponse(status_code=exc.status_code, content={"message": exc.detail})

    def startup(self) -> None:
        self.schema.ensure()
        self.users.seed_defaults()


application = BackendApplication()
app = application.app
