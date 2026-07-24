import 'package:cloud_firestore/cloud_firestore.dart';

enum CardType   { visa, mastercard, amex }
enum CardStatus { active, frozen, expired, blocked }

class CardModel {
  final String id;
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final String cvv;
  final CardType type;
  final CardStatus status;
  final bool isVirtual;
  final double spendingLimit;
  final double currentSpend;
  final bool onlineTransactions;
  final bool atmWithdrawals;
  final bool internationalPayments;
  final int gradientIndex; // 0=primary, 1=accent, 2=gold

  const CardModel({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cvv,
    required this.type,
    required this.status,
    required this.isVirtual,
    required this.spendingLimit,
    required this.currentSpend,
    required this.onlineTransactions,
    required this.atmWithdrawals,
    required this.internationalPayments,
    this.gradientIndex = 0,
  });

  factory CardModel.fromJson(String docId, Map<String, dynamic> json) {
    return CardModel(
      id: docId,
      cardNumber: json['cardNumber'] as String? ?? '',
      cardholderName: json['cardholderName'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      cvv: json['cvv'] as String? ?? '',
      type: CardType.values.firstWhere(
        (e) => e.name == (json['type'] as String?),
        orElse: () => CardType.visa,
      ),
      status: CardStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => CardStatus.active,
      ),
      isVirtual: json['isVirtual'] as bool? ?? false,
      spendingLimit: (json['spendingLimit'] as num?)?.toDouble() ?? 0.0,
      currentSpend: (json['currentSpend'] as num?)?.toDouble() ?? 0.0,
      onlineTransactions: json['onlineTransactions'] as bool? ?? true,
      atmWithdrawals: json['atmWithdrawals'] as bool? ?? true,
      internationalPayments: json['internationalPayments'] as bool? ?? false,
      gradientIndex: json['gradientIndex'] as int? ?? 0,
    );
  }

  factory CardModel.fromSnapshot(DocumentSnapshot doc) =>
      CardModel.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'type': type.name,
        'status': status.name,
        'isVirtual': isVirtual,
        'spendingLimit': spendingLimit,
        'currentSpend': currentSpend,
        'onlineTransactions': onlineTransactions,
        'atmWithdrawals': atmWithdrawals,
        'internationalPayments': internationalPayments,
        'gradientIndex': gradientIndex,
      };

  bool get isFrozen => status == CardStatus.frozen;
  bool get isActive => status == CardStatus.active;
  double get spendingPercentage =>
      spendingLimit > 0 ? (currentSpend / spendingLimit).clamp(0, 1) : 0;

  String get maskedNumber =>
      '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';

  String get networkLabel {
    switch (type) {
      case CardType.visa:       return 'VISA';
      case CardType.mastercard: return 'Mastercard';
      case CardType.amex:       return 'Amex';
    }
  }

  CardModel copyWith({
    CardStatus? status,
    bool? onlineTransactions,
    bool? atmWithdrawals,
    bool? internationalPayments,
    double? spendingLimit,
  }) {
    return CardModel(
      id: id, cardNumber: cardNumber, cardholderName: cardholderName,
      expiryDate: expiryDate, cvv: cvv, type: type,
      status: status ?? this.status, isVirtual: isVirtual,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      currentSpend: currentSpend,
      onlineTransactions: onlineTransactions ?? this.onlineTransactions,
      atmWithdrawals: atmWithdrawals ?? this.atmWithdrawals,
      internationalPayments: internationalPayments ?? this.internationalPayments,
      gradientIndex: gradientIndex,
    );
  }
}
