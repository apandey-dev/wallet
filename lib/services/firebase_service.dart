import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import '../models/user_profile.dart';
import '../models/transaction_model.dart';
import '../models/subscription_model.dart';

class FirebaseService {
  bool _isFirebaseReady = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isFirebaseReady => _isFirebaseReady;
  FirebaseAuth? get auth => _isFirebaseReady ? FirebaseAuth.instance : null;
  FirebaseFirestore? get firestore => _isFirebaseReady ? FirebaseFirestore.instance : null;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseReady = true;
      debugPrint('[FirebaseService] Firebase initialized successfully with project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    } catch (e) {
      debugPrint('[FirebaseService] Local/Standalone fallback: $e');
      _isFirebaseReady = false;
    }
  }

  /// Real Sign in with Google Account dialog & Firebase Auth
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // Triggers native Android/Web Google Account picker dialog
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount != null) {
        final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

        if (_isFirebaseReady) {
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          final firebaseUser = userCredential.user;

          if (firebaseUser != null) {
            return UserProfile(
              uid: firebaseUser.uid,
              displayName: firebaseUser.displayName?.trim().isNotEmpty == true
                  ? firebaseUser.displayName!
                  : (googleAccount.displayName ?? 'Google User'),
              email: firebaseUser.email ?? googleAccount.email,
              photoUrl: firebaseUser.photoURL ?? googleAccount.photoUrl,
              isGuest: false,
              monthlyBudget: 30000.0,
              currencySymbol: '₹',
            );
          }
        }

        // Direct Google Account info when running on standalone/desktop test
        return UserProfile(
          uid: 'google_${googleAccount.id}',
          displayName: googleAccount.displayName ?? 'Google User',
          email: googleAccount.email,
          photoUrl: googleAccount.photoUrl,
          isGuest: false,
          monthlyBudget: 30000.0,
          currencySymbol: '₹',
        );
      }
    } catch (e) {
      debugPrint('[FirebaseService] Real Google Sign-in error: $e');
    }
    return null;
  }

  /// Sign in as Guest
  Future<UserProfile> signInAsGuest() async {
    try {
      if (_isFirebaseReady) {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        final user = credential.user;
        if (user != null) {
          return UserProfile(
            uid: user.uid,
            displayName: 'Guest Explorer',
            email: 'guest@zerowallet.app',
            photoUrl: null,
            isGuest: true,
            monthlyBudget: 25000.0,
            currencySymbol: '₹',
          );
        }
      }
    } catch (e) {
      debugPrint('[FirebaseService] Anonymous auth fallback: $e');
    }

    return UserProfile(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Explorer',
      email: 'guest@zerowallet.app',
      photoUrl: null,
      isGuest: true,
      monthlyBudget: 25000.0,
      currencySymbol: '₹',
    );
  }

  /// Cloud sync hook for transactions to Cloud Firestore
  Future<void> syncTransaction(String uid, TransactionModel transaction) async {
    if (!_isFirebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      debugPrint('[FirebaseService] Firestore transaction sync error: $e');
    }
  }

  /// Cloud sync hook for subscriptions to Cloud Firestore
  Future<void> syncSubscription(String uid, SubscriptionModel subscription) async {
    if (!_isFirebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('subscriptions')
          .doc(subscription.id)
          .set(subscription.toJson());
    } catch (e) {
      debugPrint('[FirebaseService] Firestore subscription sync error: $e');
    }
  }
}
