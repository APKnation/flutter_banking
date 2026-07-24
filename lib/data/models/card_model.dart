enum CardType { visa, mastercard, amex }
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
