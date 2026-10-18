import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';

/// The result returned by ClassifierService and the Hybrid Router (Task 9.1 & 9.2).
class ClassifierResult {
  final ClassifierIntent intent;
  final double confidence;
  final ParsedTransaction? transaction;
  final String? conversationalReply;
  final List<String> suggestedPromptChips;

  const ClassifierResult({
    required this.intent,
    required this.confidence,
    this.transaction,
    this.conversationalReply,
    this.suggestedPromptChips = const [],
  });

  /// High-confidence threshold (>= 0.85) to trigger direct instant mapping without LLM.
  bool get isHighConfidence => confidence >= 0.85 && transaction != null;

  /// True if the result represents a transaction ready for user action.
  bool get hasTransaction => transaction != null;
}
