import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/recurring/data/recurring_repository_impl.dart';
import 'package:hermanos_ledgr/features/recurring/domain/forecast_engine.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_auto_log_engine.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

void main() {
  group('RecurringModel & Frequency Calculations (Task 8.1)', () {
    test('calculates next dates for daily, weekly, biweekly, monthly, yearly', () {
      final baseDate = DateTime(2026, 1, 15, 10, 0);

      expect(
        RecurringFrequency.daily.calculateNextDate(baseDate),
        DateTime(2026, 1, 16, 10, 0),
      );

      expect(
        RecurringFrequency.weekly.calculateNextDate(baseDate),
        DateTime(2026, 1, 22, 10, 0),
      );

      expect(
        RecurringFrequency.biweekly.calculateNextDate(baseDate),
        DateTime(2026, 1, 29, 10, 0),
      );

      expect(
        RecurringFrequency.monthly.calculateNextDate(baseDate),
        DateTime(2026, 2, 15, 10, 0),
      );

      expect(
        RecurringFrequency.yearly.calculateNextDate(baseDate),
        DateTime(2027, 1, 15, 10, 0),
      );
    });

    test('monthly recurrence clamps days for shorter months (Jan 31 -> Feb 28)', () {
      final jan31 = DateTime(2026, 1, 31, 12, 0);
      final febNext = RecurringFrequency.monthly.calculateNextDate(jan31);

      // 2026 is not a leap year -> Feb has 28 days
      expect(febNext.year, 2026);
      expect(febNext.month, 2);
      expect(febNext.day, 28);
    });

    test('monthly recurrence wraps properly from December to January', () {
      final dec15 = DateTime(2026, 12, 15, 8, 30);
      final janNext = RecurringFrequency.monthly.calculateNextDate(dec15);

      expect(janNext.year, 2027);
      expect(janNext.month, 1);
      expect(janNext.day, 15);
    });

    test('calculates monthly equivalent normalization factors accurately', () {
      final weeklyRule = RecurringModel(
        id: 'r_weekly',
        title: 'Weekly Grocery Allowance',
        amount: 2000.0,
        type: TransactionType.expense,
        categoryId: 'groceries',
        categoryName: 'Groceries',
        accountId: 'acc_cash',
        accountName: 'Wallet',
        frequency: RecurringFrequency.weekly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 8),
      );

      // 2000 * (52 / 12) = 8666.67
      expect(weeklyRule.monthlyEquivalent, closeTo(8666.67, 0.1));

      final monthlyRule = weeklyRule.copyWith(
        amount: 549.0,
        frequency: RecurringFrequency.monthly,
      );
      expect(monthlyRule.monthlyEquivalent, 549.0);

      final yearlyRule = weeklyRule.copyWith(
        amount: 12000.0,
        frequency: RecurringFrequency.yearly,
      );
      // 12000 / 12 = 1000/mo
      expect(yearlyRule.monthlyEquivalent, 1000.0);
    });
  });

  group('ForecastEngine Cashflow Timeline (Task 8.7 & 8.8)', () {
    test('projects cashflow accurately with multiple recurring rules over 30 days', () {
      final now = DateTime(2026, 10, 1);

      final salaryRule = RecurringModel(
        id: 'r_salary',
        title: 'Monthly Salary',
        amount: 50000.0,
        type: TransactionType.income,
        categoryId: 'salary',
        categoryName: 'Salary',
        accountId: 'acc_bank',
        accountName: 'BPI Bank',
        frequency: RecurringFrequency.monthly,
        startDate: now,
        nextDueDate: DateTime(2026, 10, 15),
      );

      final rentRule = RecurringModel(
        id: 'r_rent',
        title: 'Apartment Rent',
        amount: 15000.0,
        type: TransactionType.expense,
        categoryId: 'housing',
        categoryName: 'Housing & Rent',
        accountId: 'acc_bank',
        accountName: 'BPI Bank',
        frequency: RecurringFrequency.monthly,
        startDate: now,
        nextDueDate: DateTime(2026, 10, 5),
      );

      final wifiRule = RecurringModel(
        id: 'r_wifi',
        title: 'Fiber Internet',
        amount: 2000.0,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        accountId: 'acc_bank',
        accountName: 'BPI Bank',
        frequency: RecurringFrequency.monthly,
        startDate: now,
        nextDueDate: DateTime(2026, 10, 20),
      );

      final forecast = ForecastEngine.calculate(
        startingBalance: 10000.0,
        rules: [salaryRule, rentRule, wifiRule],
        daysHorizon: 30,
        startDate: now,
      );

      expect(forecast.startingBalance, 10000.0);
      expect(forecast.totalIncome, 50000.0);
      expect(forecast.totalExpense, 17000.0);
      // 10000 + 50000 - 17000 = 43000
      expect(forecast.endingBalance, 43000.0);
      expect(forecast.netChange, 33000.0);
      expect(forecast.isPositiveNet, isTrue);

      // Verify chronological events
      expect(forecast.upcomingOccurrences.length, 3);
      expect(forecast.upcomingOccurrences[0].rule.title, 'Apartment Rent');
      expect(forecast.upcomingOccurrences[1].rule.title, 'Monthly Salary');
      expect(forecast.upcomingOccurrences[2].rule.title, 'Fiber Internet');
    });
  });

  group('RecurringAutoLogEngine (Task 8.6)', () {
    test('auto-logs due transactions and advances due dates', () {
      final now = DateTime(2026, 10, 18, 12, 0);

      final dueRule = RecurringModel(
        id: 'r_netflix',
        title: 'Netflix Standard',
        amount: 459.0,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        accountId: 'acc_gcash',
        accountName: 'GCash',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 9, 15),
        nextDueDate: DateTime(2026, 10, 15), // 3 days ago -> due!
        isActive: true,
      );

      final futureRule = RecurringModel(
        id: 'r_gym',
        title: 'Gym Membership',
        amount: 1800.0,
        type: TransactionType.expense,
        categoryId: 'health',
        categoryName: 'Health & Fitness',
        accountId: 'acc_bdo',
        accountName: 'BDO Debit',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 10, 1),
        nextDueDate: DateTime(2026, 10, 25), // future -> not due!
        isActive: true,
      );

      final List<TransactionModel> loggedTxs = [];
      final Map<String, DateTime> updatedDueDates = {};

      final result = RecurringAutoLogEngine.checkAndProcess(
        rules: [dueRule, futureRule],
        referenceDate: now,
        onLogTransaction: (tx) => loggedTxs.add(tx),
        onAdvanceDueDate: (id, newDueDate) => updatedDueDates[id] = newDueDate,
      );

      expect(result.loggedCount, 1);
      expect(result.ruleTitles, ['Netflix Standard']);
      expect(loggedTxs.length, 1);
      expect(loggedTxs.first.title, 'Netflix Standard');
      expect(loggedTxs.first.amount, 459.0);

      // Date was advanced to Nov 15
      expect(updatedDueDates.containsKey('r_netflix'), isTrue);
      expect(updatedDueDates['r_netflix']!.month, 11);
      expect(updatedDueDates['r_netflix']!.day, 15);

      // Future rule was untouched
      expect(updatedDueDates.containsKey('r_gym'), isFalse);
    });

    test('ignores paused rules even if due date is in the past', () {
      final now = DateTime(2026, 10, 18);

      final pausedRule = RecurringModel(
        id: 'r_spotify',
        title: 'Spotify Family',
        amount: 239.0,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        accountId: 'acc_maya',
        accountName: 'Maya',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 9, 1),
        nextDueDate: DateTime(2026, 10, 1),
        isActive: false, // Paused!
      );

      final List<TransactionModel> loggedTxs = [];

      final result = RecurringAutoLogEngine.checkAndProcess(
        rules: [pausedRule],
        referenceDate: now,
        onLogTransaction: (tx) => loggedTxs.add(tx),
        onAdvanceDueDate: (id, newDueDate) {},
      );

      expect(result.loggedCount, 0);
      expect(loggedTxs.isEmpty, isTrue);
    });

    test('safeguards against negative balance when account balance is insufficient (User Scenario)', () {
      // Scenario:
      // Starting GCash balance = 1,000
      // Reference date: Nov 26, 2026
      // Rule 1: Nov 15 = 500 (sufficient, leaves 500)
      // Rule 2: Nov 25 = 600 (insufficient, needs 100 more, paused!)
      final referenceDate = DateTime(2026, 11, 26);

      final bill1 = RecurringModel(
        id: 'r_bill_1',
        title: 'Electricity Bill',
        amount: 500.0,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        accountId: 'acc_gcash',
        accountName: 'GCash',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 10, 15),
        nextDueDate: DateTime(2026, 11, 15),
        isActive: true,
      );

      final bill2 = RecurringModel(
        id: 'r_bill_2',
        title: 'Gym Membership',
        amount: 600.0,
        type: TransactionType.expense,
        categoryId: 'health',
        categoryName: 'Health & Fitness',
        accountId: 'acc_gcash',
        accountName: 'GCash',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 10, 25),
        nextDueDate: DateTime(2026, 11, 25),
        isActive: true,
      );

      final List<TransactionModel> loggedTxs = [];
      final Map<String, DateTime> updatedDueDates = {};
      final accountBalances = {'acc_gcash': 1000.0};

      final result = RecurringAutoLogEngine.checkAndProcess(
        rules: [bill1, bill2],
        accountBalances: accountBalances,
        referenceDate: referenceDate,
        onLogTransaction: (tx) => loggedTxs.add(tx),
        onAdvanceDueDate: (id, newDueDate) => updatedDueDates[id] = newDueDate,
      );

      // Bill 1 was logged
      expect(result.loggedCount, 1);
      expect(loggedTxs.length, 1);
      expect(loggedTxs.first.title, 'Electricity Bill');
      expect(loggedTxs.first.amount, 500.0);
      expect(updatedDueDates.containsKey('r_bill_1'), isTrue);

      // Bill 2 was paused due to insufficient funds (500 < 600)
      expect(result.hasInsufficientFunds, isTrue);
      expect(result.insufficientFunds.length, 1);
      final paused = result.insufficientFunds.first;
      expect(paused.rule.title, 'Gym Membership');
      expect(paused.requiredAmount, 600.0);
      expect(paused.availableBalance, 500.0);
      expect(paused.shortfall, 100.0);
      expect(updatedDueDates.containsKey('r_bill_2'), isFalse);
    });

    test('forecast engine detects shortfall and calculates max deficit without erasing negative numbers', () {
      // Scenario:
      // Starting balance = 1,000
      // Nov 15: -500 -> 500
      // Nov 25: -600 -> -100
      final now = DateTime(2026, 11, 12);

      final bill1 = RecurringModel(
        id: 'r_bill_1',
        title: 'Bill 1',
        amount: 500.0,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        accountId: 'acc_gcash',
        accountName: 'GCash',
        frequency: RecurringFrequency.monthly,
        startDate: now,
        nextDueDate: DateTime(2026, 11, 15),
      );

      final bill2 = RecurringModel(
        id: 'r_bill_2',
        title: 'Bill 2',
        amount: 600.0,
        type: TransactionType.expense,
        categoryId: 'health',
        categoryName: 'Health & Fitness',
        accountId: 'acc_gcash',
        accountName: 'GCash',
        frequency: RecurringFrequency.monthly,
        startDate: now,
        nextDueDate: DateTime(2026, 11, 25),
      );

      final forecast = ForecastEngine.calculate(
        startingBalance: 1000.0,
        rules: [bill1, bill2],
        daysHorizon: 30,
        startDate: now,
      );

      // Negative balance math is preserved!
      expect(forecast.endingBalance, -100.0);
      expect(forecast.isPositiveNet, isFalse);
      expect(forecast.netChange, -1100.0);

      // Shortfall indicators
      expect(forecast.hasShortfall, isTrue);
      expect(forecast.maxDeficit, 100.0);
      expect(forecast.firstShortfallDate, DateTime(2026, 11, 25));
      expect(forecast.firstShortfallOccurrence?.rule.title, 'Bill 2');
    });
  });

  group('RecurringRepositoryImpl SQLite Integration (Task 8.2)', () {
    late AppDatabase db;
    late RecurringRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = RecurringRepositoryImpl(db: db, recurringDao: db.recurringDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('adds, reads, updates, toggles, and deletes recurring rules in SQLite', () async {
      final rule = RecurringModel(
        id: 'rec_sql_1',
        title: 'Meralco Electric Bill',
        amount: 4200.0,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        accountId: 'acc_bpi',
        accountName: 'BPI Checking',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 11, 5),
        isActive: true,
      );

      // 1. Add rule
      final addResult = await repository.addRecurring(rule);
      expect(addResult.isSuccess, isTrue);

      // 2. Fetch all
      final all = await repository.getAllRecurring();
      expect(all.length, 1);
      expect(all.first.title, 'Meralco Electric Bill');
      expect(all.first.amount, 4200.0);
      expect(all.first.frequency, RecurringFrequency.monthly);
      expect(all.first.enableNotifications, isTrue);

      // 3. Update notification state
      final updatedNotificationRule = all.first.copyWith(enableNotifications: false);
      await repository.updateRecurring(updatedNotificationRule);
      final fetchedAfterNotifToggle = await repository.getRecurringById('rec_sql_1');
      expect(fetchedAfterNotifToggle!.enableNotifications, isFalse);

      // 4. Toggle active
      await repository.toggleActive('rec_sql_1', false);
      final paused = await repository.getRecurringById('rec_sql_1');
      expect(paused!.isActive, isFalse);

      // 4. Advance next due date
      final newDue = DateTime(2026, 12, 5);
      await repository.advanceNextDueDate('rec_sql_1', newDue);
      final advanced = await repository.getRecurringById('rec_sql_1');
      expect(advanced!.nextDueDate, newDue);

      // 5. Delete rule
      final deleteResult = await repository.deleteRecurring('rec_sql_1');
      expect(deleteResult.isSuccess, isTrue);

      final emptyList = await repository.getAllRecurring();
      expect(emptyList.isEmpty, isTrue);
    });
  });
}
