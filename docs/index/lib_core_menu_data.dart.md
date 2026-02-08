# `lib/core/menu_data.dart` 索引

## 作用

- RPG 点菜的预设菜单数据
  - `MenuCategory`：分类（FAST FOOD / NOODLES / RICE / HEALTHY / CHAOS）
  - `MenuItem`：条目（`id/name/description/category`）
  - `kPresetMenu`：预设菜单列表（可继续扩展）

## 使用点

- `lib/ui/rpg_menu_selector.dart`：按分类过滤展示并支持多选
- `lib/main.dart`：将选中条目的 `name` 作为后端 options

