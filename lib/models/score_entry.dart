class ScoreEntry {
  final int tryNumber;
  final int correct;
  final int total;
  final DateTime date;

  ScoreEntry({
    required this.tryNumber,
    required this.correct,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'tryNumber': tryNumber,
    'correct': correct,
    'total': total,
    'date': date.toIso8601String(),
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    tryNumber: json['tryNumber'],
    correct: json['correct'],
    total: json['total'],
    date: DateTime.parse(json['date']),
  );
}
