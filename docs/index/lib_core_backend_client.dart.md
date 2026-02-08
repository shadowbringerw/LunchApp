# `lib/core/backend_client.dart` 索引

## 作用

- Flutter Web 侧的后端 HTTP 客户端（使用 `dart:html` 的 `HttpRequest`）
- 提供 3 个方法：
  - `decide(options)` → `POST /api/decide`
  - `history(limit)` → `GET /api/history?limit=...`
  - `clearHistory()` → `DELETE /api/history`

## 日志

- 每次请求会打印：`[BackendClient] METHOD url`

## DTO

- `DecideResponse`：`choice/timestampMs/recent3/penalizedChoices`
- `HistoryItem`：`choice/timestampMs`

