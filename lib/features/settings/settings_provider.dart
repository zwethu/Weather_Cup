import 'package:flutter/material.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _hourlyReminders = true;
  bool _vibrationOnly = false;
  bool _testMode = false;
  String _country = 'Thailand';
  String _city = 'Chiang Rai';
  String _appearance = 'Light';

  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepository = UserRepository.instance;

  bool get hourlyReminders => _hourlyReminders;
  bool get vibrationOnly => _vibrationOnly;
  bool get testMode => _testMode;
  String get country => _country;
  String get city => _city;
  String get appearance => _appearance;

  Future<void> toggleHourlyReminders(bool value) async {
    _hourlyReminders = value;
    notifyListeners();

    if (value) {
      final user = _userRepository.getUser();
      if (user != null) {
        await _notificationService.scheduleHourlyNotifications(
          wakeTime: user.wakeTime,
          sleepTime: user.sleepTime,
          nickname: user.name,
          testMode: _testMode,
        );
        debugPrint('Notifications enabled (testMode: $_testMode)');
      }
    } else {
      await _notificationService.cancelHydrationNotifications();
      debugPrint('Notifications disabled');
    }
  }

  /// Toggle test mode on/off.
  /// If hourly reminders are already ON, reschedule immediately with new mode.
  Future<void> toggleTestMode(bool value) async {
    _testMode = value;
    notifyListeners();
    debugPrint('Test mode: $_testMode');

    if (!_hourlyReminders) return;

    final user = _userRepository.getUser();
    if (user != null) {
      await _notificationService.cancelHydrationNotifications();
      await _notificationService.scheduleHourlyNotifications(
        wakeTime: user.wakeTime,
        sleepTime: user.sleepTime,
        nickname: user.name,
        testMode: _testMode,
      );
      debugPrint('Rescheduled notifications (testMode: $_testMode)');
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
    _testMode = false;
    _country = 'Thailand';
    _city = 'Chiang Rai';
    _appearance = 'Light';
    notifyListeners();
  }
}
