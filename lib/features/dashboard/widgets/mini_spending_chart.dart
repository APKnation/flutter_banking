import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';

class MiniSpendingChart extends StatefulWidget {
  final List<double> weeklyData;
  const MiniSpendingChart({super.key, required this.weeklyData});

  @override
  State<MiniSpendingChart> createState() => _MiniSpendingChartState();
}

class _MiniSpendingChartState extends State<MiniSpendingChart> {
  bool _isMonthly = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Spending Overview',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              _ToggleChip(
                isMonthly: _isMonthly,
                onToggle: () => setState(() => _isMonthly = !_isMonthly),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('This week vs. last week',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (widget.weeklyData.reduce((a, b) => a > b ? a : b) * 1.3),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceElevated,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      AppFormatters.formatCompact(rod.toY),
                      const TextStyle(color: AppColors.textPrimary, fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(days[v.toInt().clamp(0, 6)],
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: widget.weeklyData.asMap().entries.map((e) {
                  final isHighest = e.value ==
                      widget.weeklyData.reduce((a, b) => a > b ? a : b);
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        gradient: isHighest ? AppColors.primaryGradient : null,
                        color: isHighest ? null : AppColors.surfaceCard,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final bool isMonthly;
  final VoidCallback onToggle;
  const _ToggleChip({required this.isMonthly, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Chip(label: 'Week', selected: !isMonthly),
            _Chip(label: 'Month', selected: isMonthly),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  const _Chip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMuted,
            fontSize: 11, fontWeight: FontWeight.w600,
          )),
    );
  }
}
