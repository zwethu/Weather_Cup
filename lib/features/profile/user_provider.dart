import 'package:flutter/material.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/models/weather_model.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/auth_service.dart';
import 'package:weather_cup/services/firestore_service.dart';
import 'package:weather_cup/services/weather_service.dart';

/// Provider that acts as a layer between views and persistence
/// Views should use this provider instead of directly calling UserRepository
class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository.instance;
  final WeatherService _weatherService = WeatherService();

  UserModel? _user;
  WeatherModel? _weather;
  bool _isLoadingWeather = false;
  String? _weatherError;

  UserProvider() {
    // Load user data on initialization
    _loadUser();
  }

  /// Current user data
  UserModel? get user => _user;

  /// Current weather data
  WeatherModel? get weather => _weather;

  /// Whether weather is currently being fetched
  bool get isLoadingWeather => _isLoadingWeather;

  /// Weather error message if any
  String? get weatherError => _weatherError;

  /// Check if user exists
  bool get hasUser => _user != null;

  /// Check if weather data is available
  bool get hasWeather => _weather != null;

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

  /// Base recommended daily water intake (without weather/BMI adjustment)
  int get baseWaterIntake => _user?.recommendedDailyIntake ?? 2500;

  /// Recommended daily water intake in ml (weather + BMI adjusted)
  int get recommendedDailyIntake {
    if (_user == null) return 2500;

    // Calculate with BMI and weather adjustments
    return WeatherService.calculateAdjustedWaterGoal(
      weightKg: _user!.weight,
      heightCm: _user!.height,
      temperatureC: _weather?.temperatureC,
      heatLevel: _weather?.getHeatLevel(),
    );
  }

  /// Get user's BMI
  double get bmi {
    if (_user == null || _user!.height <= 0) return 22.0;
    return WeatherService.calculateBMI(_user!.weight, _user!.height);
  }

  /// Get BMI category string
  String get bmiCategory => WeatherService.getBMICategory(bmi);

  /// Get weather tip based on current conditions
  String get weatherTip {
    if (_weather == null) {
      return "☀️ Have a great day! Remember to drink water regularly.";
    }
    return WeatherService.getWeatherTip(_weather!);
  }

  /// Get current temperature string
  String get temperatureString {
    if (_weather == null) return '--°C';
    return '${_weather!.temperatureC.round()}°C';
  }

  /// Get weather condition text
  String get weatherCondition {
    if (_weather == null) return 'Unknown';
    return _weather!.conditionText;
  }

  /// Get weather emoji
  String get weatherEmoji {
    if (_weather == null) return '🌤️';
    return WeatherService.getWeatherEmoji(_weather!.conditionText);
  }

  /// Get heat level
  HeatLevel? get heatLevel => _weather?.getHeatLevel();

  /// Load user from storage
  void _loadUser() {
    _user = _repository.getUser();
    notifyListeners();

    // Also fetch weather when user is loaded
    if (_user != null) {
      fetchWeather();
    }
  }

  /// Fetch weather for user's location
  Future<void> fetchWeather() async {
    if (_user == null) {
      debugPrint('⚠️ Cannot fetch weather: No user data');
      return;
    }

    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Fetching weather for ${_user!.city}, ${_user!.country}');

      _weather = await _weatherService.getWeatherWithFallback(
        _user!.city,
        _user!.country,
      );

      if (_weather != null) {
        debugPrint('✅ Weather loaded: ${_weather!.temperatureC}°C, ${_weather!.conditionText}');
        debugPrint('💧 Adjusted water goal: $recommendedDailyIntake ml (base: $baseWaterIntake ml)');
      } else {
        _weatherError = 'Could not fetch weather data';
        debugPrint('⚠️ Weather not available, using base water goal');
      }
    } catch (e) {
      _weatherError = 'Error: $e';
      debugPrint('❌ Error fetching weather: $e');
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  /// Refresh user data from storage
  void refresh() {
    _loadUser();
  }

  /// Refresh weather data
  Future<void> refreshWeather() async {
    await fetchWeather();
  }

  /// Save user to storage (Hive) and sync to Firestore if signed in.
  Future<void> saveUser(UserModel user) async {
    await _repository.saveUser(user);
    _user = user;
    notifyListeners();
    await _syncCurrentUserToFirestore();
  }

  /// Update specific user fields in both Hive and Firestore.
  ///
  /// Any edits made from Settings / Profile screens flow through here,
  /// so every field mutation (weight, wakeTime, city, etc.) is mirrored
  /// to the cloud automatically.
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
    await _syncCurrentUserToFirestore();
  }

  /// Push the currently loaded Hive user to Firestore (best-effort).
  ///
  /// Silently no-ops if the user is not signed in or if Hive has no
  /// record yet — we never want a failed cloud sync to break a local
  /// edit.
  Future<void> _syncCurrentUserToFirestore() async {
    final uid = AuthService.instance.currentUser?.uid;
    final local = _user;
    if (uid == null || local == null) return;
    try {
      await FirestoreService.instance.saveUserProfile(uid, local);
    } catch (e) {
      debugPrint('⚠️ Failed to sync user profile to Firestore: $e');
    }
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

