import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;
  final FirebaseService _firebaseService;

  UserProfile? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  AuthProvider(this._storageService, this._firebaseService);

  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _firebaseService.initialize();
    _user = await _storageService.getUser();
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userProfile = await _firebaseService.signInWithGoogle();
      if (userProfile != null) {
        _user = userProfile;
        await _storageService.saveUser(_user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[AuthProvider] Google Sign-in error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();

    try {
      final guestProfile = await _firebaseService.signInAsGuest();
      _user = guestProfile;
      await _storageService.saveUser(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthProvider] Guest login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> updateBudget(double budget) async {
    if (_user == null) return;
    _user = _user!.copyWith(monthlyBudget: budget);
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      displayName: displayName?.trim().isNotEmpty == true ? displayName!.trim() : _user!.displayName,
      photoUrl: photoUrl,
    );
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await _storageService.clearAuth();
    notifyListeners();
  }
}
