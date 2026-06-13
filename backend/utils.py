import json
from typing import Optional, Union


CITY_NS_ORDER: dict[str, int] = {
    "基隆市": 1, "台北市": 2, "新北市": 3, "桃園市": 4,
    "新竹市": 5, "新竹縣": 6, "苗栗縣": 7, "台中市": 8,
    "彰化縣": 9, "南投縣": 10, "雲林縣": 11, "嘉義市": 12,
    "嘉義縣": 13, "台南市": 14, "高雄市": 15, "屏東縣": 16,
    "宜蘭縣": 17, "花蓮縣": 18, "台東縣": 19,
    "澎湖縣": 20, "金門縣": 21, "連江縣": 22,
}


def norm_city(value: str | None) -> str:
    return (value or "").replace("臺", "台")


def split_location(location: str) -> tuple[str, str]:
    loc = norm_city(location).strip()
    for city in sorted(CITY_NS_ORDER, key=len, reverse=True):
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
