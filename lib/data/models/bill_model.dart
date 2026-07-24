import 'package:cloud_firestore/cloud_firestore.dart';

enum BillCategory { electricity, water, internet, phone, gas, insurance, rent, subscription }

class BillerModel {
  final String id;
  final String name;
  final String? accountNumber;
  final BillCategory category;
  final double? lastAmount;
  final DateTime? lastPaid;
  final bool isSaved;
  final String emoji;

  const BillerModel({
    required this.id,
    required this.name,
    this.accountNumber,
    required this.category,
    this.lastAmount,
    this.lastPaid,
    this.isSaved = false,
    required this.emoji,
  });

  factory BillerModel.fromJson(String docId, Map<String, dynamic> json) {
    return BillerModel(
      id: docId,
      name: json['name'] as String? ?? '',
      accountNumber: json['accountNumber'] as String?,
      category: BillCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => BillCategory.subscription, // default fallback
      ),
      lastAmount: (json['lastAmount'] as num?)?.toDouble(),
      lastPaid: (json['lastPaid'] as Timestamp?)?.toDate(),
      isSaved: json['isSaved'] as bool? ?? false,
      emoji: json['emoji'] as String? ?? '🧾',
    );
  }

  factory BillerModel.fromSnapshot(DocumentSnapshot doc) =>
      BillerModel.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (accountNumber != null) 'accountNumber': accountNumber,
        'category': category.name,
        if (lastAmount != null) 'lastAmount': lastAmount,
        if (lastPaid != null) 'lastPaid': Timestamp.fromDate(lastPaid!),
        'isSaved': isSaved,
        'emoji': emoji,
      };

  String get categoryLabel {
    switch (category) {
      case BillCategory.electricity:  return 'Electricity';
      case BillCategory.water:        return 'Water';
      case BillCategory.internet:     return 'Internet';
      case BillCategory.phone:        return 'Phone';
      case BillCategory.gas:          return 'Gas';
      case BillCategory.insurance:    return 'Insurance';
      case BillCategory.rent:         return 'Rent';
      case BillCategory.subscription: return 'Subscription';
    }
  }
}
