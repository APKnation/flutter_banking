import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/banking_repository.dart';
import '../../core/widgets/section_header.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _repo = BankingRepository();
  Map<TransactionCategory, double> _spending = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final spending = await _repo.getSpendingByCategory();
      setState(() { _spending = spending; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = _spending.values.fold(0.0, (s, a) => s + a);
    final sorted = _spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Spent this Month',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(AppFormatters.formatCurrency(totalSpent),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 36,
                                fontWeight: FontWeight.w800, letterSpacing: -1)),
                      ],
                    ),
                  ),
                  if (sorted.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 56, color: AppColors.textDisabled),
                            SizedBox(height: 12),
                            Text('No spending data this month.',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 70,
                              startDegreeOffset: 270,
                              sections: _getSections(sorted, totalSpent),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Budget', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                Text(totalSpent > 0 ? '${((totalSpent / (totalSpent * 1.2)) * 100).toStringAsFixed(0)}%' : '0%',
                                    style: const TextStyle(color: AppColors.textPrimary,
                                        fontSize: 28, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SectionHeader(title: 'Top Categories', padding: const EdgeInsets.symmetric(horizontal: 20)),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        children: sorted.take(6).map((e) => _CategoryRow(
                          category: e.key,
                          amount: e.value,
                          percentage: totalSpent > 0 ? e.value / totalSpent : 0,
                        )).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _getSections(List<MapEntry<TransactionCategory, double>> data, double total) {
    if (total == 0) return [];
    return data.map((e) {
      final color = AppColors.categoryColors[e.key.name] ?? AppColors.primary;
      final pct = (e.value / total) * 100;
      return PieChartSectionData(
        color: color, value: e.value,
        title: '${pct.toStringAsFixed(0)}%', radius: 30,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
      );
    }).toList();
  }
}

class _CategoryRow extends StatelessWidget {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  const _CategoryRow({required this.category, required this.amount, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[category.name] ?? AppColors.primary;
    String emoji = '🛒';
    if (category == TransactionCategory.food) emoji = '🍔';
    if (category == TransactionCategory.transport) emoji = '🚗';
    if (category == TransactionCategory.utilities) emoji = '🧾';
    if (category == TransactionCategory.entertainment) emoji = '🎬';
    if (category == TransactionCategory.health) emoji = '🏥';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name[0].toUpperCase() + category.name.substring(1),
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(height: 6, decoration: BoxDecoration(
                        color: AppColors.border, borderRadius: BorderRadius.circular(3))),
                    FractionallySizedBox(
                      widthFactor: percentage.clamp(0.0, 1.0),
                      child: Container(height: 6, decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(3))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(AppFormatters.formatCurrency(amount),
              style: const TextStyle(color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }
}
