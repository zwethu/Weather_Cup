import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/persistence/user_repository.dart';

/// Initializes Hive and all required adapters and repositories
class HiveInitializer {
  HiveInitializer._();

  /// Initialize Hive for Flutter and register all type adapters
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register type adapters
    _registerAdapters();

    // Initialize repositories
    await _initRepositories();
  }

  static void _registerAdapters() {
    // Register UserModel adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  }

  static Future<void> _initRepositories() async {
    // Initialize UserRepository
    await UserRepository.instance.init();
  }
}

