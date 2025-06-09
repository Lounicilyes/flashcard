import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_set.dart';
import '../models/score_entry.dart';
import '../services/storage_service.dart';

final flashcardSetsProvider =
    StateNotifierProvider<FlashcardSetsNotifier, List<FlashcardSet>>((ref) {
      return FlashcardSetsNotifier();
    });

class FlashcardSetsNotifier extends StateNotifier<List<FlashcardSet>> {
  final _storage = StorageService();
  bool loaded = false;

  FlashcardSetsNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    state = await _storage.loadSets();
    loaded = true;
  }

  Future<void> reload() async {
    state = await _storage.loadSets();
  }

  Future<void> addSet(FlashcardSet set) async {
    if (!loaded) return;
    state = [...state, set];
    await _storage.saveSets(state);
  }

  Future<void> updateSet(int index, FlashcardSet set) async {
    if (!loaded) return;
    final updated = [...state]..[index] = set;
    state = updated;
    await _storage.saveSets(state);
  }

  Future<void> deleteSet(int index) async {
    if (!loaded) return;
    final updated = [...state]..removeAt(index);
    state = updated;
    await _storage.saveSets(state);
  }

  Future<void> addScoreEntry(int setIndex, ScoreEntry entry) async {
    if (!loaded) return;
    final set = state[setIndex];
    final updatedHistory = [...set.history, entry];
    final updatedSet = FlashcardSet(
      title: set.title,
      cards: set.cards,
      history: updatedHistory,
    );
    state = [
      ...state.sublist(0, setIndex),
      updatedSet,
      ...state.sublist(setIndex + 1),
    ];
    await _storage.saveSets(state);
  }
}
