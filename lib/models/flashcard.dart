class Flashcard {
  String question;
  String answer;
  bool isKnown;

  Flashcard({
    required this.question,
    required this.answer,
    this.isKnown = false,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'isKnown': isKnown,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    question: json['question'],
    answer: json['answer'],
    isKnown: json['isKnown'] ?? false,
  );
}
