import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';
import '../models/bill_model.dart';
import '../models/card_model.dart';
import '../models/savings_goal_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

/// Firebase Cloud Firestore repository.
/// All data is fetched from and written to Firestore.
/// Collection structure:
///   /users/{uid}
///   /accounts/{accountId}
///   /transactions/{transactionId}
///   /cards/{cardId}
///   /billers/{billerId}
///   /savings_goals/{goalId}
class BankingRepository {
  static final BankingRepository _instance = BankingRepository._();
  factory BankingRepository() => _instance;
  BankingRepository._();

  final _db = FirebaseFirestore.instance;

  // ── Convenience getters ──────────────────────────────────────────────────────
  CollectionReference get _users        => _db.collection('users');
  CollectionReference get _accounts     => _db.collection('accounts');
  CollectionReference get _transactions => _db.collection('transactions');
  CollectionReference get _cards        => _db.collection('cards');
  CollectionReference get _billers      => _db.collection('billers');
  CollectionReference get _goals        => _db.collection('savings_goals');

  // ── User ─────────────────────────────────────────────────────────────────────
  /// Fetches the currently signed-in user document.
  /// [uid] should come from Firebase Auth; hardcoded for now.
  Future<UserModel?> getUser({String uid = 'user-001'}) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  // ── Accounts ─────────────────────────────────────────────────────────────────
  Future<List<AccountModel>> getAccounts({String uid = 'user-001'}) async {
    final snap = await _accounts
        .where('ownerId', isEqualTo: uid)
        .orderBy('isPrimary', descending: true)
        .get();
    return snap.docs.map((d) => AccountModel.fromSnapshot(d)).toList();
  }

  Future<double> getTotalBalance({String uid = 'user-001'}) async {
    final accounts = await getAccounts(uid: uid);
    return accounts.fold(0.0, (sum, a) => sum + a.balance);
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    await _accounts.doc(accountId).update({'balance': newBalance});
  }

  // ── Transactions ─────────────────────────────────────────────────────────────
  Future<List<TransactionModel>> getTransactions({
    int? limit,
    TransactionType? type,
    TransactionCategory? category,
    TransactionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? query,
    String uid = 'user-001',
  }) async {
    Query q = _transactions
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    if (type != null)     q = q.where('type',   isEqualTo: type.name);
    if (status != null)   q = q.where('status', isEqualTo: status.name);
    if (category != null) q = q.where('category', isEqualTo: category.name);
    if (fromDate != null) q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
    if (toDate != null)   q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(toDate));
    if (limit != null)    q = q.limit(limit);

    final snap = await q.get();
    var results = snap.docs.map((d) => TransactionModel.fromSnapshot(d)).toList();

    // Client-side text search (Firestore doesn't support LIKE queries)
    if (query != null && query.isNotEmpty) {
      final ql = query.toLowerCase();
      results = results.where((t) =>
        t.title.toLowerCase().contains(ql) ||
        (t.recipientName?.toLowerCase().contains(ql) ?? false) ||
        (t.referenceId?.toLowerCase().contains(ql) ?? false),
      ).toList();
    }

    return results;
  }

  Future<void> addTransaction(TransactionModel t, {String uid = 'user-001'}) async {
    final data = t.toJson()..['ownerId'] = uid;
    await _transactions.doc(t.id).set(data);
  }

  // Real-time stream of recent transactions
  Stream<List<TransactionModel>> transactionsStream({
    int limit = 20,
    String uid = 'user-001',
  }) {
    return _transactions
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TransactionModel.fromSnapshot(d)).toList());
  }

  // ── Cards ────────────────────────────────────────────────────────────────────
  Future<List<CardModel>> getCards({String uid = 'user-001'}) async {
    final snap = await _cards.where('ownerId', isEqualTo: uid).get();
    return snap.docs.map((d) => CardModel.fromSnapshot(d)).toList();
  }

  Future<void> updateCard(CardModel updated, {String uid = 'user-001'}) async {
    await _cards.doc(updated.id).set(
      updated.toJson()..['ownerId'] = uid,
      SetOptions(merge: true),
    );
  }

  // ── Billers ──────────────────────────────────────────────────────────────────
  Future<List<BillerModel>> getBillers({String uid = 'user-001'}) async {
    final snap = await _billers.where('ownerId', isEqualTo: uid).get();
    return snap.docs.map((d) => BillerModel.fromSnapshot(d)).toList();
  }

  Future<void> saveBiller(BillerModel biller, {String uid = 'user-001'}) async {
    final data = biller.toJson()..['ownerId'] = uid;
    await _billers.doc(biller.id).set(data);
  }

  // ── Savings Goals ────────────────────────────────────────────────────────────
  Future<List<SavingsGoalModel>> getSavingsGoals({String uid = 'user-001'}) async {
    final snap = await _goals.where('ownerId', isEqualTo: uid).get();
    return snap.docs.map((d) => SavingsGoalModel.fromSnapshot(d)).toList();
  }

  Future<void> updateGoal(SavingsGoalModel updated, {String uid = 'user-001'}) async {
    await _goals.doc(updated.id).set(
      updated.toJson()..['ownerId'] = uid,
      SetOptions(merge: true),
    );
  }

  // ── Analytics (computed from Firestore data) ─────────────────────────────────
  Future<Map<TransactionCategory, double>> getSpendingByCategory({
    String uid = 'user-001',
  }) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final txns = await getTransactions(
      uid: uid, fromDate: startOfMonth,
      type: TransactionType.debit,
    );

    final map = <TransactionCategory, double>{};
    for (final t in txns) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Future<List<double>> getWeeklySpending({String uid = 'user-001'}) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final txns = await getTransactions(
      uid: uid,
      fromDate: DateTime(weekStart.year, weekStart.month, weekStart.day),
      type: TransactionType.debit,
    );

    final daily = List<double>.filled(7, 0.0);
    for (final t in txns) {
      final dayIndex = t.createdAt.weekday - 1;
      if (dayIndex >= 0 && dayIndex < 7) {
        daily[dayIndex] += t.amount;
      }
    }
    return daily;
  }

  // ── Exchange Rates ───────────────────────────────────────────────────────────
  Future<Map<String, double>> getExchangeRates() async {
    final doc = await _db.collection('config').doc('exchange_rates').get();
    if (!doc.exists) return {};
    final data = doc.data() as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }
}
