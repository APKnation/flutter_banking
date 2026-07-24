class SavingsGoalModel {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final bool autoSave;
  final double? autoSaveAmount;
  final String colorHex;

  const SavingsGoalModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    this.autoSave = false,
    this.autoSaveAmount,
    required this.colorHex,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  double get progressPercentage => progress * 100;

  bool get isCompleted => currentAmount >= targetAmount;

  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);

  SavingsGoalModel copyWith({double? currentAmount}) {
    return SavingsGoalModel(
      id: id, name: name, emoji: emoji, targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount, targetDate: targetDate,
      autoSave: autoSave, autoSaveAmount: autoSaveAmount, colorHex: colorHex,
    );
  }
}
