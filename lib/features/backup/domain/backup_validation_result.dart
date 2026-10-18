import 'package:hermanos_ledgr/features/backup/domain/backup_manifest.dart';

/// Result of validating a backup JSON payload (Task 11.5).
class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final BackupManifest? manifest;
  final int detectedTransactions;
  final int detectedAccounts;
  final int detectedBudgets;
  final int detectedGoals;
  final int detectedDebts;
  final int detectedRecurring;
  final int detectedCategories;
  final int detectedChatMessages;
  final Map<String, dynamic>? parsedJson;

  const BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.manifest,
    this.detectedTransactions = 0,
    this.detectedAccounts = 0,
    this.detectedBudgets = 0,
    this.detectedGoals = 0,
    this.detectedDebts = 0,
    this.detectedRecurring = 0,
    this.detectedCategories = 0,
    this.detectedChatMessages = 0,
    this.parsedJson,
  });

  int get totalRecords =>
      detectedTransactions +
      detectedAccounts +
      detectedBudgets +
      detectedGoals +
      detectedDebts +
      detectedRecurring +
      detectedCategories +
      detectedChatMessages;
}
