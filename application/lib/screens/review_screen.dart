import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../models/score_entry.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flip_card.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final int setIndex;
  ReviewScreen({required this.setIndex});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int currentIndex = 0;
  bool showAnswer = false;
  int correct = 0;
  int total = 0;
  bool _scoreSaved = false;

  @override
  void initState() {
    super.initState();
    total = ref.read(flashcardSetsProvider)[widget.setIndex].cards.length;
  }

  void _saveScoreIfNeeded() {
    if (_scoreSaved) return;
    _scoreSaved = true;
    final set = ref.read(flashcardSetsProvider)[widget.setIndex];
    final nextTryNumber = (set.history.isEmpty
        ? 1
        : set.history.last.tryNumber + 1);
    ref
        .read(flashcardSetsProvider.notifier)
        .addScoreEntry(
          widget.setIndex,
          ScoreEntry(
            tryNumber: nextTryNumber,
            correct: correct,
            total: total,
            date: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final set = ref.watch(flashcardSetsProvider)[widget.setIndex];
    final cards = set.cards;

    if (currentIndex >= cards.length) {
      // Utilise addPostFrameCallback pour DÉCALER l’ajout du score
      WidgetsBinding.instance.addPostFrameCallback((_) => _saveScoreIfNeeded());

      return Scaffold(
        appBar: AppBar(title: Text('Résultat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Révision terminée !', style: TextStyle(fontSize: 22)),
              SizedBox(height: 24),
              Text(
                'Score : $correct / $total',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final Flashcard card = cards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Révision')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Carte ${currentIndex + 1} / $total',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            FlipCard(
              front: Text(
                card.question,
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              back: Text(
                card.answer,
                style: TextStyle(fontSize: 22, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              flipped: showAnswer,
              onFlip: () => setState(() => showAnswer = !showAnswer),
            ),
            SizedBox(height: 30),
            if (showAnswer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        correct++;
                        currentIndex++;
                        showAnswer = false;
                      });
                    },
                    icon: Icon(Icons.check),
                    label: Text('Bonne réponse'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        currentIndex++;
                        showAnswer = false;
                      });
                    },
                    icon: Icon(Icons.close),
                    label: Text('Mauvaise réponse'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => setState(() => showAnswer = true),
                child: Text('Voir la réponse'),
              ),
          ],
        ),
      ),
    );
  }
}
