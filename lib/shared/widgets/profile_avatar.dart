import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';

/// Reusable circular profile avatar widget that supports:
/// - Custom user-uploaded photos (PNG, JPG, animated GIF) via Base64 memory cache
/// - Dynamic user initials fallback
/// - Optional camera/edit badge
/// - Calm Finance Hermanos-Stash styling
class ProfileAvatar extends StatelessWidget {
  final double size;
  final String? profilePicBase64;
  final String userName;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final double borderWidth;

  const ProfileAvatar({
    super.key,
    this.size = 54,
    this.profilePicBase64,
    required this.userName,
    this.onTap,
    this.showEditBadge = false,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

    final initials = userName.trim().isNotEmpty
        ? userName
            .trim()
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase())
            .take(2)
            .join()
        : 'HL';

    Widget avatarCore;
    if (profilePicBase64 != null && profilePicBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(profilePicBase64!);
        avatarCore = ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildInitials(theme, isDark, accentColor, initials),
          ),
        );
      } catch (_) {
        avatarCore = _buildInitials(theme, isDark, accentColor, initials);
      }
    } else {
      avatarCore = _buildInitials(theme, isDark, accentColor, initials);
    }

    final avatarBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? StashColors.raised : theme.colorScheme.primaryContainer,
        border: Border.all(
          color: accentColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: avatarCore,
    );

    if (!showEditBadge) {
      if (onTap != null) {
        return InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: avatarBox,
        );
      }
      return avatarBox;
    }

    // With Camera/Edit Badge
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarBox,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? StashColors.surface : theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: size * 0.18,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(ThemeData theme, bool isDark, Color accentColor, String initials) {
    return Center(
      child: Text(
        initials,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: accentColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
