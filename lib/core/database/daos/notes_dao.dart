import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/notes_table.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [NotesTable])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchAllNotes() {
    return (select(notesTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<List<Note>> getAllNotes() {
    return (select(notesTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<int> insertNote(NotesTableCompanion entry) => into(notesTable).insert(entry);

  Future<bool> updateNote(NotesTableCompanion entry) => update(notesTable).replace(entry);

  Future<void> toggleDone(int id, bool isDone) {
    return (update(notesTable)..where((t) => t.id.equals(id))).write(
      NotesTableCompanion(
        isDone: Value(isDone),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteNote(int id) {
    return (delete(notesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAllNotes() => delete(notesTable).go();
}
