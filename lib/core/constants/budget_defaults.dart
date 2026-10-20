/// Domain item representing a default category monthly budget.
class DefaultBudgetItem {
  final String categoryId;
  final String categoryName;
  final double monthlyLimit;

  const DefaultBudgetItem({
    required this.categoryId,
    required this.categoryName,
    required this.monthlyLimit,
  });
}

/// Curated starter budget limits for Hermanos Ledgr personal finance tracker.
class BudgetDefaults {
  BudgetDefaults._();

  static const List<DefaultBudgetItem> defaultCategoryBudgets = [
    DefaultBudgetItem(
      categoryId: 'food',
      categoryName: 'Food & Dining',
      monthlyLimit: 8000.0,
    ),
    DefaultBudgetItem(
      categoryId: 'groceries',
      categoryName: 'Groceries',
      monthlyLimit: 6000.0,
    ),
    DefaultBudgetItem(
      categoryId: 'transport',
      categoryName: 'Transportation',
      monthlyLimit: 3500.0,
    ),
    DefaultBudgetItem(
      categoryId: 'utilities',
      categoryName: 'Utilities & Bills',
      monthlyLimit: 4500.0,
    ),
    DefaultBudgetItem(
      categoryId: 'shopping',
      categoryName: 'Shopping',
      monthlyLimit: 3000.0,
    ),
  ];
}
