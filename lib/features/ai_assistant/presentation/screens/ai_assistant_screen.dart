import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final TransactionModel? parsedTransaction;
  final bool isConfirmed;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.parsedTransaction,
    this.isConfirmed = false,
  });

  ChatMessage copyWith({
    bool? isConfirmed,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isUser: isUser,
      timestamp: timestamp,
      parsedTransaction: parsedTransaction,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      ChatMessage(
        id: 'msg_welcome',
        text:
            'Hello John! I am your on-device AI assistant. You can log expenses, income, or transfers using natural language — all parsed privately on your device.',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: 'msg_sample_user',
        text: 'Starbucks iced latte 240 from GCash',
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChatMessage(
        id: 'msg_sample_bot',
        text: 'I parsed this transaction for you. Please confirm to commit it to your ledger:',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        parsedTransaction: TransactionModel(
          id: 'tx_ai_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Starbucks iced latte',
          amount: 240.00,
          type: TransactionType.expense,
          categoryId: 'food',
          categoryName: 'Food & Dining',
          categoryIcon: Icons.restaurant_rounded,
          categoryColor: const Color(0xFFF57C00),
          accountId: 'acc_gcash',
          accountName: 'GCash',
          date: DateTime.now(),
          note: 'Parsed via local LLM',
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend([String? presetText]) {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      if (presetText == null) _inputController.clear();
    });

    _scrollToBottom();

    // Simulate fast local LLM parsing response
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final parsedTx = _parseSimulatedInput(text);
      final botMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
        text: parsedTx != null
            ? 'Parsed this from your input:'
            : "I couldn't quite extract the amount and category. Try something like 'Dinner 450 GCash'.",
        isUser: false,
        timestamp: DateTime.now(),
        parsedTransaction: parsedTx,
      );

      setState(() {
        _messages.add(botMsg);
      });
      _scrollToBottom();
    });
  }

  TransactionModel? _parseSimulatedInput(String input) {
    final lower = input.toLowerCase();

    // Extract numbers
    final numberRegex = RegExp(r'\d+(\.\d+)?');
    final match = numberRegex.firstMatch(lower);
    double amount = 150.0;
    if (match != null) {
      amount = double.tryParse(match.group(0)!) ?? 150.0;
      if (lower.contains('k') && amount < 1000) {
        amount *= 1000;
      }
    }

    final isIncome = lower.contains('salary') ||
        lower.contains('income') ||
        lower.contains('client') ||
        lower.contains('bonus');

    final isTransfer = lower.contains('transfer') || lower.contains('move');

    final categoryId = isIncome
        ? 'salary'
        : lower.contains('starbucks') || lower.contains('food') || lower.contains('dinner') || lower.contains('lunch')
            ? 'food'
            : lower.contains('electric') || lower.contains('meralco') || lower.contains('bill')
                ? 'utilities'
                : 'groceries';

    final categoryName = isIncome
        ? 'Salary'
        : categoryId == 'food'
            ? 'Food & Dining'
            : categoryId == 'utilities'
                ? 'Utilities & Bills'
                : 'Groceries';

    final accountName = lower.contains('bdo')
        ? 'BDO Savings'
        : lower.contains('maya')
            ? 'Maya'
            : 'GCash';

    final accountId = lower.contains('bdo')
        ? 'acc_bdo'
        : lower.contains('maya')
            ? 'acc_maya'
            : 'acc_gcash';

    return TransactionModel(
      id: 'tx_ai_${DateTime.now().millisecondsSinceEpoch}',
      title: input.length > 25 ? input.substring(0, 25) : input,
      amount: amount,
      type: isTransfer
          ? TransactionType.transfer
          : isIncome
              ? TransactionType.income
              : TransactionType.expense,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: isIncome ? Icons.payments_rounded : Icons.restaurant_rounded,
      categoryColor: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
      accountId: accountId,
      accountName: accountName,
      date: DateTime.now(),
      note: 'Parsed via local LLM',
    );
  }

  void _confirmTransaction(int messageIndex, TransactionModel tx) {
    HapticFeedback.mediumImpact();
    ref.read(transactionsProvider.notifier).addTransaction(tx);

    setState(() {
      _messages[messageIndex] = _messages[messageIndex].copyWith(isConfirmed: true);
    });

    UndoSnackbar.show(
      context,
      message: 'Committed ${CurrencyFormatter.format(tx.amount)} (${tx.title})',
      onUndo: () {
        ref.read(transactionsProvider.notifier).deleteTransaction(tx.id);
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Hermanos AI'),
            const SizedBox(width: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: SemanticColors.income(isDark).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: SemanticColors.income(isDark),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Offline (Qwen 3)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SemanticColors.income(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat message history
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(index, msg, theme, isDark);
              },
            ),
          ),

          // Quick Prompt Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                _buildPromptChip('☕ Starbucks 250 GCash'),
                const SizedBox(width: Spacing.sm),
                _buildPromptChip('💰 Salary 35k BDO'),
                const SizedBox(width: Spacing.sm),
                _buildPromptChip('💡 Paid electric 3400 Maya'),
                const SizedBox(width: Spacing.sm),
                _buildPromptChip('🍔 Dinner 420 Cash'),
              ],
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Type: "Coffee 180 GCash" or "Salary 40k"...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  IconButton.filled(
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: () => _handleSend(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(text),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      onPressed: () => _handleSend(text),
    );
  }

  Widget _buildMessageItem(
    int index,
    ChatMessage msg,
    ThemeData theme,
    bool isDark,
  ) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: Spacing.md, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: Spacing.md, right: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (msg.parsedTransaction != null) ...[
                const SizedBox(height: Spacing.sm),
                _buildActionCard(index, msg, theme, isDark),
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionCard(
    int index,
    ChatMessage msg,
    ThemeData theme,
    bool isDark,
  ) {
    final tx = msg.parsedTransaction!;
    final isConfirmed = msg.isConfirmed;

    return M3Card(
      color: theme.colorScheme.surfaceContainer,
      border: Border.all(
        color: isConfirmed
            ? SemanticColors.income(isDark)
            : theme.colorScheme.outlineVariant,
        width: 1,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tx.categoryColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(tx.categoryIcon, size: 18, color: tx.categoryColor),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${tx.categoryName} · ${tx.accountName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                tx.type == TransactionType.income
                    ? '+${CurrencyFormatter.format(tx.amount)}'
                    : '-${CurrencyFormatter.format(tx.amount)}',
                style: moneyStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tx.type == TransactionType.income
                      ? SemanticColors.income(isDark)
                      : SemanticColors.expense(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (isConfirmed)
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: SemanticColors.income(isDark),
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  'Committed to Ledger',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SemanticColors.income(isDark),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _confirmTransaction(index, tx),
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      setState(() {
                        _messages.removeAt(index);
                      });
                    },
                    child: const Text('Discard'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
