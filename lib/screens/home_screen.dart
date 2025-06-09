import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_set.dart';
import 'set_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(flashcardSetsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Séries de Flashcards')),
      body: sets.isEmpty
          ? Center(child: Text('Aucune série créée.'))
          : ListView.builder(
              itemCount: sets.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(sets[i].title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SetDetailScreen(setIndex: i),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        ref.read(flashcardSetsProvider.notifier).deleteSet(i);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SetDetailScreen(setIndex: i, readOnly: true),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameController = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Nouvelle série'),
              content: TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "Nom de la série"),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, nameController.text),
                  child: Text('Créer'),
                ),
              ],
            ),
          );
          if (result != null && result.trim().isNotEmpty) {
            ref
                .read(flashcardSetsProvider.notifier)
                .addSet(FlashcardSet(title: result.trim(), cards: []));
          }
        },
        child: Icon(Icons.add),
        tooltip: "Ajouter une série",
      ),
    );
  }
}
