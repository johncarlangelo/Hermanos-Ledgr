import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';

/// Represents a persistent or in-memory chat message in Hermano AI Assistant (Task 9.9, 9.16).
class AiMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<ParsedTransaction> parsedTransactions;
  final bool isConfirmed;
  final ClassifierIntent? intent;

  /// Backward-compatible getter returning the first parsed transaction if any.
  ParsedTransaction? get parsedTransaction =>
      parsedTransactions.isNotEmpty ? parsedTransactions.first : null;

  AiMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    ParsedTransaction? parsedTransaction,
    List<ParsedTransaction>? parsedTransactions,
    this.isConfirmed = false,
    this.intent,
  }) : parsedTransactions = parsedTransactions ??
            (parsedTransaction != null ? [parsedTransaction] : const []);

  AiMessage copyWith({
    String? content,
    bool? isConfirmed,
    ParsedTransaction? parsedTransaction,
    List<ParsedTransaction>? parsedTransactions,
    ClassifierIntent? intent,
  }) {
    return AiMessage(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      timestamp: timestamp,
      parsedTransactions: parsedTransactions ??
          (parsedTransaction != null
              ? [parsedTransaction]
              : this.parsedTransactions),
      isConfirmed: isConfirmed ?? this.isConfirmed,
      intent: intent ?? this.intent,
    );
  }
}
