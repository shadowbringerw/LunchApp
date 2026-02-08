# Action Log

- 新增 Flutter Web 最小可运行结构：`pubspec.yaml`、`web/`、`lib/`、`test/`
- 实现老虎机滚动：递归 `Timer`，使用 `easeOutCubic` 将 tick 间隔从 40ms 逐步放大到 220ms，总时长 3 秒
- 实现结果特效：`ResultReveal`（scale + shake）
- 实现音效：`WebAudioSfx`（Web Audio oscillator + gain ramp）
- 实现历史：`HistoryStore`（localStorage JSON + 日志）
- 实现最近 5 天：`RecentHistory`（按天去重）
- 实现加权随机：`weightedPick`（重复餐厅权重 0.5）
- 添加测试：`test/weighted_random_test.dart`

