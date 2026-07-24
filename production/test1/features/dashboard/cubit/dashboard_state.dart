import 'package:equatable/equatable.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/user_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override List<Object?> get props => [];
}

class DashboardInitial   extends DashboardState { const DashboardInitial(); }
class DashboardLoading   extends DashboardState { const DashboardLoading(); }

class DashboardLoaded extends DashboardState {
  final UserModel user;
  final List<AccountModel> accounts;
  final List<TransactionModel> recentTransactions;
  final List<double> weeklySpending;
  final bool balanceVisible;
  final double totalBalance;

  const DashboardLoaded({
    required this.user,
    required this.accounts,
    required this.recentTransactions,
    required this.weeklySpending,
    required this.balanceVisible,
    required this.totalBalance,
  });

  DashboardLoaded copyWith({
    bool? balanceVisible,
    List<AccountModel>? accounts,
    List<TransactionModel>? recentTransactions,
  }) {
    return DashboardLoaded(
      user: user,
      accounts: accounts ?? this.accounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      weeklySpending: weeklySpending,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      totalBalance: totalBalance,
    );
  }

  @override
  List<Object?> get props => [user, accounts, recentTransactions, balanceVisible, totalBalance];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override List<Object?> get props => [message];
}
