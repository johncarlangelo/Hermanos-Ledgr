import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';

const _kOnboardingKey = 'has_completed_onboarding';
const _kUserNameKey = 'user_display_name';

class OnboardingState {
  final bool isCompleted;
  final bool isLoading;
  final String userName;
  final List<String> selectedStarterAccounts;
  final String customAccountName;
  final String customAccountType;

  const OnboardingState({
    required this.isCompleted,
    this.isLoading = false,
    this.userName = 'John C.',
    this.selectedStarterAccounts = const ['GCash', 'Cash Wallet', 'BDO Savings'],
    this.customAccountName = '',
    this.customAccountType = 'bank',
  });

  OnboardingState copyWith({
    bool? isCompleted,
    bool? isLoading,
    String? userName,
    List<String>? selectedStarterAccounts,
    String? customAccountName,
    String? customAccountType,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      selectedStarterAccounts:
          selectedStarterAccounts ?? this.selectedStarterAccounts,
      customAccountName: customAccountName ?? this.customAccountName,
      customAccountType: customAccountType ?? this.customAccountType,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isCompleted = prefs.getBool(_kOnboardingKey) ?? false;
    final userName = prefs.getString(_kUserNameKey) ?? 'John C.';
    return OnboardingState(
      isCompleted: isCompleted,
      isLoading: false,
      userName: userName,
    );
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim().isEmpty ? 'John C.' : name.trim();
    state = state.copyWith(userName: trimmed);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_kUserNameKey, trimmed);
    } catch (_) {}
  }

  void toggleStarterAccount(String account) {
    final list = List<String>.from(state.selectedStarterAccounts);
    if (list.contains(account)) {
      if (list.length > 1) {
        list.remove(account);
      }
    } else {
      list.add(account);
    }
    state = state.copyWith(selectedStarterAccounts: list);
  }

  void setCustomAccountName(String name) {
    state = state.copyWith(customAccountName: name);
  }

  void setCustomAccountType(String type) {
    state = state.copyWith(customAccountType: type);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isCompleted: true);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_kOnboardingKey, true);
      await prefs.setString(_kUserNameKey, state.userName);
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    state = state.copyWith(isCompleted: false);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_kOnboardingKey, false);
    } catch (_) {}
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
