import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction_model.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentTransactionsWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions
          .map((t) => TransactionListTile(transaction: t))
          .toList(),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.isIncoming;
    final isPending  = transaction.status == TransactionStatus.pending;
    final isFailed   = transaction.status == TransactionStatus.failed;

    Color amountColor;
    if (isFailed) {
      amountColor = AppColors.textMuted;
    } else if (isPending) {
      amountColor = AppColors.warning;
    } else if (isIncoming) {
      amountColor = AppColors.success;
    } else {
      amountColor = AppColors.error;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _categoryBg(transaction.category),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(transaction.categoryEmoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(AppFormatters.formatDateTime(transaction.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncoming ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: amountColor,
                      decoration: isFailed ? TextDecoration.lineThrough : null),
                ),
                const SizedBox(height: 3),
                _StatusChip(status: transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryBg(TransactionCategory cat) {
    final hex = AppColors.categoryColors[cat.name] ?? AppColors.surface;
    return hex.withValues(alpha: 0.15);
  }
}

class _StatusChip extends StatelessWidget {
  final TransactionStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (status) {
      case TransactionStatus.completed:
        color = AppColors.success; label = 'Done';
        break;
      case TransactionStatus.pending:
        color = AppColors.warning; label = 'Pending';
        break;
      case TransactionStatus.failed:
        color = AppColors.error; label = 'Failed';
        break;
      case TransactionStatus.processing:
        color = AppColors.primary; label = 'Processing';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
