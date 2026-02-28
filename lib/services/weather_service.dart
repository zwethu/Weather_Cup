import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:weather_cup/models/weather_model.dart';

/// Service for fetching and caching weather data
///
/// Uses WeatherAPI.com for weather data and Hive for local caching.
/// Implements offline-first strategy with 24-hour cache validity.
class WeatherService {
  // Singleton pattern
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// WeatherAPI.com API key
  /// TODO: Replace with your actual API key from https://www.weatherapi.com/
  static const String _apiKey = '353e9f42108a4130ba0142834262802';

  /// Base URL for WeatherAPI.com
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  /// Hive box name for weather cache
  static const String _cacheBoxName = 'weatherCache';

  /// Cache key for current weather
  static const String _currentWeatherKey = 'current_weather';

  /// Cache duration (24 hours)
  static const Duration _cacheDuration = Duration(hours: 24);

  /// HTTP client timeout duration
  static const Duration _httpTimeout = Duration(seconds: 10);

  Box<WeatherModel>? _cacheBox;
  bool _isInitialized = false;

  /// Initialize the weather service
  ///
  /// Opens the Hive cache box for weather data
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _cacheBox = await Hive.openBox<WeatherModel>(_cacheBoxName);
      _isInitialized = true;
      debugPrint('✅ WeatherService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize WeatherService: $e');
    }
  }

  /// Fetch current weather from WeatherAPI.com
  ///
  /// Parameters:
  /// - [city]: City name (e.g., "Chiang Rai")
  /// - [country]: Country name (e.g., "Thailand")
  ///
  /// Returns [WeatherModel] if successful, null if failed
  Future<WeatherModel?> fetchCurrentWeather(String city, String country) async {
    try {
      // Build query string: "city,country"
      final query = Uri.encodeComponent('$city,$country');
      final url = Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$query');

      debugPrint('🌤️ Fetching weather for $city, $country');
      debugPrint('📡 URL: $url');

      // Make HTTP GET request with timeout
      final response = await http.get(url).timeout(_httpTimeout);

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final weather = WeatherModel.fromJson(json);

        debugPrint('✅ Weather fetched: $weather');

        // Cache the weather data
        await cacheWeather(weather);

        return weather;
      } else {
        // Log error response
        debugPrint('❌ Weather API error: ${response.statusCode}');
        debugPrint('📄 Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching weather: $e');
      return null;
    }
  }

  /// Get cached weather data from Hive
  ///
  /// Returns [WeatherModel] if cache exists and is not expired (< 24 hours)
  /// Returns null if no cache or cache is expired
  Future<WeatherModel?> getCachedWeather() async {
    try {
      // Ensure service is initialized
      if (!_isInitialized) {
        await init();
      }

      if (_cacheBox == null) {
        debugPrint('⚠️ Cache box not available');
        return null;
      }

      final cachedWeather = _cacheBox!.get(_currentWeatherKey);

      if (cachedWeather == null) {
        debugPrint('📭 No cached weather found');
        return null;
      }

      // Check if cache is expired
      if (cachedWeather.isExpired(maxAge: _cacheDuration)) {
        debugPrint('⏰ Cached weather expired (older than 24 hours)');
        return null;
      }

      debugPrint('📦 Using cached weather: $cachedWeather');
      return cachedWeather;
    } catch (e) {
      debugPrint('❌ Error reading cached weather: $e');
      return null;
    }
  }

  /// Cache weather data to Hive
  ///
  /// Saves the weather model to local storage for offline access
  Future<void> cacheWeather(WeatherModel weather) async {
    try {
      // Ensure service is initialized
      if (!_isInitialized) {
        await init();
      }

      if (_cacheBox == null) {
        debugPrint('⚠️ Cache box not available, cannot cache weather');
        return;
      }

      await _cacheBox!.put(_currentWeatherKey, weather);
      debugPrint('💾 Weather cached successfully');
    } catch (e) {
      debugPrint('❌ Error caching weather: $e');
    }
  }

  /// Get weather with fallback strategy
  ///
  /// Strategy:
  /// 1. Try to fetch fresh weather from API
  /// 2. If API fails, use cached weather (if valid)
  /// 3. Return null if both fail
  ///
  /// This is the main method to use in the app
  Future<WeatherModel?> getWeatherWithFallback(String city, String country) async {
    // Ensure service is initialized
    if (!_isInitialized) {
      await init();
    }

    debugPrint('🔄 Getting weather for $city, $country (with fallback)');

    // Try to fetch fresh weather
    final freshWeather = await fetchCurrentWeather(city, country);

    if (freshWeather != null) {
      return freshWeather;
    }

    // Fallback to cached weather
    debugPrint('⚠️ API failed, trying cached weather...');
    final cachedWeather = await getCachedWeather();

    if (cachedWeather != null) {
      debugPrint('✅ Using cached weather as fallback');
      return cachedWeather;
    }

    // Both failed
    debugPrint('❌ No weather available (API failed, no valid cache)');
    return null;
  }

  /// Clear weather cache
  Future<void> clearCache() async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.clear();
        debugPrint('🗑️ Weather cache cleared');
      }
    } catch (e) {
      debugPrint('❌ Error clearing weather cache: $e');
    }
  }

  /// Test API connection and print results to debug console
  ///
  /// Call this method to verify the WeatherAPI.com integration is working.
  /// Returns true if API call was successful, false otherwise.
  ///
  /// Usage:
  /// ```dart
  /// await WeatherService().testApiConnection();
  /// ```
  Future<bool> testApiConnection({
    String testCity = 'Bangkok',
    String testCountry = 'Thailand',
  }) async {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint('║           🧪 WEATHER API CONNECTION TEST                  ║');
    debugPrint('╠══════════════════════════════════════════════════════════╣');
    debugPrint('║ Testing: $testCity, $testCountry');
    debugPrint('║ API Key: ${_apiKey.substring(0, 8)}...${_apiKey.substring(_apiKey.length - 4)}');
    debugPrint('╚══════════════════════════════════════════════════════════╝');
    debugPrint('');

    try {
      final weather = await fetchCurrentWeather(testCity, testCountry);

      if (weather != null) {
        debugPrint('');
        debugPrint('╔══════════════════════════════════════════════════════════╗');
        debugPrint('║           ✅ API TEST SUCCESSFUL!                         ║');
        debugPrint('╠══════════════════════════════════════════════════════════╣');
        debugPrint('║ City: ${weather.cityName}');
        debugPrint('║ Country: ${weather.country}');
        debugPrint('║ Temperature: ${weather.temperatureC}°C');
        debugPrint('║ Feels Like: ${weather.feelsLikeC}°C');
        debugPrint('║ Condition: ${weather.conditionText}');
        debugPrint('║ Humidity: ${weather.humidity}%');
        debugPrint('║ Wind: ${weather.windKph} kph');
        debugPrint('║ Heat Level: ${weather.getHeatLevel()}');
        debugPrint('║ Last Updated: ${weather.lastUpdated}');
        debugPrint('╚══════════════════════════════════════════════════════════╝');
        debugPrint('');
        return true;
      } else {
        debugPrint('');
        debugPrint('╔══════════════════════════════════════════════════════════╗');
        debugPrint('║           ❌ API TEST FAILED!                             ║');
        debugPrint('║ Weather data is null. Check debug logs above.            ║');
        debugPrint('╚══════════════════════════════════════════════════════════╝');
        debugPrint('');
        return false;
      }
    } catch (e) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════╗');
      debugPrint('║           ❌ API TEST EXCEPTION!                          ║');
      debugPrint('║ Error: $e');
      debugPrint('╚══════════════════════════════════════════════════════════╝');
      debugPrint('');
      return false;
    }
  }

  // ============================================
  // Static Helper Methods
  // ============================================

  /// Calculate BMI (Body Mass Index)
  ///
  /// Formula: weight (kg) / height (m)²
  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0) return 22.0; // Default normal BMI
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  /// Calculate adjusted water intake goal based on weather and BMI
  ///
  /// Parameters:
  /// - [weightKg]: User's weight in kilograms
  /// - [heightCm]: User's height in centimeters
  /// - [temperatureC]: Current temperature in Celsius (null if no weather)
  /// - [heatLevel]: Heat level category from weather (null if no weather)
  ///
  /// Returns adjusted water goal in milliliters
  ///
  /// Logic:
  /// - Base goal: weight × 33 ml
  /// - BMI adjustment: varies by BMI category
  /// - Temperature adjustment: +100ml to +500ml based on temp
  /// - Heat level adjustment: +100ml to +400ml based on feels-like
  static int calculateAdjustedWaterGoal({
    required double weightKg,
    required double heightCm,
    double? temperatureC,
    HeatLevel? heatLevel,
  }) {
    // Base goal: 33ml per kg of body weight
    int baseGoal = (weightKg * 33).round();

    // BMI adjustment
    final bmi = calculateBMI(weightKg, heightCm);
    int bmiAdjustment = 0;

    if (bmi < 18.5) {
      // Underweight: slightly less water needed
      bmiAdjustment = -100;
    } else if (bmi >= 25 && bmi < 30) {
      // Overweight: more water helps metabolism
      bmiAdjustment = 200;
    } else if (bmi >= 30) {
      // Obese: even more water recommended
      bmiAdjustment = 400;
    }
    // Normal BMI (18.5-25): no adjustment

    // Temperature adjustment (only if weather data available)
    int tempAdjustment = 0;
    if (temperatureC != null) {
      if (temperatureC >= 35) {
        tempAdjustment = 500;
      } else if (temperatureC >= 30) {
        tempAdjustment = 300;
      } else if (temperatureC >= 25) {
        tempAdjustment = 100;
      }
    }

    // Heat level adjustment (based on feels-like temperature)
    int heatAdjustment = 0;
    if (heatLevel != null) {
      switch (heatLevel) {
        case HeatLevel.extreme:
          heatAdjustment = 400;
          break;
        case HeatLevel.veryHigh:
          heatAdjustment = 300;
          break;
        case HeatLevel.high:
          heatAdjustment = 200;
          break;
        case HeatLevel.moderate:
          heatAdjustment = 100;
          break;
        case HeatLevel.comfortable:
          heatAdjustment = 0;
          break;
      }
    }

    final totalGoal = baseGoal + bmiAdjustment + tempAdjustment + heatAdjustment;

    debugPrint('💧 Water goal calculation:');
    debugPrint('   Base (${weightKg}kg × 33): ${baseGoal}ml');
    debugPrint('   BMI adjustment (BMI: ${bmi.toStringAsFixed(1)}): ${bmiAdjustment >= 0 ? '+' : ''}${bmiAdjustment}ml');
    if (temperatureC != null) {
      debugPrint('   Temp adjustment ($temperatureC°C): +${tempAdjustment}ml');
    }
    if (heatLevel != null) {
      debugPrint('   Heat adjustment ($heatLevel): +${heatAdjustment}ml');
    }
    debugPrint('   Total: ${totalGoal}ml');

    return totalGoal;
  }

  /// Get a helpful weather tip based on current conditions
  ///
  /// Returns personalized hydration tips based on weather
  static String getWeatherTip(WeatherModel weather) {
    // Hot weather tip
    if (weather.temperatureC > 35) {
      return "🔥 Stay cool and drink extra water today! It's very hot outside.";
    }

    // Cold weather tip
    if (weather.temperatureC < 20) {
      return "🧊 Cool weather, but don't forget to stay hydrated!";
    }

    // Windy weather tip
    if (weather.windKph > 20) {
      return "🍃 Windy day ahead! Wind can dehydrate you faster.";
    }

    // High humidity tip
    if (weather.humidity > 80) {
      return "💦 High humidity today! You may sweat more, drink up!";
    }

    // Moderate heat tip
    if (weather.temperatureC > 30) {
      return "☀️ Warm day! Keep your water bottle handy.";
    }

    // Default tip
    return "☀️ Have a great day! Remember to drink water regularly.";
  }

  /// Get emoji for weather condition
  static String getWeatherEmoji(String conditionText) {
    final condition = conditionText.toLowerCase();

    if (condition.contains('sunny') || condition.contains('clear')) {
      return '☀️';
    } else if (condition.contains('cloud') || condition.contains('overcast')) {
      return '☁️';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return '🌧️';
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return '⛈️';
    } else if (condition.contains('snow')) {
      return '❄️';
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return '🌫️';
    } else if (condition.contains('wind')) {
      return '🌬️';
    } else {
      return '🌤️';
    }
  }

  /// Get color suggestion based on heat level
  static String getHeatLevelColor(HeatLevel heatLevel) {
    switch (heatLevel) {
      case HeatLevel.comfortable:
        return '#4CAF50'; // Green
      case HeatLevel.moderate:
        return '#8BC34A'; // Light Green
      case HeatLevel.high:
        return '#FFC107'; // Amber
      case HeatLevel.veryHigh:
        return '#FF9800'; // Orange
      case HeatLevel.extreme:
        return '#F44336'; // Red
    }
  }
}

