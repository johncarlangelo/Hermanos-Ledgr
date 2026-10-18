import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/data/model_manager.dart';
import 'package:hermanos_ledgr/features/notes/domain/note_model.dart';
import 'package:hermanos_ledgr/features/notes/presentation/screens/quick_notes_screen.dart';
import 'package:hermanos_ledgr/features/notes/providers/notes_provider.dart';
import 'package:hermanos_ledgr/features/profile/presentation/widgets/profile_manager_sheet.dart';
import 'package:hermanos_ledgr/features/profile/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    setGlobalSharedPreferences(prefs);
  });

  group('Profile CRUD & Multi-Profile Support (Task 12.5)', () {
    test('Initializes with default profile seeded from user name', () async {
      final container = ProviderContainer(
        overrides: [
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier('Carl A.')),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(profileNotifierProvider);
      expect(state.profiles.length, equals(1));
      expect(state.activeProfile.name, equals('Carl A.'));
      expect(state.activeProfile.isDefault, isTrue);
    });

    test('Creates new profile, switches to it, and updates identity', () async {
      final container = ProviderContainer(
        overrides: [
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier('Default User')),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(profileNotifierProvider.notifier);

      // 1. Create a Freelance profile
      final created = await notifier.createProfile(
        name: 'Freelance & Business',
        colorValue: 0xFF1976D2,
        switchToNew: true,
      );

      var state = container.read(profileNotifierProvider);
      expect(state.profiles.length, equals(2));
      expect(state.activeProfileId, equals(created.id));
      expect(state.activeProfile.name, equals('Freelance & Business'));

      // 2. Update profile name
      await notifier.updateProfile(
        id: created.id,
        name: 'Consulting Pro',
      );

      state = container.read(profileNotifierProvider);
      expect(state.activeProfile.name, equals('Consulting Pro'));

      // 3. Switch back to default profile
      final defaultProfile = state.profiles.firstWhere((p) => p.isDefault);
      await notifier.switchProfile(defaultProfile.id);

      state = container.read(profileNotifierProvider);
      expect(state.activeProfileId, equals(defaultProfile.id));
      expect(state.activeProfile.name, equals('Default User'));

      // 4. Delete the custom profile
      final deleteSuccess = await notifier.deleteProfile(created.id);
      expect(deleteSuccess, isTrue);

      state = container.read(profileNotifierProvider);
      expect(state.profiles.length, equals(1));
      expect(state.profiles.any((p) => p.id == created.id), isFalse);

      // Cannot delete default profile
      final deleteDefaultSuccess = await notifier.deleteProfile(defaultProfile.id);
      expect(deleteDefaultSuccess, isFalse);
    });
  });

  group('LLM Model Management UI Logic (Task 12.6)', () {
    test('Contains valid multi-model specs with download URLs and quant levels', () {
      final models = ModelManager.availableModels;
      expect(models.length, greaterThanOrEqualTo(3));

      final qwen05 = models.firstWhere((m) => m.id == 'qwen_0_5b');
      expect(qwen05.displayName, contains('Qwen 2.5 0.5B'));
      expect(qwen05.isRecommended, isTrue);
      expect(qwen05.quantization, equals('Q4_K_M'));

      final smol = models.firstWhere((m) => m.id == 'smollm2_360m');
      expect(smol.displayName, contains('SmolLM2'));
      expect(smol.parameterSize, equals('360M'));
    });

    test('Switches active model ID and persists across invocations', () async {
      final manager = ModelManager();
      expect(await manager.getActiveModelId(), equals('qwen_0_5b'));

      await manager.setActiveModelId('smollm2_360m');
      expect(await manager.getActiveModelId(), equals('smollm2_360m'));

      final activeSpec = await manager.getActiveModelSpec();
      expect(activeSpec.displayName, contains('SmolLM2'));
    });
  });

  group('Quick Notes Screen & Amount Extractor (Task 12.7)', () {
    test('Extracts amounts accurately from natural note text', () {
      expect(NotesNotifier.extractAmount('Bought fruits at market ₱240.50'), equals(240.50));
      expect(NotesNotifier.extractAmount('Coffee 150 GCash'), equals(150.0));
      expect(NotesNotifier.extractAmount('Pay rent 15k'), equals(15000.0));
      expect(NotesNotifier.extractAmount('Electric bill ₱2,450 pesos'), equals(2450.0));
      expect(NotesNotifier.extractAmount('Remember to call mom'), isNull);
    });

    test('Inserts, toggles completion, and queries notes via SQLite DAO', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier('Tester')),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(db.close);

      final notifier = container.read(notesNotifierProvider.notifier);
      final id = await notifier.addNote(
        content: 'Dentist appointment ₱1200',
        tag: 'Expense',
        amount: 1200.0,
      );

      final dao = container.read(notesDaoProvider);
      var notes = await dao.getAllNotes();
      expect(notes.length, equals(1));
      expect(notes.first.id, equals(id));
      expect(notes.first.content, equals('Dentist appointment ₱1200'));
      expect(notes.first.amount, equals(1200.0));
      expect(notes.first.isDone, isFalse);

      // Toggle done
      await notifier.toggleDone(id, true);
      notes = await dao.getAllNotes();
      expect(notes.first.isDone, isTrue);

      // Delete note
      await notifier.deleteNote(id);
      notes = await dao.getAllNotes();
      expect(notes.isEmpty, isTrue);
    });

    testWidgets('QuickNotesScreen mounts and displays empty state and controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            notesStreamProvider.overrideWith((ref) => Stream.value(<NoteModel>[])),
            onboardingProvider.overrideWith(() => _MockOnboardingNotifier('Tester')),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const QuickNotesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Notes & Scratchpad'), findsOneWidget);
      expect(find.text('Scratchpad is Empty'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Add Note'), findsOneWidget);
    });

    testWidgets('ProfileManagerSheet mounts with profile list and action buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingProvider.overrideWith(() => _MockOnboardingNotifier('John Angelo')),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const Scaffold(
              body: ProfileManagerSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile Manager'), findsOneWidget);
      expect(find.text('John Angelo'), findsOneWidget);
      expect(find.text('Active Profile'), findsOneWidget);
      expect(find.text('Add Another Profile'), findsOneWidget);
    });
  });
}

class _MockOnboardingNotifier extends OnboardingNotifier {
  final String _name;
  _MockOnboardingNotifier(this._name);

  @override
  OnboardingState build() => OnboardingState(
        isCompleted: true,
        userName: _name,
      );
}
