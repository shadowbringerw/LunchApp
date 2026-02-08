# Plan

- 新增 Spring Boot 后端模块 `backend/`
  - `POST /api/decide`：读取最近3条→找重复→重复项权重0.5→随机→保存→返回结果
  - `GET /api/history`：返回历史列表（降序）
  - `DELETE /api/history`：清空历史
  - H2 文件库持久化，日志输出便于录屏
- 前端改造：`BackendClient` 调用后端
  - 点击“决策”并行发起后端请求 + 3 秒滚动
  - 3 秒后若结果已到则停在结果上，否则短暂等待直到结果到达

