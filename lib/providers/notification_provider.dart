import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../services/storage_service.dart';

class NotificationProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<NotificationModel> _notifications = [];
  NotificationModel? _currentBanner;
  Timer? _bannerDismissTimer;

  NotificationProvider(this._storageService);

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  NotificationModel? get currentBanner => _currentBanner;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    _notifications = await _storageService.getNotifications();
    if (_notifications.isEmpty) {
      // Seed initial welcome notifications
      _notifications = [
        NotificationModel(
          id: const Uuid().v4(),
          title: 'Welcome to ZeroWallet',
          body: 'Sleek, minimalist offline-first expense & subscription tracking.',
          type: 'welcome',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationModel(
          id: const Uuid().v4(),
          title: 'Upcoming Renewal Alert',
          body: 'Spotify Premium renews in 3 days (₹119).',
          type: 'subscription_renewal',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: false,
        ),
      ];
      await _storageService.saveNotifications(_notifications);
    }
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String body,
    required String type,
    bool showBanner = true,
  }) {
    final notif = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notif);
    _storageService.saveNotifications(_notifications);

    if (showBanner) {
      _showBanner(notif);
    }

    notifyListeners();
  }

  void _showBanner(NotificationModel notif) {
    _bannerDismissTimer?.cancel();
    _currentBanner = notif;
    notifyListeners();

    _bannerDismissTimer = Timer(const Duration(seconds: 4), () {
      dismissBanner();
    });
  }

  void dismissBanner() {
    _bannerDismissTimer?.cancel();
    _currentBanner = null;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _storageService.saveNotifications(_notifications);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _storageService.saveNotifications(_notifications);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _storageService.saveNotifications(_notifications);
    notifyListeners();
  }

  @override
  void dispose() {
    _bannerDismissTimer?.cancel();
    super.dispose();
  }
}
