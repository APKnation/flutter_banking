import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/mock/mock_data.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;

  Map<String, String>? _selectedContact;
  String _fromAccount = 'acc-001';
  double _amount = 0;
  String _note = '';
  String _transferType = 'Instant';
  bool _isLoading = false;

  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _step++);
    } else {
      _confirm();
    }
  }

  void _back() {
    if (_step > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _confirm() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      context.pushReplacement('/transfer/success',
          extra: {'amount': _amount, 'recipient': _selectedContact?['name'] ?? 'Unknown'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: _back,
        ),
        title: const Text('Send Money'),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('${_step + 1}/3',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          )),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _step ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          const SizedBox(height: 16),
          // Pages
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _RecipientStep(
                  contacts: MockData.recentContacts,
                  selected: _selectedContact,
                  onSelect: (c) { setState(() => _selectedContact = c); _next(); },
                ),
                _AmountStep(
                  amountCtrl: _amountCtrl,
                  noteCtrl: _noteCtrl,
                  fromAccount: _fromAccount,
                  accounts: MockData.accounts,
                  transferType: _transferType,
                  onAccountChange: (v) => setState(() => _fromAccount = v),
                  onTypeChange: (v) => setState(() => _transferType = v),
                  onAmountChange: (v) => setState(() => _amount = double.tryParse(v) ?? 0),
                  onNoteChange: (v) => setState(() => _note = v),
                ),
                _ConfirmStep(
                  contact: _selectedContact,
                  amount: _amount,
                  note: _note,
                  transferType: _transferType,
                ),
              ],
            ),
          ),
          // Bottom CTA
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: AppButton(
                label: _step == 2 ? 'Confirm & Send' : 'Continue',
                icon: _step == 2 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                isLoading: _isLoading,
                onPressed: _amount > 0 || _step == 0 ? _next : null,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Step 1: Recipient Selection ───────────────────────────────────────────────
class _RecipientStep extends StatefulWidget {
  final List<Map<String, String>> contacts;
  final Map<String, String>? selected;
  final ValueChanged<Map<String, String>> onSelect;

  const _RecipientStep({required this.contacts, this.selected, required this.onSelect});

  @override
  State<_RecipientStep> createState() => _RecipientStepState();
}

class _RecipientStepState extends State<_RecipientStep> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.contacts.where((c) =>
        c['name']!.toLowerCase().contains(_query.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Who are you sending to?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          // Search
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search name, phone, or email…',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              fillColor: AppColors.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Contacts',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final isSelected = widget.selected?['name'] == c['name'];
                return GestureDetector(
                  onTap: () => widget.onSelect(c),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(c['initials']!,
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name']!, style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Text(c['phone']!, style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Amount & Details ──────────────────────────────────────────────────
class _AmountStep extends StatelessWidget {
  final TextEditingController amountCtrl;
  final TextEditingController noteCtrl;
  final String fromAccount;
  final List accounts;
  final String transferType;
  final ValueChanged<String> onAccountChange;
  final ValueChanged<String> onTypeChange;
  final ValueChanged<String> onAmountChange;
  final ValueChanged<String> onNoteChange;

  const _AmountStep({
    required this.amountCtrl, required this.noteCtrl, required this.fromAccount,
    required this.accounts, required this.transferType,
    required this.onAccountChange, required this.onTypeChange,
    required this.onAmountChange, required this.onNoteChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Amount', style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          // Big amount input
          Center(
            child: Column(
              children: [
                const Text('USD', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 4),
                IntrinsicWidth(
                  child: TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    onChanged: onAmountChange,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w800,
                          color: AppColors.textDisabled),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w800,
                          color: AppColors.textMuted),
                    ),
                  ),
                ),
                Container(height: 2, width: 120, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // From account
          const Text('From Account', style: TextStyle(color: AppColors.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: fromAccount,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: accounts.map<DropdownMenuItem<String>>((a) =>
                    DropdownMenuItem(value: a.id, child: Text(
                        '${a.name}  ·  ${AppFormatters.formatCurrency(a.balance)}'))).toList(),
                onChanged: (v) { if (v != null) onAccountChange(v); },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Transfer type
          const Text('Transfer Type', style: TextStyle(color: AppColors.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Instant', 'Standard', 'Scheduled'].map((t) {
              final selected = transferType == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChange(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(t, style: TextStyle(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Note
          TextField(
            controller: noteCtrl,
            onChanged: onNoteChange,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border)),
              prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          // Fee info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Text('No transfer fee for this transaction',
                    style: TextStyle(color: AppColors.success, fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Confirmation ──────────────────────────────────────────────────────
class _ConfirmStep extends StatelessWidget {
  final Map<String, String>? contact;
  final double amount;
  final String note;
  final String transferType;

  const _ConfirmStep({this.contact, required this.amount,
      required this.note, required this.transferType});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text('Confirm Transfer', style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          // Recipient avatar
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(contact?['initials'] ?? '??',
                  style: const TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Text(contact?['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(contact?['phone'] ?? '',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          // Amount display
          Text(AppFormatters.formatCurrency(amount),
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, letterSpacing: -1)),
          const SizedBox(height: 32),
          // Details card
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
                _Row('Transfer Type', transferType),
                const Divider(color: AppColors.border, height: 20),
                _Row('Fee', 'Free'),
                const Divider(color: AppColors.border, height: 20),
                _Row('You Pay', AppFormatters.formatCurrency(amount),
                    valueColor: AppColors.textPrimary, bold: true),
                if (note.isNotEmpty) ...[
                  const Divider(color: AppColors.border, height: 20),
                  _Row('Note', note),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Your PIN or biometrics will be required to complete this transfer.',
                      style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _Row(this.label, this.value, {this.valueColor, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}
