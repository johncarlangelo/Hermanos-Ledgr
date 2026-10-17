import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/daos/debts_dao.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_repository.dart';

/// Concrete implementation of [DebtRepository] utilizing Drift SQLite [DebtsDao].
class DebtRepositoryImpl implements DebtRepository {
  final AppDatabase db;
  final DebtsDao debtsDao;

  DebtRepositoryImpl({
    required this.db,
    required this.debtsDao,
  });

  @override
  Stream<List<DebtModel>> watchAllDebts() {
    return debtsDao.watchAllDebts().map(
          (rows) => rows.map(DatabaseMappers.debtFromDrift).toList(),
        );
  }

  @override
  Future<List<DebtModel>> getAllDebts() async {
    final rows = await debtsDao.getAllDebts();
    return rows.map(DatabaseMappers.debtFromDrift).toList();
  }

  @override
  Future<DebtModel?> getDebtById(String id) async {
    final row = await debtsDao.getDebtById(id);
    return row != null ? DatabaseMappers.debtFromDrift(row) : null;
  }

  @override
  Future<Result<void>> addDebt(DebtModel debt) async {
    try {
      await debtsDao.insertOrUpdateDebt(DatabaseMappers.debtToCompanion(debt));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to add debt: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateDebt(DebtModel debt) async {
    try {
      await debtsDao.insertOrUpdateDebt(DatabaseMappers.debtToCompanion(debt));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update debt: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> recordPayment(String id, double paymentAmount) async {
    try {
      final rowsUpdated = await debtsDao.recordPayment(id, paymentAmount);
      if (rowsUpdated > 0) {
        return const Success(null);
      }
      return Failure('Debt with id $id not found');
    } catch (e) {
      return Failure('Failed to record payment: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteDebt(String id) async {
    try {
      await debtsDao.deleteDebt(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete debt: $e', e is Exception ? e : Exception(e.toString()));
    }
  }
}
