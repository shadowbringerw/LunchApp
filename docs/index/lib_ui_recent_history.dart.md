# `lib/ui/recent_history.dart` 索引

## 作用

- 展示“最近 5 天吃过啥”
- 过滤规则：仅保留 `now - daysToShow` 之后的记录
- 去重规则：按天（yyyy-mm-dd）取第一条（历史已按时间降序）
- UI 样式：收据纸张风格（浅色纸面 + 分隔线），便于与深色背景区分

## 数据处理（Mermaid）

```mermaid
flowchart LR
  H[DecisionRecord[] desc] --> F[filter cutoff]
  F --> D[group by day key]
  D --> T[take first per day]
  T --> UI[render list]
```
