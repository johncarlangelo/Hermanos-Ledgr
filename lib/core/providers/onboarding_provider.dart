import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingKey = 'has_completed_onboarding';
const _kUserNameKey = 'user_display_name';

class OnboardingState {
  final bool isCompleted;
  final bool isLoading;
  final String userName;
  final List<String> selectedStarterAccounts;

  const OnboardingState({
    required this.isCompleted,
    this.isLoading = true,
    this.userName = 'John C.',
    this.selectedStarterAccounts = const ['GCash', 'Cash Wallet', 'BDO Savings'],
  });

  OnboardingState copyWith({
    bool? isCompleted,
    bool? isLoading,
    String? userName,
    List<String>? selectedStarterAccounts,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      selectedStarterAccounts:
          selectedStarterAccounts ?? this.selectedStarterAccounts,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    _init();
    return const OnboardingState(isCompleted: false, isLoading: true);
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool(_kOnboardingKey) ?? false;
      final userName = prefs.getString(_kUserNameKey) ?? 'John C.';
      state = state.copyWith(
        isCompleted: isCompleted,
        isLoading: false,
        userName: userName,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim().isEmpty ? 'John C.' : name.trim();
    state = state.copyWith(userName: trimmed);
    try {
      final prefs = await SharedPreferences.getInstance();
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

  Future<void> completeOnboarding() async {
    state = state.copyWith(isCompleted: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingKey, true);
      await prefs.setString(_kUserNameKey, state.userName);
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    state = state.copyWith(isCompleted: false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kOnboardingKey);
    } catch (_) {}
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
