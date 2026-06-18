from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse
import json
import mimetypes
import re


ROOT = Path(__file__).resolve().parents[1]
CHILD_ID = "child_001"
DATA_DIR = ROOT / "backend" / "data"
DATA_PATH = DATA_DIR / "store.json"


DEFAULT_STORE = {
    "family": {
        "familyId": "fam_001",
        "members": [
            {"id": "parent_001", "name": "妈妈", "role": "admin"},
            {"id": "parent_002", "name": "爸爸", "role": "member"},
        ],
        "children": [
            {"id": CHILD_ID, "name": "豆豆", "age": 8, "className": "二年级 3 班"}
        ],
    },
    "device": {
        "deviceId": "watch_001",
        "model": "豆小宝 Watch S1",
        "online": True,
        "battery": 76,
        "phone": "138 1024 8848",
        "balance": 36.8,
        "dataUsageGb": 1.8,
        "dataLimitGb": 5,
        "lastSyncAt": "2026-06-18T23:12:00+08:00",
    },
    "location": {
        "place": "星河小学北门",
        "latitude": 31.2304,
        "longitude": 121.4737,
        "accuracyMeters": 28,
        "status": "safe",
        "updatedAt": "2026-06-18T23:12:00+08:00",
    },
    "tracks": [
        {"id": "track_001", "time": "07:36", "place": "家", "detail": "离家", "status": "正常", "distance": "0km"},
        {"id": "track_002", "time": "07:51", "place": "梧桐路公交站", "detail": "通勤中", "status": "正常", "distance": "1.6km"},
        {"id": "track_003", "time": "07:58", "place": "星河小学", "detail": "到校", "status": "进入安全区", "distance": "2.2km"},
        {"id": "track_004", "time": "16:42", "place": "星河小学北门", "detail": "放学等待", "status": "安全区内", "distance": "2.2km"},
    ],
    "zones": [
        {"id": "zone_001", "name": "星河小学", "type": "安全区", "range": "300m", "enabled": True},
        {"id": "zone_002", "name": "少年宫路口", "type": "提醒区", "range": "120m", "enabled": True},
        {"id": "zone_003", "name": "城南施工段", "type": "危险区", "range": "200m", "enabled": True},
    ],
    "tasks": [
        {"id": "task_001", "title": "英语听读 15 分钟", "time": "19:10", "reward": 8, "done": False},
        {"id": "task_002", "title": "整理明天书包", "time": "20:20", "reward": 6, "done": True},
        {"id": "task_003", "title": "睡前刷牙打卡", "time": "21:00", "reward": 4, "done": False},
    ],
    "modes": [
        {"id": "study", "name": "学习模式", "time": "周一至周五 08:00-16:30", "active": True},
        {"id": "sleep", "name": "睡眠模式", "time": "每天 21:30-07:00", "active": True},
        {"id": "play", "name": "娱乐模式", "time": "每天最多 30 分钟", "active": False},
    ],
    "apps": [
        {"id": "app_phone", "name": "电话", "minutes": 12, "enabled": True, "locked": False},
        {"id": "app_chat", "name": "微聊", "minutes": 18, "enabled": True, "locked": False},
        {"id": "app_story", "name": "故事", "minutes": 24, "enabled": True, "locked": True},
        {"id": "app_sport", "name": "运动", "minutes": 31, "enabled": True, "locked": False},
    ],
    "contacts": [
        {"id": "contact_001", "name": "妈妈", "relation": "管理员", "phone": "138 1024 8848", "trusted": True},
        {"id": "contact_002", "name": "爸爸", "relation": "家人", "phone": "136 2233 9001", "trusted": True},
        {"id": "contact_003", "name": "班主任王老师", "relation": "老师", "phone": "139 0000 2016", "trusted": True},
    ],
    "report": {
        "stars": 42,
        "steps": 8650,
        "sleep": "9h 10m",
        "mood": "平稳",
        "insights": ["建议把娱乐模式放在作业完成后开启。"],
        "disclaimer": "健康和心情数据仅作辅助观察，不构成医疗或心理诊断。",
    },
}


def load_store():
    if not DATA_PATH.exists():
        return json.loads(json.dumps(DEFAULT_STORE, ensure_ascii=False))
    return json.loads(DATA_PATH.read_text(encoding="utf-8"))


def save_store():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    DATA_PATH.write_text(json.dumps(STORE, ensure_ascii=False, indent=2), encoding="utf-8")


STORE = load_store()


def ok(data=None, message="ok"):
    return 200, {"code": 0, "message": message, "data": data if data is not None else {}}


def error(status, message):
    return status, {"code": status, "message": message, "data": {}}


def next_id(prefix, items):
    return f"{prefix}_{len(items) + 1:03d}"


def bootstrap():
    child = STORE["family"]["children"][0]
    device = STORE["device"]
    location = STORE["location"]
    return {
        "child": {
            "id": child["id"],
            "name": child["name"],
            "age": child["age"],
            "className": child["className"],
            "avatar": child["name"][0],
            "device": device["model"],
            "battery": device["battery"],
            "online": device["online"],
            "phone": device["phone"],
            "balance": device["balance"],
            "dataUsage": device["dataUsageGb"],
            "dataLimit": device["dataLimitGb"],
            "lastSync": "2 分钟前",
        },
        "location": {
            "place": location["place"],
            "status": "在安全区域内" if location["status"] == "safe" else "需要关注",
            "updatedAt": "23:12",
            "accuracy": f"{location['accuracyMeters']}m",
        },
        "tracks": STORE["tracks"],
        "zones": STORE["zones"],
        "tasks": STORE["tasks"],
        "modes": STORE["modes"],
        "apps": STORE["apps"],
        "contacts": STORE["contacts"],
        "reports": {
            "stars": STORE["report"]["stars"],
            "steps": STORE["report"]["steps"],
            "sleep": STORE["report"]["sleep"],
            "mood": STORE["report"]["mood"],
        },
    }


def read_body(handler):
    length = int(handler.headers.get("Content-Length", "0"))
    if length == 0:
        return {}
    raw = handler.rfile.read(length).decode("utf-8")
    return json.loads(raw or "{}")


def route(method, raw_path, body=None):
    parsed = urlparse(raw_path)
    path = parsed.path
    query = parse_qs(parsed.query)
    body = body or {}

    if method == "GET" and path == "/api/v1/health":
        return ok({"status": "ready"})
    if method == "GET" and path == "/api/v1/bootstrap":
        return ok(bootstrap())
    if method == "GET" and path == "/api/v1/families/current":
        return ok(STORE["family"])
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/device", path):
        return ok(STORE["device"])
    if method == "POST" and path == "/api/v1/devices/bind":
        STORE["device"]["lastSyncAt"] = "2026-06-18T23:30:00+08:00"
        save_store()
        return ok({"deviceId": STORE["device"]["deviceId"], "bindCode": body.get("bindCode")}, "device bound")
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/location/current", path):
        return ok(STORE["location"])
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/location/tracks", path):
        return ok({"date": query.get("date", ["2026-06-18"])[0], "items": STORE["tracks"]})
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/geo-zones", path):
        return ok(STORE["zones"])
    if method == "POST" and re.fullmatch(r"/api/v1/children/[^/]+/geo-zones", path):
        zone = {
            "id": next_id("zone", STORE["zones"]),
            "name": body.get("name", "新守护区域"),
            "type": body.get("type", "安全区"),
            "range": body.get("range", "200m"),
            "enabled": bool(body.get("enabled", True)),
        }
        STORE["zones"].append(zone)
        save_store()
        return ok(zone, "zone created")
    zone_match = re.fullmatch(r"/api/v1/geo-zones/([^/]+)", path)
    if method == "PATCH" and zone_match:
        zone_id = zone_match.group(1)
        for zone in STORE["zones"]:
            if zone["id"] == zone_id:
                zone.update({k: v for k, v in body.items() if k in {"name", "type", "range", "enabled"}})
                save_store()
                return ok(zone, "zone updated")
        return error(404, "zone not found")
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/tasks", path):
        return ok({"date": query.get("date", ["2026-06-18"])[0], "items": STORE["tasks"]})
    if method == "POST" and re.fullmatch(r"/api/v1/children/[^/]+/tasks", path):
        task = {
            "id": next_id("task", STORE["tasks"]),
            "title": body.get("title", "新任务"),
            "time": body.get("time") or body.get("remindAt", "20:00")[-14:-9],
            "reward": int(body.get("reward", 6)),
            "done": False,
        }
        STORE["tasks"].insert(0, task)
        save_store()
        return ok(task, "task created")
    task_match = re.fullmatch(r"/api/v1/tasks/([^/]+)", path)
    if method == "PATCH" and task_match:
        task_id = task_match.group(1)
        for task in STORE["tasks"]:
            if task["id"] == task_id:
                task.update({k: v for k, v in body.items() if k in {"title", "time", "reward", "done"}})
                save_store()
                return ok(task, "task updated")
        return error(404, "task not found")
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/control/modes", path):
        return ok(STORE["modes"])
    mode_match = re.fullmatch(r"/api/v1/children/[^/]+/control/modes/([^/]+)", path)
    if method == "PATCH" and mode_match:
        mode_id = mode_match.group(1)
        for mode in STORE["modes"]:
            if mode["id"] == mode_id:
                if "enabled" in body:
                    mode["active"] = bool(body["enabled"])
                if "schedule" in body:
                    mode["time"] = body["schedule"]
                save_store()
                return ok(mode, "mode updated")
        return error(404, "mode not found")
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/apps/usage", path):
        return ok({"date": query.get("date", ["2026-06-18"])[0], "items": STORE["apps"]})
    app_match = re.fullmatch(r"/api/v1/children/[^/]+/apps/([^/]+)", path)
    if method == "PATCH" and app_match:
        app_id = app_match.group(1)
        for app in STORE["apps"]:
            if app["id"] == app_id:
                app.update({k: v for k, v in body.items() if k in {"enabled", "locked"}})
                save_store()
                return ok(app, "app updated")
        return error(404, "app not found")
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/contacts", path):
        return ok(STORE["contacts"])
    if method == "POST" and re.fullmatch(r"/api/v1/children/[^/]+/contacts", path):
        contact = {
            "id": next_id("contact", STORE["contacts"]),
            "name": body.get("name", "新联系人"),
            "relation": body.get("relation", "家人"),
            "phone": body.get("phone", ""),
            "trusted": bool(body.get("trusted", True)),
        }
        STORE["contacts"].append(contact)
        save_store()
        return ok(contact, "contact created")
    if method == "POST" and re.fullmatch(r"/api/v1/children/[^/]+/agent/messages", path):
        text = body.get("text", "")
        actions = []
        reply = f"已收到：{text}"
        if "阅读" in text or "提醒" in text or "任务" in text:
            task = {
                "id": next_id("task", STORE["tasks"]),
                "title": "阅读课外书 15 分钟" if "阅读" in text else text[:18],
                "time": "19:30" if "19:30" in text else "20:00",
                "reward": 6,
                "done": False,
            }
            STORE["tasks"].insert(0, task)
            actions.append({"type": "task.created", "taskId": task["id"]})
            reply = "已创建提醒任务，并同步到今日任务列表。"
        if "睡眠" in text:
            for mode in STORE["modes"]:
                if mode["id"] == "sleep":
                    mode["active"] = True
            actions.append({"type": "mode.enabled", "modeId": "sleep"})
            reply = "已开启睡眠模式计划，今晚自动生效。"
        if actions:
            save_store()
        return ok({"reply": reply, "actions": actions})
    if method == "GET" and re.fullmatch(r"/api/v1/children/[^/]+/reports/weekly", path):
        return ok(STORE["report"])
    return error(404, "not found")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/api/"):
            self.send_json(*route("GET", self.path))
            return
        self.send_static()

    def do_POST(self):
        self.send_json(*route("POST", self.path, read_body(self)))

    def do_PATCH(self):
        self.send_json(*route("PATCH", self.path, read_body(self)))

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,PATCH,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def send_json(self, status, payload):
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def send_static(self):
        parsed = urlparse(self.path)
        path = parsed.path.strip("/") or "index.html"
        target = (ROOT / path).resolve()
        if not str(target).startswith(str(ROOT)) or not target.exists() or target.is_dir():
            self.send_error(404)
            return
        content = target.read_bytes()
        mime = mimetypes.guess_type(str(target))[0] or "application/octet-stream"
        if target.suffix == ".js":
            mime = "text/javascript"
        self.send_response(200)
        self.send_header("Content-Type", f"{mime}; charset=utf-8")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)


def run(host="127.0.0.1", port=5173):
    server = ThreadingHTTPServer((host, port), Handler)
    print(f"豆小宝家长端服务已启动：http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
