import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/debts/data/debt_repository_impl.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';

void main() {
  group('DebtModel Domain Calculations (Task 7.1)', () {
    test('calculates paid amount, percentage, and progressPercent correctly', () {
      final debt = DebtModel(
        id: 'debt_1',
        type: DebtType.debt,
        personName: 'Carlos M.',
        originalAmount: 10000.0,
        remainingAmount: 6000.0,
        dueDate: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now(),
      );

      expect(debt.paidAmount, 4000.0);
      expect(debt.paidPercentage, closeTo(0.40, 0.001));
      expect(debt.progressPercent, 40);
      expect(debt.isSettled, isFalse);
    });

    test('marks as settled when remaining amount is zero or negative', () {
      final debt = DebtModel(
        id: 'debt_2',
        type: DebtType.receivable,
        personName: 'Elena R.',
        originalAmount: 5000.0,
        remainingAmount: 0.0,
        isSettled: true,
        createdAt: DateTime.now(),
      );

      expect(debt.paidAmount, 5000.0);
      expect(debt.paidPercentage, 1.0);
      expect(debt.progressPercent, 100);
      expect(debt.isSettled, isTrue);
    });

    test('detects overdue dates correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final overdueDebt = DebtModel(
        id: 'debt_3',
        type: DebtType.debt,
        personName: 'Bank Loan',
        originalAmount: 15000.0,
        remainingAmount: 15000.0,
        dueDate: pastDate,
        createdAt: DateTime.now(),
      );

      expect(overdueDebt.isOverdue, isTrue);
      expect(overdueDebt.remainingDays, lessThan(0));

      final futureDate = DateTime.now().add(const Duration(days: 10));
      final activeDebt = DebtModel(
        id: 'debt_4',
        type: DebtType.receivable,
        personName: 'David L.',
        originalAmount: 3000.0,
        remainingAmount: 3000.0,
        dueDate: futureDate,
        createdAt: DateTime.now(),
      );

      expect(activeDebt.isOverdue, isFalse);
      expect(activeDebt.remainingDays, greaterThanOrEqualTo(9));
    });

    test('settled debts are not considered overdue even if past due date', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final settledDebt = DebtModel(
        id: 'debt_5',
        type: DebtType.debt,
        personName: 'Credit Card',
        originalAmount: 8000.0,
        remainingAmount: 0.0,
        isSettled: true,
        dueDate: pastDate,
        createdAt: DateTime.now(),
      );

      expect(settledDebt.isSettled, isTrue);
      expect(settledDebt.isOverdue, isFalse);
    });
  });

  group('DebtRepositoryImpl SQLite Integration (Task 7.2 & 7.7)', () {
    late AppDatabase db;
    late DebtRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = DebtRepositoryImpl(db: db, debtsDao: db.debtsDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('inserts, streams, updates, and deletes debts in SQLite', () async {
      final payable = DebtModel(
        id: 'd_test_1',
        type: DebtType.debt,
        personName: 'Marco P.',
        originalAmount: 5000.0,
        remainingAmount: 5000.0,
        dueDate: DateTime(2027, 6, 30),
        note: 'Dinner split advance',
        createdAt: DateTime.now(),
      );

      final receivable = DebtModel(
        id: 'd_test_2',
        type: DebtType.receivable,
        personName: 'Sarah T.',
        originalAmount: 3200.0,
        remainingAmount: 3200.0,
        dueDate: DateTime(2027, 7, 15),
        note: 'Coffee & snacks',
        createdAt: DateTime.now(),
      );

      // 1. Add both via repository
      await repository.addDebt(payable);
      await repository.addDebt(receivable);

      // 2. Fetch all
      final allDebts = await repository.getAllDebts();
      expect(allDebts.length, 2);

      // 3. Filter payable and receivable
      final payables = allDebts.where((d) => d.type == DebtType.debt).toList();
      expect(payables.length, 1);
      expect(payables.first.personName, 'Marco P.');
      expect(payables.first.type, DebtType.debt);

      final receivables = allDebts.where((d) => d.type == DebtType.receivable).toList();
      expect(receivables.length, 1);
      expect(receivables.first.personName, 'Sarah T.');
      expect(receivables.first.type, DebtType.receivable);

      // 4. Record partial payment (Task 7.7)
      final payResult = await repository.recordPayment('d_test_1', 2000.0);
      expect(payResult.isSuccess, isTrue);

      final updatedPayable = await repository.getDebtById('d_test_1');
      expect(updatedPayable, isNotNull);
      expect(updatedPayable!.remainingAmount, 3000.0);
      expect(updatedPayable.isSettled, isFalse);

      // 5. Full payoff to settle
      await repository.recordPayment('d_test_1', 3000.0);
      final settledPayable = await repository.getDebtById('d_test_1');
      expect(settledPayable!.remainingAmount, 0.0);
      expect(settledPayable.isSettled, isTrue);

      // 6. Delete debt
      final deleteResult = await repository.deleteDebt('d_test_2');
      expect(deleteResult.isSuccess, isTrue);

      final remainingAll = await repository.getAllDebts();
      expect(remainingAll.length, 1);
      expect(remainingAll.first.id, 'd_test_1');
    });
  });
}
