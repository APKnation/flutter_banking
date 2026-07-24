import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/bill_model.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_header.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billers = MockData.billers;
    final upcoming = billers.where((b) => b.isSaved).toList();
    final allCategories = BillCategory.values;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Pay Bills'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (context.canPop()) context.pop();
            else context.go('/home');
          }
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next bill alert
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.errorGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                boxShadow: [
                  BoxShadow(color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Electricity Bill Due',
                            style: TextStyle(color: Colors.white, fontWeight: 
                                FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('\$124.30 due in 3 days',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPath: () {}, // Handled by gesture detector
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SectionHeader(title: 'Saved Billers', padding: const EdgeInsets.symmetric(horizontal: 20)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: upcoming.length,
                itemBuilder: (_, i) => _SavedBillerCard(biller: upcoming[i]),
              ),
            ),
            const SizedBox(height: 32),
            SectionHeader(title: 'Categories', padding: const EdgeInsets.symmetric(horizontal: 20)),
            const SizedBox(height: 16),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: allCategories.length,
              itemBuilder: (_, i) => _CategoryButton(category: allCategories[i]),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SavedBillerCard extends StatelessWidget {
  final BillerModel biller;
  const _SavedBillerCard({required this.biller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(biller.emoji, style: const TextStyle(fontSize: 24)),
              const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(biller.name,
                  style: const TextStyle(color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(AppFormatters.formatCurrency(biller.lastAmount),
                  style: const TextStyle(color: AppColors.primary,
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final BillCategory category;
  const _CategoryButton({required this.category});

  @override
  Widget build(BuildContext context) {
    String emoji;
    switch (category) {
      case BillCategory.electricity: emoji = '⚡'; break;
      case BillCategory.water: emoji = '💧'; break;
      case BillCategory.internet: emoji = '📡'; break;
      case BillCategory.phone: emoji = '📱'; break;
      case BillCategory.subscription: emoji = '🎬'; break;
      case BillCategory.insurance: emoji = '🏥'; break;
      case BillCategory.gas: emoji = '🔥'; break;
      case BillCategory.other: emoji = '🧾'; break;
    }

    return Column(
      children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(height: 8),
        Text(category.name[0].toUpperCase() + category.name.substring(1),
            style: const TextStyle(color: AppColors.textSecondary,
                fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
