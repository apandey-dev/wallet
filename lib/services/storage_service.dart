import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/subscription_model.dart';
import '../models/notification_model.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _keyUser = 'user_profile';
  static const String _keyAccounts = 'accounts';
  static const String _keyCategories = 'categories';
  static const String _keyTransactions = 'transactions';
  static const String _keySubscriptions = 'subscriptions';
  static const String _keyNotifications = 'notifications';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyMonthlyBudget = 'monthly_budget_val';
  static const String _keyCategoryBudgets = 'category_budgets';

  Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<UserProfile?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Accounts
  Future<void> saveAccounts(List<AccountModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyAccounts, jsonEncode(list));
  }

  Future<List<AccountModel>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyAccounts);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => AccountModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Categories
  Future<void> saveCategories(List<CategoryModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyCategories, jsonEncode(list));
  }

  Future<List<CategoryModel>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCategories);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Transactions
  Future<void> saveTransactions(List<TransactionModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(list));
  }

  Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyTransactions);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Subscriptions
  Future<void> saveSubscriptions(List<SubscriptionModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keySubscriptions, jsonEncode(list));
  }

  Future<List<SubscriptionModel>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySubscriptions);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => SubscriptionModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Notifications
  Future<void> saveNotifications(List<NotificationModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyNotifications, jsonEncode(list));
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyNotifications);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Budgets
  Future<void> saveMonthlyBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonthlyBudget, budget);
  }

  Future<double?> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyBudget);
  }

  Future<void> saveCategoryBudgets(Map<String, double> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCategoryBudgets, jsonEncode(budgets));
  }

  Future<Map<String, double>> getCategoryBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCategoryBudgets);
    if (data == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(data);
      return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (_) {
      return {};
    }
  }
}
