# Architecture

## 模块划分

- `lib/main.dart`：主页面与交互（输入菜单、启动仪式动画、展示结果与历史）
- `lib/core/backend_client.dart`：后端调用（HTTP：decide/history/clear）
- `backend/`：Spring Boot 后端（加权随机 + 历史持久化 + 日志）
- `lib/core/web_audio_sfx.dart`：Web Audio 音效（tick / win）
- `lib/core/menu_data.dart`：预设菜单数据（RPG 点菜）
- `lib/ui/result_reveal.dart`：结果放大 + 震动特效
- `lib/ui/recent_history.dart`：最近 5 天展示（按天取最近一次）
- `lib/ui/lebanc_background.dart`：咖啡馆+Persona5 背景（渐变/斜纹/噪点）
- `lib/ui/outlined_text.dart`：Persona5 风格描边文字
- `lib/ui/leblanc_entrance.dart`：进店入口页（点按进入）
- `lib/ui/rpg_menu_selector.dart`：RPG 菜单选择器（分类/游标/描述）

## 数据流（Mermaid）

```mermaid
flowchart TD
  UI[LunchDeciderPage] -->|select/equip| OPTS[Options List]
  UI -->|POST /api/decide| API[Spring Boot Backend]
  UI -->|GET /api/history| API
  API -->|H2| DB[(H2 file DB)]
  API -->|returns chosen| CHOSEN[chosen option]
  API -->|returns history| HIST[DecisionRecord[]]
  UI -->|3s slot spin| SLOT[slotText updates]
  CHOSEN -->|stop| REVEAL[ResultReveal]
  HIST -->|render| RECENT[RecentHistory last 5 days]
```
