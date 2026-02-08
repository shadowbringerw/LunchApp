# `lib/ui/outlined_text.dart` 索引

## 作用

- Persona5 风格的“描边文字”（黑色描边 + 填充色）
- 复用在：
  - 菜单标题 `MENU`
  - 老虎机滚动文本
  - 巨大“决策”按钮文字
  - 最终结果展示（`ResultReveal`）

## 实现

- 通过 `Stack` 叠两层 `Text`
  - 底层：`Paint.stroke` 绘制描边
  - 顶层：普通填充文本

