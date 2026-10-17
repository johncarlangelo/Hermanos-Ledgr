import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/daos/accounts_dao.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_repository.dart';

/// Concrete implementation of [AccountRepository] backed by Drift SQLite database and [AccountsDao].
class AccountRepositoryImpl implements AccountRepository {
  final AccountsDao accountsDao;
  final AppDatabase db;

  AccountRepositoryImpl({
    required this.accountsDao,
    required this.db,
  });

  @override
  Stream<List<AccountModel>> watchAccounts() {
    return accountsDao.watchAllAccounts().map(
          (rows) => rows.map(DatabaseMappers.accountFromDrift).toList(),
        );
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    try {
      final rows = await accountsDao.getAllAccounts();
      return rows.map(DatabaseMappers.accountFromDrift).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AccountModel?> getAccountById(String id) async {
    try {
      final row = await accountsDao.getAccountById(id);
      return row != null ? DatabaseMappers.accountFromDrift(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<void>> addAccount(AccountModel account) async {
    try {
      final companion = DatabaseMappers.accountToCompanion(account);
      await accountsDao.insertOrUpdateAccount(companion);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to add account: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateAccount(AccountModel account) async {
    try {
      final companion = DatabaseMappers.accountToCompanion(account);
      await accountsDao.insertOrUpdateAccount(companion);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update account: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateBalance(String id, double delta) async {
    try {
      await accountsDao.updateBalance(id, delta);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update balance: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String id) async {
    try {
      // Purge associated transactions first to maintain database integrity
      await (db.delete(db.transactionsTable)
            ..where((t) =>
                t.accountId.equals(id) |
                t.destinationAccountId.equals(id)))
          .go();

      // Delete account record via DAO
      await accountsDao.deleteAccount(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete account: $e', e is Exception ? e : Exception(e.toString()));
    }
  }
}

/// Provider exposing the [AccountRepository] implementation.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AccountRepositoryImpl(
    accountsDao: db.accountsDao,
    db: db,
  );
});
