import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/profile/domain/profile_model.dart';

const _kProfilesListKey = 'hermanos_profiles_list';
const _kActiveProfileIdKey = 'hermanos_active_profile_id';

class ProfileState {
  final List<ProfileModel> profiles;
  final String activeProfileId;

  const ProfileState({
    required this.profiles,
    required this.activeProfileId,
  });

  ProfileModel get activeProfile {
    return profiles.firstWhere(
      (p) => p.id == activeProfileId,
      orElse: () => profiles.isNotEmpty
          ? profiles.first
          : ProfileModel(
              id: 'profile_default',
              name: 'User',
              isDefault: true,
              createdAt: DateTime.now(),
            ),
    );
  }

  ProfileState copyWith({
    List<ProfileModel>? profiles,
    String? activeProfileId,
  }) {
    return ProfileState(
      profiles: profiles ?? this.profiles,
      activeProfileId: activeProfileId ?? this.activeProfileId,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final onboardingState = ref.watch(onboardingProvider);
    List<ProfileModel> profiles = [];
    String? activeId;

    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final rawJson = prefs.getString(_kProfilesListKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        profiles = ProfileModel.decodeList(rawJson);
      }
      activeId = prefs.getString(_kActiveProfileIdKey);
    } catch (_) {}

    // Seed initial default profile if list is empty
    if (profiles.isEmpty) {
      final defaultProfile = ProfileModel(
        id: 'profile_default',
        name: onboardingState.userName.isNotEmpty ? onboardingState.userName : 'User',
        avatarBase64: onboardingState.profilePicBase64,
        isDefault: true,
        colorValue: 0xFF00897B, // Stash Teal
        createdAt: DateTime.now(),
      );
      profiles = [defaultProfile];
      activeId = defaultProfile.id;
      _persistProfiles(profiles, activeId);
    }

    activeId ??= profiles.first.id;

    return ProfileState(
      profiles: profiles,
      activeProfileId: activeId,
    );
  }

  void _persistProfiles(List<ProfileModel> profiles, String activeId) {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setString(_kProfilesListKey, ProfileModel.encodeList(profiles));
      prefs.setString(_kActiveProfileIdKey, activeId);
    } catch (_) {}
  }

  /// Creates a new profile and optionally switches to it (Task 12.5).
  Future<ProfileModel> createProfile({
    required String name,
    String? avatarBase64,
    int? colorValue,
    bool switchToNew = true,
  }) async {
    final newId = 'profile_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = ProfileModel(
      id: newId,
      name: name.trim().isEmpty ? 'New Profile' : name.trim(),
      avatarBase64: avatarBase64,
      isDefault: false,
      colorValue: colorValue ?? 0xFF00897B,
      createdAt: DateTime.now(),
    );

    final updated = [...state.profiles, newProfile];
    final activeId = switchToNew ? newId : state.activeProfileId;

    state = state.copyWith(profiles: updated, activeProfileId: activeId);
    _persistProfiles(updated, activeId);

    if (switchToNew) {
      _syncToOnboarding(newProfile);
    }

    return newProfile;
  }

  /// Switches active profile (Task 12.5).
  Future<void> switchProfile(String profileId) async {
    if (state.activeProfileId == profileId) return;

    final target = state.profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => state.activeProfile,
    );

    state = state.copyWith(activeProfileId: target.id);
    _persistProfiles(state.profiles, target.id);
    _syncToOnboarding(target);
  }

  /// Updates an existing profile's name, avatar, or color (Task 12.5).
  Future<void> updateProfile({
    required String id,
    String? name,
    String? avatarBase64,
    bool clearAvatar = false,
    int? colorValue,
  }) async {
    final updated = state.profiles.map((p) {
      if (p.id == id) {
        return p.copyWith(
          name: name?.trim().isNotEmpty == true ? name!.trim() : p.name,
          avatarBase64: avatarBase64,
          clearAvatar: clearAvatar,
          colorValue: colorValue ?? p.colorValue,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(profiles: updated);
    _persistProfiles(updated, state.activeProfileId);

    if (id == state.activeProfileId) {
      final active = updated.firstWhere((p) => p.id == id);
      _syncToOnboarding(active);
    }
  }

  /// Deletes a non-default profile (Task 12.5).
  Future<bool> deleteProfile(String id) async {
    final target = state.profiles.firstWhere((p) => p.id == id, orElse: () => state.activeProfile);
    if (target.isDefault || state.profiles.length <= 1) {
      return false; // Cannot delete default or the last remaining profile
    }

    final updated = state.profiles.where((p) => p.id != id).toList();
    var newActiveId = state.activeProfileId;

    // If deleted profile was currently active, switch to default profile
    if (newActiveId == id) {
      final defaultProfile = updated.firstWhere((p) => p.isDefault, orElse: () => updated.first);
      newActiveId = defaultProfile.id;
      _syncToOnboarding(defaultProfile);
    }

    state = state.copyWith(profiles: updated, activeProfileId: newActiveId);
    _persistProfiles(updated, newActiveId);
    return true;
  }

  void _syncToOnboarding(ProfileModel profile) {
    final onboarding = ref.read(onboardingProvider.notifier);
    onboarding.setUserName(profile.name);
    onboarding.setProfilePic(profile.avatarBase64);
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
