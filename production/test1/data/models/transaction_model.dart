import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType   { debit, credit, transfer, bill }
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

  factory TransactionModel.fromJson(String docId, Map<String, dynamic> json) {
    return TransactionModel(
      id: docId,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == (json['type'] as String?),
        orElse: () => TransactionType.debit,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => TransactionStatus.completed,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => TransactionCategory.other,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fromAccount: json['fromAccount'] as String? ?? '',
      toAccount: json['toAccount'] as String?,
      recipientName: json['recipientName'] as String?,
      note: json['note'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
      referenceId: json['referenceId'] as String?,
    );
  }

  factory TransactionModel.fromSnapshot(DocumentSnapshot doc) =>
      TransactionModel.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() => {
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        'amount': amount,
        'type': type.name,
        'status': status.name,
        'category': category.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'fromAccount': fromAccount,
        if (toAccount != null) 'toAccount': toAccount,
        if (recipientName != null) 'recipientName': recipientName,
        if (note != null) 'note': note,
        if (fee != null) 'fee': fee,
        if (referenceId != null) 'referenceId': referenceId,
      };

  bool get isIncoming => type == TransactionType.credit;

  bool get isOutgoing =>
      type == TransactionType.debit || type == TransactionType.bill;

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
