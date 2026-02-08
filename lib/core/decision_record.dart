class DecisionRecord {
  DecisionRecord({
    required this.choice,
    required this.timestampMs,
  });

  final String choice;
  final int timestampMs;

  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(timestampMs);

  Map<String, Object?> toJson() => <String, Object?>{
        'choice': choice,
        'timestampMs': timestampMs,
      };

  static DecisionRecord fromJson(Map<String, Object?> json) {
    final choice = json['choice'];
    final timestampMs = json['timestampMs'];
    if (choice is! String || timestampMs is! int) {
      throw FormatException('Invalid DecisionRecord json: $json');
    }
    return DecisionRecord(choice: choice, timestampMs: timestampMs);
  }
}

