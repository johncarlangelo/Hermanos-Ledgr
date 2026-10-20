import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';

/// The result returned by ClassifierService and the Hybrid Router (Task 9.1 & 9.2).
class ClassifierResult {
  final ClassifierIntent intent;
  final double confidence;
  final List<ParsedTransaction> transactions;
  final String? conversationalReply;
  final List<String> suggestedPromptChips;

  /// Backward-compatible getter returning the first parsed transaction if any.
  ParsedTransaction? get transaction =>
      transactions.isNotEmpty ? transactions.first : null;

  ClassifierResult({
    required this.intent,
    required this.confidence,
    ParsedTransaction? transaction,
    List<ParsedTransaction>? transactions,
    this.conversationalReply,
    this.suggestedPromptChips = const [],
  }) : transactions = transactions ??
            (transaction != null ? [transaction] : const []);

  /// High-confidence threshold (>= 0.85) to trigger direct instant mapping without LLM.
  bool get isHighConfidence => confidence >= 0.85 && transactions.isNotEmpty;

  /// True if the result represents a transaction ready for user action.
  bool get hasTransaction => transactions.isNotEmpty;
}
