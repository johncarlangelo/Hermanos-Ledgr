/// Intents recognized by the Tier 1 Classifier and Hybrid Router (Task 9.1).
enum ClassifierIntent {
  /// User wants to log an expense, income, or transfer.
  logTransaction,

  /// User is asking about their account balances or net worth.
  queryBalance,

  /// User is asking how much they spent this month, week, or overall.
  querySpending,

  /// Casual greeting, help request, or capability question.
  greetingOrHelp,

  /// Complex multi-item split or conversational prompt best handled by Tier 2 LLM.
  complexOrSplit,

  /// Gibberish, random keystrokes, or unrecognized inputs (no amount or intent detected).
  unclearOrGibberish,
}
