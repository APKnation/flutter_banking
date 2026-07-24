import '../models/account_model.dart';
import '../models/bill_model.dart';
import '../models/card_model.dart';
import '../models/savings_goal_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class MockData {
  MockData._();

  // ── Current User ────────────────────────────────────────────────────────────
  static final UserModel currentUser = UserModel(
    id: 'user-001',
    name: 'Alex Johnson',
    email: 'alex.johnson@neobank.com',
    phone: '+1 (234) 567-8901',
    initials: 'AJ',
    kycStatus: 'verified',
    membershipTier: 'gold',
    createdAt: DateTime(2022, 3, 15),
  );

  // ── Accounts ─────────────────────────────────────────────────────────────────
  static final List<AccountModel> accounts = [
    AccountModel(
      id: 'acc-001', name: 'Main Savings',
      accountNumber: '4521897654', iban: 'US12 3456 7890 1234 5678',
      bic: 'NEOBK001', balance: 24580.50, type: AccountType.savings,
      currency: 'TSH', isPrimary: true, interestRate: 2.5,
      createdAt: DateTime(2022, 3, 15),
    ),
    AccountModel(
      id: 'acc-002', name: 'Checking Account',
      accountNumber: '7893214560', iban: 'US98 7654 3210 9876 5432',
      bic: 'NEOBK001', balance: 5430.25, type: AccountType.checking,
      currency: 'TSH', isPrimary: false,
      createdAt: DateTime(2022, 3, 15),
    ),
    AccountModel(
      id: 'acc-003', name: 'Investment Portfolio',
      accountNumber: '1234567890', iban: 'US11 2345 6789 0123 4567',
      bic: 'NEOBK001', balance: 85230.75, type: AccountType.investment,
      currency: 'TSH', isPrimary: false, interestRate: 8.2,
      createdAt: DateTime(2022, 6, 20),
    ),
  ];

  // ── Transactions ─────────────────────────────────────────────────────────────
  static List<TransactionModel> get transactions {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'txn-001', title: 'Salary Deposit',
        subtitle: 'Monthly salary — Employer Inc.',
        amount: 5500.00, type: TransactionType.credit,
        status: TransactionStatus.completed, category: TransactionCategory.salary,
        createdAt: now.subtract(const Duration(hours: 2)),
        fromAccount: 'Employer Inc.', toAccount: 'acc-001',
        referenceId: 'REF2024001', fee: 0,
      ),
      TransactionModel(
        id: 'txn-002', title: 'Starbucks Coffee',
        subtitle: 'Grand Central Station',
        amount: 12.50, type: TransactionType.debit,
        status: TransactionStatus.completed, category: TransactionCategory.food,
        createdAt: now.subtract(const Duration(hours: 5)),
        fromAccount: 'acc-002', referenceId: 'REF2024002', fee: 0,
      ),
      TransactionModel(
        id: 'txn-003', title: 'Netflix Subscription',
        subtitle: 'Monthly renewal',
        amount: 15.99, type: TransactionType.bill,
        status: TransactionStatus.completed, category: TransactionCategory.entertainment,
        createdAt: now.subtract(const Duration(days: 1)),
        fromAccount: 'acc-002', referenceId: 'REF2024003',
      ),
      TransactionModel(
        id: 'txn-004', title: 'Transfer to Sarah',
        subtitle: 'P2P Transfer',
        amount: 250.00, type: TransactionType.transfer,
        status: TransactionStatus.completed, category: TransactionCategory.transfer,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        fromAccount: 'acc-001', toAccount: 'acc-sarah',
        recipientName: 'Sarah Mitchell', note: 'Dinner split', fee: 0,
        referenceId: 'REF2024004',
      ),
      TransactionModel(
        id: 'txn-005', title: 'Amazon Purchase',
        subtitle: 'Electronics & Tech',
        amount: 89.99, type: TransactionType.debit,
        status: TransactionStatus.completed, category: TransactionCategory.shopping,
        createdAt: now.subtract(const Duration(days: 2)),
        fromAccount: 'acc-002', referenceId: 'REF2024005',
      ),
      TransactionModel(
        id: 'txn-006', title: 'Electricity Bill',
        subtitle: 'ConEd Utilities',
        amount: 124.30, type: TransactionType.bill,
        status: TransactionStatus.completed, category: TransactionCategory.utilities,
        createdAt: now.subtract(const Duration(days: 3)),
        fromAccount: 'acc-001', referenceId: 'REF2024006',
      ),
      TransactionModel(
        id: 'txn-007', title: 'Freelance Payment',
        subtitle: 'Project delivery milestone',
        amount: 1200.00, type: TransactionType.credit,
        status: TransactionStatus.completed, category: TransactionCategory.salary,
        createdAt: now.subtract(const Duration(days: 4)),
        fromAccount: 'Client Corp', toAccount: 'acc-001',
        referenceId: 'REF2024007',
      ),
      TransactionModel(
        id: 'txn-008', title: 'Gym Membership',
        subtitle: 'FitLife Monthly',
        amount: 49.99, type: TransactionType.bill,
        status: TransactionStatus.pending, category: TransactionCategory.health,
        createdAt: now.subtract(const Duration(days: 4, hours: 6)),
        fromAccount: 'acc-002', referenceId: 'REF2024008',
      ),
      TransactionModel(
        id: 'txn-009', title: 'Uber Ride',
        subtitle: 'Airport → Downtown',
        amount: 38.50, type: TransactionType.debit,
        status: TransactionStatus.completed, category: TransactionCategory.transport,
        createdAt: now.subtract(const Duration(days: 5)),
        fromAccount: 'acc-002', referenceId: 'REF2024009',
      ),
      TransactionModel(
        id: 'txn-010', title: 'Investment Dividend',
        subtitle: 'Q3 Portfolio Return',
        amount: 430.20, type: TransactionType.credit,
        status: TransactionStatus.completed, category: TransactionCategory.investment,
        createdAt: now.subtract(const Duration(days: 7)),
        fromAccount: 'Portfolio', toAccount: 'acc-003',
        referenceId: 'REF2024010',
      ),
      TransactionModel(
        id: 'txn-011', title: 'Whole Foods Market',
        subtitle: 'Weekly groceries',
        amount: 87.40, type: TransactionType.debit,
        status: TransactionStatus.completed, category: TransactionCategory.food,
        createdAt: now.subtract(const Duration(days: 8)),
        fromAccount: 'acc-002', referenceId: 'REF2024011',
      ),
      TransactionModel(
        id: 'txn-012', title: 'Failed Transfer',
        subtitle: 'Declined — insufficient funds',
        amount: 500.00, type: TransactionType.transfer,
        status: TransactionStatus.failed, category: TransactionCategory.transfer,
        createdAt: now.subtract(const Duration(days: 10)),
        fromAccount: 'acc-002', recipientName: 'Mike Thompson',
        referenceId: 'REF2024012',
      ),
      TransactionModel(
        id: 'txn-013', title: 'Spotify Premium',
        subtitle: 'Music subscription',
        amount: 9.99, type: TransactionType.bill,
        status: TransactionStatus.completed, category: TransactionCategory.entertainment,
        createdAt: now.subtract(const Duration(days: 12)),
        fromAccount: 'acc-002', referenceId: 'REF2024013',
      ),
      TransactionModel(
        id: 'txn-014', title: 'Transfer from Emma',
        subtitle: 'P2P Received',
        amount: 75.00, type: TransactionType.credit,
        status: TransactionStatus.completed, category: TransactionCategory.transfer,
        createdAt: now.subtract(const Duration(days: 14)),
        fromAccount: 'Emma Davis', toAccount: 'acc-001',
        recipientName: 'Emma Davis', referenceId: 'REF2024014',
      ),
    ];
  }

  // ── Cards ────────────────────────────────────────────────────────────────────
  static final List<CardModel> cards = [
    CardModel(
      id: 'card-001', cardNumber: '4521897654321001',
      cardholderName: 'ALEX JOHNSON', expiryDate: '09/27', cvv: '384',
      type: CardType.visa, status: CardStatus.active, isVirtual: false,
      spendingLimit: 5000.00, currentSpend: 1850.20,
      onlineTransactions: true, atmWithdrawals: true, internationalPayments: true,
      gradientIndex: 0,
    ),
    CardModel(
      id: 'card-002', cardNumber: '5412789654321002',
      cardholderName: 'ALEX JOHNSON', expiryDate: '03/26', cvv: '721',
      type: CardType.mastercard, status: CardStatus.active, isVirtual: true,
      spendingLimit: 2000.00, currentSpend: 340.50,
      onlineTransactions: true, atmWithdrawals: false, internationalPayments: false,
      gradientIndex: 1,
    ),
    CardModel(
      id: 'card-003', cardNumber: '3782234567891003',
      cardholderName: 'ALEX JOHNSON', expiryDate: '12/25', cvv: '5432',
      type: CardType.amex, status: CardStatus.frozen, isVirtual: false,
      spendingLimit: 10000.00, currentSpend: 7230.00,
      onlineTransactions: true, atmWithdrawals: true, internationalPayments: true,
      gradientIndex: 2,
    ),
  ];

  // ── Billers ──────────────────────────────────────────────────────────────────
  static final List<BillerModel> billers = [
    BillerModel(id: 'bill-001', name: 'ConEd Electric', accountNumber: '9981234567',
        category: BillCategory.electricity, lastAmount: 124.30,
        lastPaid: DateTime.now().subtract(const Duration(days: 3)), isSaved: true, emoji: '⚡'),
    BillerModel(id: 'bill-002', name: 'City Water Dept.', accountNumber: '7761234567',
        category: BillCategory.water, lastAmount: 45.00,
        lastPaid: DateTime.now().subtract(const Duration(days: 30)), isSaved: true, emoji: '💧'),
    BillerModel(id: 'bill-003', name: 'Comcast Internet', accountNumber: '5541234567',
        category: BillCategory.internet, lastAmount: 89.99,
        lastPaid: DateTime.now().subtract(const Duration(days: 15)), isSaved: true, emoji: '📡'),
    BillerModel(id: 'bill-004', name: 'AT&T Mobile', accountNumber: '6671234567',
        category: BillCategory.phone, lastAmount: 75.00, isSaved: false, emoji: '📱'),
    BillerModel(id: 'bill-005', name: 'Netflix', accountNumber: '9991234567',
        category: BillCategory.subscription, lastAmount: 15.99,
        lastPaid: DateTime.now().subtract(const Duration(days: 1)), isSaved: true, emoji: '🎬'),
    BillerModel(id: 'bill-006', name: 'Health Insurance', accountNumber: '3331234567',
        category: BillCategory.insurance, lastAmount: 350.00, isSaved: false, emoji: '🏥'),
    BillerModel(id: 'bill-007', name: 'Spotify Premium', accountNumber: '4441234567',
        category: BillCategory.subscription, lastAmount: 9.99,
        lastPaid: DateTime.now().subtract(const Duration(days: 12)), isSaved: true, emoji: '🎵'),
    BillerModel(id: 'bill-008', name: 'Natural Gas Co.', accountNumber: '2221234567',
        category: BillCategory.gas, lastAmount: 67.40, isSaved: false, emoji: '🔥'),
  ];

  // ── Savings Goals ────────────────────────────────────────────────────────────
  static final List<SavingsGoalModel> savingsGoals = [
    SavingsGoalModel(id: 'goal-001', name: 'Dream Vacation', emoji: '✈️',
        targetAmount: 5000.00, currentAmount: 2350.00,
        targetDate: DateTime.now().add(const Duration(days: 180)),
        autoSave: true, autoSaveAmount: 200.00, colorHex: '#5B7BFF'),
    SavingsGoalModel(id: 'goal-002', name: 'Emergency Fund', emoji: '🛡️',
        targetAmount: 15000.00, currentAmount: 8500.00,
        autoSave: true, autoSaveAmount: 500.00, colorHex: '#00E5C0'),
    SavingsGoalModel(id: 'goal-003', name: 'New MacBook', emoji: '💻',
        targetAmount: 2500.00, currentAmount: 900.00,
        targetDate: DateTime.now().add(const Duration(days: 90)),
        autoSave: false, colorHex: '#FFBB33'),
    SavingsGoalModel(id: 'goal-004', name: 'Wedding Fund', emoji: '💍',
        targetAmount: 20000.00, currentAmount: 4200.00,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        autoSave: true, autoSaveAmount: 1000.00, colorHex: '#FF4B6E'),
  ];

  // ── Analytics ────────────────────────────────────────────────────────────────
  static Map<TransactionCategory, double> get spendingByCategory {
    final map = <TransactionCategory, double>{};
    for (final t in transactions) {
      if (t.isOutgoing) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  static List<double> get monthlySpending => [2840, 3120, 2650, 3500, 2980, 3240];
  static List<double> get monthlyIncome    => [6700, 6700, 7900, 6700, 6700, 6700];

  // ── Contacts ─────────────────────────────────────────────────────────────────
  static List<Map<String, String>> get recentContacts => [
    {'name': 'Sarah Mitchell', 'phone': '+1 555 0101', 'initials': 'SM'},
    {'name': 'Mike Thompson',  'phone': '+1 555 0102', 'initials': 'MT'},
    {'name': 'Emma Davis',     'phone': '+1 555 0103', 'initials': 'ED'},
    {'name': 'James Wilson',   'phone': '+1 555 0104', 'initials': 'JW'},
    {'name': 'Lisa Chen',      'phone': '+1 555 0105', 'initials': 'LC'},
    {'name': 'Robert Park',    'phone': '+1 555 0106', 'initials': 'RP'},
  ];

  // ── Exchange Rates (TSH base) ─────────────────────────────────────────────────
  static Map<String, double> get exchangeRates => {
    'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.50, 'AUD': 1.53,
    'CAD': 1.36, 'CHF': 0.89, 'CNY': 7.24,  'INR': 83.15,
    'MXN': 17.15, 'BRL': 4.97, 'KRW': 1325.0, 'SGD': 1.35,
  };

  // ── Notifications ─────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get notifications => [
    {
      'id': 'n-001', 'icon': '💰', 'type': 'credit',
      'title': 'Salary Received!',
      'body': '\$5,500.00 credited to Main Savings.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': 'n-002', 'icon': '💸', 'type': 'transfer',
      'title': 'Transfer Successful',
      'body': '\$250.00 sent to Sarah Mitchell.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
    },
    {
      'id': 'n-003', 'icon': '⚠️', 'type': 'alert',
      'title': 'Budget Alert',
      'body': 'You\'ve used 80% of your Food & Dining budget.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
    },
    {
      'id': 'n-004', 'icon': '🔔', 'type': 'bill',
      'title': 'Bill Payment Due',
      'body': 'Electricity bill of \$124.30 is due in 3 days.',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
    },
    {
      'id': 'n-005', 'icon': '🔒', 'type': 'security',
      'title': 'New Login Detected',
      'body': 'Login from iPhone 15 Pro • New York, US.',
      'time': DateTime.now().subtract(const Duration(days: 5)),
      'isRead': true,
    },
  ];
}
