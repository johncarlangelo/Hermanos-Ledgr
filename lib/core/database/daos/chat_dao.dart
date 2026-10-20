import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/chat_messages_table.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatMessagesTable])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Stream<List<ChatMessagesTableData>> watchAllMessages() =>
      (select(chatMessagesTable)..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).watch();

  Future<List<ChatMessagesTableData>> getAllMessages({int limit = 50}) async {
    final rows = await (select(chatMessagesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .get();
    return rows.reversed.toList();
  }

  Future<int> insertMessage(ChatMessagesTableCompanion msg) async {
    final id = await into(chatMessagesTable).insert(msg, mode: InsertMode.insertOrReplace);
    await pruneOldMessages(maxToKeep: 50);
    return id;
  }

  Future<int> pruneOldMessages({int maxToKeep = 50}) async {
    final rows = await (select(chatMessagesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();

    if (rows.length <= maxToKeep) return 0;

    final toRemove = rows.sublist(maxToKeep);
    final idsToRemove = toRemove.map((r) => r.id).toList();

    return (delete(chatMessagesTable)..where((t) => t.id.isIn(idsToRemove))).go();
  }

  Future<int> markConfirmed(String id) =>
      (update(chatMessagesTable)..where((t) => t.id.equals(id))).write(
        const ChatMessagesTableCompanion(isConfirmed: Value(true)),
      );

  Future<int> deleteMessage(String id) =>
      (delete(chatMessagesTable)..where((t) => t.id.equals(id))).go();

  Future<int> clearHistory() => delete(chatMessagesTable).go();
}
