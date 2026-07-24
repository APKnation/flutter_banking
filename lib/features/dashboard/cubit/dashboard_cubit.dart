import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/banking_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BankingRepository _repo;
  DashboardCubit(this._repo) : super(const DashboardInitial());

  Future<void> load() async {
    emit(const DashboardLoading());
    try {
      final user = await _repo.getUser();
      if (user == null) {
        emit(const DashboardError(
            'No user data found in Firebase. Please seed the database first.'));
        return;
      }
      final accounts     = await _repo.getAccounts();
      final txns         = await _repo.getTransactions(limit: 5);
      final weeklyData   = await _repo.getWeeklySpending();
      final totalBalance = accounts.fold<double>(0, (s, a) => s + a.balance);

      emit(DashboardLoaded(
        user: user,
        accounts: accounts,
        recentTransactions: txns,
        weeklySpending: weeklyData,
        balanceVisible: true,
        totalBalance: totalBalance,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  void toggleBalanceVisibility() {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(balanceVisible: !s.balanceVisible));
  }

  Future<void> refresh() => load();
}
