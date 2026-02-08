# `lib/core/custom_menu_store.dart` 索引

## 作用

- 将自定义菜单持久化到 Web `localStorage`
- key：`kunlun_custom_menu_v1`
- 方法：
  - `load()`：读取全部自定义条目
  - `upsert(item)`：按 `name+category` 覆盖/插入并保存
