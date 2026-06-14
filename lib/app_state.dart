import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models.dart';

class AppState extends ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  String? _emailUser;
  
  bool get isLoggedIn => _currentUser != null || _emailUser != null;

  String get userName {
    if (_currentUser != null) return _currentUser!.displayName ?? 'Người dùng';
    if (_emailUser != null) return _emailUser!.split('@').first;
    return 'Người dùng';
  }

  String get userEmail {
    if (_currentUser != null) return _currentUser!.email;
    if (_emailUser != null) return _emailUser!;
    return 'Chưa đăng nhập';
  }

  String? get userPhotoUrl {
    return _currentUser?.photoUrl;
  }

  AppState() {
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _currentUser = event.user;
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        _currentUser = null;
      }
      notifyListeners();
    });
    
    try {
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account != null) {
        _currentUser = account;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error in silent sign in: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.authenticate();
    } catch (error) {
      debugPrint("Error signing in with Google: $error");
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Mock login delay
    await Future.delayed(const Duration(seconds: 1));
    _emailUser = email;
    notifyListeners();
  }

  Future<void> signOut() async {
    _emailUser = null;
    await GoogleSignIn.instance.disconnect();
    notifyListeners();
  }

  int _currentTab = 0;
  int get currentTab => _currentTab;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  void toggleOffline() {
    _isOffline = !_isOffline;
    if (!_isOffline) {
      _syncPendingTransactions();
    }
    notifyListeners();
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  final List<Transaction> _transactions = [
    Transaction(
      id: '1', name: 'Bún bò Huế', amount: 55000,
      type: TransactionType.expense, category: 'Ăn uống', categoryEmoji: '🍜',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Transaction(
      id: '2', name: 'Lương tháng 6', amount: 8200000,
      type: TransactionType.income, category: 'Thu nhập', categoryEmoji: '💼',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '3', name: 'Cà phê The Coffee House', amount: 45000,
      type: TransactionType.expense, category: 'Ăn uống', categoryEmoji: '☕',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    ),
    Transaction(
      id: '4', name: 'Vinmart mua sắm', amount: 280000,
      type: TransactionType.expense, category: 'Mua sắm', categoryEmoji: '🛒',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '5', name: 'CGV xem phim', amount: 120000,
      type: TransactionType.expense, category: 'Giải trí', categoryEmoji: '🎬',
      date: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
    ),
    Transaction(
      id: '6', name: 'Grab đi làm', amount: 35000,
      type: TransactionType.expense, category: 'Di chuyển', categoryEmoji: '🚗',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      id: '7', name: 'Pizza 4P\'s', amount: 350000,
      type: TransactionType.expense, category: 'Ăn uống', categoryEmoji: '🍕',
      date: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
    ),
    Transaction(
      id: '8', name: 'Tiền thưởng dự án', amount: 500000,
      type: TransactionType.income, category: 'Thu nhập', categoryEmoji: '🎁',
      date: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Transaction(
      id: '9', name: 'Trà sữa Gong Cha', amount: 55000,
      type: TransactionType.expense, category: 'Ăn uống', categoryEmoji: '🧋',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Transaction(
      id: '10', name: 'Thuốc tây', amount: 150000,
      type: TransactionType.expense, category: 'Y tế', categoryEmoji: '💊',
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> get recentTransactions => _transactions.take(4).toList();

  double get totalBalance => _transactions
      .fold(0.0, (sum, t) => t.type == TransactionType.income ? sum + t.amount : sum - t.amount);

  double get monthlyIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  void addTransaction(Transaction t) {
    Transaction newTx = Transaction(
      id: t.id,
      name: t.name,
      amount: t.amount,
      type: t.type,
      category: t.category,
      categoryEmoji: t.categoryEmoji,
      date: t.date,
      note: t.note,
      paymentMethod: t.paymentMethod,
      syncStatus: _isOffline ? SyncStatus.offline : SyncStatus.pending,
    );
    _transactions.insert(0, newTx);
    notifyListeners();

    if (!_isOffline) {
      _simulateBackgroundSync(newTx.id);
    }
  }

  void updateTransactionSyncStatus(String id, SyncStatus status) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final oldTx = _transactions[index];
      _transactions[index] = Transaction(
        id: oldTx.id,
        name: oldTx.name,
        amount: oldTx.amount,
        type: oldTx.type,
        category: oldTx.category,
        categoryEmoji: oldTx.categoryEmoji,
        date: oldTx.date,
        note: oldTx.note,
        paymentMethod: oldTx.paymentMethod,
        syncStatus: status,
      );
      notifyListeners();
    }
  }

  Future<void> _simulateBackgroundSync(String txId) async {
    await Future.delayed(const Duration(seconds: 2));
    updateTransactionSyncStatus(txId, SyncStatus.synced);
  }

  void _syncPendingTransactions() {
    for (var tx in _transactions) {
      if (tx.syncStatus == SyncStatus.offline || tx.syncStatus == SyncStatus.pending) {
        updateTransactionSyncStatus(tx.id, SyncStatus.pending);
        _simulateBackgroundSync(tx.id);
      }
    }
  }

  List<Map<String, dynamic>> getTimeBasedSuggestions() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) { // Morning
      return [
        {'name': 'Cà phê', 'emoji': '☕', 'amount': '35000', 'category': 'Ăn uống', 'usedCount': 24},
        {'name': 'Ăn sáng', 'emoji': '🍞', 'amount': '40000', 'category': 'Ăn uống', 'usedCount': 18},
        {'name': 'Trà sữa', 'emoji': '🥤', 'amount': '50000', 'category': 'Ăn uống', 'usedCount': 10},
      ];
    } else if (hour >= 11 && hour < 14) { // Noon
      return [
        {'name': 'Cơm trưa', 'emoji': '🍱', 'amount': '50000', 'category': 'Ăn uống', 'usedCount': 35},
        {'name': 'Nước uống', 'emoji': '🥤', 'amount': '25000', 'category': 'Ăn uống', 'usedCount': 20},
        {'name': 'Grab', 'emoji': '🚗', 'amount': '35000', 'category': 'Di chuyển', 'usedCount': 15},
      ];
    } else if (hour >= 17 && hour < 22) { // Evening
      return [
        {'name': 'Ăn tối', 'emoji': '🍲', 'amount': '80000', 'category': 'Ăn uống', 'usedCount': 22},
        {'name': 'Mua sắm', 'emoji': '🛒', 'amount': '250000', 'category': 'Mua sắm', 'usedCount': 12},
        {'name': 'Giải trí', 'emoji': '🎬', 'amount': '150000', 'category': 'Giải trí', 'usedCount': 8},
      ];
    } else {
      return [
        {'name': 'Cửa hàng tiện lợi', 'emoji': '🏪', 'amount': '50000', 'category': 'Mua sắm', 'usedCount': 30},
        {'name': 'Grab', 'emoji': '🚗', 'amount': '45000', 'category': 'Di chuyển', 'usedCount': 25},
        {'name': 'Ăn vặt', 'emoji': '🍟', 'amount': '30000', 'category': 'Ăn uống', 'usedCount': 15},
      ];
    }
  }

  List<Map<String, dynamic>> getFrequentHabits() {
    return [
      {'name': 'Highlands Coffee', 'emoji': '☕', 'amount': '45000', 'category': 'Ăn uống', 'usedCount': 15},
      {'name': 'Cơm trưa', 'emoji': '🍱', 'amount': '55000', 'category': 'Ăn uống', 'usedCount': 32},
      {'name': 'Grab Bike', 'emoji': '🏍️', 'amount': '25000', 'category': 'Di chuyển', 'usedCount': 28},
      {'name': 'Circle K', 'emoji': '🛒', 'amount': '40000', 'category': 'Mua sắm', 'usedCount': 18},
    ];
  }

  final List<SavingsGoal> _savingsGoals = [
    SavingsGoal(id: 's1', name: 'Du lịch Nhật Bản', emoji: '🇯🇵', targetAmount: 50000000, savedAmount: 15000000, deadline: DateTime(2026, 12, 31)),
    SavingsGoal(id: 's2', name: 'Quỹ dự phòng', emoji: '🛡️', targetAmount: 100000000, savedAmount: 45000000, deadline: DateTime(2027, 6, 30)),
    SavingsGoal(id: 's3', name: 'Macbook mới', emoji: '💻', targetAmount: 40000000, savedAmount: 38000000, deadline: DateTime(2026, 9, 30)),
  ];

  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);

  void addSavingsGoal(SavingsGoal goal) {
    _savingsGoals.add(goal);
    notifyListeners();
  }

  void addFundsToGoal(String goalId, double amount) {
    final index = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final oldGoal = _savingsGoals[index];
      _savingsGoals[index] = SavingsGoal(
        id: oldGoal.id,
        name: oldGoal.name,
        emoji: oldGoal.emoji,
        targetAmount: oldGoal.targetAmount,
        savedAmount: oldGoal.savedAmount + amount,
        deadline: oldGoal.deadline,
      );
      notifyListeners();
    }
  }

  final List<Budget> budgets = [
    Budget(id: 'b1', name: 'Ăn uống', emoji: '🍔', limit: 3000000, spent: 2100000,
        startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30)),
    Budget(id: 'b2', name: 'Giải trí', emoji: '🎮', limit: 1000000, spent: 950000,
        startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30)),
    Budget(id: 'b3', name: 'Di chuyển', emoji: '🚗', limit: 1500000, spent: 600000,
        startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30)),
    Budget(id: 'b4', name: 'Mua sắm', emoji: '🛒', limit: 1500000, spent: 800000,
        startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30)),
    Budget(id: 'b5', name: 'Y tế', emoji: '💊', limit: 500000, spent: 350000,
        startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30)),
  ];

  final List<Map<String, dynamic>> monthlyData = [
    {'month': 'T1', 'income': 7200000.0, 'expense': 5100000.0},
    {'month': 'T2', 'income': 7500000.0, 'expense': 5800000.0},
    {'month': 'T3', 'income': 8000000.0, 'expense': 6200000.0},
    {'month': 'T4', 'income': 7800000.0, 'expense': 5500000.0},
    {'month': 'T5', 'income': 7300000.0, 'expense': 5200000.0},
    {'month': 'T6', 'income': 8200000.0, 'expense': 5750000.0},
  ];

  final List<Map<String, dynamic>> categoryBreakdown = [
    {'name': 'Ăn uống', 'emoji': '🍔', 'amount': 2100000.0, 'percent': 37.0, 'color': Color(0xFFEF4444)},
    {'name': 'Mua sắm', 'emoji': '🛒', 'amount': 1150000.0, 'percent': 20.0, 'color': Color(0xFFF59E0B)},
    {'name': 'Giải trí', 'emoji': '🎮', 'amount': 950000.0, 'percent': 17.0, 'color': Color(0xFF8B5CF6)},
    {'name': 'Di chuyển', 'emoji': '🚗', 'amount': 800000.0, 'percent': 14.0, 'color': Color(0xFF3B82F6)},
    {'name': 'Khác', 'emoji': '📦', 'amount': 700000.0, 'percent': 12.0, 'color': Color(0xFF10B981)},
  ];
}