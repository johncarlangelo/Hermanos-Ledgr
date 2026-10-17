import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/profile_photo_adjust_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/profile_avatar.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for editing user display name and profile picture.
/// Strictly supports PNG, JPG, and GIF images.
class ProfileEditSheet extends ConsumerStatefulWidget {
  const ProfileEditSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const ProfileEditSheet(),
    );
  }

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  late final TextEditingController _nameController;
  String? _pendingProfilePic;
  bool _isPicModified = false;

  @override
  void initState() {
    super.initState();
    final onboardingState = ref.read(onboardingProvider);
    _nameController = TextEditingController(text: onboardingState.userName);
    _pendingProfilePic = onboardingState.profilePicBase64;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif'],
      );

      if (file == null) return;

      final ext = file.extension?.toLowerCase() ?? '';

      // Strict validation for PNG, JPG, and GIF
      if (!['png', 'jpg', 'jpeg', 'gif'].contains(ext)) {
        if (mounted) {
          UndoSnackbar.error(
            context,
            message: 'Only PNG, JPG, and GIF images are supported',
          );
        }
        return;
      }

      final bytes = await file.xFile.readAsBytes();
      if (bytes.isEmpty) {
        if (mounted) {
          UndoSnackbar.error(context, message: 'Could not read image file');
        }
        return;
      }

      // 5MB safeguard
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) {
          UndoSnackbar.error(context, message: 'Image must be under 5MB');
        }
        return;
      }

      if (!mounted) return;
      final croppedBase64 = await ProfilePhotoAdjustSheet.show(
        context,
        rawImageBytes: bytes,
      );

      if (croppedBase64 != null && mounted) {
        setState(() {
          _pendingProfilePic = croppedBase64;
          _isPicModified = true;
        });
      }
    } catch (e) {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Failed to select image: $e');
      }
    }
  }

  void _save() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      UndoSnackbar.error(context, message: 'Please enter a valid name');
      return;
    }

    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setUserName(newName);

    if (_isPicModified) {
      notifier.setProfilePic(_pendingProfilePic);
    }

    Navigator.of(context).pop();
    UndoSnackbar.success(
      context,
      message: 'Profile updated successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'John';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.xl + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Text(
                        'Edit Profile',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Avatar & Photo Picker Section
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      size: 88,
                      userName: displayName,
                      profilePicBase64: _pendingProfilePic,
                      showEditBadge: true,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: Spacing.md),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_outlined, size: 16),
                          label: Text(_pendingProfilePic != null ? 'Change Photo' : 'Upload Photo'),
                        ),
                        if (_pendingProfilePic != null) ...[
                          const SizedBox(width: Spacing.sm),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _pendingProfilePic = null;
                                _isPicModified = true;
                              });
                            },
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: SemanticColors.expense(isDark),
                            ),
                            label: Text(
                              'Remove',
                              style: TextStyle(color: SemanticColors.expense(isDark)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports PNG, JPG, and GIF (up to 5MB)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Name Input Field
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'e.g. John C.',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  suffixIcon: _nameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _nameController.clear(),
                        )
                      : null,
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: Spacing.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
