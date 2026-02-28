import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _hourlyReminders = true;
  bool _vibrationOnly = false;
  String _country = 'Thailand';
  String _city = 'Chiang Rai';
  String _appearance = 'Light';

  bool get hourlyReminders => _hourlyReminders;
  bool get vibrationOnly => _vibrationOnly;
  String get country => _country;
  String get city => _city;
  String get appearance => _appearance;

  void toggleHourlyReminders(bool value) {
    _hourlyReminders = value;
    notifyListeners();
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
