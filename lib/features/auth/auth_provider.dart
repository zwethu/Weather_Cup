import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    AuthService.instance.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await AuthService.instance.signUp(email: email, password: password);
      // New accounts start fresh locally — discard any leftover Hive data
      // from a previous user on this device.
      await UserRepository.instance.clearUser();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final cred = await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      // ── Sync Firestore → Hive so local state matches the cloud before
      // the router makes its redirect decision. Without this, the router
      // sees "profile complete" in Firestore and routes to /main, while
      // UserProvider (which reads Hive only) still has a null user.
      final uid = cred.user?.uid;
      if (uid != null) {
        // Clear any leftover data from a previous account on this device.
        await UserRepository.instance.clearUser();
        await UserRepository.instance.syncFromCloud(uid);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    // Wipe the local Hive profile so the next account on this device does
    // not inherit stale data.
    await UserRepository.instance.clearUser();
    await AuthService.instance.signOut();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await AuthService.instance.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}