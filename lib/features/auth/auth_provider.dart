import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weather_cup/persistence/intake_repository.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/auth_service.dart';
import 'package:weather_cup/services/firestore_service.dart';

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
      await IntakeRepository.instance.clearAll();
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
        await IntakeRepository.instance.clearAll();
        // Pull the user's profile and the last week of hydration logs
        // from Firestore so the Home + History screens render the
        // correct data immediately after login.
        await UserRepository.instance.syncFromCloud(uid);
        await IntakeRepository.instance.syncFromCloud(uid);
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
    // Wipe local caches so the next account on this device does not
    // inherit stale data.
    await UserRepository.instance.clearUser();
    await IntakeRepository.instance.clearAll();
    await AuthService.instance.signOut();
  }

  /// Delete the user's Firebase account along with all their cloud and
  /// local data.
  ///
  /// Firebase requires a recent login for `user.delete()`, so the caller
  /// must pass the user's current [password] — we re-authenticate first
  /// and then delete. Returns `true` on success.
  Future<bool> deleteAccount({required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final current = AuthService.instance.currentUser;
      if (current == null || current.email == null) {
        _errorMessage = 'You are not signed in.';
        return false;
      }

      // Re-authenticate so Firebase accepts the delete request.
      final cred = EmailAuthProvider.credential(
        email: current.email!,
        password: password,
      );
      await current.reauthenticateWithCredential(cred);

      // Delete Firestore data BEFORE the auth user, because security
      // rules typically require the caller to still be authenticated.
      final uid = current.uid;
      try {
        await FirestoreService.instance.deleteAllUserData(uid);
      } catch (e) {
        debugPrint('⚠️ Failed to delete Firestore user data: $e');
      }

      await current.delete();

      // Finally, wipe local Hive caches.
      await UserRepository.instance.clearUser();
      await IntakeRepository.instance.clearAll();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Could not delete your account. Please try again.';
      debugPrint('❌ Delete account error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
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
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}