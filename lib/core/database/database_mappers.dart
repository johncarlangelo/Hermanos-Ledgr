import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/budget/domain/budget_model.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Extension and mapper utilities converting between Drift SQLite tables
/// and Hermanos Ledgr domain models.
class DatabaseMappers {
  DatabaseMappers._();

  static AccountModel accountFromDrift(AccountsTableData row) {
    return AccountModel(
      id: row.id,
      name: row.name,
      type: AccountType.values.firstWhere(
        (e) => e.name == row.type,
        orElse: () => AccountType.bank,
      ),
      balance: row.balance,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(row.iconCode, fontFamily: 'MaterialIcons'),
      color: Color(row.colorValue),
      institution: row.institution,
      monthlyChange: row.monthlyChange,
    );
  }

  static AccountsTableCompanion accountToCompanion(AccountModel account) {
    return AccountsTableCompanion.insert(
      id: account.id,
      name: account.name,
      type: account.type.name,
      balance: account.balance,
      iconCode: account.icon.codePoint,
      colorValue: account.color.toARGB32(),
      institution: account.institution ?? '',
      monthlyChange: Value(account.monthlyChange),
    );
  }

  static TransactionModel transactionFromDrift(TransactionsTableData row) {
    return TransactionModel(
      id: row.id,
      title: row.title,
      amount: row.amount,
      type: TransactionType.values.firstWhere(
        (e) => e.name == row.type,
        orElse: () => TransactionType.expense,
      ),
      categoryId: row.categoryId,
      categoryName: row.categoryName,
      // ignore: non_const_argument_for_const_parameter
      categoryIcon: IconData(row.categoryIconCode, fontFamily: 'MaterialIcons'),
      categoryColor: Color(row.categoryColorValue),
      accountId: row.accountId,
      accountName: row.accountName,
      destinationAccountId: row.destinationAccountId,
      destinationAccountName: row.destinationAccountName,
      date: row.date,
      note: row.note,
      receiptImagePath: row.receiptImagePath,
    );
  }

  static TransactionsTableCompanion transactionToCompanion(TransactionModel tx) {
    return TransactionsTableCompanion.insert(
      id: tx.id,
      title: tx.title,
      amount: tx.amount,
      type: tx.type.name,
      categoryId: tx.categoryId,
      categoryName: tx.categoryName,
      categoryIconCode: tx.categoryIcon.codePoint,
      categoryColorValue: tx.categoryColor.toARGB32(),
      accountId: tx.accountId,
      accountName: tx.accountName,
      destinationAccountId: Value(tx.destinationAccountId),
      destinationAccountName: Value(tx.destinationAccountName),
      date: tx.date,
      note: Value(tx.note),
      receiptImagePath: Value(tx.receiptImagePath),
    );
  }

  static BudgetModel budgetFromDrift(
    BudgetsTableData row, {
    required double spentAmount,
    IconData icon = Icons.pie_chart_rounded,
    Color color = const Color(0xFF00897B),
  }) {
    return BudgetModel(
      id: row.id,
      categoryId: row.categoryId,
      categoryName: row.categoryName,
      categoryIcon: icon,
      categoryColor: color,
      limitAmount: row.monthlyLimit,
      spentAmount: spentAmount,
    );
  }

  static GoalModel goalFromDrift(GoalsTableData row) {
    return GoalModel(
      id: row.id,
      name: row.name,
      targetAmount: row.targetAmount,
      currentAmount: row.currentAmount,
      targetDate: row.targetDate,
      // ignore: non_const_argument_for_const_parameter
      icon: row.iconCode != null
          // ignore: non_const_argument_for_const_parameter
          ? IconData(row.iconCode!, fontFamily: 'MaterialIcons')
          : Icons.savings_rounded,
      color: row.colorValue != null
          ? Color(row.colorValue!)
          : const Color(0xFF00897B),
      isCompleted: row.isCompleted,
    );
  }

  static GoalsTableCompanion goalToCompanion(GoalModel goal) {
    return GoalsTableCompanion.insert(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: Value(goal.currentAmount),
      targetDate: Value(goal.targetDate),
      iconCode: Value(goal.icon.codePoint),
      colorValue: Value(goal.color.toARGB32()),
      isCompleted: Value(goal.isCompleted),
    );
  }
}
