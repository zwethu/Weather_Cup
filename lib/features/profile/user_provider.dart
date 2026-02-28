import 'package:flutter/material.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/persistence/user_repository.dart';

/// Provider that acts as a layer between views and persistence
/// Views should use this provider instead of directly calling UserRepository
class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository.instance;

  UserModel? _user;

  UserProvider() {
    // Load user data on initialization
    _loadUser();
  }

  /// Current user data
  UserModel? get user => _user;

  /// Check if user exists
  bool get hasUser => _user != null;

  /// Check if onboarding is completed
  bool get hasCompletedOnboarding => _user?.onboardingCompleted ?? false;

  /// User's name or fallback
  String get userName => _user?.name ?? 'Friend';

  /// User's initial for avatar
  String get userInitial => userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

  /// User's gender
  String get gender => _user?.gender ?? 'Not set';

  /// User's weight in kg
  double get weight => _user?.weight ?? 0;

  /// User's height in cm
  double get height => _user?.height ?? 0;

  /// User's wake time
  String get wakeTime => _user?.wakeTime ?? '06:30';

  /// User's sleep time
  String get sleepTime => _user?.sleepTime ?? '23:30';

  /// User's country
  String get country => _user?.country ?? 'Not set';

  /// User's city
  String get city => _user?.city ?? 'Not set';

  /// Formatted location string
  String get location => hasUser ? '${_user!.city}, ${_user!.country}' : 'Location not set';

  /// Recommended daily water intake in ml
  int get recommendedDailyIntake => _user?.recommendedDailyIntake ?? 2500;

  /// Load user from storage
  void _loadUser() {
    _user = _repository.getUser();
    notifyListeners();
  }

  /// Refresh user data from storage
  void refresh() {
    _loadUser();
  }

  /// Save user to storage
  Future<void> saveUser(UserModel user) async {
    await _repository.saveUser(user);
    _user = user;
    notifyListeners();
  }

  /// Update specific user fields
  Future<void> updateUser({
    String? name,
    String? gender,
    double? weight,
    double? height,
    String? wakeTime,
    String? sleepTime,
    String? country,
    String? city,
    bool? onboardingCompleted,
  }) async {
    await _repository.updateUser(
      name: name,
      gender: gender,
      weight: weight,
      height: height,
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      country: country,
      city: city,
      onboardingCompleted: onboardingCompleted,
    );
    _loadUser();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    _loadUser();
  }

  /// Clear all user data
  Future<void> clearUser() async {
    await _repository.clearUser();
    _user = null;
    notifyListeners();
  }
}

