#!/usr/bin/env python3
"""本机机器参数接收服务 —— 手机 / Unity 调试面板联通测试用。

用法:
  python3 machine_param_server.py
  python3 machine_param_server.py --port 8765 --host 0.0.0.0

接口:
  GET  /              状态页（手机浏览器可直接打开）
  GET  /health        {"ok": true}
  POST /api/params    接收机器自定义参数 JSON，落盘到 received/
  OPTIONS *           CORS 预检
"""

from __future__ import annotations

import argparse
import json
import socket
import traceback
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent
RECEIVED_DIR = ROOT / "received"
RECEIVED_DIR.mkdir(parents=True, exist_ok=True)

LAST_PAYLOAD: dict | None = None
LAST_ERROR: str | None = None
RECV_COUNT = 0


def lan_ips() -> list[str]:
    ips: list[str] = []
    try:
        hostname = socket.gethostname()
        for info in socket.getaddrinfo(hostname, None, socket.AF_INET):
            ip = info[4][0]
            if not ip.startswith("127.") and ip not in ips:
                ips.append(ip)
    except OSError:
        pass
    # 再试一次 UDP 探测默认出站网卡
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        if ip not in ips:
            ips.insert(0, ip)
    except OSError:
        pass
    return ips or ["127.0.0.1"]


class Handler(BaseHTTPRequestHandler):
    server_version = "MachineParamServer/0.1"

    def log_message(self, fmt: str, *args) -> None:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {self.address_string()} {fmt % args}")

    def _cors(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-Machine-Name, X-Scheme-Name")

    def _json(self, code: int, body: dict) -> None:
        raw = json.dumps(body, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self._cors()
        self.end_headers()
        self.wfile.write(raw)

    def _html(self, code: int, html: str) -> None:
        raw = html.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self._cors()
        self.end_headers()
        self.wfile.write(raw)

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self._cors()
        self.end_headers()

    def do_GET(self) -> None:
        path = urlparse(self.path).path
        if path == "/health":
            self._json(200, {"ok": True, "receivedCount": RECV_COUNT})
            return
        if path == "/last":
            self._json(
                200,
                {
                    "ok": True,
                    "receivedCount": RECV_COUNT,
                    "last": LAST_PAYLOAD,
                    "lastError": LAST_ERROR,
                },
            )
            return
        if path in ("/", "/index.html"):
            self._html(200, status_page())
            return
        self._json(404, {"ok": False, "error": f"unknown path: {path}"})

    def do_POST(self) -> None:
        global LAST_PAYLOAD, LAST_ERROR, RECV_COUNT
        path = urlparse(self.path).path
        if path not in ("/api/params", "/api/machine-params"):
            self._json(404, {"ok": False, "error": f"unknown path: {path}"})
            return

        length = int(self.headers.get("Content-Length", "0") or 0)
        if length <= 0:
            LAST_ERROR = "empty body"
            self._json(400, {"ok": False, "error": "empty body"})
            return
        if length > 2 * 1024 * 1024:
            LAST_ERROR = "body too large"
            self._json(413, {"ok": False, "error": "body too large (>2MB)"})
            return

        try:
            raw = self.rfile.read(length)
            text = raw.decode("utf-8")
            data = json.loads(text)
            if not isinstance(data, dict):
                raise ValueError("root JSON must be an object")

            machine = (
                data.get("machine")
                or data.get("machineName")
                or self.headers.get("X-Machine-Name")
                or "unknown"
            )
            scheme = (
                data.get("scheme")
                or data.get("schemeName")
                or self.headers.get("X-Scheme-Name")
                or "default"
            )
            ts = datetime.now().strftime("%Y%m%d_%H%M%S")
            safe_machine = "".join(c if c.isalnum() or c in "-_" else "_" for c in str(machine))
            safe_scheme = "".join(c if c.isalnum() or c in "-_" else "_" for c in str(scheme))
            out = RECEIVED_DIR / f"{ts}_{safe_machine}_{safe_scheme}.json"
            envelope = {
                "receivedAt": datetime.now().isoformat(timespec="seconds"),
                "client": self.client_address[0],
                "machine": machine,
                "scheme": scheme,
                "payload": data,
            }
            out.write_text(json.dumps(envelope, ensure_ascii=False, indent=2), encoding="utf-8")

            LAST_PAYLOAD = envelope
            LAST_ERROR = None
            RECV_COUNT += 1
            print(f"  -> saved {out.name} ({length} bytes) from {self.client_address[0]}")
            self._json(
                200,
                {
                    "ok": True,
                    "message": "received",
                    "savedAs": out.name,
                    "receivedCount": RECV_COUNT,
                },
            )
        except Exception as e:
            LAST_ERROR = f"{e}\n{traceback.format_exc()}"
            print(f"  !! receive failed: {e}")
            self._json(400, {"ok": False, "error": str(e)})


def status_page() -> str:
    last_preview = "尚无收到数据"
    if LAST_PAYLOAD is not None:
        last_preview = json.dumps(LAST_PAYLOAD, ensure_ascii=False, indent=2)

    ips = lan_ips()
    links = "".join(
        f'<li><a href="http://{ip}:{PORT}/">{ip}:{PORT}</a></li>' for ip in ips
    )
    err = f"<pre style='color:#c00'>{LAST_ERROR}</pre>" if LAST_ERROR else ""
    return f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>机器参数接收服务</title>
  <style>
    body {{ font-family: -apple-system, sans-serif; margin: 24px; background: #111; color: #eee; }}
    a {{ color: #6cf; }}
    pre {{ background: #1c1c1c; padding: 12px; overflow: auto; border-radius: 8px; }}
    .ok {{ color: #6d6; }}
    button {{ font-size: 16px; padding: 10px 16px; margin: 8px 8px 8px 0; }}
  </style>
</head>
<body>
  <h1>机器参数接收服务</h1>
  <p class="ok">服务正常 · 已接收 {RECV_COUNT} 次</p>
  <p>本机可达地址：</p>
  <ul>{links}</ul>
  <p>
    <button onclick="sendTest()">发送测试 JSON</button>
    <button onclick="location.reload()">刷新</button>
  </p>
  <h2>最近一次</h2>
  {err}
  <pre id="last">{last_preview}</pre>
  <script>
    async function sendTest() {{
      const body = {{
        machine: "BlazingWild100x",
        scheme: "phone-test",
        params: {{
          "Timing.collectFlyDuration": 0.4,
          "Timing.nudgeArrowDuration": 0.5
        }}
      }};
      try {{
        const res = await fetch("/api/params", {{
          method: "POST",
          headers: {{ "Content-Type": "application/json" }},
          body: JSON.stringify(body)
        }});
        const data = await res.json();
        alert(res.ok ? ("成功: " + data.savedAs) : ("失败: " + data.error));
        location.reload();
      }} catch (e) {{
        alert("请求失败: " + e);
      }}
    }}
  </script>
</body>
</html>
"""


PORT = 8765


def main() -> None:
    global PORT
    parser = argparse.ArgumentParser(description="Machine param receive server")
    parser.add_argument("--host", default="0.0.0.0", help="bind address (0.0.0.0 = LAN)")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    PORT = args.port

    httpd = ThreadingHTTPServer((args.host, args.port), Handler)
    ips = lan_ips()
    print("=" * 56)
    print("  机器参数接收服务已启动")
    print(f"  bind: {args.host}:{args.port}")
    for ip in ips:
        print(f"  手机浏览器打开: http://{ip}:{args.port}/")
        print(f"  POST 参数到:     http://{ip}:{args.port}/api/params")
    print(f"  落盘目录: {RECEIVED_DIR}")
    print("  Ctrl+C 停止")
    print("=" * 56)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nstopped.")
        httpd.server_close()


if __name__ == "__main__":
    main()
