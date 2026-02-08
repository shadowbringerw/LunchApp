# `backend/src/main/java/com/kunlunlunch/decision/api/DecideController.java` 索引

## 作用

- 提供后端 API，并输出“可录屏展示”的后端日志：
  - `POST /api/decide`：加权随机并写入历史
  - `GET /api/history?limit=200`：读取历史（降序）
  - `DELETE /api/history`：清空历史

## 日志格式

- `DECIDE ... choice="xxx" at=...`
- `HISTORY limit=... returned=...`
- `HISTORY cleared at=...`

