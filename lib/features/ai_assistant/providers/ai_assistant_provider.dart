import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/data/llm_service_impl.dart';
import 'package:hermanos_ledgr/features/ai_assistant/data/model_manager.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/ai_message.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_service.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/llm_service.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/nlp_parser.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';
import 'package:hermanos_ledgr/features/ai_assistant/providers/chat_repository_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

class AiThinkingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  @override
  set state(bool value) => super.state = value;
}

class AiThinkingStatusNotifier extends Notifier<String> {
  @override
  String build() => 'Hermano is thinking...';

  @override
  set state(String value) => super.state = value;
}

final isAiThinkingProvider = NotifierProvider<AiThinkingNotifier, bool>(() {
  return AiThinkingNotifier();
});

final aiThinkingStatusProvider = NotifierProvider<AiThinkingStatusNotifier, String>(() {
  return AiThinkingStatusNotifier();
});

final classifierServiceProvider = Provider<ClassifierService>((ref) {
  return ClassifierService();
});

final modelManagerProvider = Provider<ModelManager>((ref) {
  return ModelManager();
});

final llmServiceProvider = Provider<LlmService>((ref) {
  return LlmServiceImpl();
});

/// Async state notifier managing chat history and the Cascaded Hybrid AI pipeline (Tasks 9.2, 9.7, 9.12).
class AiChatNotifier extends AsyncNotifier<List<AiMessage>> {
  @override
  Future<List<AiMessage>> build() async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.getAllMessages();

    return result.when(
      onSuccess: (savedMessages) {
        if (savedMessages.isNotEmpty) {
          return savedMessages;
        }
        return [_createWelcomeMessage()];
      },
      onFailure: (msg, ex) => [_createWelcomeMessage()],
    );
  }

  AiMessage _createWelcomeMessage() {
    final rawName = ref.read(onboardingProvider).userName.trim();
    final userName = rawName.isEmpty ? 'there' : rawName.split(' ').first;
    return AiMessage(
      id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
      content:
          'Hello $userName! I am Hermano, your on-device personal financial assistant. You can log expenses, income, or transfers using natural language — completely private and offline.\n\nTry tapping one of the quick suggestions below or type your own.',
      isUser: false,
      timestamp: DateTime.now(),
      intent: ClassifierIntent.greetingOrHelp,
    );
  }

  /// Dispatches a user message through the Cascaded Hybrid AI pipeline.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);
    final userMsg = AiMessage(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final currentMessages = state.value ?? [];
    state = AsyncData([...currentMessages, userMsg]);
    await repo.saveMessage(userMsg);

    ref.read(isAiThinkingProvider.notifier).state = true;
    ref.read(aiThinkingStatusProvider.notifier).state = 'Hermano is thinking...';

    try {
      // 1. Evaluate with Tier 1 Classifier (< 15ms)
      final classifier = ref.read(classifierServiceProvider);
      final accounts = ref.read(accountsProvider);
      final categories = CategoryDefaults.defaultCategories;

      final result = classifier.classify(
        rawInput: trimmed,
        accounts: accounts,
        categories: categories,
      );

      // 2. Handle based on Intent
      switch (result.intent) {
        case ClassifierIntent.greetingOrHelp:
          await _respondWithText(
            result.conversationalReply ?? "Hello! How can I help with your budget today?",
            intent: ClassifierIntent.greetingOrHelp,
          );
          break;

        case ClassifierIntent.queryBalance:
          final totalBal = accounts.fold<double>(0.0, (sum, a) => sum + a.balance);
          final reply = accounts.isEmpty
              ? "You don't have any accounts set up yet."
              : "Your total balance across ${accounts.length} account${accounts.length == 1 ? '' : 's'} is ${CurrencyFormatter.format(totalBal)}.";
          await _respondWithText(reply, intent: ClassifierIntent.queryBalance);
          break;

        case ClassifierIntent.querySpending:
          final transactions = ref.read(transactionsProvider);
          final now = DateTime.now();
          final thisMonthTxs = transactions.where((t) =>
              t.type == TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month).toList();

          final totalSpent = thisMonthTxs.fold<double>(0.0, (sum, t) => sum + t.amount);
          final reply = thisMonthTxs.isEmpty
              ? "You haven't logged any expenses yet this month. Everything is calm!"
              : "You've logged ${thisMonthTxs.length} expense${thisMonthTxs.length == 1 ? '' : 's'} totaling ${CurrencyFormatter.format(totalSpent)} this month.";
          await _respondWithText(reply, intent: ClassifierIntent.querySpending);
          break;

        case ClassifierIntent.unclearOrGibberish:
          await _respondWithText(
            result.conversationalReply ??
                "I couldn't detect an amount or known expense. For example, try 'Coffee 150 GCash' or 'Salary 45k BDO'.",
            intent: ClassifierIntent.unclearOrGibberish,
          );
          break;

        case ClassifierIntent.complexOrSplit:
          await _handleComplexOrSplit(trimmed, accounts, categories);
          break;

        case ClassifierIntent.logTransaction:
          if (result.isHighConfidence && result.transactions.isNotEmpty) {
            // Tier 1 direct return
            await _respondWithTransactions(
              result.transactions,
              replyText: result.transactions.length > 1
                  ? "Parsed ${result.transactions.length} transactions ready for confirmation:"
                  : "Parsed your transaction ready for confirmation:",
            );
          } else {
            // Lower confidence: attempt Tier 2 if model is present, else show best-guess
            final modelManager = ref.read(modelManagerProvider);
            final isModelReady = await modelManager.isModelDownloaded();

            if (isModelReady) {
              ref.read(aiThinkingStatusProvider.notifier).state = 'Qwen AI is analyzing...';
              await _handleWithTier2(trimmed, accounts, categories, fallbackTxs: result.transactions);
            } else {
              await _respondWithTransactions(
                result.transactions,
                replyText: result.transactions.length > 1
                    ? "I extracted ${result.transactions.length} transactions, please verify before confirming:"
                    : "I extracted this from your input, please verify before confirming:",
              );
            }
          }
          break;
      }
    } finally {
      ref.read(isAiThinkingProvider.notifier).state = false;
    }
  }

  Future<void> _handleComplexOrSplit(
    String userText,
    List<dynamic> accounts,
    List<dynamic> categories,
  ) async {
    final modelManager = ref.read(modelManagerProvider);
    final isModelReady = await modelManager.isModelDownloaded();

    if (!isModelReady) {
      // Check if Tier 1 multiple extraction was able to grab transactions
      final classifier = ref.read(classifierServiceProvider);
      final multi = classifier.classifyMultiple(
        rawInput: userText,
        accounts: ref.read(accountsProvider),
        categories: CategoryDefaults.defaultCategories,
      );
      if (multi != null && multi.transactions.isNotEmpty) {
        await _respondWithTransactions(
          multi.transactions,
          replyText: "Parsed ${multi.transactions.length} transactions ready for confirmation:",
        );
        return;
      }

      await _respondWithText(
        "This input looks like a multi-item split or complex request. Download the Hermano Brain (Qwen 2.5 0.5B ~350MB) to handle multi-item queries and detailed financial advice.",
        intent: ClassifierIntent.complexOrSplit,
      );
      return;
    }

    ref.read(aiThinkingStatusProvider.notifier).state = 'Qwen AI is analyzing...';
    await _handleWithTier2(userText, accounts, categories);
  }

  Future<void> _handleWithTier2(
    String userText,
    List<dynamic> accounts,
    List<dynamic> categories, {
    List<ParsedTransaction> fallbackTxs = const [],
  }) async {
    final llm = ref.read(llmServiceProvider);
    final modelManager = ref.read(modelManagerProvider);

    if (!llm.isLoaded) {
      final path = await modelManager.getModelPath();
      await llm.loadModel(path);
    }

    final catNames = CategoryDefaults.defaultCategories.map((c) => c.name).toList();
    final accList = ref.read(accountsProvider);
    final accNames = accList.map((a) => a.name).toList();
    final today = DateTime.now().toIso8601String().split('T').first;

    final jsonStr = await llm.generateStructuredJson(
      userPrompt: userText,
      categories: catNames,
      accounts: accNames,
      todayDate: today,
    );

    if (jsonStr != null) {
      final parsedList = NlpParser.parseLlmJsonList(
        rawLlmOutput: jsonStr,
        accounts: accList,
        categories: CategoryDefaults.defaultCategories,
      );

      if (parsedList.isNotEmpty) {
        await _respondWithTransactions(
          parsedList,
          replyText: parsedList.length > 1
              ? "Qwen AI extracted ${parsedList.length} transactions:"
              : "Qwen AI parsed this transaction:",
        );
        return;
      }
    }

    // Fallback if LLM failed to return structured json
    if (fallbackTxs.isNotEmpty) {
      await _respondWithTransactions(
        fallbackTxs,
        replyText: fallbackTxs.length > 1
            ? "Extracted ${fallbackTxs.length} transactions:"
            : "Extracted transaction details:",
      );
    } else {
      await _respondWithText(
        "I couldn't quite extract the full transaction. Try phrasing it with an amount and category, like 'Lunch 250 GCash'.",
      );
    }
  }

  Future<void> _respondWithText(String replyText, {ClassifierIntent? intent}) async {
    final repo = ref.read(chatRepositoryProvider);
    final botMsg = AiMessage(
      id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
      content: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      intent: intent,
    );

    final current = state.value ?? [];
    state = AsyncData([...current, botMsg]);
    await repo.saveMessage(botMsg);
  }

  Future<void> _respondWithTransactions(
    List<ParsedTransaction> txs, {
    required String replyText,
    ClassifierIntent? intent,
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    final botMsg = AiMessage(
      id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
      content: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      parsedTransactions: txs,
      intent: intent ?? ClassifierIntent.logTransaction,
    );

    final current = state.value ?? [];
    state = AsyncData([...current, botMsg]);
    await repo.saveMessage(botMsg);
  }

  /// Confirms and commits a single parsed transaction from a message card to Drift SQLite.
  Future<void> confirmSingleTransaction(
    BuildContext context,
    String messageId,
    String txId,
  ) async {
    final messages = state.value ?? [];
    final msgIndex = messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = messages[msgIndex];
    final txIndex = msg.parsedTransactions.indexWhere((t) => t.id == txId);
    if (txIndex == -1) return;

    final targetTx = msg.parsedTransactions[txIndex];
    if (targetTx.isConfirmed) return;

    final txModel = targetTx.toTransactionModel();
    final transactionsNotifier = ref.read(transactionsProvider.notifier);

    // Save to real Drift SQLite database
    transactionsNotifier.addTransaction(txModel);

    // Update in message
    final updatedTxs = List<ParsedTransaction>.from(msg.parsedTransactions);
    updatedTxs[txIndex] = targetTx.copyWith(isConfirmed: true);

    final allConfirmed = updatedTxs.every((t) => t.isConfirmed);
    final updatedMsg = msg.copyWith(
      parsedTransactions: updatedTxs,
      isConfirmed: allConfirmed,
    );

    final repo = ref.read(chatRepositoryProvider);
    await repo.saveMessage(updatedMsg);

    final updatedList = List<AiMessage>.from(messages);
    updatedList[msgIndex] = updatedMsg;
    state = AsyncData(updatedList);

    // Show floating pill UndoSnackbar (Mandatory Design Rule)
    if (context.mounted) {
      UndoSnackbar.show(
        context,
        message: 'Logged ${txModel.title} (${CurrencyFormatter.format(txModel.amount)})',
        onUndo: () {
          transactionsNotifier.deleteTransaction(txModel.id);
        },
      );
    }
  }

  /// Confirms and commits ALL pending parsed transactions in a message.
  Future<void> confirmAllTransactions(
    BuildContext context,
    String messageId,
  ) async {
    final messages = state.value ?? [];
    final msgIndex = messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = messages[msgIndex];
    final unconfirmed = msg.parsedTransactions.where((t) => !t.isConfirmed).toList();
    if (unconfirmed.isEmpty) return;

    final transactionsNotifier = ref.read(transactionsProvider.notifier);
    final addedModels = <TransactionModel>[];

    for (final ptx in unconfirmed) {
      final model = ptx.toTransactionModel();
      transactionsNotifier.addTransaction(model);
      addedModels.add(model);
    }

    final updatedTxs = msg.parsedTransactions
        .map((t) => t.copyWith(isConfirmed: true))
        .toList();

    final updatedMsg = msg.copyWith(
      parsedTransactions: updatedTxs,
      isConfirmed: true,
    );

    final repo = ref.read(chatRepositoryProvider);
    await repo.saveMessage(updatedMsg);

    final updatedList = List<AiMessage>.from(messages);
    updatedList[msgIndex] = updatedMsg;
    state = AsyncData(updatedList);

    if (context.mounted) {
      final count = addedModels.length;
      final totalAmount = addedModels.fold<double>(0.0, (s, m) => s + m.amount);
      UndoSnackbar.show(
        context,
        message: 'Logged $count transaction${count == 1 ? '' : 's'} (${CurrencyFormatter.format(totalAmount)})',
        onUndo: () {
          for (final m in addedModels) {
            transactionsNotifier.deleteTransaction(m.id);
          }
        },
      );
    }
  }

  /// Confirms and commits the transaction to the real Drift SQLite database with 5s Undo (backward compatibility).
  Future<void> confirmTransaction(BuildContext context, AiMessage message) async {
    await confirmAllTransactions(context, message.id);
  }

  /// Discards a single proposed transaction from a message card.
  Future<void> discardSingleTransaction(String messageId, String txId) async {
    final messages = state.value ?? [];
    final msgIndex = messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = messages[msgIndex];
    final updatedTxs = msg.parsedTransactions.where((t) => t.id != txId).toList();
    final allConfirmed = updatedTxs.isEmpty || updatedTxs.every((t) => t.isConfirmed);

    final updatedMsg = msg.copyWith(
      parsedTransactions: updatedTxs,
      isConfirmed: allConfirmed,
    );

    final repo = ref.read(chatRepositoryProvider);
    await repo.saveMessage(updatedMsg);

    final updatedList = List<AiMessage>.from(messages);
    updatedList[msgIndex] = updatedMsg;
    state = AsyncData(updatedList);
  }

  /// Discards a proposed transaction card (backward compatibility).
  Future<void> discardTransaction(String messageId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.markConfirmed(messageId); // mark so card disables action buttons

    final updated = (state.value ?? []).map((m) {
      if (m.id == messageId) {
        return m.copyWith(isConfirmed: true);
      }
      return m;
    }).toList();
    state = AsyncData(updated);
  }

  /// Clears chat history from SQLite database.
  Future<void> clearChat() async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.clearHistory();
    state = AsyncData([_createWelcomeMessage()]);
  }
}

final aiChatProvider = AsyncNotifierProvider<AiChatNotifier, List<AiMessage>>(() {
  return AiChatNotifier();
});
