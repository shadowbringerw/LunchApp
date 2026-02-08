import 'dart:convert';
import 'dart:html' as html;

import 'custom_menu_item.dart';

class CustomMenuStore {
  CustomMenuStore({this.storageKey = 'kunlun_custom_menu_v1'});

  final String storageKey;

  Future<List<CustomMenuItem>> load() async {
    final raw = html.window.localStorage[storageKey];
    if (raw == null || raw.trim().isEmpty) return <CustomMenuItem>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <CustomMenuItem>[];
      return decoded
          .whereType<Map>()
          .map((e) => CustomMenuItem.fromJson(e.cast<String, Object?>()))
          .toList();
    } catch (e) {
      print('[CustomMenuStore] load failed: $e');
      return <CustomMenuItem>[];
    }
  }

  Future<void> save(List<CustomMenuItem> items) async {
    final payload = jsonEncode(items.map((e) => e.toJson()).toList());
    html.window.localStorage[storageKey] = payload;
  }

  Future<List<CustomMenuItem>> upsert(CustomMenuItem item) async {
    final existing = await load();
    final updated = <CustomMenuItem>[
      item,
      ...existing.where((e) => e.name != item.name || e.category != item.category),
    ];
    await save(updated);
    print('[CustomMenuStore] upsert "${item.name}" category="${item.category}"');
    return updated;
  }
}
