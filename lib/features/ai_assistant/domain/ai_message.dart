import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';

/// Represents a persistent or in-memory chat message in Hermano AI Assistant (Task 9.9, 9.16).
class AiMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ParsedTransaction? parsedTransaction;
  final bool isConfirmed;
  final ClassifierIntent? intent;

  const AiMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.parsedTransaction,
    this.isConfirmed = false,
    this.intent,
  });

  AiMessage copyWith({
    String? content,
    bool? isConfirmed,
    ParsedTransaction? parsedTransaction,
    ClassifierIntent? intent,
  }) {
    return AiMessage(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      timestamp: timestamp,
      parsedTransaction: parsedTransaction ?? this.parsedTransaction,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      intent: intent ?? this.intent,
    );
  }
}
