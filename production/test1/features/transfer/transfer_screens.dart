import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/banking_repository.dart';

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
                onPressed: () {},
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
        Text(value, style: const TextStyle(color: AppColors.textPrimary,
            fontSize: 13, fontWeight: FontWeight.w600)),
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
  final _repo = BankingRepository();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  double _amount = 0;
  AccountModel? _primaryAccount;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final accounts = await _repo.getAccounts();
      final primary = accounts.firstWhere(
        (a) => a.isPrimary,
        orElse: () => accounts.first,
      );
      setState(() { _primaryAccount = primary; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _qrData =>
      'neobank://request?account=${_primaryAccount?.accountNumber ?? ''}'
      '&amount=$_amount&note=${_noteCtrl.text}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  // QR placeholder — qr_flutter not supported on linux desktop
                  Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_rounded, size: 140, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_primaryAccount?.accountNumber ?? '',
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
