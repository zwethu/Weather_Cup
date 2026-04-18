import 'package:hive/hive.dart';

part 'daily_intake.g.dart';

/// Daily water intake record with Hive persistence
///
/// Stores the water consumption data for a single day,
/// including the amount drunk, goal, and weather conditions at that time.
@HiveType(typeId: 4)
class DailyIntake extends HiveObject {
  /// Date of this intake record (stored as date only, no time)
  @HiveField(0)
  DateTime date;

  /// Total amount of water drunk in ml
  @HiveField(1)
  int amount;

  /// Daily goal in ml (weather-adjusted)
  @HiveField(2)
  int goal;

  /// List of individual drink entries (timestamps and amounts)
  @HiveField(3)
  List<DrinkEntry> entries;

  /// Temperature at the time of record (for reference)
  @HiveField(4)
  double? temperature;

  /// Weather condition text
  @HiveField(5)
  String? weatherCondition;

  DailyIntake({
    required this.date,
    this.amount = 0,
    required this.goal,
    List<DrinkEntry>? entries,
    this.temperature,
    this.weatherCondition,
  }) : entries = entries ?? [];

  /// Percentage of goal achieved (0-100+)
  int get percentage => goal > 0 ? ((amount / goal) * 100).round() : 0;

  /// Whether goal has been reached
  bool get isGoalReached => percentage >= 100;

  /// Remaining amount to reach goal
  int get remaining => (goal - amount).clamp(0, goal);

  /// Progress as decimal (0.0 to 1.0+)
  double get progress => goal > 0 ? amount / goal : 0;

  /// Day abbreviation (Mon, Tue, etc.)
  String get dayAbbreviation {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  /// Formatted date string (e.g., "28 Feb")
  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  /// Add a drink entry
  void addDrink(int ml) {
    entries.add(DrinkEntry(
      timestamp: DateTime.now(),
      amount: ml,
    ));
    amount += ml;
  }

  /// Remove last drink entry (undo)
  bool undoLastDrink() {
    if (entries.isEmpty) return false;
    final lastEntry = entries.removeLast();
    amount = (amount - lastEntry.amount).clamp(0, amount);
    return true;
  }

  /// Create a copy with updated fields
  DailyIntake copyWith({
    DateTime? date,
    int? amount,
    int? goal,
    List<DrinkEntry>? entries,
    double? temperature,
    String? weatherCondition,
  }) {
    return DailyIntake(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      goal: goal ?? this.goal,
      entries: entries ?? List.from(this.entries),
      temperature: temperature ?? this.temperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
    );
  }

  @override
  String toString() {
    return 'DailyIntake(date: $formattedDate, amount: ${amount}ml, '
        'goal: ${goal}ml, percentage: $percentage%)';
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'date': this.date.toIso8601String(),       // ← this.date
      'amount': this.amount,                      // ← this.amount
      'goal': this.goal,                          // ← this.goal
      'temperature': this.temperature,
      'weatherCondition': this.weatherCondition,
      'entries': this.entries.map((e) => {        // ← this.entries
        'timestamp': e.timestamp.toIso8601String(),
        'amount': e.amount,
      }).toList(),
    };
  }
}

/// Individual drink entry with timestamp
@HiveType(typeId: 5)
class DrinkEntry {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  int amount;

  DrinkEntry({
    required this.timestamp,
    required this.amount,
  });

  /// Formatted time string (e.g., "14:30")
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'DrinkEntry($formattedTime: ${amount}ml)';


}

