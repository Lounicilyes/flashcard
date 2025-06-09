import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard.dart';
import 'review_screen.dart';

class SetDetailScreen extends ConsumerWidget {
  final int setIndex;
  final bool readOnly;
  SetDetailScreen({required this.setIndex, this.readOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(flashcardSetsProvider);
    final set = sets[setIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(set.title),
        actions: [
          if (!readOnly)
            IconButton(
              icon: Icon(Icons.play_arrow),
              tooltip: 'Commencer la révision',
              onPressed: set.cards.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(setIndex: setIndex),
                      ),
                    ),
            ),
          if (readOnly)
            IconButton(
              icon: Icon(Icons.play_arrow),
              tooltip: 'Commencer la révision',
              onPressed: set.cards.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(setIndex: setIndex),
                      ),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Liste des cartes (garde ton code actuel)
          Expanded(
            child: set.cards.isEmpty
                ? Center(child: Text('Aucune carte dans cette série.'))
                : ListView.builder(
                    itemCount: set.cards.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(set.cards[i].question),
                      subtitle: Text(set.cards[i].answer),
                      trailing: readOnly
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    await _editCardDialog(
                                      context,
                                      ref,
                                      setIndex,
                                      i,
                                      set.cards[i],
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    final updatedSet = FlashcardSet(
                                      title: set.title,
                                      cards: [...set.cards..removeAt(i)],
                                    );
                                    ref
                                        .read(flashcardSetsProvider.notifier)
                                        .updateSet(setIndex, updatedSet);
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Historique des révisions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Container(
            height: 150,
            child: set.history.isEmpty
                ? Center(child: Text("Aucun essai enregistré"))
                : ListView.builder(
                    itemCount: set.history.length,
                    itemBuilder: (context, i) {
                      final entry = set.history[i];
                      return ListTile(
                        leading: Text("Essai #${entry.tryNumber}"),
                        title: Text("${entry.correct} / ${entry.total}"),
                        subtitle: Text(
                          "${entry.date.day}/${entry.date.month}/${entry.date.year} - ${entry.date.hour}h${entry.date.minute.toString().padLeft(2, '0')}"
                          "\nTaux : ${entry.total > 0 ? ((entry.correct / entry.total) * 100).toStringAsFixed(1) : '0'}%",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: readOnly
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await _addCardDialog(context, ref, setIndex);
              },
              child: Icon(Icons.add),
              tooltip: "Ajouter une carte",
            ),
    );
  }

  Future<void> _addCardDialog(
    BuildContext context,
    WidgetRef ref,
    int setIndex,
  ) async {
    final qController = TextEditingController();
    final aController = TextEditingController();
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nouvelle carte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: InputDecoration(hintText: "Question"),
            ),
            TextField(
              controller: aController,
              decoration: InputDecoration(hintText: "Réponse"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, [qController.text, aController.text]),
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
    if (result is List<String> &&
        result[0].trim().isNotEmpty &&
        result[1].trim().isNotEmpty) {
      final sets = ref.read(flashcardSetsProvider);
      final set = sets[setIndex];
      final newCards = List<Flashcard>.from(set.cards)
        ..add(Flashcard(question: result[0].trim(), answer: result[1].trim()));
      final updatedSet = FlashcardSet(title: set.title, cards: newCards);
      ref.read(flashcardSetsProvider.notifier).updateSet(setIndex, updatedSet);
    }
  }

  Future<void> _editCardDialog(
    BuildContext context,
    WidgetRef ref,
    int setIndex,
    int cardIndex,
    Flashcard card,
  ) async {
    final qController = TextEditingController(text: card.question);
    final aController = TextEditingController(text: card.answer);
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier la carte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: InputDecoration(hintText: "Question"),
            ),
            TextField(
              controller: aController,
              decoration: InputDecoration(hintText: "Réponse"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, [qController.text, aController.text]),
            child: Text('Modifier'),
          ),
        ],
      ),
    );
    if (result is List<String> &&
        result[0].trim().isNotEmpty &&
        result[1].trim().isNotEmpty) {
      final sets = ref.read(flashcardSetsProvider);
      final set = sets[setIndex];
      final newCards = List<Flashcard>.from(set.cards)
        ..[cardIndex] = Flashcard(
          question: result[0].trim(),
          answer: result[1].trim(),
        );
      final updatedSet = FlashcardSet(title: set.title, cards: newCards);
      ref.read(flashcardSetsProvider.notifier).updateSet(setIndex, updatedSet);
    }
  }
}
