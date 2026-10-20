import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/profile/domain/profile_model.dart';
import 'package:hermanos_ledgr/features/profile/providers/profile_provider.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/profile_photo_adjust_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/profile_avatar.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for creating or editing a user profile (Task 12.5).
class CreateProfileSheet extends ConsumerStatefulWidget {
  final ProfileModel? editingProfile;

  const CreateProfileSheet({super.key, this.editingProfile});

  static Future<ProfileModel?> show(BuildContext context, {ProfileModel? editingProfile}) {
    return showModalBottomSheet<ProfileModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateProfileSheet(editingProfile: editingProfile),
    );
  }

  @override
  ConsumerState<CreateProfileSheet> createState() => _CreateProfileSheetState();
}

class _CreateProfileSheetState extends ConsumerState<CreateProfileSheet> {
  late final TextEditingController _nameController;
  String? _avatarBase64;
  int _selectedColor = 0xFF00897B; // Default Stash Teal
  final _imagePicker = ImagePicker();

  static const List<int> _colorOptions = [
    0xFF00897B, // Stash Teal
    0xFF1976D2, // Blue
    0xFF7B1FA2, // Purple
    0xFFE65100, // Orange
    0xFFC2185B, // Rose
    0xFF2E7D32, // Emerald
    0xFF455A64, // Slate
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingProfile?.name ?? '');
    _avatarBase64 = widget.editingProfile?.avatarBase64;
    _selectedColor = widget.editingProfile?.colorValue ?? 0xFF00897B;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    HapticFeedback.selectionClick();
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      final croppedBase64 = await ProfilePhotoAdjustSheet.show(
        context,
        rawImageBytes: bytes,
      );

      if (croppedBase64 != null && mounted) {
        setState(() => _avatarBase64 = croppedBase64);
      }
    } catch (e) {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Could not load photo: $e');
      }
    }
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      UndoSnackbar.error(context, message: 'Please enter a profile name');
      return;
    }

    HapticFeedback.mediumImpact();
    final notifier = ref.read(profileNotifierProvider.notifier);

    if (widget.editingProfile != null) {
      await notifier.updateProfile(
        id: widget.editingProfile!.id,
        name: name,
        avatarBase64: _avatarBase64,
        clearAvatar: _avatarBase64 == null,
        colorValue: _selectedColor,
      );
      if (mounted) {
        Navigator.pop(context);
        UndoSnackbar.success(context, message: 'Profile updated');
      }
    } else {
      final created = await notifier.createProfile(
        name: name,
        avatarBase64: _avatarBase64,
        colorValue: _selectedColor,
        switchToNew: true,
      );
      if (mounted) {
        Navigator.pop(context, created);
        UndoSnackbar.success(context, message: 'Created and switched to "$name"');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.editingProfile != null;

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
              // Title
              Text(
                isEditing ? 'Edit Profile' : 'Create New Profile',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                isEditing
                    ? 'Update profile identity and avatar'
                    : 'Add a distinct profile (e.g., Freelance, Business, Family)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Avatar & Photo Picker
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ProfileAvatar(
                      size: 88,
                      userName: _nameController.text.isNotEmpty ? _nameController.text : 'U',
                      profilePicBase64: _avatarBase64,
                    ),
                    InkWell(
                      onTap: () => _showPhotoOptions(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: StashColors.tealAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? StashColors.raised : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Color(0xFF0F1E1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Name TextField
              TextField(
                controller: _nameController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Profile Name',
                  hintText: 'e.g. Freelance, Household, Business',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Color Accent Selector
              Text(
                'ACCENT BADGE COLOR',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.sm,
                children: _colorOptions.map((colorVal) {
                  final color = Color(colorVal);
                  final isSelected = _selectedColor == colorVal;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedColor = colorVal);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 20, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
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
                  isEditing ? 'Save Changes' : 'Create Profile',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
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
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_avatarBase64 != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _avatarBase64 = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
