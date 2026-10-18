import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/notes/domain/note_model.dart';
import 'package:hermanos_ledgr/features/notes/presentation/widgets/add_note_sheet.dart';
import 'package:hermanos_ledgr/features/notes/providers/notes_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Interactive Material 3 card representing a single Quick Note / Scratchpad item (Task 12.7).
/// Strict Zero Stock Android Native UI: custom animated check container, tabular figures, custom bottom sheets.
class NoteCard extends ConsumerWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  Color _getTagColor(String? tag) {
    switch (tag?.toLowerCase()) {
      case 'expense':
        return const Color(0xFFF57C00); // Orange
      case 'reminder':
        return StashColors.tealAccent; // Teal
      case 'idea':
        return const Color(0xFFAB47BC); // Purple
      default:
        return const Color(0xFF29B6F6); // Light Blue
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tagColor = _getTagColor(note.tag);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: note.isDone
            ? (isDark ? StashColors.base.withValues(alpha: 0.5) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4))
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: note.isDone
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AddNoteSheet.show(context, editingNote: note),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Zero Stock Checkbox (AnimatedContainer with 7dp radius)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(notesNotifierProvider.notifier).toggleDone(note.id, !note.isDone);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: note.isDone ? StashColors.tealAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: note.isDone ? StashColors.tealAccent : theme.colorScheme.outlineVariant,
                        width: 1.8,
                      ),
                    ),
                    child: note.isDone
                        ? const Icon(Icons.check, size: 18, color: Color(0xFF0F1E1B))
                        : null,
                  ),
                ),
                const SizedBox(width: Spacing.md),

                // Note Content & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Tag badge & Date
                      Row(
                        children: [
                          if (note.tag != null && note.tag!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tagColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                note.tag!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: tagColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                          ],
                          Text(
                            DateFormat('MMM d, h:mm a').format(note.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),

                      // Main Content Text
                      Text(
                        note.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: note.isDone ? TextDecoration.lineThrough : null,
                          color: note.isDone ? theme.colorScheme.onSurfaceVariant : null,
                          height: 1.35,
                        ),
                      ),

                      // Attached Amount & Log Action
                      if (note.amount != null && note.amount! > 0) ...[
                        const SizedBox(height: Spacing.sm),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '₱${note.amount!.toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  color: StashColors.tealAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                AddTransactionSheet.show(
                                  context,
                                  initialType: TransactionType.expense,
                                  initialAmount: note.amount,
                                  initialTitle: note.content.split('\n').first,
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.receipt_long_rounded, size: 14, color: StashColors.tealAccent),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Log to Ledger',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: StashColors.tealAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete Note',
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    await ref.read(notesNotifierProvider.notifier).deleteNote(note.id);
                    if (context.mounted) {
                      UndoSnackbar.show(
                        context,
                        message: 'Note deleted',
                        onUndo: () {
                          ref.read(notesNotifierProvider.notifier).addNote(
                                content: note.content,
                                tag: note.tag,
                                amount: note.amount,
                              );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
