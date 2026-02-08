import 'dart:math';

double weightForOption({
  required String option,
  required Set<String> penalizedChoices,
}) {
  if (penalizedChoices.contains(option)) {
    return 0.5;
  }
  return 1.0;
}

String weightedPick({
  required List<String> options,
  required Set<String> penalizedChoices,
  Random? random,
}) {
  if (options.isEmpty) {
    throw ArgumentError.value(options, 'options', 'Must not be empty');
  }
  final rng = random ?? Random();

  double total = 0;
  final weights = List<double>.filled(options.length, 0);
  for (var i = 0; i < options.length; i++) {
    final w =
        weightForOption(option: options[i], penalizedChoices: penalizedChoices);
    weights[i] = w;
    total += w;
  }

  if (total <= 0) {
    return options[rng.nextInt(options.length)];
  }

  var r = rng.nextDouble() * total;
  for (var i = 0; i < options.length; i++) {
    r -= weights[i];
    if (r <= 0) {
      return options[i];
    }
  }
  return options.last;
}
