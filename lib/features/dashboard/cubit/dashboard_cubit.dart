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
        _repo.getWeeklySpending(),
      ]);

      final user        = results[0];
      final accounts    = results[1] as dynamic;
      final txns        = results[2] as dynamic;
      final weeklyData  = results[3] as List<double>;

      final totalBalance = (accounts as List)
          .fold<double>(0, (s, a) => s + (a.balance as double));

      // Guard: if there is no user document yet, emit an error prompting seed
      if (user == null) {
        emit(const DashboardError(
            'No user data found in Firebase. Please seed the database first.'));
        return;
      }

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
