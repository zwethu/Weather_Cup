import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/persistence/hive_boxes.dart';
import 'package:weather_cup/services/firestore_service.dart';

/// Repository for managing user data persistence with Hive
class UserRepository {
  static UserRepository? _instance;
  late Box<UserModel> _userBox;

  UserRepository._();

  /// Singleton instance
  static UserRepository get instance {
    _instance ??= UserRepository._();
    return _instance!;
  }

  /// Initialize the repository (call after Hive.initFlutter)
  Future<void> init() async {
    _userBox = await Hive.openBox<UserModel>(HiveBoxes.userBox);
  }

  /// Get the current user profile, or null if not set
  UserModel? getUser() {
    if (_userBox.isEmpty) return null;
    return _userBox.getAt(0);
  }

  /// Check if user has completed onboarding
  bool hasCompletedOnboarding() {
    final user = getUser();
    return user?.onboardingCompleted ?? false;
  }

  /// Save or update user profile
  Future<void> saveUser(UserModel user) async {
    if (_userBox.isEmpty) {
      await _userBox.add(user);
    } else {
      await _userBox.putAt(0, user);
    }
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
    final currentUser = getUser();
    if (currentUser == null) {
      // Create new user if none exists
      final newUser = UserModel(
        name: name ?? '',
        gender: gender ?? 'Male',
        weight: weight ?? 0,
        height: height ?? 0,
        wakeTime: wakeTime ?? '06:30',
        sleepTime: sleepTime ?? '23:30',
        country: country ?? '',
        city: city ?? '',
        onboardingCompleted: onboardingCompleted ?? false,
      );
      await saveUser(newUser);
    } else {
      final updatedUser = currentUser.copyWith(
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
      await saveUser(updatedUser);
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await updateUser(onboardingCompleted: true);
  }

  /// Clear all user data (for reset functionality)
  Future<void> clearUser() async {
    await _userBox.clear();
  }

  /// Hydrate the local Hive box from Firestore for the given [uid].
  ///
  /// Returns the synced [UserModel] if a Firestore profile exists and was
  /// persisted locally, or `null` if the cloud profile is missing / incomplete.
  ///
  /// Call this right after a successful sign-in so that `UserProvider` and the
  /// router see consistent data on the current device.
  Future<UserModel?> syncFromCloud(String uid) async {
    final data = await FirestoreService.instance.getUserProfile(uid);
    if (data == null) return null;

    final isComplete = data['profileSetupComplete'] == true;
    if (!isComplete) return null;

    final synced = UserModel(
      name: (data['name'] as String?) ?? '',
      gender: (data['gender'] as String?) ?? 'Male',
      weight: (data['weight'] as num?)?.toDouble() ?? 0,
      height: (data['height'] as num?)?.toDouble() ?? 0,
      wakeTime: (data['wakeTime'] as String?) ?? '06:30',
      sleepTime: (data['sleepTime'] as String?) ?? '23:30',
      country: (data['country'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      // A user whose profile is complete in Firestore has, by definition,
      // finished onboarding.
      onboardingCompleted: true,
    );

    await saveUser(synced);
    return synced;
  }

  /// Close the box (call on app dispose if needed)
  Future<void> close() async {
    await _userBox.close();
  }
}

