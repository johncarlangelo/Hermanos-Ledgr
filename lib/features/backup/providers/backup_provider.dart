import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/backup/data/backup_service.dart';
import 'package:hermanos_ledgr/features/backup/data/backup_storage_service.dart';
import 'package:hermanos_ledgr/features/backup/data/csv_export_service.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_entry.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_validation_result.dart';
import 'package:hermanos_ledgr/features/budget/providers/mock_budgets_provider.dart';
import 'package:hermanos_ledgr/features/dashboard/providers/dashboard_provider.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';

class BackupState {
  final bool isAutoBackupEnabled;
  final DateTime? lastAutoBackupTime;
  final List<BackupEntry> localBackups;
  final bool isLoading;
  final String? statusMessage;
  final String? errorMessage;

  const BackupState({
    this.isAutoBackupEnabled = true,
    this.lastAutoBackupTime,
    this.localBackups = const [],
    this.isLoading = false,
    this.statusMessage,
    this.errorMessage,
  });

  BackupState copyWith({
    bool? isAutoBackupEnabled,
    DateTime? lastAutoBackupTime,
    List<BackupEntry>? localBackups,
    bool? isLoading,
    String? statusMessage,
    String? errorMessage,
    bool clearStatus = false,
    bool clearError = false,
  }) {
    return BackupState(
      isAutoBackupEnabled: isAutoBackupEnabled ?? this.isAutoBackupEnabled,
      lastAutoBackupTime: lastAutoBackupTime ?? this.lastAutoBackupTime,
      localBackups: localBackups ?? this.localBackups,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

final backupStorageServiceProvider = Provider<BackupStorageService>((ref) {
  return BackupStorageService();
});

class BackupNotifier extends Notifier<BackupState> {
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _lastAutoBackupTimeKey = 'last_auto_backup_time';

  @override
  BackupState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final enabled = prefs.getBool(_autoBackupEnabledKey) ?? true;
    final lastTimeStr = prefs.getString(_lastAutoBackupTimeKey);
    final lastTime = lastTimeStr != null ? DateTime.tryParse(lastTimeStr) : null;

    // Load local backups asynchronously
    Future.microtask(() => refreshLocalBackups());

    return BackupState(
      isAutoBackupEnabled: enabled,
      lastAutoBackupTime: lastTime,
    );
  }

  BackupService get _backupService => ref.read(backupServiceProvider);
  BackupStorageService get _storageService => ref.read(backupStorageServiceProvider);

  /// Reloads local backup files from disk.
  Future<void> refreshLocalBackups() async {
    try {
      final list = await _storageService.listBackups();
      state = state.copyWith(localBackups: list);
    } catch (e) {
      debugPrint('Error listing local backups: $e');
    }
  }

  /// Toggles automatic daily backup preference (Task 11.3).
  Future<void> toggleAutoBackup(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_autoBackupEnabledKey, enabled);
    state = state.copyWith(isAutoBackupEnabled: enabled);
  }

  /// Checks if daily backup should run on app launch (Tasks 11.3, 11.6).
  Future<bool> checkAndRunDailyAutoBackup() async {
    if (!state.isAutoBackupEnabled) return false;

    final now = DateTime.now();
    final last = state.lastAutoBackupTime;

    // Check if backup has already been performed today
    if (last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day) {
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final json = await _backupService.serializeDatabaseToJson();
      await _storageService.saveAutoBackup(json);

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_lastAutoBackupTimeKey, now.toIso8601String());

      final updatedList = await _storageService.listBackups();
      state = state.copyWith(
        isLoading: false,
        lastAutoBackupTime: now,
        localBackups: updatedList,
        statusMessage: 'Daily auto-backup created',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Auto-backup failed: $e',
      );
      return false;
    }
  }

  /// Creates a manual full database JSON backup, saves to device, and optionally triggers share sheet (Tasks 11.1, 11.4).
  Future<File?> createManualBackup({bool openShareSheet = true}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true, clearStatus: true);
      final json = await _backupService.serializeDatabaseToJson();
      final file = await _storageService.saveManualBackup(json);

      if (openShareSheet) {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Hermanos Ledgr Full Database Backup (${DateTime.now().toIso8601String().split('T').first})',
          subject: 'Hermanos Ledgr Backup',
        );
      }

      await refreshLocalBackups();
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Backup saved successfully',
      );
      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Manual backup failed: $e',
      );
      return null;
    }
  }

  /// Exports transactions to a CSV file and triggers the share sheet (Task 11.2, 11.4).
  Future<File?> exportTransactionsCsv({bool openShareSheet = true}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final txs = ref.read(transactionsProvider);
      final csvContent = CsvExportService.generateTransactionsCsv(txs);

      final dir = await _storageService.getBackupDirectory();
      final nowStr = DateTime.now().toIso8601String().split('T').first;
      final file = File('${dir.path}/transactions_$nowStr.csv');
      await file.writeAsString(csvContent);

      if (openShareSheet) {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Hermanos Ledgr Transactions CSV Export ($nowStr)',
          subject: 'Transactions CSV Export',
        );
      }

      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Transactions exported to CSV',
      );
      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'CSV export failed: $e',
      );
      return null;
    }
  }

  /// Validates a raw JSON backup string before restoring (Task 11.5).
  BackupValidationResult validateBackupJson(String rawJson) {
    return _backupService.validateBackupJson(rawJson);
  }

  /// Restores full ledger database from a raw JSON string (Task 11.5).
  Future<Map<String, int>> restoreFromJson(
    String rawJson, {
    bool replaceExisting = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true, clearStatus: true);
      final counts = await _backupService.restoreDatabaseFromJson(
        rawJson,
        replaceExisting: replaceExisting,
      );

      // Invalidate all reactive UI providers to force immediate database re-read
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(goalsProvider);
      ref.invalidate(debtsProvider);
      ref.invalidate(recurringProvider);
      ref.invalidate(dashboardProvider);

      await refreshLocalBackups();
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Ledger restored successfully (${counts['transactions']} transactions)',
      );
      return counts;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Restoration failed: $e',
      );
      rethrow;
    }
  }

  /// Restores from a local backup file.
  Future<Map<String, int>> restoreFromFile(
    String filePath, {
    bool replaceExisting = true,
  }) async {
    final content = await _storageService.readBackupContent(filePath);
    return restoreFromJson(content, replaceExisting: replaceExisting);
  }

  /// Deletes a local backup file.
  Future<bool> deleteBackup(String filePath) async {
    final success = await _storageService.deleteBackup(filePath);
    if (success) {
      await refreshLocalBackups();
    }
    return success;
  }
}

final backupProvider = NotifierProvider<BackupNotifier, BackupState>(
  BackupNotifier.new,
);
