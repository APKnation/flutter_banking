import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory SavingsGoalModel.fromJson(String docId, Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: docId,
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🎯',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: (json['targetDate'] as Timestamp?)?.toDate(),
      autoSave: json['autoSave'] as bool? ?? false,
      autoSaveAmount: (json['autoSaveAmount'] as num?)?.toDouble(),
      colorHex: json['colorHex'] as String? ?? '#7C3AED',
    );
  }

  factory SavingsGoalModel.fromSnapshot(DocumentSnapshot doc) =>
      SavingsGoalModel.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        if (targetDate != null) 'targetDate': Timestamp.fromDate(targetDate!),
        'autoSave': autoSave,
        if (autoSaveAmount != null) 'autoSaveAmount': autoSaveAmount,
        'colorHex': colorHex,
      };

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  double get progressPercentage => progress * 100;

  bool get isCompleted => currentAmount >= targetAmount;

  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);

  SavingsGoalModel copyWith({double? currentAmount}) {
    return SavingsGoalModel(
      id: id, name: name, emoji: emoji, targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate, autoSave: autoSave,
      autoSaveAmount: autoSaveAmount, colorHex: colorHex,
    );
  }
}
