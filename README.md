# KunLun Lunch App

一个带“仪式感”的午饭决策器：输入菜单列表 → 点击巨大“决策”按钮 → 3 秒老虎机式滚动 → 停在最终结果并放大震动，同时记录历史并降低连续重复概率。

## 运行（Flutter Web）

前置：本机安装 Flutter（建议 stable）。

```bash
flutter pub get
flutter run -d chrome --web-port 5175
```

## 运行（Spring Boot 后端，带日志）

前置：JDK 17。

```bash
cd backend
chmod +x mvnw
./mvnw test
./mvnw spring-boot:run
```

后端默认端口：`8082`（配置在 `backend/src/main/resources/application.yml`）。

## 功能

- 菜单输入：一行一个，支持逗号/顿号分隔
- 决策动画：名字快速跳动并逐渐减速，持续 3 秒后停下
- 结果特效：放大 + 震动
- 音效：滚动 tick + 选中 win（Web Audio，无需音频资源文件）
- 历史记录：后端存储每次结果和时间戳（并输出后端日志）
- 最近 5 天：页面底部展示（按天取最近一次）
- 加权随机：最近 3 次出现过的餐厅，本次权重降低 50%

## 录屏建议（含日志）

1. 先运行后端 `mvn spring-boot:run`，终端会打印每次请求与加权随机细节。
2. 再运行前端 `flutter run -d chrome --web-port 5175`。
3. 录屏时同时录制 Chrome 窗口 + 后端终端窗口（以及前端终端可选）。
