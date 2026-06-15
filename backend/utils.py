import json
from typing import Optional, Union


CITY_NAMES: tuple[str, ...] = (
    "基隆市", "台北市", "新北市", "桃園市",
    "新竹市", "新竹縣", "苗栗縣", "台中市",
    "彰化縣", "南投縣", "雲林縣", "嘉義市",
    "嘉義縣", "台南市", "高雄市", "屏東縣",
    "宜蘭縣", "花蓮縣", "台東縣",
    "澎湖縣", "金門縣", "連江縣",
)


def norm_city(value: str | None) -> str:
    return (value or "").replace("臺", "台")


def split_location(location: str) -> tuple[str, str]:
    loc = norm_city(location).strip()
    for city in sorted(CITY_NAMES, key=len, reverse=True):
        if loc.startswith(city):
            return city, loc
    return "", loc


def json_text(value: Union[str, dict, None]) -> Optional[str]:
    if value is None:
        return None
    if isinstance(value, str):
        return value
    return json.dumps(value, ensure_ascii=False)


def fmt_time(value) -> str:
    if value is None:
        return "09:00"
    text = str(value)
    return text[:5] if len(text) >= 5 else text
