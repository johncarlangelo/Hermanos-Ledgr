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
    final userName = ref.read(onboardingProvider).userName.split(' ').first;
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
        if (result.isHighConfidence && result.transaction != null) {
          // Tier 1 direct return
          await _respondWithTransaction(
            result.transaction!,
            replyText: "Parsed your transaction ready for confirmation:",
          );
        } else {
          // Lower confidence: attempt Tier 2 if model is present, else show best-guess
          final modelManager = ref.read(modelManagerProvider);
          final isModelReady = await modelManager.isModelDownloaded();

          if (isModelReady) {
            await _handleWithTier2(trimmed, accounts, categories, fallbackTx: result.transaction);
          } else {
            await _respondWithTransaction(
              result.transaction!,
              replyText: "I extracted this from your input, please verify before confirming:",
            );
          }
        }
        break;
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
      await _respondWithText(
        "This input looks like a multi-item split or complex request. Download the Hermano Brain (Qwen 2.5 0.5B ~350MB) to handle multi-item queries and detailed financial advice.",
        intent: ClassifierIntent.complexOrSplit,
      );
      return;
    }

    await _handleWithTier2(userText, accounts, categories);
  }

  Future<void> _handleWithTier2(
    String userText,
    List<dynamic> accounts,
    List<dynamic> categories, {
    ParsedTransaction? fallbackTx,
  }) async {
    final llm = ref.read(llmServiceProvider);
    final modelManager = ref.read(modelManagerProvider);

    if (!llm.isLoaded) {
      final path = await modelManager.getModelPath();
      await llm.loadModel(path);
    }

    final catNames = CategoryDefaults.defaultCategories.map((c) => c.name).toList();
    final accNames = ref.read(accountsProvider).map((a) => a.name).toList();
    final today = DateTime.now().toIso8601String().split('T').first;

    final jsonStr = await llm.generateStructuredJson(
      userPrompt: userText,
      categories: catNames,
      accounts: accNames,
      todayDate: today,
    );

    if (jsonStr != null) {
      final parsed = NlpParser.parseLlmJson(
        rawLlmOutput: jsonStr,
        accounts: ref.read(accountsProvider),
        categories: CategoryDefaults.defaultCategories,
      );

      if (parsed != null) {
        await _respondWithTransaction(parsed, replyText: "Qwen AI parsed this transaction:");
        return;
      }
    }

    // Fallback if LLM failed to return structured json
    if (fallbackTx != null) {
      await _respondWithTransaction(fallbackTx, replyText: "Extracted transaction details:");
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

  Future<void> _respondWithTransaction(ParsedTransaction tx, {required String replyText}) async {
    final repo = ref.read(chatRepositoryProvider);
    final botMsg = AiMessage(
      id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
      content: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      parsedTransaction: tx,
      intent: ClassifierIntent.logTransaction,
    );

    final current = state.value ?? [];
    state = AsyncData([...current, botMsg]);
    await repo.saveMessage(botMsg);
  }

  /// Confirms and commits the transaction to the real Drift SQLite database with 5s Undo (Task 9.12).
  Future<void> confirmTransaction(BuildContext context, AiMessage message) async {
    if (message.parsedTransaction == null || message.isConfirmed) return;

    final txModel = message.parsedTransaction!.toTransactionModel();
    final transactionsNotifier = ref.read(transactionsProvider.notifier);

    // Save to real Drift SQLite database
    transactionsNotifier.addTransaction(txModel);

    // Mark confirmed in chat
    final repo = ref.read(chatRepositoryProvider);
    await repo.markConfirmed(message.id);

    final updated = (state.value ?? []).map((m) {
      if (m.id == message.id) {
        return m.copyWith(isConfirmed: true);
      }
      return m;
    }).toList();
    state = AsyncData(updated);

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

  /// Discards a proposed transaction card.
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
