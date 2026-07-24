import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { savings, checking, investment, loan }

class AccountModel {
  final String id;
  final String name;
  final String accountNumber;
  final String iban;
  final String bic;
  final double balance;
  final AccountType type;
  final String currency;
  final bool isPrimary;
  final double? interestRate;
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.iban,
    required this.bic,
    required this.balance,
    required this.type,
    required this.currency,
    required this.isPrimary,
    this.interestRate,
    required this.createdAt,
  });

  factory AccountModel.fromJson(String docId, Map<String, dynamic> json) {
    return AccountModel(
      id: docId,
      name: json['name'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      iban: json['iban'] as String? ?? '',
      bic: json['bic'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      type: AccountType.values.firstWhere(
        (e) => e.name == (json['type'] as String?),
        orElse: () => AccountType.checking,
      ),
      currency: json['currency'] as String? ?? 'TSH',
      isPrimary: json['isPrimary'] as bool? ?? false,
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AccountModel.fromSnapshot(DocumentSnapshot doc) =>
      AccountModel.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'accountNumber': accountNumber,
        'iban': iban,
        'bic': bic,
        'balance': balance,
        'type': type.name,
        'currency': currency,
        'isPrimary': isPrimary,
        if (interestRate != null) 'interestRate': interestRate,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  String get typeLabel {
    switch (type) {
      case AccountType.savings:    return 'Savings Account';
      case AccountType.checking:   return 'Checking Account';
      case AccountType.investment: return 'Investment Portfolio';
      case AccountType.loan:       return 'Loan Account';
    }
  }

  AccountModel copyWith({double? balance}) {
    return AccountModel(
      id: id, name: name, accountNumber: accountNumber, iban: iban, bic: bic,
      balance: balance ?? this.balance, type: type, currency: currency,
      isPrimary: isPrimary, interestRate: interestRate, createdAt: createdAt,
    );
  }
}
