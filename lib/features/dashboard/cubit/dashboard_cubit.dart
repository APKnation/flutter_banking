import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/banking_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BankingRepository _repo;
  DashboardCubit(this._repo) : super(const DashboardInitial());

  Future<void> load() async {
    emit(const DashboardLoading());
    try {
      final results = await Future.wait([
        _repo.getUser(),
        _repo.getAccounts(),
        _repo.getTransactions(limit: 5),
      ]);
      final accounts = results[1] as dynamic;
      final totalBalance = accounts.fold<double>(0, (s, a) => s + a.balance);
      emit(DashboardLoaded(
        user: results[0] as dynamic,
        accounts: accounts,
        recentTransactions: results[2] as dynamic,
        weeklySpending: [120, 250, 80, 340, 190, 420, 270],
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
