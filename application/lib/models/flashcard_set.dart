import 'flashcard.dart';
import 'score_entry.dart';

class FlashcardSet {
  String title;
  List<Flashcard> cards;
  List<ScoreEntry> history;

  FlashcardSet({
    required this.title,
    required this.cards,
    List<ScoreEntry>? history,
  }) : history = history ?? [];

  Map<String, dynamic> toJson() => {
    'title': title,
    'cards': cards.map((c) => c.toJson()).toList(),
    'history': history.map((h) => h.toJson()).toList(),
  };

  factory FlashcardSet.fromJson(Map<String, dynamic> json) => FlashcardSet(
    title: json['title'],
    cards: (json['cards'] as List).map((c) => Flashcard.fromJson(c)).toList(),
    history: json['history'] != null
        ? (json['history'] as List).map((h) => ScoreEntry.fromJson(h)).toList()
        : [],
  );
}
