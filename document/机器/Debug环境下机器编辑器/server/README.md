# 机器参数接收服务（联通测试）

本机开 HTTP，手机同 Wi‑Fi 访问，验证「编辑器发送 → 本机接收」链路。

## 启动

```bash
cd "/Users/zcz/zczWorkspace/document/机器/Debug环境下机器编辑器/server"
python3 machine_param_server.py
# 或指定端口
python3 machine_param_server.py --port 8765
```

## 手机测试

1. 手机连同一 Wi‑Fi（与电脑同一网段）。
2. 浏览器打开：`http://<本机局域网IP>:8765/`
3. 点「发送测试 JSON」——成功会提示 `savedAs`，本机 `received/` 下出现文件。
4. 也可用 curl：

```bash
curl -X POST "http://172.16.20.45:8765/api/params" \
  -H "Content-Type: application/json" \
  -d '{"machine":"BlazingWild100x","scheme":"test","params":{"Timing.collectFlyDuration":0.4}}'
```

## 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/` | 状态页 |
| GET | `/health` | `{"ok":true}` |
| GET | `/last` | 最近一次接收内容 |
| POST | `/api/params` | 接收参数 JSON，写入 `received/` |

成功响应：`{"ok":true,"savedAs":"...json","receivedCount":N}`  
失败响应：`{"ok":false,"error":"..."}`（HTTP 4xx）

若手机打不开：检查防火墙是否放行 8765，确认 IP 是否仍是当前网卡地址。
