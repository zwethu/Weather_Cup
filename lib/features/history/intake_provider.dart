import 'package:flutter/foundation.dart';
import 'package:weather_cup/models/daily_intake.dart';
import 'package:weather_cup/persistence/intake_repository.dart';

/// Provider for managing water intake tracking
///
/// Handles today's intake, history, and provides real-time updates
/// to the UI when drinks are added.
class IntakeProvider extends ChangeNotifier {
  final IntakeRepository _repository = IntakeRepository.instance;

  DailyIntake? _todayIntake;
  List<DailyIntake> _weeklyIntake = [];
  List<DailyIntake> _allIntake = [];
  bool _isLoading = false;

  /// Today's intake record
  DailyIntake? get todayIntake => _todayIntake;

  /// This week's intake records (for bar chart)
  List<DailyIntake> get weeklyIntake => _weeklyIntake;

  /// All intake records sorted by date descending (for daily details list)
  List<DailyIntake> get allIntake => _allIntake;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Today's total amount drunk
  int get todayAmount => _todayIntake?.amount ?? 0;

  /// Today's goal
  int get todayGoal => _todayIntake?.goal ?? 2500;

  /// Today's remaining amount
  int get todayRemaining => _todayIntake?.remaining ?? 2500;

  /// Today's progress (0.0 to 1.0+)
  double get todayProgress => _todayIntake?.progress ?? 0;

  /// Today's percentage
  int get todayPercentage => _todayIntake?.percentage ?? 0;

  /// Whether today's goal is reached
  bool get isGoalReached => _todayIntake?.isGoalReached ?? false;

  /// Today's drink entries
  List<DrinkEntry> get todayEntries => _todayIntake?.entries ?? [];

  /// Initialize the provider with the current goal
  Future<void> init({required int dailyGoal}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.init();
      await loadTodayIntake(dailyGoal: dailyGoal);
      await loadWeeklyIntake(dailyGoal: dailyGoal);
      await loadAllIntake();
    } catch (e) {
      debugPrint('❌ Error initializing IntakeProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load today's intake
  Future<void> loadTodayIntake({required int dailyGoal}) async {
    try {
      _todayIntake = await _repository.getTodayIntake(defaultGoal: dailyGoal);
      debugPrint('📊 Today: ${_todayIntake?.amount}ml / ${_todayIntake?.goal}ml');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading today\'s intake: $e');
    }
  }

  /// Load this week's intake (for bar chart)
  Future<void> loadWeeklyIntake({required int dailyGoal}) async {
    try {
      _weeklyIntake = _repository.getThisWeekIntake(defaultGoal: dailyGoal);
      debugPrint('📅 Loaded ${_weeklyIntake.length} days for weekly chart');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading weekly intake: $e');
    }
  }

  /// Load all intake records (sorted by date descending)
  Future<void> loadAllIntake() async {
    try {
      _allIntake = _repository.getAllRecordsSorted();
      debugPrint('📚 Loaded ${_allIntake.length} total intake records');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading all intake: $e');
    }
  }

  /// Add a drink (in ml)
  Future<void> addDrink(int ml, {required int currentGoal}) async {
    try {
      _todayIntake = await _repository.addDrinkToday(ml, defaultGoal: currentGoal);

      // Update weekly data to reflect today's change
      _updateTodayInWeekly();

      // Update all intake list
      _updateTodayInAll();

      debugPrint('🥤 Added ${ml}ml - Total: ${_todayIntake?.amount}ml');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error adding drink: $e');
    }
  }

  /// Undo the last drink
  Future<bool> undoLastDrink() async {
    try {
      final result = await _repository.undoLastDrink();
      if (result != null) {
        _todayIntake = result;
        _updateTodayInWeekly();
        _updateTodayInAll();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error undoing drink: $e');
      return false;
    }
  }

  /// Update today's goal (e.g., when weather changes)
  Future<void> updateTodayGoal(int newGoal) async {
    try {
      _todayIntake = await _repository.updateTodayGoal(newGoal);
      _updateTodayInWeekly();
      _updateTodayInAll();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating goal: $e');
    }
  }

  /// Update weather info for today's record
  Future<void> updateWeatherInfo({
    double? temperature,
    String? condition,
  }) async {
    if (_todayIntake != null) {
      final updated = _todayIntake!.copyWith(
        temperature: temperature,
        weatherCondition: condition,
      );
      await _repository.saveIntake(updated);
      _todayIntake = updated;
      notifyListeners();
    }
  }

  /// Update today's entry in the weekly list
  void _updateTodayInWeekly() {
    if (_todayIntake == null) return;

    final todayIndex = _weeklyIntake.indexWhere(
      (intake) => _isSameDay(intake.date, _todayIntake!.date),
    );

    if (todayIndex >= 0) {
      _weeklyIntake[todayIndex] = _todayIntake!;
    }
  }

  /// Update today's entry in the all intake list
  void _updateTodayInAll() {
    if (_todayIntake == null) return;

    final todayIndex = _allIntake.indexWhere(
      (intake) => _isSameDay(intake.date, _todayIntake!.date),
    );

    if (todayIndex >= 0) {
      _allIntake[todayIndex] = _todayIntake!;
    } else {
      // Today not in list yet, add it at the beginning (newest first)
      _allIntake.insert(0, _todayIntake!);
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get statistics for the last N days
  Map<String, dynamic> getStatistics({int days = 30}) {
    return _repository.getStatistics(days: days);
  }

  /// Refresh all data
  Future<void> refresh({required int dailyGoal}) async {
    await loadTodayIntake(dailyGoal: dailyGoal);
    await loadWeeklyIntake(dailyGoal: dailyGoal);
    await loadAllIntake();
  }
}

