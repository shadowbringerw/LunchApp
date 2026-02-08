# `lib/core/weighted_random.dart` 索引

## 作用

- `weightedPick`：对 `options` 做加权随机
- 业务规则：`penalizedChoices` 中的选项权重为 `0.5`，否则为 `1.0`
  - `penalizedChoices` 由主页面根据“最近 3 次记录中出现重复的餐厅”计算得到

## 算法

1. 计算每个选项权重并求和 `total`
2. 生成随机数 `r ∈ [0, total)`
3. 线性扫描减去权重，`r <= 0` 的位置即为选中项

## 复杂度

- 时间：O(n)
- 空间：O(n)（weights 数组）

