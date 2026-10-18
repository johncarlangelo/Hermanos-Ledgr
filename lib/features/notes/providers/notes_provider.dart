import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/daos/notes_dao.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/notes/domain/note_model.dart';
import 'package:hermanos_ledgr/features/profile/providers/profile_provider.dart';

final notesDaoProvider = Provider<NotesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesDao(db);
});

final notesStreamProvider = StreamProvider<List<NoteModel>>((ref) {
  final dao = ref.watch(notesDaoProvider);
  return dao.watchAllNotes().map(
        (entries) => entries
            .map(
              (e) => NoteModel(
                id: e.id,
                profileId: e.profileId,
                content: e.content,
                tag: e.tag,
                amount: e.amount,
                isDone: e.isDone,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
              ),
            )
            .toList(),
      );
});

class NotesNotifier extends Notifier<void> {
  @override
  void build() {}

  NotesDao get _dao => ref.read(notesDaoProvider);

  /// Heuristic helper to extract optional currency amounts from quick note text.
  static double? extractAmount(String text) {
    // Matches ₱150, 150.50, 150 php, 150 pesos, 50k
    final kMatch = RegExp(r'(?:₱|\b)(\d+(?:\.\d+)?)\s*k\b', caseSensitive: false).firstMatch(text);
    if (kMatch != null) {
      final base = double.tryParse(kMatch.group(1)!);
      if (base != null) return base * 1000;
    }

    final match = RegExp(r'(?:₱|php|pesos)?\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)\s*(?:php|pesos)?', caseSensitive: false).firstMatch(text);
    if (match != null) {
      final clean = match.group(1)!.replaceAll(',', '');
      return double.tryParse(clean);
    }
    return null;
  }

  /// Adds a new quick note into SQLite (Task 12.7).
  Future<int> addNote({
    required String content,
    String? tag,
    double? amount,
  }) async {
    final profileState = ref.read(profileNotifierProvider);
    final detectedAmount = amount ?? extractAmount(content);
    final now = DateTime.now();

    final id = await _dao.insertNote(
      NotesTableCompanion.insert(
        profileId: Value(profileState.activeProfileId),
        content: content.trim(),
        tag: Value(tag),
        amount: Value(detectedAmount),
        isDone: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  /// Toggles note completed status (Task 12.7).
  Future<void> toggleDone(int id, bool isDone) async {
    await _dao.toggleDone(id, isDone);
  }

  /// Updates existing note content, tag, or amount.
  Future<void> updateNote({
    required int id,
    required String content,
    String? tag,
    double? amount,
    required bool isDone,
  }) async {
    final now = DateTime.now();
    await _dao.updateNote(
      NotesTableCompanion(
        id: Value(id),
        content: Value(content.trim()),
        tag: Value(tag),
        amount: Value(amount ?? extractAmount(content)),
        isDone: Value(isDone),
        updatedAt: Value(now),
      ),
    );
  }

  /// Deletes a note permanently from SQLite.
  Future<void> deleteNote(int id) async {
    await _dao.deleteNote(id);
  }
}

final notesNotifierProvider = NotifierProvider<NotesNotifier, void>(NotesNotifier.new);
