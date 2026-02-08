# Summary

完成：

- 真实后端已加入：Spring Boot (`backend/`)，每次决策都有后端请求与日志输出
- 前端已改为调用后端：保持 3 秒“仪式感”滚动，最终展示后端返回结果
- 历史持久化从 `localStorage` 升级为后端 H2 文件库

下一步（你本机执行）：

- `cd backend && chmod +x mvnw && ./mvnw test && ./mvnw spring-boot:run`（8082）
- `flutter pub get && flutter run -d chrome --web-port 5175`
- 录屏：Chrome + 后端终端（能看到 `DECIDE ...` 日志）

2026.02.06.18
