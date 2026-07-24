import '../mock/mock_data.dart';
import '../models/account_model.dart';
import '../models/bill_model.dart';
import '../models/card_model.dart';
import '../models/savings_goal_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

/// Mock repository — swap with real API calls for production.
class BankingRepository {
  static final BankingRepository _instance = BankingRepository._();
  factory BankingRepository() => _instance;
  BankingRepository._();

  // Local mutable state
  final List<AccountModel>      _accounts      = List.from(MockData.accounts);
  final List<CardModel>         _cards         = List.from(MockData.cards);
  final List<SavingsGoalModel>  _goals         = List.from(MockData.savingsGoals);
  List<TransactionModel>        _transactions  = MockData.transactions;

  // ── User ────────────────────────────────────────────────────────────────────
  Future<UserModel> getUser() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.currentUser;
  }

  // ── Accounts ─────────────────────────────────────────────────────────────────
  Future<List<AccountModel>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_accounts);
  }

  double get totalBalance =>
      _accounts.fold(0, (sum, a) => sum + a.balance);

  // ── Transactions ─────────────────────────────────────────────────────────────
  Future<List<TransactionModel>> getTransactions({
    int? limit,
    TransactionType? type,
    TransactionCategory? category,
    TransactionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    var list = List<TransactionModel>.from(_transactions);

    if (type != null)     list = list.where((t) => t.type == type).toList();
    if (category != null) list = list.where((t) => t.category == category).toList();
    if (status != null)   list = list.where((t) => t.status == status).toList();
    if (fromDate != null) list = list.where((t) => t.createdAt.isAfter(fromDate)).toList();
    if (toDate != null)   list = list.where((t) => t.createdAt.isBefore(toDate)).toList();
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((t) =>
        t.title.toLowerCase().contains(q) ||
        (t.recipientName?.toLowerCase().contains(q) ?? false) ||
        (t.referenceId?.toLowerCase().contains(q) ?? false),
      ).toList();
    }
    if (limit != null) list = list.take(limit).toList();
    return list;
  }

  Future<void> addTransaction(TransactionModel t) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _transactions = [t, ..._transactions];
  }

  // ── Cards ─────────────────────────────────────────────────────────────────────
  Future<List<CardModel>> getCards() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_cards);
  }

  Future<void> updateCard(CardModel updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _cards.indexWhere((c) => c.id == updated.id);
    if (idx != -1) _cards[idx] = updated;
  }

  // ── Billers ───────────────────────────────────────────────────────────────────
  Future<List<BillerModel>> getBillers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.billers;
  }

  // ── Savings Goals ─────────────────────────────────────────────────────────────
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_goals);
  }

  Future<void> updateGoal(SavingsGoalModel updated) async {
    final idx = _goals.indexWhere((g) => g.id == updated.id);
    if (idx != -1) _goals[idx] = updated;
  }

  // ── Analytics ─────────────────────────────────────────────────────────────────
  Future<Map<TransactionCategory, double>> getSpendingByCategory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.spendingByCategory;
  }

  Future<List<double>> getMonthlySpending() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.monthlySpending;
  }

  Future<List<double>> getMonthlyIncome() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.monthlyIncome;
  }

  // ── Exchange Rates ────────────────────────────────────────────────────────────
  Future<Map<String, double>> getExchangeRates() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.exchangeRates;
  }
}
