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

  String get typeLabel {
    switch (type) {
      case AccountType.savings:     return 'Savings Account';
      case AccountType.checking:    return 'Checking Account';
      case AccountType.investment:  return 'Investment Portfolio';
      case AccountType.loan:        return 'Loan Account';
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
