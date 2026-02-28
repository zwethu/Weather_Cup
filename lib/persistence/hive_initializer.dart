import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_cup/models/daily_intake.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/models/weather_model.dart';
import 'package:weather_cup/persistence/intake_repository.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/weather_service.dart';

/// Initializes Hive and all required adapters and repositories
class HiveInitializer {
  HiveInitializer._();

  /// Initialize Hive for Flutter and register all type adapters
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register type adapters
    _registerAdapters();

    // Initialize repositories and services
    await _initRepositories();
  }

  static void _registerAdapters() {
    // Register UserModel adapter (typeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Register WeatherModel adapter (typeId: 2)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WeatherModelAdapter());
    }

    // Register HeatLevel adapter (typeId: 3)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HeatLevelAdapter());
    }

    // Register DailyIntake adapter (typeId: 4)
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DailyIntakeAdapter());
    }

    // Register DrinkEntry adapter (typeId: 5)
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(DrinkEntryAdapter());
    }
  }

  static Future<void> _initRepositories() async {
    // Initialize UserRepository
    await UserRepository.instance.init();

    // Initialize WeatherService cache
    await WeatherService().init();

    // Initialize IntakeRepository
    await IntakeRepository.instance.init();
  }
}

