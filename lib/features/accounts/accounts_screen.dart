import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/account_model.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = MockData.accounts;
    final total = accounts.fold(0.0, (s, a) => s + a.balance);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Net Worth',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(AppFormatters.formatCurrency(total),
                      style: const TextStyle(color: Colors.white, fontSize: 32,
                          fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: AppColors.accent, size: 16),
                      const SizedBox(width: 6),
                      const Text('+8.2% this year',
                          style: TextStyle(color: AppColors.accent, fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('All Accounts', style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            ...accounts.map((a) => _AccountCard(account: a,
                onTap: () => context.push('/accounts/detail', extra: a))),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onTap;
  const _AccountCard({required this.account, required this.onTap});

  static const List<LinearGradient> _gradients = [
    AppColors.primaryGradient, AppColors.accentGradient, AppColors.goldGradient,
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[account.type.index % _gradients.length];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: grad, borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(account.name, style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15)),
                      if (account.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Primary',
                              style: TextStyle(color: AppColors.primary, fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(AppFormatters.maskAccountNumber(account.accountNumber),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(AppFormatters.formatCurrency(account.balance),
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontSize: 16)),
                const SizedBox(height: 4),
                Text(account.typeLabel,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account Detail Screen ─────────────────────────────────────────────────────
class AccountDetailScreen extends StatelessWidget {
  final AccountModel account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final qrData = 'neobank://pay?iban=${account.iban}&bic=${account.bic}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: Column(
                children: [
                  Text(account.typeLabel,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(AppFormatters.formatCurrency(account.balance),
                      style: const TextStyle(color: Colors.white, fontSize: 36,
                          fontWeight: FontWeight.w800, letterSpacing: -1)),
                  if (account.interestRate != null) ...[
                    const SizedBox(height: 8),
                    Text('${account.interestRate}% interest p.a.',
                        style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _DetailRow('Account Number', account.accountNumber, copyable: true),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow('IBAN', account.iban, copyable: true),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow('BIC / SWIFT', account.bic, copyable: true),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow('Currency', account.currency),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow('Status', account.isPrimary ? 'Primary Account' : 'Active'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // QR Code
            const Text('Share via QR', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(data: qrData, size: 180, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Download Statement',
              style: AppButtonStyle.secondary,
              icon: Icons.download_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  const _DetailRow(this.label, this.value, {this.copyable = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: AppColors.textPrimary,
                fontSize: 13, fontWeight: FontWeight.w600)),
            if (copyable) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1)));
                },
                child: const Icon(Icons.copy_rounded,
                    color: AppColors.primary, size: 16),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
