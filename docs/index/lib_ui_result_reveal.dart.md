# `lib/ui/result_reveal.dart` 索引

## 作用

- 当结果文本变化时，执行：
  1. 放大（`easeOutBack`）
  2. 震动（sin/cos 衰减）
- 文本风格：使用 `OutlinedText` 做 Persona5 风格描边字

## 动画

- `_scaleController`：280ms
- `_shakeController`：520ms

## 触发点

- `didUpdateWidget`：当 `text` 变化且非空，调用 `_play()`
