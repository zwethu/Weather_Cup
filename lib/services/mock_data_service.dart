import 'package:weather_cup/models/daily_intake.dart';

class MockDataService {
  static List<DailyIntake> getWeeklyIntakeData() {
    return [
      DailyIntake(
        day: 'Mon',
        amount: 2000,
        goal: 2500,
        percentage: 80,
      ),
      DailyIntake(
        day: 'Tue',
        amount: 2600,
        goal: 2500,
        percentage: 104,
      ),
      DailyIntake(
        day: 'Wed',
        amount: 1800,
        goal: 2500,
        percentage: 72,
      ),
      DailyIntake(
        day: 'Thu',
        amount: 2500,
        goal: 2500,
        percentage: 100,
      ),
      DailyIntake(
        day: 'Fri',
        amount: 2300,
        goal: 2500,
        percentage: 92,
      ),
      DailyIntake(
        day: 'Sat',
        amount: 1500,
        goal: 2500,
        percentage: 60,
      ),
      DailyIntake(
        day: 'Sun',
        amount: 2700,
        goal: 2500,
        percentage: 108,
      ),
    ];
  }
}
