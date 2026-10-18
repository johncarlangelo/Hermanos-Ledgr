import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/notes/presentation/widgets/add_note_sheet.dart';
import 'package:hermanos_ledgr/features/notes/presentation/widgets/note_card.dart';
import 'package:hermanos_ledgr/features/notes/providers/notes_provider.dart';

/// Full screen for Financial Quick Notes & Scratchpad (Task 12.7).
class QuickNotesScreen extends ConsumerStatefulWidget {
  const QuickNotesScreen({super.key});

  @override
  ConsumerState<QuickNotesScreen> createState() => _QuickNotesScreenState();
}

class _QuickNotesScreenState extends ConsumerState<QuickNotesScreen> {
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: Completed

  static const List<String> _filters = ['All', 'Pending', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesAsync = ref.watch(notesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes & Scratchpad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Note',
            onPressed: () => AddNoteSheet.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddNoteSheet.show(context),
        backgroundColor: StashColors.tealAccent,
        foregroundColor: const Color(0xFF0F1E1B),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text(
          'Add Note',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: notesAsync.when(
        data: (allNotes) {
          // Filter notes
          var filtered = allNotes.where((n) {
            if (_selectedFilterIndex == 1 && n.isDone) return false;
            if (_selectedFilterIndex == 2 && !n.isDone) return false;
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final matchesContent = n.content.toLowerCase().contains(q);
              final matchesTag = n.tag?.toLowerCase().contains(q) ?? false;
              if (!matchesContent && !matchesTag) return false;
            }
            return true;
          }).toList();

          final pendingCount = allNotes.where((n) => !n.isDone).length;
          final doneCount = allNotes.where((n) => n.isDone).length;

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search notes or tags...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Filter Segmented Row & Counter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...List.generate(_filters.length, (idx) {
                            final isSelected = _selectedFilterIndex == idx;
                            return Padding(
                              padding: const EdgeInsets.only(right: Spacing.xs),
                              child: ChoiceChip(
                                label: Text(_filters[idx]),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedFilterIndex = idx);
                                  }
                                },
                                selectedColor: StashColors.tealAccent.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: isSelected ? StashColors.tealAccent : null,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          }),
                          const SizedBox(width: Spacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$pendingCount pending · $doneCount done',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Notes List or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(context, allNotes.isEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          left: Spacing.lg,
                          right: Spacing.lg,
                          top: Spacing.sm,
                          bottom: 80, // FAB clearance
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: Spacing.sm),
                        itemBuilder: (context, index) {
                          return NoteCard(note: filtered[index]);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading notes: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isCompletelyEmpty) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              isCompletelyEmpty ? 'Scratchpad is Empty' : 'No Matching Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              isCompletelyEmpty
                  ? 'Keep track of unbilled expenses, budget reminders, or ideas.'
                  : 'Try adjusting your search query or filter chip.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isCompletelyEmpty) ...[
              const SizedBox(height: Spacing.lg),
              FilledButton.icon(
                onPressed: () => AddNoteSheet.show(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create First Note'),
                style: FilledButton.styleFrom(
                  backgroundColor: StashColors.tealAccent,
                  foregroundColor: const Color(0xFF0F1E1B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
