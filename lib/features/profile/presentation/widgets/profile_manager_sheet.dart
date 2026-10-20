import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/profile/domain/profile_model.dart';
import 'package:hermanos_ledgr/features/profile/presentation/widgets/create_profile_sheet.dart';
import 'package:hermanos_ledgr/features/profile/providers/profile_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/profile_avatar.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Material 3 Custom Bottom Sheet for managing and switching profiles (Tasks 12.4, 12.5).
class ProfileManagerSheet extends ConsumerWidget {
  const ProfileManagerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileManagerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileState = ref.watch(profileNotifierProvider);
    final profiles = profileState.profiles;
    final activeId = profileState.activeProfileId;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Row with Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Manager',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Switch or manage multiple ledger identities',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: () => CreateProfileSheet.show(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                    tooltip: 'Add Profile',
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Profiles List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profiles.length,
                separatorBuilder: (context, index) => const SizedBox(height: Spacing.sm),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isActive = profile.id == activeId;
                  final badgeColor = Color(profile.colorValue);

                  return _buildProfileItem(
                    context: context,
                    ref: ref,
                    theme: theme,
                    isDark: isDark,
                    profile: profile,
                    isActive: isActive,
                    badgeColor: badgeColor,
                  );
                },
              ),
              const SizedBox(height: Spacing.lg),

              // Add Profile CTA Card
              InkWell(
                onTap: () => CreateProfileSheet.show(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: StashColors.tealAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: StashColors.tealAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Another Profile',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Create a profile for personal, freelance, or family finances',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required bool isDark,
    required ProfileModel profile,
    required bool isActive,
    required Color badgeColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? StashColors.base : theme.colorScheme.surface)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? StashColors.tealAccent
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: StashColors.tealAccent.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(profileNotifierProvider.notifier).switchProfile(profile.id);
            UndoSnackbar.info(context, message: 'Switched to profile: ${profile.name}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md - 2,
            ),
            child: Row(
              children: [
                // Avatar
                ProfileAvatar(
                  size: 44,
                  userName: profile.name,
                  profilePicBase64: profile.avatarBase64,
                ),
                const SizedBox(width: Spacing.md),

                // Name & Tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          if (profile.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Default',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive ? 'Active Profile' : 'Tap to switch',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: isActive
                              ? StashColors.tealAccent
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active check indicator or Action buttons
                if (isActive)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: StashColors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Color(0xFF0F1E1B),
                    ),
                  ),

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit Profile',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => CreateProfileSheet.show(context, editingProfile: profile),
                ),

                // Delete Button (only if not default and multiple profiles exist)
                if (!profile.isDefault && ref.watch(profileNotifierProvider).profiles.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    tooltip: 'Delete Profile',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _confirmDelete(context, ref, profile),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(Spacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 36),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Delete Profile "${profile.name}"?',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'This profile identity will be removed. Default profile will remain.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final ok = await ref.read(profileNotifierProvider.notifier).deleteProfile(profile.id);
                          if (ok && context.mounted) {
                            UndoSnackbar.info(context, message: 'Profile "${profile.name}" deleted');
                          }
                        },
                        style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
