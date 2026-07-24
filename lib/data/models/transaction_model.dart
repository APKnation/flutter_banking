enum TransactionType { debit, credit, transfer, bill }
enum TransactionStatus { completed, pending, failed, processing }
enum TransactionCategory {
  food, transport, shopping, entertainment, health,
  utilities, salary, investment, transfer, other
}

class TransactionModel {
  final String id;
  final String title;
  final String? subtitle;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionCategory category;
  final DateTime createdAt;
  final String fromAccount;
  final String? toAccount;
  final String? recipientName;
  final String? note;
  final double? fee;
  final String? referenceId;

  const TransactionModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.type,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.fromAccount,
    this.toAccount,
    this.recipientName,
    this.note,
    this.fee,
    this.referenceId,
  });

  bool get isIncoming =>
      type == TransactionType.credit;

  bool get isOutgoing =>
      type == TransactionType.debit ||
      type == TransactionType.bill;

  String get categoryLabel {
    switch (category) {
      case TransactionCategory.food:          return 'Food & Drinks';
      case TransactionCategory.transport:     return 'Transport';
      case TransactionCategory.shopping:      return 'Shopping';
      case TransactionCategory.entertainment: return 'Entertainment';
      case TransactionCategory.health:        return 'Health';
      case TransactionCategory.utilities:     return 'Utilities';
      case TransactionCategory.salary:        return 'Salary';
      case TransactionCategory.investment:    return 'Investment';
      case TransactionCategory.transfer:      return 'Transfer';
      case TransactionCategory.other:         return 'Other';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case TransactionCategory.food:          return '🍔';
      case TransactionCategory.transport:     return '🚗';
      case TransactionCategory.shopping:      return '🛍️';
      case TransactionCategory.entertainment: return '🎬';
      case TransactionCategory.health:        return '💊';
      case TransactionCategory.utilities:     return '⚡';
      case TransactionCategory.salary:        return '💼';
      case TransactionCategory.investment:    return '📈';
      case TransactionCategory.transfer:      return '💸';
      case TransactionCategory.other:         return '📦';
    }
  }
}
