import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/notes/domain/note_model.dart';
import 'package:hermanos_ledgr/features/notes/providers/notes_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom Material 3 bottom sheet for adding or editing a quick financial note (Task 12.7).
class AddNoteSheet extends ConsumerStatefulWidget {
  final NoteModel? editingNote;

  const AddNoteSheet({super.key, this.editingNote});

  static Future<void> show(BuildContext context, {NoteModel? editingNote}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddNoteSheet(editingNote: editingNote),
    );
  }

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  late final TextEditingController _contentController;
  late final TextEditingController _amountController;
  String _selectedTag = 'Expense';

  static const List<String> _tags = ['Expense', 'Reminder', 'Idea', 'General'];

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.editingNote?.content ?? '');
    _amountController = TextEditingController(
      text: widget.editingNote?.amount != null ? widget.editingNote!.amount!.toStringAsFixed(2) : '',
    );
    _selectedTag = widget.editingNote?.tag ?? 'Expense';
  }

  @override
  void dispose() {
    _contentController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      UndoSnackbar.error(context, message: 'Please enter note content');
      return;
    }

    HapticFeedback.mediumImpact();
    final notifier = ref.read(notesNotifierProvider.notifier);
    final customAmount = double.tryParse(_amountController.text.replaceAll(',', '').trim());

    if (widget.editingNote != null) {
      await notifier.updateNote(
        id: widget.editingNote!.id,
        content: text,
        tag: _selectedTag,
        amount: customAmount,
        isDone: widget.editingNote!.isDone,
      );
      if (mounted) {
        Navigator.pop(context);
        UndoSnackbar.success(context, message: 'Note updated');
      }
    } else {
      await notifier.addNote(
        content: text,
        tag: _selectedTag,
        amount: customAmount,
      );
      if (mounted) {
        Navigator.pop(context);
        UndoSnackbar.success(context, message: 'Quick note saved to scratchpad');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.editingNote != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Title
              Text(
                isEditing ? 'Edit Quick Note' : 'Add Financial Note',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Jot down pending purchases, budget reminders, or ideas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Tag Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tags.map((tag) {
                    final isSelected = _selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: Spacing.sm),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(tag),
                        onSelected: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTag = tag);
                        },
                        selectedColor: StashColors.tealAccent.withValues(alpha: 0.2),
                        checkmarkColor: StashColors.tealAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Content TextField
              TextField(
                controller: _contentController,
                autofocus: !isEditing,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g. Bought fruits at market ₱240\nPay electric bill before Friday...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Optional Amount Field
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (Optional)',
                  prefixText: '₱ ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Save Action Button
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: StashColors.tealAccent,
                  foregroundColor: const Color(0xFF0F1E1B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update Note' : 'Save to Scratchpad',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
