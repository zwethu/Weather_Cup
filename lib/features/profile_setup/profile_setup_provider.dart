import 'package:flutter/material.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/notification_service.dart';

class ProfileSetupProvider extends ChangeNotifier {
  int _currentStep = 0;
  final int totalSteps = 5; // 0-4 (5 steps)

  // Form data
  String _name = '';
  String _gender = 'Male';
  String _weight = '';
  String _height = '';
  String _wakeTime = '06:30';
  String _sleepTime = '23:30';
  // Start as empty so the Location step is required and cannot be skipped
  String _country = '';
  String _city = '';

  // Add reference to repository
  final UserRepository _userRepository = UserRepository.instance;

  // Getters
  int get currentStep => _currentStep;
  String get name => _name;
  String get gender => _gender;
  String get weight => _weight;
  String get height => _height;
  String get wakeTime => _wakeTime;
  String get sleepTime => _sleepTime;
  String get country => _country;
  String get city => _city;

  // Parsed numeric values (null if invalid)
  double? get weightValue => double.tryParse(_weight);
  double? get heightValue => double.tryParse(_height);

  // Validation flags
  bool get weightIsValid => weightValue != null && weightValue! > 0;
  bool get heightIsValid => heightValue != null && heightValue! > 0;

  double get progress => (_currentStep + 1) / totalSteps;
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == totalSteps - 1;

  // Setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setWeight(String value) {
    // Sanitize numeric input: allow digits and a single decimal separator.
    _weight = _sanitizeNumberInput(value);
    notifyListeners();
  }

  void setHeight(String value) {
    _height = _sanitizeNumberInput(value);
    notifyListeners();
  }

  void setWakeTime(String value) {
    _wakeTime = value;
    notifyListeners();
  }

  void setSleepTime(String value) {
    _sleepTime = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value.trim();
    notifyListeners();
  }

  void setCity(String value) {
    _city = value.trim();
    notifyListeners();
  }

  // Navigation
  void nextStep() {
    // Only advance if current step validation passes (defensive check)
    if (_currentStep < totalSteps - 1 && canProceedFromStep(_currentStep)) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 0;
    _name = '';
    _gender = 'Male';
    _weight = '';
    _height = '';
    _wakeTime = '06:30';
    _sleepTime = '23:30';
    _country = '';
    _city = '';
    notifyListeners();
  }

  // Validation
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0: // Welcome
        return true;
      case 1: // Personal Info
        return _name.isNotEmpty && _gender.isNotEmpty;
      case 2: // Body Info
        // Require valid positive numeric weight and height
        return weightIsValid && heightIsValid;
      case 3: // Daily Routine
        return _wakeTime.isNotEmpty && _sleepTime.isNotEmpty;
      case 4: // Location
        return _country.isNotEmpty && _city.isNotEmpty;
      default:
        return false;
    }
  }

  // Helpers
  String _sanitizeNumberInput(String input) {
    if (input.isEmpty) return '';
    // Normalize comma to dot
    input = input.replaceAll(',', '.');
    // Remove any characters except digits and dot
    input = input.replaceAll(RegExp(r'[^0-9.]'), '');
    // If more than one dot, keep the first and remove others
    final firstDot = input.indexOf('.');
    if (firstDot >= 0) {
      final before = input.substring(0, firstDot + 1);
      final after = input.substring(firstDot + 1).replaceAll('.', '');
      input = before + after;
    }
    return input;
  }

  /// Save profile to local storage and mark onboarding as completed
  Future<void> saveProfile() async {
    final user = UserModel(
      name: _name,
      gender: _gender,
      weight: weightValue ?? 0,
      height: heightValue ?? 0,
      wakeTime: _wakeTime,
      sleepTime: _sleepTime,
      country: _country,
      city: _city,
      onboardingCompleted: true,
    );
    await _userRepository.saveUser(user);

    // Initialize and request permissions
    final notificationService = NotificationService();
    await notificationService.initializeNotifications();
    final permissionGranted = await notificationService.requestPermissions();
    debugPrint('🔔 Notification permission granted: $permissionGranted');

    // 🧪 IMMEDIATE TEST: Show notification NOW to verify it works
    await notificationService.showImmediateTestNotification(nickname: _name);

    // Schedule hourly hydration notifications
    // Set testMode: true to test with notifications every minute
    final result = await notificationService.scheduleHourlyNotifications(
      wakeTime: _wakeTime,
      sleepTime: _sleepTime,
      nickname: _name,
      testMode: false, //   🧪 Change to true to test!
    );
    debugPrint('🔔 Notifications scheduled: $result');

    // Debug: Print pending notifications
    await notificationService.debugPrintPendingNotifications();
  }

  /// Load existing profile from local storage (if any)
  void loadFromStorage() {
    final user = _userRepository.getUser();
    if (user != null) {
      _name = user.name;
      _gender = user.gender;
      _weight = user.weight.toString();
      _height = user.height.toString();
      _wakeTime = user.wakeTime;
      _sleepTime = user.sleepTime;
      _country = user.country;
      _city = user.city;
      notifyListeners();
    }
  }

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding => _userRepository.hasCompletedOnboarding();
}
