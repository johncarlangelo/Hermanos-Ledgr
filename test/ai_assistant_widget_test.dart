import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/ai_message.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/chat_repository.dart';
import 'package:hermanos_ledgr/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:hermanos_ledgr/features/ai_assistant/providers/chat_repository_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';

class _TestOnboardingNotifier extends OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState(
        isCompleted: true,
        userName: 'John C.',
      );
}

class _FakeAccountsNotifier extends AccountsNotifier {
  final List<AccountModel> initial;
  _FakeAccountsNotifier(this.initial);

  @override
  List<AccountModel> build() => initial;
}

class _InMemoryChatRepository implements ChatRepository {
  final List<AiMessage> _messages = [];

  @override
  Stream<List<AiMessage>> watchMessages() => Stream.value(_messages);

  @override
  Future<Result<List<AiMessage>>> getAllMessages() async => Success(_messages);

  @override
  Future<Result<void>> saveMessage(AiMessage message) async {
    final idx = _messages.indexWhere((m) => m.id == message.id);
    if (idx != -1) {
      _messages[idx] = message;
    } else {
      _messages.add(message);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markConfirmed(String id) async {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _messages[idx] = _messages[idx].copyWith(isConfirmed: true);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteMessage(String id) async {
    _messages.removeWhere((m) => m.id == id);
    return const Success(null);
  }

  @override
  Future<Result<void>> clearHistory() async {
    _messages.clear();
    return const Success(null);
  }
}

class _FakeTransactionsNotifier extends TransactionsNotifier {
  final List<TransactionModel> addedTxs = [];

  @override
  List<TransactionModel> build() => [];

  @override
  void addTransaction(TransactionModel tx) {
    addedTxs.add(tx);
    state = [tx, ...state];
  }
}

void main() {
  final sampleAccount = AccountModel(
    id: 'acc_gcash',
    name: 'GCash',
    type: AccountType.eWallet,
    balance: 5000.0,
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFF007DFE),
  );

  Widget buildTestChatApp({
    ChatRepository? chatRepo,
    _FakeTransactionsNotifier? txNotifier,
  }) {
    return ProviderScope(
      overrides: [
        onboardingProvider.overrideWith(_TestOnboardingNotifier.new),
        chatRepositoryProvider.overrideWithValue(chatRepo ?? _InMemoryChatRepository()),
        if (txNotifier != null)
          transactionsProvider.overrideWith(() => txNotifier),
        accountsProvider.overrideWith(() => _FakeAccountsNotifier([sampleAccount])),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const AiAssistantScreen(),
      ),
    );
  }

  testWidgets('AiAssistantScreen mounts and displays welcome message & prompt chips', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestChatApp());
    await tester.pumpAndSettle();

    expect(find.text('Hermano'), findsOneWidget);
    expect(find.textContaining('I am Hermano'), findsOneWidget);
    expect(find.text('☕ Starbucks 250 GCash'), findsOneWidget);
  });

  testWidgets('Strict Zero Hallucination: Gibberish input NEVER creates a transaction action card', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestChatApp());
    await tester.pumpAndSettle();

    // Type random gibberish with NO numbers or financial keywords
    final textFieldFinder = find.byType(TextField);
    await tester.enterText(textFieldFinder, 'jdhfjkd');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    // Verify user message appears
    expect(find.text('jdhfjkd'), findsOneWidget);

    // Verify Hermano responds with helpful guidance, NOT a transaction card
    expect(find.textContaining("I couldn't detect an amount or known expense"), findsOneWidget);

    // Confirm buttons must NOT exist
    expect(find.text('Confirm'), findsNothing);
    expect(find.text('Committed to Ledger'), findsNothing);
  });

  testWidgets('Valid transaction prompt generates Action Card and Confirm commits to DB with Undo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final txNotifier = _FakeTransactionsNotifier();
    await tester.pumpWidget(buildTestChatApp(txNotifier: txNotifier));
    await tester.pumpAndSettle();

    // Enter a valid expense
    final textFieldFinder = find.byType(TextField);
    await tester.enterText(textFieldFinder, 'Coffee 150 GCash');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    // Verify Action Card is generated
    expect(find.textContaining('Coffee'), findsAtLeast(1));
    expect(find.textContaining('150.00'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // Tap Confirm button
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Verify it marked committed to ledger
    expect(find.text('Committed to Ledger'), findsOneWidget);

    // Verify transaction was added to the repository
    expect(txNotifier.addedTxs.length, equals(1));
    expect(txNotifier.addedTxs.first.amount, equals(150.0));
    expect(txNotifier.addedTxs.first.accountId, equals('acc_gcash'));
  });
}
