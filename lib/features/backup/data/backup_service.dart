import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_manifest.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_validation_result.dart';

/// Full database backup and restore service (Tasks 11.1, 11.5).
class BackupService {
  final AppDatabase _db;

  const BackupService(this._db);

  /// Serializes the entire Drift SQLite database into a structured JSON string.
  Future<String> serializeDatabaseToJson() async {
    final accounts = await _db.select(_db.accountsTable).get();
    final transactions = await _db.select(_db.transactionsTable).get();
    final categories = await _db.select(_db.categoriesTable).get();
    final budgets = await _db.select(_db.budgetsTable).get();
    final goals = await _db.select(_db.goalsTable).get();
    final debts = await _db.select(_db.debtsTable).get();
    final recurring = await _db.select(_db.recurringTransactionsTable).get();
    final chatMessages = await _db.select(_db.chatMessagesTable).get();
    final notes = await _db.select(_db.notesTable).get();

    final manifest = BackupManifest(
      exportDate: DateTime.now(),
      app: AppConstants.appName,
      schemaVersion: _db.schemaVersion,
      appVersion: AppConstants.appVersion,
      appBuildNumber: AppConstants.appBuildNumber,
      accountsCount: accounts.length,
      transactionsCount: transactions.length,
      categoriesCount: categories.length,
      budgetsCount: budgets.length,
      goalsCount: goals.length,
      debtsCount: debts.length,
      recurringCount: recurring.length,
      chatMessagesCount: chatMessages.length,
    );

    final payload = {
      'manifest': manifest.toJson(),
      'exportDate': manifest.exportDate.toIso8601String(),
      'app': manifest.app,
      'appVersion': manifest.appVersion,
      'accountsCount': accounts.length,
      'transactionsCount': transactions.length,
      'accounts': accounts
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'type': a.type,
                'balance': a.balance,
                'iconCode': a.iconCode,
                'colorValue': a.colorValue,
                'institution': a.institution,
                'monthlyChange': a.monthlyChange,
              })
          .toList(),
      'transactions': transactions
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'amount': t.amount,
                'type': t.type,
                'categoryId': t.categoryId,
                'categoryName': t.categoryName,
                'categoryIconCode': t.categoryIconCode,
                'categoryColorValue': t.categoryColorValue,
                'accountId': t.accountId,
                'accountName': t.accountName,
                'destinationAccountId': t.destinationAccountId,
                'destinationAccountName': t.destinationAccountName,
                'date': t.date.toIso8601String(),
                'note': t.note,
                'receiptImagePath': t.receiptImagePath,
              })
          .toList(),
      'categories': categories
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'iconCode': c.iconCode,
                'colorValue': c.colorValue,
                'isExpense': c.isExpense,
                'isCustom': c.isCustom,
              })
          .toList(),
      'budgets': budgets
          .map((b) => {
                'id': b.id,
                'categoryId': b.categoryId,
                'categoryName': b.categoryName,
                'monthlyLimit': b.monthlyLimit,
                'month': b.month,
                'year': b.year,
              })
          .toList(),
      'goals': goals
          .map((g) => {
                'id': g.id,
                'name': g.name,
                'targetAmount': g.targetAmount,
                'currentAmount': g.currentAmount,
                'targetDate': g.targetDate?.toIso8601String(),
                'iconCode': g.iconCode,
                'colorValue': g.colorValue,
                'isCompleted': g.isCompleted,
              })
          .toList(),
      'debts': debts
          .map((d) => {
                'id': d.id,
                'type': d.type,
                'personName': d.personName,
                'originalAmount': d.originalAmount,
                'remainingAmount': d.remainingAmount,
                'note': d.note,
                'dueDate': d.dueDate?.toIso8601String(),
                'isSettled': d.isSettled,
                'createdAt': d.createdAt.toIso8601String(),
              })
          .toList(),
      'recurring': recurring
          .map((r) => {
                'id': r.id,
                'title': r.title,
                'amount': r.amount,
                'type': r.type,
                'categoryId': r.categoryId,
                'categoryName': r.categoryName,
                'accountId': r.accountId,
                'accountName': r.accountName,
                'frequency': r.frequency,
                'startDate': r.startDate.toIso8601String(),
                'nextDueDate': r.nextDueDate.toIso8601String(),
                'isActive': r.isActive,
              })
          .toList(),
      'chatMessages': chatMessages
          .map((m) => {
                'id': m.id,
                'content': m.content,
                'isUser': m.isUser,
                'timestamp': m.timestamp.toIso8601String(),
                'parsedTxJson': m.parsedTxJson,
                'isConfirmed': m.isConfirmed,
                'intent': m.intent,
              })
          .toList(),
      'notes': notes
          .map((n) => {
                'id': n.id,
                'profileId': n.profileId,
                'content': n.content,
                'tag': n.tag,
                'amount': n.amount,
                'isDone': n.isDone,
                'createdAt': n.createdAt.toIso8601String(),
                'updatedAt': n.updatedAt.toIso8601String(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Validates a raw JSON string to verify whether it contains a restorable backup.
  BackupValidationResult validateBackupJson(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) {
      return const BackupValidationResult(
        isValid: false,
        errorMessage: 'Backup content is empty.',
      );
    }

    try {
      final decoded = jsonDecode(trimmed);

      if (decoded is List) {
        // Legacy or simple list of transaction maps
        final txs = decoded.whereType<Map<String, dynamic>>().toList();
        if (txs.isEmpty) {
          return const BackupValidationResult(
            isValid: false,
            errorMessage: 'JSON list contains no valid transaction objects.',
          );
        }
        return BackupValidationResult(
          isValid: true,
          detectedTransactions: txs.length,
          parsedJson: {'transactions': txs},
        );
      }

      if (decoded is! Map<String, dynamic>) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Expected JSON object for ledger backup.',
        );
      }

      BackupManifest? manifest;
      if (decoded.containsKey('manifest') && decoded['manifest'] is Map) {
        try {
          manifest = BackupManifest.fromJson(
            Map<String, dynamic>.from(decoded['manifest'] as Map),
          );
        } catch (_) {}
      }

      final txList = decoded['transactions'] is List
          ? (decoded['transactions'] as List).whereType<Map>().toList()
          : [];
      final accList = decoded['accounts'] is List
          ? (decoded['accounts'] as List).whereType<Map>().toList()
          : [];
      final catList = decoded['categories'] is List
          ? (decoded['categories'] as List).whereType<Map>().toList()
          : [];
      final budList = decoded['budgets'] is List
          ? (decoded['budgets'] as List).whereType<Map>().toList()
          : [];
      final goalList = decoded['goals'] is List
          ? (decoded['goals'] as List).whereType<Map>().toList()
          : [];
      final debtList = decoded['debts'] is List
          ? (decoded['debts'] as List).whereType<Map>().toList()
          : [];
      final recurList = decoded['recurring'] is List
          ? (decoded['recurring'] as List).whereType<Map>().toList()
          : [];
      final chatList = decoded['chatMessages'] is List
          ? (decoded['chatMessages'] as List).whereType<Map>().toList()
          : [];

      if (txList.isEmpty && accList.isEmpty && debtList.isEmpty && goalList.isEmpty) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'No accounts, transactions, or ledger records found in backup.',
        );
      }

      return BackupValidationResult(
        isValid: true,
        manifest: manifest,
        detectedTransactions: txList.length,
        detectedAccounts: accList.length,
        detectedCategories: catList.length,
        detectedBudgets: budList.length,
        detectedGoals: goalList.length,
        detectedDebts: debtList.length,
        detectedRecurring: recurList.length,
        detectedChatMessages: chatList.length,
        parsedJson: decoded,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'Invalid JSON syntax: ${e.toString().split('\n').first}',
      );
    }
  }

  /// Restores database state from a validated JSON string atomically (Task 11.5).
  Future<Map<String, int>> restoreDatabaseFromJson(
    String rawJson, {
    bool replaceExisting = true,
  }) async {
    final validation = validateBackupJson(rawJson);
    if (!validation.isValid || validation.parsedJson == null) {
      throw FormatException(
        validation.errorMessage ?? 'Invalid backup payload for restoration.',
      );
    }

    final data = validation.parsedJson!;
    final restoredCounts = <String, int>{
      'accounts': 0,
      'transactions': 0,
      'categories': 0,
      'budgets': 0,
      'goals': 0,
      'debts': 0,
      'recurring': 0,
      'chatMessages': 0,
      'notes': 0,
    };

    await _db.transaction(() async {
      if (replaceExisting) {
        // Clear all dependent tables first
        await _db.delete(_db.notesTable).go();
        await _db.delete(_db.chatMessagesTable).go();
        await _db.delete(_db.recurringTransactionsTable).go();
        await _db.delete(_db.debtsTable).go();
        await _db.delete(_db.goalsTable).go();
        await _db.delete(_db.budgetsTable).go();
        await _db.delete(_db.transactionsTable).go();
        await _db.delete(_db.accountsTable).go();
      }

      // 1. Restore Accounts
      if (data['accounts'] is List) {
        for (final raw in (data['accounts'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['name'] != null) {
            await _db.into(_db.accountsTable).insert(
                  AccountsTableCompanion.insert(
                    id: m['id'].toString(),
                    name: m['name'].toString(),
                    type: m['type']?.toString() ?? 'bank',
                    balance: (m['balance'] as num?)?.toDouble() ?? 0.0,
                    iconCode: (m['iconCode'] as num?)?.toInt() ?? 0xe3f8,
                    colorValue: (m['colorValue'] as num?)?.toInt() ?? 0xFF00897B,
                    institution: m['institution']?.toString() ?? '',
                    monthlyChange: drift.Value((m['monthlyChange'] as num?)?.toDouble() ?? 0.0),
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['accounts'] = (restoredCounts['accounts'] ?? 0) + 1;
          }
        }
      }

      // 2. Restore Categories (if custom)
      if (data['categories'] is List) {
        for (final raw in (data['categories'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['name'] != null) {
            await _db.into(_db.categoriesTable).insert(
                  CategoriesTableCompanion.insert(
                    id: m['id'].toString(),
                    name: m['name'].toString(),
                    iconCode: (m['iconCode'] as num?)?.toInt() ?? 0xe148,
                    colorValue: (m['colorValue'] as num?)?.toInt() ?? 0xFF00897B,
                    isExpense: drift.Value(m['isExpense'] == true),
                    isCustom: drift.Value(m['isCustom'] == true),
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['categories'] = (restoredCounts['categories'] ?? 0) + 1;
          }
        }
      }

      // 3. Restore Transactions
      if (data['transactions'] is List) {
        for (final raw in (data['transactions'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['amount'] != null) {
            final date = m['date'] != null
                ? DateTime.tryParse(m['date'].toString()) ?? DateTime.now()
                : DateTime.now();

            await _db.into(_db.transactionsTable).insert(
                  TransactionsTableCompanion.insert(
                    id: m['id'].toString(),
                    title: m['title']?.toString() ?? 'Transaction',
                    amount: (m['amount'] as num).toDouble(),
                    type: m['type']?.toString() ?? 'expense',
                    categoryId: m['categoryId']?.toString() ?? 'other_expense',
                    categoryName: m['categoryName']?.toString() ?? 'Other',
                    categoryIconCode: (m['categoryIconCode'] as num?)?.toInt() ?? 0xe148,
                    categoryColorValue: (m['categoryColorValue'] as num?)?.toInt() ?? 0xFF757575,
                    accountId: m['accountId']?.toString() ?? 'cash',
                    accountName: m['accountName']?.toString() ?? 'Cash',
                    destinationAccountId: drift.Value(m['destinationAccountId']?.toString()),
                    destinationAccountName: drift.Value(m['destinationAccountName']?.toString()),
                    date: date,
                    note: drift.Value(m['note']?.toString()),
                    receiptImagePath: drift.Value(m['receiptImagePath']?.toString()),
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['transactions'] = (restoredCounts['transactions'] ?? 0) + 1;
          }
        }
      }

      // 4. Restore Budgets
      if (data['budgets'] is List) {
        for (final raw in (data['budgets'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['monthlyLimit'] != null) {
            await _db.into(_db.budgetsTable).insert(
                  BudgetsTableCompanion.insert(
                    id: m['id'].toString(),
                    categoryId: m['categoryId']?.toString() ?? '',
                    categoryName: m['categoryName']?.toString() ?? '',
                    monthlyLimit: (m['monthlyLimit'] as num).toDouble(),
                    month: (m['month'] as num?)?.toInt() ?? DateTime.now().month,
                    year: (m['year'] as num?)?.toInt() ?? DateTime.now().year,
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['budgets'] = (restoredCounts['budgets'] ?? 0) + 1;
          }
        }
      }

      // 5. Restore Goals
      if (data['goals'] is List) {
        for (final raw in (data['goals'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['name'] != null) {
            final tDate = m['targetDate'] != null
                ? DateTime.tryParse(m['targetDate'].toString())
                : null;
            await _db.into(_db.goalsTable).insert(
                  GoalsTableCompanion.insert(
                    id: m['id'].toString(),
                    name: m['name'].toString(),
                    targetAmount: (m['targetAmount'] as num?)?.toDouble() ?? 0.0,
                    currentAmount: drift.Value((m['currentAmount'] as num?)?.toDouble() ?? 0.0),
                    targetDate: drift.Value(tDate),
                    iconCode: drift.Value((m['iconCode'] as num?)?.toInt()),
                    colorValue: drift.Value((m['colorValue'] as num?)?.toInt()),
                    isCompleted: drift.Value(m['isCompleted'] == true),
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['goals'] = (restoredCounts['goals'] ?? 0) + 1;
          }
        }
      }

      // 6. Restore Debts
      if (data['debts'] is List) {
        for (final raw in (data['debts'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['personName'] != null) {
            final dDate = m['dueDate'] != null
                ? DateTime.tryParse(m['dueDate'].toString())
                : null;
            final cDate = m['createdAt'] != null
                ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now();

            await _db.into(_db.debtsTable).insert(
                  DebtsTableCompanion.insert(
                    id: m['id'].toString(),
                    type: m['type']?.toString() ?? 'debt',
                    personName: m['personName'].toString(),
                    originalAmount: (m['originalAmount'] as num?)?.toDouble() ?? 0.0,
                    remainingAmount: (m['remainingAmount'] as num?)?.toDouble() ?? 0.0,
                    note: drift.Value(m['note']?.toString()),
                    dueDate: drift.Value(dDate),
                    isSettled: drift.Value(m['isSettled'] == true),
                    createdAt: cDate,
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['debts'] = (restoredCounts['debts'] ?? 0) + 1;
          }
        }
      }

      // 7. Restore Recurring Rules
      if (data['recurring'] is List) {
        for (final raw in (data['recurring'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['title'] != null) {
            final sDate = m['startDate'] != null
                ? DateTime.tryParse(m['startDate'].toString()) ?? DateTime.now()
                : DateTime.now();
            final nDate = m['nextDueDate'] != null
                ? DateTime.tryParse(m['nextDueDate'].toString()) ?? DateTime.now()
                : DateTime.now();

            await _db.into(_db.recurringTransactionsTable).insert(
                  RecurringTransactionsTableCompanion.insert(
                    id: m['id'].toString(),
                    title: m['title'].toString(),
                    amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
                    type: m['type']?.toString() ?? 'expense',
                    categoryId: m['categoryId']?.toString() ?? 'other_expense',
                    categoryName: m['categoryName']?.toString() ?? 'Other',
                    accountId: m['accountId']?.toString() ?? 'cash',
                    accountName: m['accountName']?.toString() ?? 'Cash',
                    frequency: m['frequency']?.toString() ?? 'monthly',
                    startDate: sDate,
                    nextDueDate: nDate,
                    isActive: drift.Value(m['isActive'] != false),
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['recurring'] = (restoredCounts['recurring'] ?? 0) + 1;
          }
        }
      }

      // 8. Restore Chat Messages
      if (data['chatMessages'] is List) {
        for (final raw in (data['chatMessages'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id'] != null && m['content'] != null) {
            final ts = m['timestamp'] != null
                ? DateTime.tryParse(m['timestamp'].toString()) ?? DateTime.now()
                : DateTime.now();

            await _db.into(_db.chatMessagesTable).insert(
                  ChatMessagesTableCompanion.insert(
                    id: m['id'].toString(),
                    content: m['content'].toString(),
                    isUser: m['isUser'] == true,
                    timestamp: ts,
                    parsedTxJson: drift.Value(m['parsedTxJson']?.toString()),
                    isConfirmed: drift.Value(m['isConfirmed'] == true),
                    intent: drift.Value(m['intent']?.toString()),
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['chatMessages'] = (restoredCounts['chatMessages'] ?? 0) + 1;
          }
        }
      }

      // 9. Restore Quick Notes (Task 12.7)
      if (data['notes'] is List) {
        for (final raw in (data['notes'] as List).whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          if (m['content'] != null) {
            final cDate = m['createdAt'] != null
                ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now();
            final uDate = m['updatedAt'] != null
                ? DateTime.tryParse(m['updatedAt'].toString()) ?? cDate
                : cDate;

            await _db.into(_db.notesTable).insert(
                  NotesTableCompanion.insert(
                    profileId: drift.Value(m['profileId']?.toString() ?? 'default'),
                    content: m['content'].toString(),
                    tag: drift.Value(m['tag']?.toString()),
                    amount: drift.Value((m['amount'] as num?)?.toDouble()),
                    isDone: drift.Value(m['isDone'] == true),
                    createdAt: cDate,
                    updatedAt: uDate,
                  ),
                  mode: drift.InsertMode.insertOrReplace,
                );
            restoredCounts['notes'] = (restoredCounts['notes'] ?? 0) + 1;
          }
        }
      }
    });

    return restoredCounts;
  }
}
