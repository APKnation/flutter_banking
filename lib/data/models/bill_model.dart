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
