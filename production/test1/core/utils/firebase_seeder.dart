import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/account_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/card_model.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';

/// One-time seeder: uploads mock data to Firebase Cloud Firestore.
/// Run this ONCE from a button or during development to populate your
/// database. After seeding, all data lives in Firebase.
class FirebaseSeeder {
  static const _uid = 'user-001';
  static final _db = FirebaseFirestore.instance;

  static Future<void> seed() async {
    print('🌱 Starting Firebase seed...');
    await _seedUser();
    await _seedAccounts();
    await _seedTransactions();
    await _seedCards();
    await _seedBillers();
    await _seedGoals();
    await _seedExchangeRates();
    print('✅ Firebase seed complete!');
  }

  // ── User ──────────────────────────────────────────────────────────────────────
  static Future<void> _seedUser() async {
    final user = UserModel(
      id: _uid,
      name: 'Alex Johnson',
      email: 'alex.johnson@neobank.tz',
      phone: '+255 700 123 456',
      initials: 'AJ',
      kycStatus: 'verified',
      membershipTier: 'gold',
      createdAt: DateTime(2022, 3, 15),
    );
    await _db.collection('users').doc(_uid).set(user.toJson());
    print('   ✓ User seeded');
  }

  // ── Accounts ──────────────────────────────────────────────────────────────────
  static Future<void> _seedAccounts() async {
    final accounts = [
      AccountModel(
        id: 'acc-001', name: 'Main Savings',
        accountNumber: '4521897654',
        iban: 'TZ12 3456 7890 1234 5678', bic: 'NEOBK001',
        balance: 24580.50, type: AccountType.savings,
        currency: 'TSH', isPrimary: true, interestRate: 2.5,
        createdAt: DateTime(2022, 3, 15),
      ),
      AccountModel(
        id: 'acc-002', name: 'Checking Account',
        accountNumber: '7893214560',
        iban: 'TZ98 7654 3210 9876 5432', bic: 'NEOBK001',
        balance: 5430.25, type: AccountType.checking,
        currency: 'TSH', isPrimary: false,
        createdAt: DateTime(2022, 3, 15),
      ),
      AccountModel(
        id: 'acc-003', name: 'Investment Portfolio',
        accountNumber: '1234567890',
        iban: 'TZ11 2345 6789 0123 4567', bic: 'NEOBK001',
        balance: 85230.75, type: AccountType.investment,
        currency: 'TSH', isPrimary: false, interestRate: 8.2,
        createdAt: DateTime(2022, 6, 20),
      ),
    ];
    final batch = _db.batch();
    for (final a in accounts) {
      final doc = _db.collection('accounts').doc(a.id);
      batch.set(doc, a.toJson()..['ownerId'] = _uid);
    }
    await batch.commit();
    print('   ✓ Accounts seeded');
  }

  // ── Transactions ──────────────────────────────────────────────────────────────
  static Future<void> _seedTransactions() async {
    final now = DateTime.now();
    final transactions = [
      TransactionModel(id: const Uuid().v4(), title: 'Salary Deposit', amount: 5500, type: TransactionType.credit, status: TransactionStatus.completed, category: TransactionCategory.salary, createdAt: now.subtract(const Duration(days: 1)), fromAccount: 'Employer', toAccount: 'acc-001', fee: 0, referenceId: 'REF-001'),
      TransactionModel(id: const Uuid().v4(), title: 'Groceries - Shoprite', amount: 87.50, type: TransactionType.debit, status: TransactionStatus.completed, category: TransactionCategory.food, createdAt: now.subtract(const Duration(days: 2)), fromAccount: 'acc-001', fee: 0, referenceId: 'REF-002'),
      TransactionModel(id: const Uuid().v4(), title: 'Uber Ride', amount: 23.00, type: TransactionType.debit, status: TransactionStatus.completed, category: TransactionCategory.transport, createdAt: now.subtract(const Duration(days: 2)), fromAccount: 'acc-001', fee: 0, referenceId: 'REF-003'),
      TransactionModel(id: const Uuid().v4(), title: 'Netflix Subscription', amount: 15.99, type: TransactionType.bill, status: TransactionStatus.completed, category: TransactionCategory.entertainment, createdAt: now.subtract(const Duration(days: 4)), fromAccount: 'acc-001', fee: 0, referenceId: 'REF-004'),
      TransactionModel(id: const Uuid().v4(), title: 'Transfer to Sarah', amount: 250, type: TransactionType.transfer, status: TransactionStatus.completed, category: TransactionCategory.transfer, createdAt: now.subtract(const Duration(days: 5)), fromAccount: 'acc-001', toAccount: 'Sarah Mitchell', recipientName: 'Sarah Mitchell', fee: 0, referenceId: 'REF-005'),
      TransactionModel(id: const Uuid().v4(), title: 'Electricity Bill', amount: 124.30, type: TransactionType.bill, status: TransactionStatus.pending, category: TransactionCategory.utilities, createdAt: now.subtract(const Duration(days: 6)), fromAccount: 'acc-001', fee: 0, referenceId: 'REF-006'),
      TransactionModel(id: const Uuid().v4(), title: 'Investment Dividend', amount: 320.00, type: TransactionType.credit, status: TransactionStatus.completed, category: TransactionCategory.investment, createdAt: now.subtract(const Duration(days: 8)), fromAccount: 'Investment Portfolio', toAccount: 'acc-001', fee: 0, referenceId: 'REF-007'),
      TransactionModel(id: const Uuid().v4(), title: 'Pharmacy', amount: 45.00, type: TransactionType.debit, status: TransactionStatus.completed, category: TransactionCategory.health, createdAt: now.subtract(const Duration(days: 9)), fromAccount: 'acc-001', fee: 0, referenceId: 'REF-008'),
      TransactionModel(id: const Uuid().v4(), title: 'Online Shopping', amount: 199.99, type: TransactionType.debit, status: TransactionStatus.failed, category: TransactionCategory.shopping, createdAt: now.subtract(const Duration(days: 10)), fromAccount: 'acc-001', fee: 2.50, referenceId: 'REF-009'),
      TransactionModel(id: const Uuid().v4(), title: 'Water Bill', amount: 38.00, type: TransactionType.bill, status: TransactionStatus.completed, category: TransactionCategory.utilities, createdAt: now.subtract(const Duration(days: 14)), fromAccount: 'acc-001', fee: 0, referenceId: 'REF-010'),
    ];
    final batch = _db.batch();
    for (final t in transactions) {
      final doc = _db.collection('transactions').doc(t.id);
      batch.set(doc, t.toJson()..['ownerId'] = _uid);
    }
    await batch.commit();
    print('   ✓ Transactions seeded');
  }

  // ── Cards ─────────────────────────────────────────────────────────────────────
  static Future<void> _seedCards() async {
    final cards = [
      CardModel(
        id: 'card-001', cardNumber: '4521897654321234',
        cardholderName: 'Alex Johnson', expiryDate: '12/28', cvv: '123',
        type: CardType.visa, status: CardStatus.active, isVirtual: false,
        spendingLimit: 5000, currentSpend: 1230.50,
        onlineTransactions: true, atmWithdrawals: true,
        internationalPayments: false, gradientIndex: 0,
      ),
      CardModel(
        id: 'card-002', cardNumber: '5421897654321234',
        cardholderName: 'Alex Johnson', expiryDate: '08/26', cvv: '456',
        type: CardType.mastercard, status: CardStatus.frozen, isVirtual: true,
        spendingLimit: 2000, currentSpend: 0,
        onlineTransactions: true, atmWithdrawals: false,
        internationalPayments: true, gradientIndex: 2,
      ),
    ];
    final batch = _db.batch();
    for (final c in cards) {
      final doc = _db.collection('cards').doc(c.id);
      batch.set(doc, c.toJson()..['ownerId'] = _uid);
    }
    await batch.commit();
    print('   ✓ Cards seeded');
  }

  // ── Billers ───────────────────────────────────────────────────────────────────
  static Future<void> _seedBillers() async {
    final billers = [
      BillerModel(id: 'biller-001', name: 'TANESCO', category: BillCategory.electricity, lastAmount: 124.30, emoji: '⚡', isSaved: true),
      BillerModel(id: 'biller-002', name: 'DAWASCO', category: BillCategory.water, lastAmount: 38.00, emoji: '💧', isSaved: true),
      BillerModel(id: 'biller-003', name: 'Vodacom', category: BillCategory.internet, lastAmount: 55.00, emoji: '📡', isSaved: true),
      BillerModel(id: 'biller-004', name: 'NHIF', category: BillCategory.insurance, lastAmount: 30.00, emoji: '🏥', isSaved: true),
    ];
    final batch = _db.batch();
    for (final b in billers) {
      final doc = _db.collection('billers').doc(b.id);
      batch.set(doc, b.toJson()..['ownerId'] = _uid);
    }
    await batch.commit();
    print('   ✓ Billers seeded');
  }

  // ── Savings Goals ─────────────────────────────────────────────────────────────
  static Future<void> _seedGoals() async {
    final goals = [
      SavingsGoalModel(id: 'goal-001', name: 'Emergency Fund', emoji: '🛡️', targetAmount: 10000, currentAmount: 4500, colorHex: '#7C3AED', autoSave: true, autoSaveAmount: 200),
      SavingsGoalModel(id: 'goal-002', name: 'New Car', emoji: '🚗', targetAmount: 25000, currentAmount: 8000, colorHex: '#0EA5E9', targetDate: DateTime(2026, 12, 31)),
      SavingsGoalModel(id: 'goal-003', name: 'Vacation', emoji: '✈️', targetAmount: 3000, currentAmount: 2100, colorHex: '#F59E0B'),
    ];
    final batch = _db.batch();
    for (final g in goals) {
      final doc = _db.collection('savings_goals').doc(g.id);
      batch.set(doc, g.toJson()..['ownerId'] = _uid);
    }
    await batch.commit();
    print('   ✓ Savings goals seeded');
  }

  // ── Exchange Rates ────────────────────────────────────────────────────────────
  static Future<void> _seedExchangeRates() async {
    await _db.collection('config').doc('exchange_rates').set({
      'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.50, 'AUD': 1.53,
      'CAD': 1.36, 'CHF': 0.89, 'CNY': 7.24, 'INR': 83.15,
      'USD': 2500.0, // 1 USD = 2500 TSH approx
    });
    print('   ✓ Exchange rates seeded');
  }
}
