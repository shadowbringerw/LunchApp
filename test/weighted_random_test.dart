import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:kunlun_lunch_app/core/weighted_random.dart';

void main() {
  test('weightedPick penalizes recent3 options', () {
    final options = <String>['A', 'B'];
    final rng = Random(0);

    var a = 0;
    var b = 0;
    for (var i = 0; i < 3000; i++) {
      final picked = weightedPick(
        options: options,
        penalizedChoices: <String>{'A'},
        random: rng,
      );
      if (picked == 'A') a++;
      if (picked == 'B') b++;
    }

    expect(b, greaterThan(a));
  });

  test('weightedPick works when all options penalized', () {
    final options = <String>['A', 'B', 'C'];
    final rng = Random(1);
    for (var i = 0; i < 50; i++) {
      final picked = weightedPick(
        options: options,
        penalizedChoices: <String>{'A', 'B', 'C'},
        random: rng,
      );
      expect(options, contains(picked));
    }
  });
}
