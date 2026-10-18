import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_service.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/ai_prompts.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/nlp_parser.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

void main() {
  final classifier = ClassifierService();
  final testDate = DateTime(2026, 10, 18, 12, 0);

  final sampleAccounts = [
    AccountModel(
      id: 'acc_gcash',
      name: 'GCash Wallet',
      institution: 'GCash',
      type: AccountType.eWallet,
      balance: 15400.0,
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF007DFE),
    ),
    AccountModel(
      id: 'acc_maya',
      name: 'Maya Account',
      institution: 'Maya',
      type: AccountType.eWallet,
      balance: 8500.0,
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF00E676),
    ),
    AccountModel(
      id: 'acc_bdo',
      name: 'BDO Savings',
      institution: 'BDO',
      type: AccountType.bank,
      balance: 75000.0,
      icon: Icons.account_balance_rounded,
      color: const Color(0xFF0038A8),
    ),
    AccountModel(
      id: 'acc_bpi',
      name: 'BPI Checking',
      institution: 'BPI',
      type: AccountType.bank,
      balance: 42000.0,
      icon: Icons.account_balance_rounded,
      color: const Color(0xFFB71C1C),
    ),
  ];

  group('ClassifierService Strict Entity & Gibberish Validation (Task 9.1)', () {
    test('strictly rejects gibberish and random text without numbers (Zero Hallucination)', () {
      final gibberishInputs = [
        'test',
        'jdhfjkd',
        'asdfgh',
        'what is this',
        'random text string',
        'some words here',
      ];

      for (final text in gibberishInputs) {
        final result = classifier.classify(
          rawInput: text,
          accounts: sampleAccounts,
          categories: CategoryDefaults.defaultCategories,
          now: testDate,
        );

        expect(result.intent, equals(ClassifierIntent.unclearOrGibberish),
            reason: 'Failed on input: "$text"');
        expect(result.confidence, equals(0.0), reason: 'Confidence must be 0 for: "$text"');
        expect(result.transaction, isNull, reason: 'Transaction must be null for: "$text"');
        expect(result.hasTransaction, isFalse);
        expect(result.conversationalReply, isNotNull);
      }
    });

    test('correctly recognizes greetings and help intents', () {
      final greetings = ['hi', 'hello', 'kumusta', 'help', 'who are you'];
      for (final g in greetings) {
        final result = classifier.classify(
          rawInput: g,
          accounts: sampleAccounts,
          categories: CategoryDefaults.defaultCategories,
          now: testDate,
        );
        expect(result.intent, equals(ClassifierIntent.greetingOrHelp));
        expect(result.confidence, equals(1.0));
        expect(result.transaction, isNull);
      }
    });

    test('correctly recognizes balance inquiries', () {
      final inquiries = ['How much do I have?', 'Total balance', 'Net worth', 'Pera ko'];
      for (final q in inquiries) {
        final result = classifier.classify(
          rawInput: q,
          accounts: sampleAccounts,
          categories: CategoryDefaults.defaultCategories,
          now: testDate,
        );
        expect(result.intent, equals(ClassifierIntent.queryBalance));
        expect(result.transaction, isNull);
      }
    });

    test('correctly recognizes spending inquiries', () {
      final inquiries = ['How much did I spend this month?', 'Total expenses', 'Monthly spending'];
      for (final q in inquiries) {
        final result = classifier.classify(
          rawInput: q,
          accounts: sampleAccounts,
          categories: CategoryDefaults.defaultCategories,
          now: testDate,
        );
        expect(result.intent, equals(ClassifierIntent.querySpending));
        expect(result.transaction, isNull);
      }
    });

    test('parses simple expense with amount, category keyword, and account', () {
      final result = classifier.classify(
        rawInput: 'Coffee 150 GCash',
        accounts: sampleAccounts,
        categories: CategoryDefaults.defaultCategories,
        now: testDate,
      );

      expect(result.intent, equals(ClassifierIntent.logTransaction));
      expect(result.isHighConfidence, isTrue);
      expect(result.confidence, greaterThanOrEqualTo(0.85));

      final tx = result.transaction!;
      expect(tx.amount, equals(150.0));
      expect(tx.type, equals(TransactionType.expense));
      expect(tx.categoryId, equals('food'));
      expect(tx.accountId, equals('acc_gcash'));
      expect(tx.date, equals(testDate));
    });

    test('parses Taglish "k" multiplier amounts accurately (Gas 1.5k BDO)', () {
      final result = classifier.classify(
        rawInput: 'Gas 1.5k BDO',
        accounts: sampleAccounts,
        categories: CategoryDefaults.defaultCategories,
        now: testDate,
      );

      expect(result.intent, equals(ClassifierIntent.logTransaction));
      final tx = result.transaction!;
      expect(tx.amount, equals(1500.0));
      expect(tx.categoryId, equals('transport'));
      expect(tx.accountId, equals('acc_bdo'));
    });

    test('parses currency symbols and large amounts (₱3,450.50 Meralco via Maya)', () {
      final result = classifier.classify(
        rawInput: '₱3,450.50 Meralco via Maya',
        accounts: sampleAccounts,
        categories: CategoryDefaults.defaultCategories,
        now: testDate,
      );

      expect(result.intent, equals(ClassifierIntent.logTransaction));
      final tx = result.transaction!;
      expect(tx.amount, equals(3450.50));
      expect(tx.categoryId, equals('utilities'));
      expect(tx.accountId, equals('acc_maya'));
    });

    test('parses income and relative date kahapon (Salary 50k BPI kahapon)', () {
      final result = classifier.classify(
        rawInput: 'Salary 50k BPI kahapon',
        accounts: sampleAccounts,
        categories: CategoryDefaults.defaultCategories,
        now: testDate,
      );

      expect(result.intent, equals(ClassifierIntent.logTransaction));
      final tx = result.transaction!;
      expect(tx.amount, equals(50000.0));
      expect(tx.type, equals(TransactionType.income));
      expect(tx.categoryId, equals('salary'));
      expect(tx.accountId, equals('acc_bpi'));
      expect(tx.date.day, equals(testDate.subtract(const Duration(days: 1)).day));
    });

    test('detects complex multi-item split for Tier 2 delegation', () {
      final result = classifier.classify(
        rawInput: '1500 for groceries and 350 for grab ride',
        accounts: sampleAccounts,
        categories: CategoryDefaults.defaultCategories,
        now: testDate,
      );

      expect(result.intent, equals(ClassifierIntent.complexOrSplit));
    });
  });

  group('NlpParser LLM Output Sanitization (Task 9.6)', () {
    test('parses valid JSON string with markdown fences from LLM', () {
      const llmOutput = '''
```json
{
  "type": "expense",
  "amount": 250.0,
  "category": "Food & Dining",
  "account": "GCash Wallet",
  "date": "2026-10-18",
  "note": "Starbucks caramel macchiato"
}
```
''';

      final parsed = NlpParser.parseLlmJson(
        rawLlmOutput: llmOutput,
        accounts: sampleAccounts,
        categories: CategoryDefaults.defaultCategories,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(250.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.categoryId, equals('food'));
      expect(parsed.accountId, equals('acc_gcash'));
      expect(parsed.note, equals('Starbucks caramel macchiato'));
    });

    test('gracefully returns null for error JSON or unparseable text', () {
      expect(
        NlpParser.parseLlmJson(
          rawLlmOutput: '{"error": "unclear input"}',
          accounts: sampleAccounts,
          categories: CategoryDefaults.defaultCategories,
        ),
        isNull,
      );

      expect(
        NlpParser.parseLlmJson(
          rawLlmOutput: 'I do not understand',
          accounts: sampleAccounts,
          categories: CategoryDefaults.defaultCategories,
        ),
        isNull,
      );
    });
  });

  group('AiPrompts System Prompt & ChatML Generation (Task 9.8)', () {
    test('builds system prompt containing user categories, accounts, and today date', () {
      final prompt = AiPrompts.buildTransactionSystemPrompt(
        categories: ['Food & Dining', 'Transportation'],
        accounts: ['GCash', 'BDO Savings'],
        todayDate: '2026-10-18',
      );

      expect(prompt, contains("Today's Date: 2026-10-18"));
      expect(prompt, contains('Available Categories: [Food & Dining, Transportation]'));
      expect(prompt, contains('Available Accounts: [GCash, BDO Savings]'));
      expect(prompt, contains('{"error": "unclear"}'));
    });

    test('formats prompt into standard Qwen 2.5 ChatML structure', () {
      final chatMl = AiPrompts.formatQwenChatMl(
        systemPrompt: 'You are Hermano.',
        userPrompt: 'Coffee 150 GCash',
      );

      expect(chatMl, startsWith('<|im_start|>system\nYou are Hermano.<|im_end|>\n'));
      expect(chatMl, contains('<|im_start|>user\nCoffee 150 GCash<|im_end|>\n'));
      expect(chatMl, endsWith('<|im_start|>assistant\n'));
    });

    test('builds spending summary prompt with ChatML format', () {
      final summaryPrompt = AiPrompts.buildSpendingSummaryPrompt(
        spendingContext: 'Total: 5000, Top: Food (3000)',
      );

      expect(summaryPrompt, contains('<|im_start|>system'));
      expect(summaryPrompt, contains('Total: 5000, Top: Food (3000)'));
      expect(summaryPrompt, endsWith('<|im_start|>assistant\n'));
    });
  });
}
