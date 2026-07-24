import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account_model.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final bool isVisible;
  final VoidCallback onToggle;
  final String userName;
  final int notificationCount;
  final VoidCallback onNotificationTap;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.isVisible,
    required this.onToggle,
    required this.userName,
    required this.notificationCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(userName.split(' ').first,
                      style: const TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Row(
                children: [
                  // Notification bell
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Stack(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_rounded,
                              color: Colors.white, size: 20),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            top: 6, right: 6,
                            child: Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Balance label
          Row(
            children: [
              Text('Total Balance',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(isVisible),
              isVisible
                  ? AppFormatters.formatCurrency(totalBalance)
                  : '\$ ••••••••',
              style: const TextStyle(color: Colors.white, fontSize: 34,
                  fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _StatPill(label: 'Income', amount: 6700, icon: Icons.arrow_downward_rounded,
                  color: AppColors.success),
              const SizedBox(width: 12),
              _StatPill(label: 'Spend', amount: 3240, icon: Icons.arrow_upward_rounded,
                  color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _StatPill({required this.label, required this.amount,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10, fontWeight: FontWeight.w500)),
                Text(AppFormatters.formatCompact(amount),
                    style: const TextStyle(color: Colors.white, fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account Summary Cards ─────────────────────────────────────────────────────

class AccountSummaryCard extends StatelessWidget {
  final AccountModel account;
  final bool isVisible;
  final VoidCallback onTap;

  const AccountSummaryCard({
    super.key,
    required this.account,
    required this.isVisible,
    required this.onTap,
  });

  static const List<LinearGradient> _gradients = [
    AppColors.primaryGradient,
    AppColors.accentGradient,
    AppColors.goldGradient,
  ];

  static const List<IconData> _icons = [
    Icons.savings_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.trending_up_rounded,
    Icons.credit_score_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final gradIndex = account.type.index % _gradients.length;
    final iconIndex = account.type.index % _icons.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: _gradients[gradIndex],
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: _gradients[gradIndex].colors.first.withValues(alpha: 0.3),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icons[iconIndex], color: Colors.white, size: 20),
                ),
                if (account.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Primary',
                        style: TextStyle(color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const Spacer(),
            Text(account.name,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              isVisible
                  ? AppFormatters.formatCurrency(account.balance)
                  : '\$••••••',
              style: const TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w800),
            ),
            if (account.interestRate != null) ...[
              const SizedBox(height: 4),
              Text('${account.interestRate}% p.a.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}
