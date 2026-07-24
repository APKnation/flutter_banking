import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../data/repositories/banking_repository.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'widgets/balance_card.dart';
import 'widgets/mini_spending_chart.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_transactions_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(BankingRepository())..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return _buildSkeleton();
          }
          if (state is DashboardError) {
            return _buildError(context, state.message);
          }
          if (state is DashboardLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => context.read<DashboardCubit>().refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Translucent app bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: const SizedBox(),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                BalanceCard(
                  totalBalance: state.totalBalance,
                  isVisible: state.balanceVisible,
                  onToggle: () => context.read<DashboardCubit>().toggleBalanceVisibility(),
                  userName: state.user.name,
                  notificationCount: 2,
                  onNotificationTap: () => context.push('/notifications'),
                ),
                const SizedBox(height: 24),

                // Account Cards
                SectionHeader(
                  title: 'My Accounts',
                  actionLabel: 'View All',
                  onAction: () => context.push('/accounts'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.accounts.length,
                    itemBuilder: (_, i) => AccountSummaryCard(
                      account: state.accounts[i],
                      isVisible: state.balanceVisible,
                      onTap: () => context.push('/accounts/detail',
                          extra: state.accounts[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Actions
                SectionHeader(title: 'Quick Actions', padding: const EdgeInsets.symmetric(horizontal: 20)),
                const SizedBox(height: 16),
                const QuickActions(),
                const SizedBox(height: 28),

                // Spending Chart
                MiniSpendingChart(weeklyData: state.weeklySpending),
                const SizedBox(height: 28),

                // Recent Transactions
                SectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'See All',
                  onAction: () => context.go('/transactions'),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    children: state.recentTransactions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final t = entry.value;
                      return Column(
                        children: [
                          TransactionListTile(
                            transaction: t,
                            onTap: () => _showDetail(context, t),
                          ),
                          if (i < state.recentTransactions.length - 1)
                            const Divider(height: 1, indent: 20, endIndent: 20),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext ctx, t) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => _TransactionDetailSheet(transaction: t),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const ShimmerCard(height: 200),
          const SizedBox(height: 24),
          const ShimmerLoading(height: 14, width: 120),
          const SizedBox(height: 14),
          const ShimmerCard(height: 120),
          const SizedBox(height: 24),
          const ShimmerLoading(height: 14, width: 100),
          const SizedBox(height: 14),
          ...List.generate(5, (_) => const ShimmerTransactionItem()),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<DashboardCubit>().load(),
            child: const Text('Retry', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// Inline detail sheet
class _TransactionDetailSheet extends StatelessWidget {
  final dynamic transaction;
  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        color: AppColors.surface,
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(transaction.categoryEmoji,
                  style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(transaction.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${transaction.isIncoming ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800,
                  color: transaction.isIncoming ? AppColors.success : AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Reference', value: transaction.referenceId ?? 'N/A'),
            _DetailRow(label: 'Date', value: transaction.createdAt.toString().substring(0, 16)),
            _DetailRow(label: 'Category', value: transaction.categoryLabel),
            _DetailRow(label: 'Status', value: transaction.status.name.toUpperCase()),
            if (transaction.note != null)
              _DetailRow(label: 'Note', value: transaction.note!),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13,
              fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
