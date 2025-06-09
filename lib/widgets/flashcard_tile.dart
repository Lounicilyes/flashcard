import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardTile extends StatelessWidget {
  final Flashcard card;
  const FlashcardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(card.question), subtitle: Text(card.answer));
  }
}
