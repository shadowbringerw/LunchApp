import 'package:flutter/material.dart';

import '../core/decision_record.dart';

class RecentHistory extends StatelessWidget {
  const RecentHistory({
    super.key,
    required this.history,
    required this.now,
    this.daysToShow = 5,
  });

  final List<DecisionRecord> history;
  final DateTime now;
  final int daysToShow;

  @override
  Widget build(BuildContext context) {
    final items =
        _recentByDay(history: history, now: now, daysToShow: daysToShow);

    final paper = const Color(0xFFF6F0E6);
    final ink = const Color(0xFF141110);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: ink.withOpacity(0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: ink),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'RECENT $daysToShow DAYS',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          color: ink,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Leblanc',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFFB91C1C),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: ink.withOpacity(0.12)),
              const SizedBox(height: 10),
              if (items.isEmpty)
                Text(
                  '暂无记录',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ink.withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                )
              else
                ...items.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 112,
                          child: Text(
                            e.dayLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: ink.withOpacity(0.65),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.choice,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: ink,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyItem {
  _DailyItem({required this.dayLabel, required this.choice});

  final String dayLabel;
  final String choice;
}

List<_DailyItem> _recentByDay({
  required List<DecisionRecord> history,
  required DateTime now,
  required int daysToShow,
}) {
  final cutoff = now.subtract(Duration(days: daysToShow));
  final byDay = <String, DecisionRecord>{};

  for (final r in history) {
    if (r.timestamp.isBefore(cutoff)) continue;
    final d = r.timestamp;
    final key = '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    byDay.putIfAbsent(key, () => r);
    if (byDay.length >= daysToShow) break;
  }

  return byDay.entries.map((e) {
    final date = e.key;
    final record = e.value;
    return _DailyItem(dayLabel: date, choice: record.choice);
  }).toList();
}
