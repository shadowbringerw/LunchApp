# `lib/ui/rpg_menu_selector.dart` 索引

## 作用

- RPG 点菜选择器
  - 分类 Tab：skew 造型
  - 条目列表：可多选（装备/取消）
  - 游标：hover/点击项显示小箭头
  - 底部 INFO：展示当前条目 description
  - 背景：铺满菜单区域的立绘背景（`BoxFit.cover`）+ 模糊 + 渐变遮罩保证可读性
  - 自定义条目：支持以 `customItems` 注入并按其 `category` 出现在对应分类（含 `CUSTOM`）

## 音效接入

- `onToggleSfx`：点击切换选中时回调（外部可接 `WebAudioSfx.tick()`）
