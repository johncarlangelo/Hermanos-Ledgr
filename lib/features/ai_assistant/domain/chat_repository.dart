import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/ai_message.dart';

/// Clean Architecture abstract repository for AI chat history persistence (Task 9.16).
abstract class ChatRepository {
  Stream<List<AiMessage>> watchMessages();
  Future<Result<List<AiMessage>>> getAllMessages();
  Future<Result<void>> saveMessage(AiMessage message);
  Future<Result<void>> markConfirmed(String id);
  Future<Result<void>> deleteMessage(String id);
  Future<Result<void>> clearHistory();
}
