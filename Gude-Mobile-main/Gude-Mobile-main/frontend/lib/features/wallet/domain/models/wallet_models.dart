class WalletTransaction {
  final String id;
  final String title;
  final double amount;
  final bool isCredit;
  final DateTime date;
  final TransactionCategory category;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.category,
  });
}

enum TransactionCategory {
  marketplace,
  food,
  transport,
  printing,
  textbooks,
  savings,
  other,
}

extension TransactionCategoryExt on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.marketplace: return 'Marketplace';
      case TransactionCategory.food:        return 'Food';
      case TransactionCategory.transport:   return 'Transport';
      case TransactionCategory.printing:    return 'Printing';
      case TransactionCategory.textbooks:   return 'Textbooks';
      case TransactionCategory.savings:     return 'Savings';
      case TransactionCategory.other:       return 'Other';
    }
  }
}

class BudgetCategory {
  final String name;
  final double allocated;
  final double spent;
  final String emoji;

  const BudgetCategory({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.emoji,
  });

  double get remaining   => allocated - spent;
  double get percentage  => allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
}

class SavingsGoal {
  final String id;
  final String name;
  final double target;
  final double saved;
  final String emoji;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
    required this.emoji,
  });

  double get percentage => target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
  double get remaining  => target - saved;
}
