import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/flashcard_set.dart';

class StorageService {
  static const _filename = 'flashcards.json';

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  Future<List<FlashcardSet>> loadSets() async {
    try {
      final file = await _getLocalFile();
      if (!(await file.exists())) return [];
      final jsonStr = await file.readAsString();
      final List decoded = json.decode(jsonStr);
      return decoded.map((e) => FlashcardSet.fromJson(e)).toList();
    } catch (e) {
      print("Erreur lecture JSON: $e");
      return [];
    }
  }

  Future<void> saveSets(List<FlashcardSet> sets) async {
    final file = await _getLocalFile();
    final jsonStr = json.encode(sets.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonStr);
  }
}
