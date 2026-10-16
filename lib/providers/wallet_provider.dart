import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/subscription_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import 'notification_provider.dart';

class WalletProvider extends ChangeNotifier {
  final StorageService _storageService;
  final FirebaseService _firebaseService;
  NotificationProvider? _notificationProvider;

  List<AccountModel> _accounts = [];
  List<CategoryModel> _categories = [];
  List<TransactionModel> _transactions = [];
  List<SubscriptionModel> _subscriptions = [];
  double _monthlyBudget = 50000.0;
  Map<String, double> _categoryBudgets = {};

  String _filterCategory = 'All';
  TransactionType? _filterType;
  String _searchQuery = '';

  WalletProvider(this._storageService, this._firebaseService);

  void updateNotificationProvider(NotificationProvider notifProvider) {
    _notificationProvider = notifProvider;
  }

  List<AccountModel> get accounts => List.unmodifiable(_accounts);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<SubscriptionModel> get subscriptions => List.unmodifiable(_subscriptions);

  String get filterCategory => _filterCategory;
  TransactionType? get filterType => _filterType;
  String get searchQuery => _searchQuery;

  // Total balance across all user accounts
  double get totalNetWorth {
    if (_accounts.isEmpty) {
      return totalIncome - totalExpense;
    }
    return _accounts.fold(0.0, (sum, a) => sum + a.balance);
  }

  // Filtered transactions
  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
      final matchesCategory = _filterCategory == 'All' || t.category == _filterCategory;
      final matchesType = _filterType == null || t.type == _filterType;
      final matchesQuery = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesType && matchesQuery;
    }).toList();
  }

  List<TransactionModel> getTransactionsForAccount(String accountId) {
    return _transactions.where((t) => t.accountId == accountId || t.toAccountId == accountId).toList();
  }

  double getAccountIncome(String accountId) {
    return _transactions
        .where((t) => (t.accountId == accountId && t.type == TransactionType.income) ||
                      (t.toAccountId == accountId && t.type == TransactionType.transfer))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getAccountExpense(String accountId) {
    return _transactions
        .where((t) => (t.accountId == accountId && t.type == TransactionType.expense) ||
                      (t.accountId == accountId && t.type == TransactionType.transfer))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Financial Stats
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => totalNetWorth;

  double get monthlySubscriptionCommitment {
    return _subscriptions
        .where((s) => s.isActive)
        .fold(0.0, (sum, s) {
          if (s.billingCycle == BillingCycle.yearly) {
            return sum + (s.amount / 12);
          }
          return sum + s.amount;
        });
  }

  // Budget metrics
  double get monthlyBudget => _monthlyBudget;
  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);

  double getCategoryBudget(String category) => _categoryBudgets[category] ?? 5000.0;

  double getCategorySpent(String category) {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
                      t.category == category &&
                      t.date.month == now.month &&
                      t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get remainingMonthlyBudget => (_monthlyBudget - totalExpense).clamp(0.0, double.infinity);

  double get budgetUsedPercentage {
    if (_monthlyBudget <= 0) return 0.0;
    return (totalExpense / _monthlyBudget).clamp(0.0, 2.0);
  }

  Future<void> init() async {
    _accounts = await _storageService.getAccounts();
    _categories = await _storageService.getCategories();
    _transactions = await _storageService.getTransactions();
    _subscriptions = await _storageService.getSubscriptions();

    final savedMonthly = await _storageService.getMonthlyBudget();
    if (savedMonthly != null && savedMonthly > 0) {
      _monthlyBudget = savedMonthly;
    }

    _categoryBudgets = await _storageService.getCategoryBudgets();
    if (_categoryBudgets.isEmpty) {
      _seedDefaultCategoryBudgets();
      await _storageService.saveCategoryBudgets(_categoryBudgets);
    }

    if (_categories.isEmpty) {
      _seedDefaultCategories();
    }

    if (_accounts.isEmpty && _transactions.isEmpty && _subscriptions.isEmpty) {
      await _seedInitialData();
    }
    notifyListeners();
  }

  void _seedDefaultCategoryBudgets() {
    _categoryBudgets = {
      'Food & Coffee': 12000.0,
      'Shopping': 8000.0,
      'Subscriptions': 3000.0,
      'Bills & Utilities': 10000.0,
      'Travel': 5000.0,
      'Health': 4000.0,
      'General': 8000.0,
    };
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    await _storageService.saveMonthlyBudget(amount);
    _notificationProvider?.addNotification(
      title: 'Target Limit Updated',
      body: 'Monthly spending threshold set to ₹${amount.toStringAsFixed(0)}.',
      type: 'info',
    );
    notifyListeners();
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    _categoryBudgets[category] = amount;
    await _storageService.saveCategoryBudgets(_categoryBudgets);
    _notificationProvider?.addNotification(
      title: 'Category Budget Updated',
      body: '$category budget set to ₹${amount.toStringAsFixed(0)}.',
      type: 'info',
    );
    notifyListeners();
  }

  void _seedDefaultCategories() {
    _categories = [
      CategoryModel(id: 'cat_coffee', name: 'Food & Coffee', icon: 'coffee', isDefault: true),
      CategoryModel(id: 'cat_shopping', name: 'Shopping', icon: 'shopping', isDefault: true),
      CategoryModel(id: 'cat_sub', name: 'Subscriptions', icon: 'sub', isDefault: true),
      CategoryModel(id: 'cat_bill', name: 'Bills & Utilities', icon: 'bill', isDefault: true),
      CategoryModel(id: 'cat_travel', name: 'Travel', icon: 'travel', isDefault: true),
      CategoryModel(id: 'cat_health', name: 'Health', icon: 'health', isDefault: true),
      CategoryModel(id: 'cat_salary', name: 'Salary', icon: 'income', isDefault: true),
      CategoryModel(id: 'cat_general', name: 'General', icon: 'wallet', isDefault: true),
    ];
    _storageService.saveCategories(_categories);
  }

  Future<void> addCategory(String name, String icon) async {
    final cat = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      isDefault: false,
    );
    _categories.add(cat);
    if (!_categoryBudgets.containsKey(name)) {
      _categoryBudgets[name] = 5000.0;
      await _storageService.saveCategoryBudgets(_categoryBudgets);
    }
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    final cat = _categories.firstWhere((c) => c.id == id, orElse: () => CategoryModel(id: '', name: '', icon: ''));
    if (cat.name.isNotEmpty) {
      _categoryBudgets.remove(cat.name);
      await _storageService.saveCategoryBudgets(_categoryBudgets);
    }
    _categories.removeWhere((c) => c.id == id);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> _seedInitialData() async {
    final now = DateTime.now();

    _accounts = [
      AccountModel(
        id: 'acc_hdfc',
        name: 'HDFC Salary Bank',
        balance: 62450.0,
        type: 'bank',
        icon: 'wallet',
        colorHex: '#1E293B',
      ),
      AccountModel(
        id: 'acc_cash',
        name: 'Cash in Hand',
        balance: 8200.0,
        type: 'cash',
        icon: 'income',
        colorHex: '#0F766E',
      ),
      AccountModel(
        id: 'acc_icici',
        name: 'ICICI Savings',
        balance: 45000.0,
        type: 'savings',
        icon: 'wallet',
        colorHex: '#312E81',
      ),
    ];

    _transactions = [
      TransactionModel(
        id: const Uuid().v4(),
        title: 'Monthly Salary',
        amount: 85000.0,
        category: 'Salary',
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 4)),
        icon: 'income',
        note: 'Direct deposit',
        accountId: 'acc_hdfc',
      ),
      TransactionModel(
        id: const Uuid().v4(),
        title: 'ATM Cash Withdrawal',
        amount: 5000.0,
        category: 'Self Transfer',
        type: TransactionType.transfer,
        date: now.subtract(const Duration(days: 2)),
        icon: 'wallet',
        note: 'Transferred HDFC -> Cash',
        accountId: 'acc_hdfc',
        toAccountId: 'acc_cash',
      ),
      TransactionModel(
        id: const Uuid().v4(),
        title: 'Uber Ride',
        amount: 580.0,
        category: 'Travel',
        type: TransactionType.expense,
        date: now.subtract(const Duration(hours: 3)),
        icon: 'travel',
        note: 'Transport • May 29',
        accountId: 'acc_hdfc',
      ),
      TransactionModel(
        id: const Uuid().v4(),
        title: 'Spotify Premium',
        amount: 649.0,
        category: 'Subscriptions',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1)),
        icon: 'sub',
        note: 'Entertainment • May 15',
        accountId: 'acc_hdfc',
      ),
      TransactionModel(
        id: const Uuid().v4(),
        title: 'Amazon Purchase',
        amount: 1240.0,
        category: 'Shopping',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
        icon: 'shopping',
        note: 'Shopping • May 3',
        accountId: 'acc_hdfc',
      ),
      TransactionModel(
        id: const Uuid().v4(),
        title: 'Coffee & Snacks',
        amount: 420.0,
        category: 'Food & Coffee',
        type: TransactionType.expense,
        date: now.subtract(const Duration(hours: 8)),
        icon: 'coffee',
        note: 'Paid via cash',
        accountId: 'acc_cash',
      ),
    ];

    _subscriptions = [
      SubscriptionModel(
        id: const Uuid().v4(),
        name: 'Spotify Premium',
        amount: 119.0,
        billingCycle: BillingCycle.monthly,
        nextRenewalDate: now.add(const Duration(days: 3)),
        category: 'Subscriptions',
        icon: 'sub',
      ),
      SubscriptionModel(
        id: const Uuid().v4(),
        name: 'Netflix 4K',
        amount: 649.0,
        billingCycle: BillingCycle.monthly,
        nextRenewalDate: now.add(const Duration(days: 12)),
        category: 'Subscriptions',
        icon: 'sub',
      ),
      SubscriptionModel(
        id: const Uuid().v4(),
        name: 'GitHub Copilot',
        amount: 850.0,
        billingCycle: BillingCycle.monthly,
        nextRenewalDate: now.add(const Duration(days: 18)),
        category: 'Subscriptions',
        icon: 'sub',
      ),
    ];

    await _storageService.saveAccounts(_accounts);
    await _storageService.saveTransactions(_transactions);
    await _storageService.saveSubscriptions(_subscriptions);
  }

  Future<void> addAccount(AccountModel acc) async {
    _accounts.add(acc);
    await _storageService.saveAccounts(_accounts);
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    await _storageService.saveAccounts(_accounts);
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel item, {double? monthlyBudget}) async {
    _transactions.insert(0, item);

    // Update account balances
    if (item.type == TransactionType.expense && item.accountId != null) {
      final idx = _accounts.indexWhere((a) => a.id == item.accountId);
      if (idx != -1) {
        _accounts[idx] = _accounts[idx].copyWith(
          balance: _accounts[idx].balance - item.amount,
        );
        await _storageService.saveAccounts(_accounts);
      }
    } else if (item.type == TransactionType.income && item.accountId != null) {
      final idx = _accounts.indexWhere((a) => a.id == item.accountId);
      if (idx != -1) {
        _accounts[idx] = _accounts[idx].copyWith(
          balance: _accounts[idx].balance + item.amount,
        );
        await _storageService.saveAccounts(_accounts);
      }
    } else if (item.type == TransactionType.transfer && item.accountId != null && item.toAccountId != null) {
      final fromIdx = _accounts.indexWhere((a) => a.id == item.accountId);
      final toIdx = _accounts.indexWhere((a) => a.id == item.toAccountId);
      if (fromIdx != -1) {
        _accounts[fromIdx] = _accounts[fromIdx].copyWith(
          balance: _accounts[fromIdx].balance - item.amount,
        );
      }
      if (toIdx != -1) {
        _accounts[toIdx] = _accounts[toIdx].copyWith(
          balance: _accounts[toIdx].balance + item.amount,
        );
      }
      await _storageService.saveAccounts(_accounts);
    }

    await _storageService.saveTransactions(_transactions);
    _firebaseService.syncTransaction('current_user', item);

    // In-app alert for action
    String notifTitle = 'Expense Logged';
    if (item.type == TransactionType.income) notifTitle = 'Income Added';
    if (item.type == TransactionType.transfer) notifTitle = 'Self Transfer Completed';

    _notificationProvider?.addNotification(
      title: notifTitle,
      body: '₹${item.amount.toStringAsFixed(0)} • ${item.title}',
      type: item.type == TransactionType.transfer ? 'info' : 'transaction_logged',
    );

    // Check monthly and category budget threshold
    final effectiveBudget = (monthlyBudget != null && monthlyBudget > 0) ? monthlyBudget : _monthlyBudget;
    if (effectiveBudget > 0 && item.type == TransactionType.expense) {
      final currentExpense = totalExpense;
      final ratio = currentExpense / effectiveBudget;
      if (ratio >= 1.0) {
        _notificationProvider?.addNotification(
          title: 'Budget Limit Exceeded!',
          body: 'You spent ₹${currentExpense.toStringAsFixed(0)} of your ₹${effectiveBudget.toStringAsFixed(0)} limit.',
          type: 'budget_alert',
        );
      } else if (ratio >= 0.8) {
        _notificationProvider?.addNotification(
          title: 'Budget Alert (80%)',
          body: 'You have reached ${(ratio * 100).toStringAsFixed(0)}% of your monthly budget.',
          type: 'budget_alert',
        );
      }
    }

    // Category-specific budget check
    if (item.type == TransactionType.expense && _categoryBudgets.containsKey(item.category)) {
      final catBudget = _categoryBudgets[item.category]!;
      final catSpent = getCategorySpent(item.category);
      if (catSpent > catBudget) {
        _notificationProvider?.addNotification(
          title: '${item.category} Budget Alert',
          body: 'Exceeded budget of ₹${catBudget.toStringAsFixed(0)} (spent ₹${catSpent.toStringAsFixed(0)}).',
          type: 'budget_alert',
        );
      }
    }

    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> addSubscription(SubscriptionModel item) async {
    _subscriptions.insert(0, item);
    await _storageService.saveSubscriptions(_subscriptions);

    _firebaseService.syncSubscription('current_user', item);

    _notificationProvider?.addNotification(
      title: 'Subscription Added',
      body: '${item.name} (₹${item.amount.toStringAsFixed(0)}/${item.billingCycle.name})',
      type: 'info',
    );

    notifyListeners();
  }

  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    await _storageService.saveSubscriptions(_subscriptions);
    notifyListeners();
  }

  Future<void> toggleSubscription(String id) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updated = _subscriptions[index].copyWith(
        isActive: !_subscriptions[index].isActive,
      );
      _subscriptions[index] = updated;
      await _storageService.saveSubscriptions(_subscriptions);
      notifyListeners();
    }
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _filterCategory = 'All';
    _filterType = null;
    _searchQuery = '';
    notifyListeners();
  }
}
