import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/decision_record.dart';
import 'core/backend_client.dart';
import 'core/custom_menu_item.dart';
import 'core/custom_menu_store.dart';
import 'core/menu_data.dart';
import 'core/web_audio_sfx.dart';
import 'ui/lebanc_background.dart';
import 'ui/leblanc_entrance.dart';
import 'ui/outlined_text.dart';
import 'ui/recent_history.dart';
import 'ui/result_reveal.dart';
import 'ui/rpg_menu_selector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _preloadFonts();
  runApp(const KunLunLunchApp());
}

Future<void> _preloadFonts() async {
  try {
    final loader = FontLoader('NotoSansSC')
      ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'));
    await loader.load();
  } catch (e) {
    debugPrint('[Fonts] preload failed: $e');
  }
}

class KunLunLunchApp extends StatelessWidget {
  const KunLunLunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = const ColorScheme.dark(
      primary: Color(0xFFEF4444),
      onPrimary: Color(0xFF0B0A0A),
      secondary: Color(0xFFF59E0B),
      onSecondary: Color(0xFF141110),
      surface: Color(0xFF121010),
      onSurface: Color(0xFFF5F0E6),
      surfaceContainerHighest: Color(0xFF171312),
      onSurfaceVariant: Color(0xFFE7DDCF),
      outline: Color(0xFF3A2C2A),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'PingFang SC',
      fontFamilyFallback: const [
        'Hiragino Sans GB',
        'Heiti SC',
        'Microsoft YaHei',
        'NotoSansSC',
        'sans-serif',
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KunLun Lunch',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF080707),
        cardTheme: CardThemeData(
          color: scheme.surfaceContainerHighest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outline.withOpacity(0.5)),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0E0C0C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.outline.withOpacity(0.55)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.outline.withOpacity(0.55)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: scheme.primary.withOpacity(0.9), width: 1.2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
      home: const LunchDeciderPage(),
    );
  }
}

enum _AppPage { entrance, menu }

class LunchDeciderPage extends StatefulWidget {
  const LunchDeciderPage({super.key});

  @override
  State<LunchDeciderPage> createState() => _LunchDeciderPageState();
}

class _LunchDeciderPageState extends State<LunchDeciderPage> {
  _AppPage _currentPage = _AppPage.entrance;
  
  final _backend = BackendClient(baseUrl: 'http://localhost:8082');
  final _customMenuStore = CustomMenuStore();
  final _rng = math.Random();
  final _sfx = WebAudioSfx();
  final _quickAddController = TextEditingController();
  String? _requestedCategory;
  int _categoryRequestId = 0;
  String _quickAddCategory = MenuCategory.custom;

  Set<String> _selectedOptions = <String>{};
  List<CustomMenuItem> _customItems = <CustomMenuItem>[];
  List<String> _recent3 = <String>[];
  List<DecisionRecord> _historyRecords = <DecisionRecord>[];

  bool _spinning = false;
  String _slotText = '准备好开始仪式了吗？';
  String _finalResult = '';

  Timer? _spinTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHistory());
    unawaited(_loadCustomMenu());
  }

  Future<void> _loadHistory() async {
    final items = await _backend.history(limit: 500);
    final records = items
        .map((e) => DecisionRecord(choice: e.choice, timestampMs: e.timestampMs))
        .toList()
      ..sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
    final recent3 = _recentChoicesByDay(records, daysToTake: 3);
    setState(() {
      _historyRecords = records;
      _recent3 = recent3;
    });
    print('[LunchDecider] history loaded from backend: ${records.length} records');
  }

  Future<void> _loadCustomMenu() async {
    final items = await _customMenuStore.load();
    setState(() => _customItems = items);
    print('[LunchDecider] custom menu loaded: ${items.length}');
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    _quickAddController.dispose();
    super.dispose();
  }

  Future<void> _decide() async {
    if (_spinning) return;
    if (_selectedOptions.isEmpty) {
      setState(() {
        _slotText = '请先装备至少 1 个菜单';
        _finalResult = '';
      });
      return;
    }

    final optionsList = _selectedOptions.toList();
    final decideFuture = _backend.decide(optionsList);

    setState(() {
      _spinning = true;
      _finalResult = '';
    });

    _spinTimer?.cancel();
    final started = DateTime.now();
    const totalMs = 3000;

    DecideResponse? decideResponse;
    Object? decideError;
    decideFuture.then((r) => decideResponse = r).catchError((e) => decideError = e);

    void tick() {
      final elapsedMs = DateTime.now().difference(started).inMilliseconds;
      if (elapsedMs >= totalMs) {
        if (decideError != null) {
          _spinTimer?.cancel();
          setState(() {
            _spinning = false;
            _slotText = '后端请求失败，请重试';
            _finalResult = '';
          });
          print('[LunchDecider] decide error: $decideError');
          return;
        }
        if (decideResponse == null) {
          _spinTimer = Timer(const Duration(milliseconds: 60), tick);
          return;
        }

        final chosen = decideResponse!.choice;
        _spinTimer?.cancel();
        setState(() {
          _spinning = false;
          _slotText = chosen;
          _finalResult = chosen;
          _recent3 = decideResponse!.recent3;
        });
        print(
          '[LunchDecider] decide done: chosen="$chosen" recent3=$_recent3 '
          'penalized=${decideResponse!.penalizedChoices}',
        );
        _sfx.win();
        unawaited(_loadHistory());
        return;
      }

      final t = elapsedMs / totalMs;
      final eased = Curves.easeOutCubic.transform(t.clamp(0, 1));
      final intervalMs = (40 + (220 - 40) * eased).round();

      setState(() {
        _slotText = optionsList[_rng.nextInt(optionsList.length)];
      });
      _sfx.tick();

      _spinTimer = Timer(Duration(milliseconds: intervalMs), tick);
    }

    tick();
  }

  void _clearCurrentSelection() {
    _spinTimer?.cancel();
    setState(() {
      _selectedOptions = <String>{};
      _finalResult = '';
      _spinning = false;
      _slotText = '已清空装备，请重新选择菜单';
    });
  }

  void _quickAdd() {
    final raw = _quickAddController.text.trim();
    if (raw.isEmpty) return;

    final parsed = _parseQuickAdd(raw);
    final name = parsed.name;
    final description = parsed.description ?? _autoDescription(name);

    setState(() {
      _selectedOptions = <String>{..._selectedOptions, name};
      _requestedCategory = _quickAddCategory;
      _categoryRequestId++;
      _quickAddController.clear();
      _slotText = '已装备：$name';
    });

    unawaited(
      _customMenuStore
          .upsert(CustomMenuItem(
            name: name,
            description: description,
            category: _quickAddCategory,
          ))
          .then((items) {
        setState(() => _customItems = items);
      }),
    );
    _sfx.tick();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage == _AppPage.entrance) {
      return LeblancEntrancePage(
        onEnter: () {
          setState(() {
            _currentPage = _AppPage.menu;
          });
          _sfx.win(); // Play a sound on enter
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'LEBLANC',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'KunLun Lunch · 决策仪式',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _spinning ? null : _clearCurrentSelection,
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
            child: const Text('清空当前选择'),
          ),
        ],
      ),
      body: LeblancBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Replaced _MenuInputCard with RpgMenuSelector
                  Expanded(
                    flex: 4,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                OutlinedText(
                                  text: 'MENU SELECTION',
                                  strokeWidth: 3,
                                  strokeColor: const Color(0xFF050505),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.4,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ) ??
                                      const TextStyle(),
                                ),
                                const Spacer(),
                                Text(
                                  '已装备 ${_selectedOptions.length} 个',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: RpgMenuSelector(
                                selectedIds: _selectedOptions,
                                onSelectionChanged: (newSelection) {
                                  setState(() {
                                    _selectedOptions = newSelection;
                                  });
                                },
                                onToggleSfx: _sfx.tick,
                                recent3: _recent3,
                                customItems: _customItems,
                                requestedCategory: _requestedCategory,
                                categoryRequestId: _categoryRequestId,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _CategoryChipPicker(
                                  value: _quickAddCategory,
                                  onChanged: (v) => setState(() => _quickAddCategory = v),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _quickAddController,
                                    decoration: const InputDecoration(
                                      hintText: '快速添加：输入餐厅/菜名（回车或点 +）',
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _quickAdd(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 44,
                                  width: 52,
                                  child: FilledButton(
                                    onPressed: _quickAdd,
                                    child: const Text('+'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DecisionCard(
                    spinning: _spinning,
                    slotText: _slotText,
                    finalResult: _finalResult,
                    onDecide: _decide,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: RecentHistory(
                            history: _historyRecords,
                            now: DateTime.now(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.spinning,
    required this.slotText,
    required this.finalResult,
    required this.onDecide,
  });

  final bool spinning;
  final String slotText;
  final String finalResult;
  final VoidCallback onDecide;

  @override
  Widget build(BuildContext context) {
    final buttonText = spinning ? '正在天选…' : '决策';
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0A0A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.55),
                  width: 1.2,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 120),
                child: Center(
                  key: ValueKey(slotText),
                  child: OutlinedText(
                    text: slotText,
                    textAlign: TextAlign.center,
                    strokeWidth: 4,
                    strokeColor: const Color(0xFF050505),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: scheme.onSurface,
                        ) ??
                        TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: scheme.onSurface,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 72,
              child: FilledButton(
                onPressed: spinning ? null : onDecide,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shadowColor: Colors.black.withOpacity(0.65),
                  elevation: 2,
                  textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                ),
                child: OutlinedText(
                  text: buttonText,
                  textAlign: TextAlign.center,
                  strokeWidth: 4,
                  strokeColor: const Color(0xFF050505),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ) ??
                      TextStyle(
                        fontSize: 24,
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (finalResult.isNotEmpty)
              Column(
                children: [
                  Text(
                    'TAKE YOUR TIME',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: scheme.onSurface.withOpacity(0.75),
                        ),
                  ),
                  const SizedBox(height: 8),
                  ResultReveal(text: finalResult),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ParsedQuickAdd {
  _ParsedQuickAdd({required this.name, this.description});

  final String name;
  final String? description;
}

List<String> _recentChoicesByDay(
  List<DecisionRecord> records, {
  required int daysToTake,
}) {
  final byDay = <String, String>{};
  for (final r in records) {
    final d = r.timestamp;
    final key = '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    byDay.putIfAbsent(key, () => r.choice);
    if (byDay.length >= daysToTake) break;
  }
  return byDay.values.toList(growable: false);
}

_ParsedQuickAdd _parseQuickAdd(String raw) {
  for (final delimiter in const ['|', '｜', '：', ':']) {
    final idx = raw.indexOf(delimiter);
    if (idx <= 0) continue;
    final name = raw.substring(0, idx).trim();
    final desc = raw.substring(idx + 1).trim();
    if (name.isEmpty) continue;
    return _ParsedQuickAdd(name: name, description: desc.isEmpty ? null : desc);
  }
  return _ParsedQuickAdd(name: raw.trim());
}

String _autoDescription(String name) {
  return '自定义条目「$name」。你亲手写下的决定，命运会认真对待。';
}

class _CategoryChipPicker extends StatelessWidget {
  const _CategoryChipPicker({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <String>[
      MenuCategory.fastFood,
      MenuCategory.noodles,
      MenuCategory.rice,
      MenuCategory.healthy,
      MenuCategory.random,
      MenuCategory.custom,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        border: Border.all(color: scheme.outline.withOpacity(0.55)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF0B0A0A),
          iconEnabledColor: scheme.secondary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}
