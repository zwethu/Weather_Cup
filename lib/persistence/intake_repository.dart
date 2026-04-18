import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:weather_cup/models/daily_intake.dart';
import 'package:weather_cup/persistence/hive_boxes.dart';
import 'package:weather_cup/services/auth_service.dart';
import 'package:weather_cup/services/firestore_service.dart';

/// Repository for managing daily water intake records
///
/// Handles persistence of intake data using Hive.
/// Stores records by date for easy retrieval.
class IntakeRepository {
  static final IntakeRepository _instance = IntakeRepository._internal();
  static IntakeRepository get instance => _instance;
  IntakeRepository._internal();

  // Use the centralized box name
  static const String _boxName = HiveBoxes.dailyIntakeBox;
  Box<DailyIntake>? _box;
  bool _isInitialized = false;

  /// Initialize the repository
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _box = await Hive.openBox<DailyIntake>(_boxName);
      _isInitialized = true;
      debugPrint('✅ IntakeRepository initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize IntakeRepository: $e');
    }
  }

  /// Get the key for a specific date (yyyy-MM-dd format)
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get today's intake record (creates new if doesn't exist)
  Future<DailyIntake> getTodayIntake({required int defaultGoal}) async {
    if (!_isInitialized) await init();

    final today = DateTime.now();
    final key = _dateKey(today);

    DailyIntake? intake = _box?.get(key);

    if (intake == null) {
      // Create new record for today
      intake = DailyIntake(
        date: DateTime(today.year, today.month, today.day),
        goal: defaultGoal,
      );
      await _box?.put(key, intake);
      debugPrint('📝 Created new intake record for today');
    }

    return intake;
  }

  /// Get intake for a specific date
  DailyIntake? getIntakeForDate(DateTime date) {
    final key = _dateKey(date);
    return _box?.get(key);
  }

  /// Save/update intake record (write-through to Firestore when signed in).
  Future<void> saveIntake(DailyIntake intake) async {
    if (!_isInitialized) await init();

    final key = _dateKey(intake.date);
    await _box?.put(key, intake);
    debugPrint('💾 Saved intake: $intake');

    // Mirror to Firestore so the record survives reinstalls / device
    // changes. Failures are logged but never rethrown — the local write
    // already succeeded and the user should not see a crash because the
    // network hiccuped.
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirestoreService.instance.saveHydrationData(uid, intake);
      } catch (e) {
        debugPrint('⚠️ Failed to sync hydration to Firestore: $e');
      }
    }
  }

  /// Add drink to today's record
  Future<DailyIntake> addDrinkToday(int ml, {required int defaultGoal}) async {
    if (!_isInitialized) await init();

    final intake = await getTodayIntake(defaultGoal: defaultGoal);
    intake.addDrink(ml);
    await saveIntake(intake);

    debugPrint('🥤 Added ${ml}ml - Total: ${intake.amount}ml / ${intake.goal}ml');
    return intake;
  }

  /// Undo last drink from today
  Future<DailyIntake?> undoLastDrink() async {
    if (!_isInitialized) await init();

    final today = DateTime.now();
    final key = _dateKey(today);
    final intake = _box?.get(key);

    if (intake != null && intake.undoLastDrink()) {
      await saveIntake(intake);
      debugPrint('↩️ Undid last drink - Total: ${intake.amount}ml');
      return intake;
    }
    return null;
  }

  /// Update today's goal (e.g., when weather changes)
  Future<DailyIntake> updateTodayGoal(int newGoal) async {
    if (!_isInitialized) await init();

    final intake = await getTodayIntake(defaultGoal: newGoal);
    final updatedIntake = intake.copyWith(goal: newGoal);
    await saveIntake(updatedIntake);

    debugPrint('🎯 Updated today\'s goal to ${newGoal}ml');
    return updatedIntake;
  }

  /// Get intake records for the last N days
  List<DailyIntake> getLastNDays(int days, {required int defaultGoal}) {
    final List<DailyIntake> records = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final intake = _box?.get(key);

      if (intake != null) {
        records.add(intake);
      } else {
        // Create placeholder for missing days
        records.add(DailyIntake(
          date: DateTime(date.year, date.month, date.day),
          goal: defaultGoal,
          amount: 0,
        ));
      }
    }

    return records;
  }

  /// Get this week's intake records (Mon-Sun)
  List<DailyIntake> getThisWeekIntake({required int defaultGoal}) {
    final now = DateTime.now();
    // Get Monday of this week
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final List<DailyIntake> records = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final key = _dateKey(date);
      final intake = _box?.get(key);

      if (intake != null) {
        records.add(intake);
      } else {
        // Create placeholder
        records.add(DailyIntake(
          date: DateTime(date.year, date.month, date.day),
          goal: defaultGoal,
          amount: 0,
        ));
      }
    }

    return records;
  }

  /// Get all intake records
  List<DailyIntake> getAllRecords() {
    return _box?.values.toList() ?? [];
  }

  /// Get all intake records sorted by date descending (newest first)
  List<DailyIntake> getAllRecordsSorted() {
    final records = getAllRecords();
    records.sort((a, b) => b.date.compareTo(a.date)); // Descending order
    return records;
  }

  /// Clear all records (local only).
  Future<void> clearAll() async {
    await _box?.clear();
    debugPrint('🗑️ Cleared all intake records');
  }

  /// Hydrate the local Hive box from Firestore for the given [uid].
  ///
  /// Pulls the last [daysBack] days of hydration records (default 7 —
  /// enough to render the weekly bar chart) and writes them into Hive.
  ///
  /// Returns the number of records synced.
  Future<int> syncFromCloud(String uid, {int daysBack = 7}) async {
    if (!_isInitialized) await init();
    if (_box == null) return 0;

    int synced = 0;
    final now = DateTime.now();
    for (int i = 0; i < daysBack; i++) {
      final date = now.subtract(Duration(days: i));
      try {
        final data =
            await FirestoreService.instance.getHydrationData(uid, date);
        if (data == null) continue;
        final intake = DailyIntake.fromFirestoreMap(data);
        final key = _dateKey(intake.date);
        await _box!.put(key, intake);
        synced++;
      } catch (e) {
        debugPrint('⚠️ Failed to sync $i-days-ago hydration: $e');
      }
    }
    debugPrint('☁️ Hydration sync from cloud: $synced record(s)');
    return synced;
  }

  /// Get statistics
  Map<String, dynamic> getStatistics({int days = 30}) {
    final records = getAllRecords()
        .where((r) => r.date.isAfter(DateTime.now().subtract(Duration(days: days))))
        .toList();

    if (records.isEmpty) {
      return {
        'totalDays': 0,
        'daysReachedGoal': 0,
        'averageIntake': 0,
        'averagePercentage': 0,
        'totalWater': 0,
      };
    }

    final daysReachedGoal = records.where((r) => r.isGoalReached).length;
    final totalWater = records.fold<int>(0, (sum, r) => sum + r.amount);
    final averageIntake = totalWater ~/ records.length;
    final averagePercentage = records.fold<int>(0, (sum, r) => sum + r.percentage) ~/ records.length;

    return {
      'totalDays': records.length,
      'daysReachedGoal': daysReachedGoal,
      'averageIntake': averageIntake,
      'averagePercentage': averagePercentage,
      'totalWater': totalWater,
    };
  }
}
