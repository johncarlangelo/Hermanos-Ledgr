import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/backup/data/backup_service.dart';
import 'package:hermanos_ledgr/features/backup/data/backup_storage_service.dart';
import 'package:hermanos_ledgr/features/backup/data/csv_export_service.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

void main() {
  group('CsvExportService (Task 11.2)', () {
    test('Correctly escapes and exports transactions to CSV', () {
      final txs = [
        TransactionModel(
          id: 'tx_1',
          title: 'Grocery, "Market" & Food',
          amount: 1250.50,
          type: TransactionType.expense,
          categoryId: 'groceries',
          categoryName: 'Groceries',
          categoryIcon: const IconData(0xe148, fontFamily: 'MaterialIcons'),
          categoryColor: const Color(0xFF43A047),
          accountId: 'gcash',
          accountName: 'GCash',
          date: DateTime(2026, 10, 15, 14, 30),
          note: 'Line 1\nLine 2 with "quotes"',
        ),
      ];

      final csv = CsvExportService.generateTransactionsCsv(txs);

      expect(csv, contains('ID,Date,Title,Type,Category,Account,DestinationAccount,Amount,Note'));
      expect(csv, contains('tx_1'));
      expect(csv, contains('"Grocery, ""Market"" & Food"'));
      expect(csv, contains('1250.50'));
      expect(csv, contains('"Line 1\nLine 2 with ""quotes"""'));
    });

    test('Correctly exports accounts to CSV', () {
      final accs = [
        const AccountModel(
          id: 'acc_bdo',
          name: 'BDO Savings, Main',
          type: AccountType.bank,
          balance: 55000.75,
          icon: IconData(0xe3f8, fontFamily: 'MaterialIcons'),
          color: Color(0xFF00897B),
          institution: 'BDO Unibank',
          monthlyChange: 1200.0,
        ),
      ];

      final csv = CsvExportService.generateAccountsCsv(accs);

      expect(csv, contains('ID,Name,Type,Institution,Balance,MonthlyChange'));
      expect(csv, contains('acc_bdo'));
      expect(csv, contains('"BDO Savings, Main"'));
      expect(csv, contains('55000.75'));
    });
  });

  group('BackupStorageService & 7-Backup Retention (Task 11.3, 11.6)', () {
    late Directory tempDir;
    late BackupStorageService storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ledgr_backup_test_');
      storage = BackupStorageService(tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Saves auto backups and prunes oldest when exceeding 7', () async {
      // Create 10 mock auto-backups with staggered timestamps
      for (int i = 0; i < 10; i++) {
        final content = jsonEncode({
          'transactionsCount': i + 1,
          'accountsCount': 1,
        });
        final file = File('${tempDir.path}/auto_backup_2026_10_${(10 + i).toString().padLeft(2, '0')}_120000.json');
        await file.writeAsString(content);
        // Small delay to ensure modified timestamps differ
        await Future.delayed(const Duration(milliseconds: 10));
      }

      var list = await storage.listBackups();
      expect(list.length, equals(10));

      // Trigger retention pruning (keepLast: 7)
      final pruned = await storage.pruneAutoBackups(keepLast: 7);
      expect(pruned, equals(3));

      list = await storage.listBackups();
      expect(list.length, equals(7));

      // Verify that newest backups were retained
      expect(list.first.fileName, contains('auto_backup_2026_10_19'));
    });

    test('Deletes a specific backup file', () async {
      final file = await storage.saveManualBackup('{"test": true}', customName: 'delete_me');
      expect(await file.exists(), isTrue);

      final success = await storage.deleteBackup(file.path);
      expect(success, isTrue);
      expect(await file.exists(), isFalse);
    });
  });

  group('BackupService Full Serialization & Restoration (Task 11.1, 11.5)', () {
    late AppDatabase db;
    late BackupService backupService;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      backupService = BackupService(db);

      // Seed sample account and transaction
      await db.into(db.accountsTable).insert(
            AccountsTableCompanion.insert(
              id: 'acc_test',
              name: 'Test Wallet',
              type: 'wallet',
              balance: 1500.0,
              iconCode: 0xe3f8,
              colorValue: 0xFF00897B,
              institution: 'Cash',
            ),
          );

      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: 'tx_test_1',
              title: 'Coffee',
              amount: 150.0,
              type: 'expense',
              categoryId: 'food',
              categoryName: 'Food & Dining',
              categoryIconCode: 0xe148,
              categoryColorValue: 0xFFF57C00,
              accountId: 'acc_test',
              accountName: 'Test Wallet',
              date: DateTime(2026, 10, 15),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('Serializes full database into structured JSON with manifest', () async {
      final jsonStr = await backupService.serializeDatabaseToJson();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded.containsKey('manifest'), isTrue);
      expect(decoded['transactionsCount'], equals(1));
      expect(decoded['accountsCount'], equals(1));
      expect(decoded['accounts'], isNotEmpty);
      expect(decoded['transactions'], isNotEmpty);

      final manifest = decoded['manifest'] as Map<String, dynamic>;
      expect(manifest['app'], equals('Hermanos Ledgr'));
      expect(manifest['transactionsCount'], equals(1));
    });

    test('Validates backup JSON accurately', () {
      const validJson = '''
      {
        "transactionsCount": 1,
        "accountsCount": 1,
        "accounts": [{"id": "acc_1", "name": "Cash"}],
        "transactions": [{"id": "tx_1", "title": "Snack", "amount": 50.0}]
      }
      ''';

      final validResult = backupService.validateBackupJson(validJson);
      expect(validResult.isValid, isTrue);
      expect(validResult.detectedTransactions, equals(1));
      expect(validResult.detectedAccounts, equals(1));

      final invalidResult = backupService.validateBackupJson('{invalid json');
      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.errorMessage, contains('Invalid JSON'));

      final emptyResult = backupService.validateBackupJson('{"empty": true}');
      expect(emptyResult.isValid, isFalse);
    });

    test('Restores database atomically with replacement', () async {
      final backupPayload = jsonEncode({
        'accounts': [
          {
            'id': 'acc_restored',
            'name': 'Restored Bank',
            'type': 'bank',
            'balance': 10000.0,
            'iconCode': 0xe3f8,
            'colorValue': 0xFF00897B,
            'institution': 'BPI',
          }
        ],
        'transactions': [
          {
            'id': 'tx_restored_1',
            'title': 'Restored Salary',
            'amount': 25000.0,
            'type': 'income',
            'categoryId': 'salary',
            'categoryName': 'Salary',
            'categoryIconCode': 0xe148,
            'categoryColorValue': 0xFF2E7D52,
            'accountId': 'acc_restored',
            'accountName': 'Restored Bank',
            'date': '2026-10-18T10:00:00.000',
          }
        ],
        'budgets': [
          {
            'id': 'bg_restored',
            'categoryId': 'food',
            'categoryName': 'Food & Dining',
            'monthlyLimit': 5000.0,
            'month': 10,
            'year': 2026,
          }
        ],
      });

      final counts = await backupService.restoreDatabaseFromJson(
        backupPayload,
        replaceExisting: true,
      );

      expect(counts['accounts'], equals(1));
      expect(counts['transactions'], equals(1));
      expect(counts['budgets'], equals(1));

      // Verify old account was replaced by restored account
      final accs = await db.select(db.accountsTable).get();
      expect(accs.length, equals(1));
      expect(accs.first.id, equals('acc_restored'));
      expect(accs.first.name, equals('Restored Bank'));

      final txs = await db.select(db.transactionsTable).get();
      expect(txs.length, equals(1));
      expect(txs.first.id, equals('tx_restored_1'));
      expect(txs.first.amount, equals(25000.0));
    });
  });
}
