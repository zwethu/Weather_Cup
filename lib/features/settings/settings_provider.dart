import 'package:flutter/material.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _hourlyReminders = true;
  bool _vibrationOnly = false;
  String _country = 'Thailand';
  String _city = 'Chiang Rai';
  String _appearance = 'Light';

  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepository = UserRepository.instance;

  bool get hourlyReminders => _hourlyReminders;
  bool get vibrationOnly => _vibrationOnly;
  String get country => _country;
  String get city => _city;
  String get appearance => _appearance;

  void toggleHourlyReminders(bool value) async {
    _hourlyReminders = value;
    notifyListeners();

    if (value) {
      // Enable notifications - reschedule based on user's wake/sleep times
      final user = _userRepository.getUser();
      if (user != null) {
        await _notificationService.scheduleHourlyNotifications(
          wakeTime: user.wakeTime,
          sleepTime: user.sleepTime,
          nickname: user.name,
          testMode: false, // 🧪 Change to true to test!
        );
        debugPrint("notification: $value");
      }
    } else {
      // Disable notifications
      debugPrint("notification: $value");
      await _notificationService.cancelAllNotifications();
    }
  }

  void toggleVibration(bool value) {
    _vibrationOnly = value;
    notifyListeners();
  }

  void setLocation(String country, String city) {
    _country = country;
    _city = city;
    notifyListeners();
  }

  void setAppearance(String value) {
    _appearance = value;
    notifyListeners();
  }

  void resetAllSettings() {
    _hourlyReminders = true;
    _vibrationOnly = false;
    _country = 'Thailand';
    _city = 'Chiang Rai';
    _appearance = 'Light';
    notifyListeners();
  }
}
