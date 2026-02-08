# Plan

目标：实现“午饭决策仪式” Web App（Flutter），满足 MVP + 动画音效 + 历史记录与加权随机。

高层设计：

- UI：单页 `LunchDeciderPage`
  - 菜单输入框 + 选项计数
  - 巨大“决策”按钮
  - 槽机滚动 3 秒（从快到慢）
  - 停下后结果放大+震动
  - 底部展示最近 5 天历史（按天取最近一次）
- 数据层：`HistoryStore`（`localStorage` JSON）
- 算法：`weightedPick`（若最近 3 次中某餐厅出现重复，则权重 -50%）
- 录屏：依赖 `print` 日志展示“数据层调用”

