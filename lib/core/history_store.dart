import 'dart:convert';
import 'dart:html' as html;

import 'decision_record.dart';

class HistoryStore {
  HistoryStore({
    this.storageKey = 'kunlun_lunch_history_v1',
  });

  final String storageKey;

  Future<List<DecisionRecord>> load() async {
    final raw = html.window.localStorage[storageKey];
    if (raw == null || raw.trim().isEmpty) {
      print('[HistoryStore] load: 0 records');
      return <DecisionRecord>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        print('[HistoryStore] load: invalid payload (not a list)');
        return <DecisionRecord>[];
      }
      final records = <DecisionRecord>[];
      for (final item in decoded) {
        if (item is Map) {
          records.add(DecisionRecord.fromJson(item.cast<String, Object?>()));
        }
      }
      records.sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
      print('[HistoryStore] load: ${records.length} records');
      return records;
    } catch (e) {
      print('[HistoryStore] load failed: $e');
      return <DecisionRecord>[];
    }
  }

  Future<void> save(List<DecisionRecord> records) async {
    final payload = jsonEncode(records.map((e) => e.toJson()).toList());
    html.window.localStorage[storageKey] = payload;
  }

  Future<void> addChoice(String choice, DateTime time) async {
    final existing = await load();
    final updated = <DecisionRecord>[
      DecisionRecord(choice: choice, timestampMs: time.millisecondsSinceEpoch),
      ...existing,
    ];
    await save(updated);
    print('[HistoryStore] addChoice="$choice" at ${time.toIso8601String()}');
  }

  Future<void> clear() async {
    html.window.localStorage.remove(storageKey);
    print('[HistoryStore] cleared');
  }
}
