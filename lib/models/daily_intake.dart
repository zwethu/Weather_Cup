class DailyIntake {
  final String day;
  final int amount;
  final int goal;
  final int percentage;

  DailyIntake({
    required this.day,
    required this.amount,
    required this.goal,
    required this.percentage,
  });

  bool get isGoalReached => percentage >= 100;
}
