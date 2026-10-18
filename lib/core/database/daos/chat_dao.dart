import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/chat_messages_table.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatMessagesTable])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Stream<List<ChatMessagesTableData>> watchAllMessages() =>
      (select(chatMessagesTable)..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).watch();

  Future<List<ChatMessagesTableData>> getAllMessages() =>
      (select(chatMessagesTable)..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).get();

  Future<int> insertMessage(ChatMessagesTableCompanion msg) =>
      into(chatMessagesTable).insert(msg, mode: InsertMode.insertOrReplace);

  Future<int> markConfirmed(String id) =>
      (update(chatMessagesTable)..where((t) => t.id.equals(id))).write(
        const ChatMessagesTableCompanion(isConfirmed: Value(true)),
      );

  Future<int> deleteMessage(String id) =>
      (delete(chatMessagesTable)..where((t) => t.id.equals(id))).go();

  Future<int> clearHistory() => delete(chatMessagesTable).go();
}
