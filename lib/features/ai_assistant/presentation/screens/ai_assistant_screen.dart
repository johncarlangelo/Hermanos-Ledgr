import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/ai_message.dart';
import 'package:hermanos_ledgr/features/ai_assistant/presentation/widgets/model_download_sheet.dart';
import 'package:hermanos_ledgr/features/ai_assistant/providers/ai_assistant_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isModelReady = false;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    final manager = ref.read(modelManagerProvider);
    final ready = await manager.isModelDownloaded();
    if (mounted) {
      setState(() => _isModelReady = ready);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend([String? presetText]) {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _inputController.clear();
    }

    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _handleVoiceInput() {
    HapticFeedback.selectionClick();
    // Voice query trigger with suggestions (Task 9.13)
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: StashColors.tealAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: StashColors.tealAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Listening for transaction...',
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Say: "Coffee 150 GCash" or "Salary 45k BPI"',
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    label: const Text('☕ Coffee 150 GCash'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _handleSend('Coffee 150 GCash');
                    },
                  ),
                  ActionChip(
                    label: const Text('⛽ Gas 2.5k BDO'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _handleSend('Gas 2.5k BDO');
                    },
                  ),
                  ActionChip(
                    label: const Text('⚡ Meralco 3500 Maya'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _handleSend('Meralco 3500 Maya');
                    },
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
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
    final chatAsync = ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Hermano'),
            const SizedBox(width: Spacing.sm),
            GestureDetector(
              onTap: () async {
                await ModelDownloadSheet.show(context);
                _checkModelStatus();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (_isModelReady ? StashColors.tealAccent : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isModelReady ? StashColors.tealAccent : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isModelReady ? 'Qwen 2.5 Active' : 'Tier 1 Fast',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _isModelReady ? StashColors.tealAccent : const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 14,
                      color: _isModelReady ? StashColors.tealAccent : const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Model Manager',
            onPressed: () async {
              await ModelDownloadSheet.show(context);
              _checkModelStatus();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Chat History',
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message history from Drift SQLite
          Expanded(
            child: chatAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
                      child: EmptyStateView(
                        icon: Icons.auto_awesome_rounded,
                        title: 'I am Hermano, your AI budget co-pilot',
                        subtitle:
                            'Type naturally to log transactions, check account balances, or ask about your monthly spending.',
                        actionLabel: 'Try Voice Input',
                        onAction: _handleVoiceInput,
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(Spacing.lg),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(msg, theme, isDark);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text('Error loading messages: $err'),
              ),
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
                const SizedBox(width: Spacing.xs),
                _buildPromptChip('🍱 Lunch 280 Maya'),
                const SizedBox(width: Spacing.xs),
                _buildPromptChip('💰 Salary 50k BDO kahapon'),
                const SizedBox(width: Spacing.xs),
                _buildPromptChip('⚡ Meralco 3500 Maya'),
                const SizedBox(width: Spacing.xs),
                _buildPromptChip('🛒 Groceries 1.8k GCash'),
                const SizedBox(width: Spacing.xs),
                _buildPromptChip('📊 How much did I spend this month?'),
                const SizedBox(width: Spacing.xs),
                _buildPromptChip('💳 What is my balance?'),
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
                  IconButton(
                    icon: const Icon(Icons.mic_rounded, color: StashColors.tealAccent),
                    tooltip: 'Voice Input',
                    onPressed: _handleVoiceInput,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Type: "Coffee 180 GCash" or "Salary 40k"...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: StashColors.tealAccent,
                      foregroundColor: Colors.black,
                    ),
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
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _inputController.text = text;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputController.text.length),
            );
          });
          _focusNode.requestFocus();
          _scrollToBottom();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? StashColors.line.withValues(alpha: 0.8)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? StashColors.dim : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    AiMessage msg,
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
            msg.content,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
              if (msg.parsedTransaction != null) ...[
                const SizedBox(height: Spacing.sm),
                _buildActionCard(msg, theme, isDark),
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionCard(
    AiMessage msg,
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
                      backgroundColor: StashColors.tealAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(38),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      ref.read(aiChatProvider.notifier).confirmTransaction(context, msg);
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(60, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () {
                    // Prefill AddTransactionSheet with parsed data
                    AddTransactionSheet.show(
                      context,
                      initialType: tx.type,
                    );
                  },
                  child: const Text('Edit'),
                ),
                const SizedBox(width: Spacing.xs),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Discard',
                  onPressed: () {
                    ref.read(aiChatProvider.notifier).discardTransaction(msg.id);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
