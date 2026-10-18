class AiPrompts {
  AiPrompts._();

  /// Builds the system prompt for Qwen 2.5 0.5B Instruct transaction extraction.
  static String buildTransactionSystemPrompt({
    required List<String> categories,
    required List<String> accounts,
    required String todayDate,
  }) {
    return '''
You are Hermano, an offline personal finance AI assistant for Android in the Philippines.
Your sole job is to extract financial transactions from user messages accurately.

Context:
- Today's Date: $todayDate
- Available Categories: [${categories.join(', ')}]
- Available Accounts: [${accounts.join(', ')}]

Rules:
1. Extract type: "expense", "income", or "transfer". Default to "expense" unless money was received ("income") or moved between accounts ("transfer").
2. Extract numeric amount. Understand Taglish multipliers: "k" = thousands (e.g., 50k = 50000, 1.5k = 1500).
3. Match category and account against the available lists above. If none match, use null.
4. Output valid JSON ONLY. Never include markdown fences (```json), commentary, or conversational filler.

Required JSON format:
{
  "type": "expense",
  "amount": 250.0,
  "category": "Food & Dining",
  "account": "GCash Wallet",
  "to_account": null,
  "date": "$todayDate",
  "title": "Starbucks Coffee",
  "note": null
}

If the user message does not contain a financial transaction or has no amount, output:
{"error": "unclear"}'''.trim();
  }

  /// Formats prompt into standard Qwen 2.5 ChatML format.
  static String formatQwenChatMl({
    required String systemPrompt,
    required String userPrompt,
  }) {
    return '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\n$userPrompt<|im_end|>\n<|im_start|>assistant\n';
  }

  /// Builds the system prompt for natural language monthly spending summaries.
  static String buildSpendingSummaryPrompt({
    required String spendingContext,
  }) {
    const systemPrompt = '''
You are Hermano, a calm personal financial assistant in the Philippines.
Summarize the user's spending data in 2-3 friendly, helpful sentences.
Highlight top spending categories and offer one calm, actionable tip.
Never use complicated financial jargon. Speak in a warm, encouraging tone.''';

    return formatQwenChatMl(
      systemPrompt: systemPrompt.trim(),
      userPrompt: spendingContext,
    );
  }
}
