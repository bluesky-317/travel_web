import uuid
from typing import Optional

import bcrypt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer


class PasswordService:
    def hash(self, password: str) -> str:
        return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    def verify(self, password: str, hashed: str) -> bool:
        return bcrypt.checkpw(password.encode("utf-8"), hashed.encode("utf-8"))


class SessionStore:
    def __init__(self):
        self._sessions: dict[str, dict] = {}

    def create(self, user: dict) -> str:
        token = str(uuid.uuid4())
        self._sessions[token] = user
        return token

    def get(self, token: str | None) -> dict | None:
        if not token:
            return None
        return self._sessions.get(token)

    def update_user(self, token: str, **fields) -> None:
        if token in self._sessions:
            self._sessions[token].update(fields)

    def remove_user_sessions(self, user_id: str) -> None:
        for token in [t for t, u in self._sessions.items() if u.get("id") == user_id]:
            self._sessions.pop(token, None)


class AuthDependencies:
    def __init__(self, sessions: SessionStore):
        self.sessions = sessions
        self.security = HTTPBearer(auto_error=False)

    def current_user(
        self,
        credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False)),
    ):
        if not credentials:
            raise HTTPException(status_code=401, detail="未登入")
        user = self.sessions.get(credentials.credentials)
        if not user:
            raise HTTPException(status_code=401, detail="Token 無效或已過期")
        return user

    def optional_user(
        self,
        credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False)),
    ):
        if not credentials:
            return None
        return self.sessions.get(credentials.credentials)

    def require_admin(self, current_user: dict) -> dict:
        if current_user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="需要管理員權限")
        return current_user
