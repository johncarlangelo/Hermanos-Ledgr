import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';

/// Abstract contract defining account persistence and querying operations.
abstract class AccountRepository {
  /// Stream that emits the list of all accounts whenever the underlying store updates.
  Stream<List<AccountModel>> watchAccounts();

  /// Retrieve all accounts once.
  Future<List<AccountModel>> getAccounts();

  /// Retrieve a specific account by its unique identifier.
  Future<AccountModel?> getAccountById(String id);

  /// Insert a new account.
  Future<Result<void>> addAccount(AccountModel account);

  /// Update an existing account's metadata (name, type, color, institution, balance).
  Future<Result<void>> updateAccount(AccountModel account);

  /// Update an account's balance by adding [delta].
  Future<Result<void>> updateBalance(String id, double delta);

  /// Delete an account and its associated transaction records.
  Future<Result<void>> deleteAccount(String id);
}
