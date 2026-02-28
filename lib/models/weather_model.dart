import 'package:hive/hive.dart';

part 'weather_model.g.dart';

/// Heat level categories based on feels-like temperature
/// Used to adjust water intake recommendations
@HiveType(typeId: 3)
enum HeatLevel {
  @HiveField(0)
  comfortable, // < 25°C feels like

  @HiveField(1)
  moderate, // 25-30°C

  @HiveField(2)
  high, // 30-35°C

  @HiveField(3)
  veryHigh, // 35-40°C

  @HiveField(4)
  extreme, // > 40°C
}

/// Weather data model with Hive persistence
///
/// Stores current weather conditions fetched from WeatherAPI.com
/// Used to adjust water intake recommendations based on temperature
@HiveType(typeId: 2)
class WeatherModel extends HiveObject {
  /// Current temperature in Celsius
  @HiveField(0)
  double temperatureC;

  /// Feels like temperature in Celsius (used for heat level calculation)
  @HiveField(1)
  double feelsLikeC;

  /// Weather condition description (e.g., "Sunny", "Cloudy")
  @HiveField(2)
  String conditionText;

  /// Weather condition code from API
  @HiveField(3)
  int conditionCode;

  /// Humidity percentage (0-100)
  @HiveField(4)
  int humidity;

  /// Wind speed in kilometers per hour
  @HiveField(5)
  double windKph;

  /// Timestamp when weather data was last updated
  @HiveField(6)
  DateTime lastUpdated;

  /// City name for the weather location
  @HiveField(7)
  String cityName;

  /// Country name for the weather location
  @HiveField(8)
  String country;

  WeatherModel({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.conditionText,
    required this.conditionCode,
    required this.humidity,
    required this.windKph,
    required this.lastUpdated,
    required this.cityName,
    required this.country,
  });

  /// Create WeatherModel from WeatherAPI.com JSON response
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "location": { "name": "City", "country": "Country" },
  ///   "current": {
  ///     "temp_c": 35.0,
  ///     "feelslike_c": 38.5,
  ///     "condition": { "text": "Sunny", "code": 1000 },
  ///     "humidity": 65,
  ///     "wind_kph": 12.5,
  ///     "last_updated": "2026-02-28 21:00"
  ///   }
  /// }
  /// ```
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;

    // Parse last_updated string to DateTime
    DateTime parsedLastUpdated;
    try {
      final lastUpdatedStr = current['last_updated'] as String;
      parsedLastUpdated = DateTime.parse(lastUpdatedStr.replaceFirst(' ', 'T'));
    } catch (e) {
      parsedLastUpdated = DateTime.now();
    }

    return WeatherModel(
      temperatureC: (current['temp_c'] as num).toDouble(),
      feelsLikeC: (current['feelslike_c'] as num).toDouble(),
      conditionText: condition['text'] as String,
      conditionCode: condition['code'] as int,
      humidity: current['humidity'] as int,
      windKph: (current['wind_kph'] as num).toDouble(),
      lastUpdated: parsedLastUpdated,
      cityName: location['name'] as String,
      country: location['country'] as String,
    );
  }

  /// Convert WeatherModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'location': {
        'name': cityName,
        'country': country,
      },
      'current': {
        'temp_c': temperatureC,
        'feelslike_c': feelsLikeC,
        'condition': {
          'text': conditionText,
          'code': conditionCode,
        },
        'humidity': humidity,
        'wind_kph': windKph,
        'last_updated': lastUpdated.toIso8601String(),
      },
    };
  }

  /// Create a copy of WeatherModel with optional field updates
  WeatherModel copyWith({
    double? temperatureC,
    double? feelsLikeC,
    String? conditionText,
    int? conditionCode,
    int? humidity,
    double? windKph,
    DateTime? lastUpdated,
    String? cityName,
    String? country,
  }) {
    return WeatherModel(
      temperatureC: temperatureC ?? this.temperatureC,
      feelsLikeC: feelsLikeC ?? this.feelsLikeC,
      conditionText: conditionText ?? this.conditionText,
      conditionCode: conditionCode ?? this.conditionCode,
      humidity: humidity ?? this.humidity,
      windKph: windKph ?? this.windKph,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
    );
  }

  /// Get heat level category based on feels-like temperature
  ///
  /// Categories:
  /// - comfortable: < 25°C
  /// - moderate: 25-30°C
  /// - high: 30-35°C
  /// - veryHigh: 35-40°C
  /// - extreme: > 40°C
  HeatLevel getHeatLevel() {
    if (feelsLikeC >= 40) {
      return HeatLevel.extreme;
    } else if (feelsLikeC >= 35) {
      return HeatLevel.veryHigh;
    } else if (feelsLikeC >= 30) {
      return HeatLevel.high;
    } else if (feelsLikeC >= 25) {
      return HeatLevel.moderate;
    } else {
      return HeatLevel.comfortable;
    }
  }

  /// Check if this weather data is expired (older than given duration)
  bool isExpired({Duration maxAge = const Duration(hours: 24)}) {
    return DateTime.now().difference(lastUpdated) > maxAge;
  }

  @override
  String toString() {
    return 'WeatherModel(city: $cityName, temp: $temperatureC°C, '
        'feelsLike: $feelsLikeC°C, condition: $conditionText, '
        'humidity: $humidity%, wind: ${windKph}kph)';
  }
}

