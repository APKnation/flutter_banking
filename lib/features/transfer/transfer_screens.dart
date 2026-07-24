import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_data.dart';

// ── Transfer Success ──────────────────────────────────────────────────────────
class TransferSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const TransferSuccessScreen({super.key, this.extra});

  @override
  State<TransferSuccessScreen> createState() => _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends State<TransferSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _circleScale;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _circleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _circleScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _circleCtrl, curve: Curves.elasticOut));
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(_contentCtrl);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    _runAnim();
  }

  Future<void> _runAnim() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _circleCtrl.forward();
    await _contentCtrl.forward();
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount    = (widget.extra?['amount'] as double?) ?? 0;
    final recipient = widget.extra?['recipient'] as String? ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              // Success circle
              ScaleTransition(
                scale: _circleScale,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 32),
              // Content
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: Column(
                    children: [
                      const Text('Money Sent!', style: TextStyle(fontSize: 28,
                          fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Your transfer of ${AppFormatters.formatCurrency(amount)}\nto $recipient was successful.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
                      const SizedBox(height: 32),
                      // Receipt card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            _ReceiptRow('Amount', AppFormatters.formatCurrency(amount)),
                            const Divider(color: AppColors.border, height: 20),
                            _ReceiptRow('Recipient', recipient),
                            const Divider(color: AppColors.border, height: 20),
                            _ReceiptRow('Date', AppFormatters.formatDateTime(DateTime.now())),
                            const Divider(color: AppColors.border, height: 20),
                            _ReceiptRow('Status', 'Completed ✓'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Buttons
              AppButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Share Receipt',
                style: AppButtonStyle.secondary,
                icon: Icons.share_rounded,
                onPressed: () {}, // In a real app, share PDF
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13,
            fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Request Money ─────────────────────────────────────────────────────────────
class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  double _amount = 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _qrData =>
      'neobank://request?account=${MockData.accounts.first.accountNumber}'
      '&amount=$_amount&note=${_noteCtrl.text}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Request Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: _qrData,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(MockData.currentUser.name,
                      style: const TextStyle(fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.maskAccountNumber(
                      MockData.accounts.first.accountNumber),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  if (_amount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(AppFormatters.formatCurrency(_amount),
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Amount input
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Request amount (optional)',
                prefixText: 'TSH ',
                filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add a reason (optional)',
                filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Share Link',
                    style: AppButtonStyle.secondary,
                    icon: Icons.link_rounded,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'WhatsApp',
                    icon: Icons.chat_rounded,
                    gradient: AppColors.accentGradient,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
