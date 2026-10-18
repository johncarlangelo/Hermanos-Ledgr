import 'package:hermanos_ledgr/core/database/daos/chat_dao.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/ai_message.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/chat_repository.dart';

/// Concrete implementation of [ChatRepository] backed by Drift SQLite (Task 9.16).
class ChatRepositoryImpl implements ChatRepository {
  final ChatDao _chatDao;

  ChatRepositoryImpl(this._chatDao);

  @override
  Stream<List<AiMessage>> watchMessages() {
    return _chatDao.watchAllMessages().map(
          (rows) => rows.map(DatabaseMappers.chatMessageFromDrift).toList(),
        );
  }

  @override
  Future<Result<List<AiMessage>>> getAllMessages() async {
    try {
      final rows = await _chatDao.getAllMessages();
      final messages = rows.map(DatabaseMappers.chatMessageFromDrift).toList();
      return Success(messages);
    } catch (e) {
      return Failure('Failed to load chat history: $e');
    }
  }

  @override
  Future<Result<void>> saveMessage(AiMessage message) async {
    try {
      final companion = DatabaseMappers.chatMessageToCompanion(message);
      await _chatDao.insertMessage(companion);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save chat message: $e');
    }
  }

  @override
  Future<Result<void>> markConfirmed(String id) async {
    try {
      await _chatDao.markConfirmed(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to mark message as confirmed: $e');
    }
  }

  @override
  Future<Result<void>> deleteMessage(String id) async {
    try {
      await _chatDao.deleteMessage(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete message: $e');
    }
  }

  @override
  Future<Result<void>> clearHistory() async {
    try {
      await _chatDao.clearHistory();
      return const Success(null);
    } catch (e) {
      return Failure('Failed to clear chat history: $e');
    }
  }
}
