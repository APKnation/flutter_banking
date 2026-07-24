import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/card_model.dart';
import '../../core/widgets/section_header.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageCtrl = PageController(viewportFraction: 0.85);
  int _currIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = MockData.cards;
    if (cards.isEmpty) return const Scaffold();

    final activeCard = cards[_currIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Cards'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Card Carousel
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: cards.length,
                onPageChanged: (i) => setState(() => _currIndex = i),
                itemBuilder: (context, i) {
                  return AnimatedScale(
                    scale: _currIndex == i ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: _DebitCard(card: cards[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currIndex == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currIndex == i ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Card Settings
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _SettingsSwitch(
                    title: 'Online Transactions',
                    subtitle: 'Allow payments on the web',
                    icon: Icons.language_rounded,
                    value: activeCard.onlineTransactions,
                    onChanged: (v) {},
                  ),
                  const Divider(color: AppColors.border, height: 1, indent: 60),
                  _SettingsSwitch(
                    title: 'ATM Withdrawals',
                    subtitle: 'Allow cash withdrawals',
                    icon: Icons.local_atm_rounded,
                    value: activeCard.atmWithdrawals,
                    onChanged: (v) {},
                  ),
                  const Divider(color: AppColors.border, height: 1, indent: 60),
                  _SettingsSwitch(
                    title: 'International Payments',
                    subtitle: 'Allow payments abroad',
                    icon: Icons.flight_takeoff_rounded,
                    value: activeCard.internationalPayments,
                    onChanged: (v) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Actions
            SectionHeader(title: 'Manage Card', padding: const EdgeInsets.symmetric(horizontal: 20)),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ActionTile(
                    title: 'Show PIN',
                    icon: Icons.dialpad_rounded,
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: activeCard.status == CardStatus.frozen ? 'Unfreeze Card' : 'Freeze Card',
                    icon: Icons.ac_unit_rounded,
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: 'Replace Card',
                    icon: Icons.credit_card_off_rounded,
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _DebitCard extends StatelessWidget {
  final CardModel card;
  const _DebitCard({required this.card});

  static const _gradients = [
    AppColors.darkGradient,
    AppColors.primaryGradient,
    AppColors.goldGradient,
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[card.gradientIndex % _gradients.length];
    final isFrozen = card.status == CardStatus.frozen;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 20, offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.contactless_rounded, color: Colors.white, size: 28),
                  Text(card.type.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                card.cardNumber.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
                style: const TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w600, letterSpacing: 2),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CARDHOLDER',
                          style: TextStyle(color: Colors.white54, fontSize: 9,
                              letterSpacing: 1, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(card.cardholderName,
                          style: const TextStyle(color: Colors.white, fontSize: 13,
                              fontWeight: FontWeight.w600, letterSpacing: 1)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EXPIRES',
                          style: TextStyle(color: Colors.white54, fontSize: 9,
                              letterSpacing: 1, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(card.expiryDate,
                          style: const TextStyle(color: Colors.white, fontSize: 13,
                              fontWeight: FontWeight.w600, letterSpacing: 1)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CVV',
                          style: TextStyle(color: Colors.white54, fontSize: 9,
                              letterSpacing: 1, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('•••',
                          style: TextStyle(color: Colors.white, fontSize: 13,
                              fontWeight: FontWeight.w600, letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Frosted glass overlay if frozen
        if (isFrozen)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ac_unit_rounded, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text('FROZEN', style: TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title, required this.subtitle,
    required this.icon, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title, required this.icon,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(color: color,
                  fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
