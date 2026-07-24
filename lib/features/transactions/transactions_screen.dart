import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/banking_repository.dart';
import '../dashboard/widgets/recent_transactions_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _repo = BankingRepository();
  List<TransactionModel> _txns = [];
  List<TransactionModel> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();
  TransactionType? _typeFilter;
  TransactionStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final txns = await _repo.getTransactions();
    setState(() { _txns = txns; _filtered = txns; _loading = false; });
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _txns.where((t) {
        final matchQ = q.isEmpty ||
            t.title.toLowerCase().contains(q) ||
            (t.recipientName?.toLowerCase().contains(q) ?? false) ||
            (t.referenceId?.toLowerCase().contains(q) ?? false);
        final matchType   = _typeFilter == null   || t.type == _typeFilter;
        final matchStatus = _statusFilter == null || t.status == _statusFilter;
        return matchQ && matchType && matchStatus;
      }).toList();
    });
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        selectedType: _typeFilter,
        selectedStatus: _statusFilter,
        onApply: (type, status) {
          setState(() { _typeFilter = type; _statusFilter = status; });
          _applyFilter();
        },
      ),
    );
  }

  // Group by date
  Map<String, List<TransactionModel>> get _grouped {
    final map = <String, List<TransactionModel>>{};
    for (final t in _filtered) {
      final key = AppFormatters.formatDate(t.createdAt);
      (map[key] ??= []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Transaction History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded),
                if (_typeFilter != null || _statusFilter != null)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                  ),
              ],
            ),
            onPressed: _showFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _search,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search transactions…',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                        onPressed: () { _search.clear(); _applyFilter(); })
                    : null,
                filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
          // Active filters
          if (_typeFilter != null || _statusFilter != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_typeFilter != null) _FilterChip(
                    label: _typeFilter!.name,
                    onRemove: () { setState(() => _typeFilter = null); _applyFilter(); },
                  ),
                  if (_statusFilter != null) _FilterChip(
                    label: _statusFilter!.name,
                    onRemove: () { setState(() => _statusFilter = null); _applyFilter(); },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          if (_loading)
            Expanded(
              child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (_, __) => const ShimmerTransactionItem()),
            )
          else if (_filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 56,
                        color: AppColors.textDisabled),
                    const SizedBox(height: 12),
                    const Text('No transactions found',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    if (_search.text.isNotEmpty || _typeFilter != null)
                      TextButton(
                        onPressed: () {
                          _search.clear();
                          setState(() { _typeFilter = null; _statusFilter = null; });
                          _applyFilter();
                        },
                        child: const Text('Clear filters',
                            style: TextStyle(color: AppColors.primary)),
                      ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _grouped.length,
                  itemBuilder: (_, groupIndex) {
                    final key  = _grouped.keys.elementAt(groupIndex);
                    final items = _grouped[key]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Text(key,
                              style: const TextStyle(color: AppColors.textMuted,
                                  fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Column(
                            children: items.asMap().entries.map((e) => Column(
                              children: [
                                TransactionListTile(
                                  transaction: e.value,
                                  onTap: () => _showDetail(context, e.value),
                                ),
                                if (e.key < items.length - 1)
                                  const Divider(height: 1, indent: 20, endIndent: 20,
                                      color: AppColors.border),
                              ],
                            )).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext ctx, TransactionModel t) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => TransactionDetailSheet(transaction: t),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12,
              fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, color: AppColors.primary, size: 14),
          ),
        ],
      ),
    );
  }
}

// ── Filter Sheet ──────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final void Function(TransactionType?, TransactionStatus?) onApply;

  const _FilterSheet({this.selectedType, this.selectedStatus, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  TransactionType? _type;
  TransactionStatus? _status;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _status = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Text('Filter Transactions', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 24),
          const Text('Transaction Type', style: TextStyle(color: AppColors.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: TransactionType.values.map((t) {
              final sel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = sel ? null : t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(t.name[0].toUpperCase() + t.name.substring(1),
                      style: TextStyle(color: sel ? Colors.white : AppColors.textSecondary,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Status', style: TextStyle(color: AppColors.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: TransactionStatus.values.map((s) {
              final sel = _status == s;
              return GestureDetector(
                onTap: () => setState(() => _status = sel ? null : s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppColors.accent : AppColors.border),
                  ),
                  child: Text(s.name[0].toUpperCase() + s.name.substring(1),
                      style: TextStyle(color: sel ? Colors.white : AppColors.textSecondary,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() { _type = null; _status = null; });
                    widget.onApply(null, null);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_type, _status);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Transaction Detail Sheet ──────────────────────────────────────────────────
class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIn = transaction.isIncoming;
    final isFailed = transaction.status == TransactionStatus.failed;
    final color = isFailed ? AppColors.textMuted : isIn ? AppColors.success : AppColors.error;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            // Icon
            Center(
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Text(transaction.categoryEmoji,
                    style: const TextStyle(fontSize: 36))),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Text(transaction.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${isIn ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color,
                        decoration: isFailed ? TextDecoration.lineThrough : null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Row('Reference ID', transaction.referenceId ?? 'N/A'),
            _Row('Date & Time', AppFormatters.formatDateTime(transaction.createdAt)),
            _Row('Category', transaction.categoryLabel),
            _Row('Status', transaction.status.name.toUpperCase()),
            if (transaction.fromAccount.isNotEmpty)
              _Row('From', transaction.fromAccount),
            if (transaction.toAccount != null)
              _Row('To', transaction.toAccount!),
            if (transaction.fee != null)
              _Row('Fee', transaction.fee == 0 ? 'Free' : '\$${transaction.fee!.toStringAsFixed(2)}'),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              _Row('Note', transaction.note!),
            const SizedBox(height: 24),
            // Download receipt button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download Receipt'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13,
                  fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
