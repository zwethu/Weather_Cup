import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service for managing hourly hydration notifications.
///
/// This service handles:
/// - Initialization of flutter_local_notifications
/// - Requesting notification permissions for Android 13+ and iOS
/// - Scheduling hourly hydration reminders between wake and sleep times
/// - Canceling all scheduled notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Base notification ID for hourly notifications (IDs: 1000-1023)
  static const int _baseNotificationId = 1000;

  /// Maximum number of hourly notifications (24 hours max)
  static const int _maxNotifications = 24;

  /// Notification messages that rotate for variety
  static const List<String> _notificationMessages = [
    "Hey {nickname}, time to hydrate! 💙",
    "{nickname}, don't forget your water! 💙",
    "Water break, {nickname}! Your body will thank you 💙",
    "Stay hydrated, {nickname}! 💙",
    "{nickname}, sip some water! 💙",
  ];

  /// Android notification channel configuration
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'hydration_reminder_channel',
    'Hydration Reminders',
    description: 'Hourly reminders to drink water',
    importance: Importance.max, // Changed to max for heads-up notifications
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  bool _isInitialized = false;

  /// Initialize the notification service.
  ///
  /// Sets up flutter_local_notifications for both Android and iOS platforms.
  /// Must be called before any other notification methods.
  ///
  /// Returns [true] if initialization was successful, [false] otherwise.
  Future<bool> initializeNotifications() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

      // Android initialization settings
      const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosInitializationSettings =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      // Initialize the plugin
      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Create Android notification channel
      if (Platform.isAndroid) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      _isInitialized = initialized ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  /// Handle notification tap response
  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap if needed
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions for the current platform.
  ///
  /// For Android 13+ (API 33+): Requests POST_NOTIFICATIONS permission
  /// For iOS: Requests alert, badge, and sound permissions
  ///
  /// Returns [true] if permission was granted, [false] otherwise.
  Future<bool> requestPermissions() async {
    try {
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        // Request permission for Android 13+ (API level 33)
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          final bool? granted = await androidPlugin.requestNotificationsPermission();
          permissionGranted = granted ?? false;
        }
      } else if (Platform.isIOS) {
        // Request permission for iOS
        final bool? granted = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        permissionGranted = granted ?? false;
      }

      return permissionGranted;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedule hourly hydration notifications between wake time and sleep time.
  ///
  /// Notifications are scheduled from [wakeTime] + 1 hour to [sleepTime] - 1 hour.
  /// For example, if wakeTime is "06:30" and sleepTime is "23:30":
  /// - First notification: 07:30
  /// - Last notification: 22:30
  /// - Total: 16 notifications (07:30, 08:30, ..., 22:30)
  ///
  /// Parameters:
  /// - [wakeTime]: Wake time in "HH:mm" format (e.g., "06:30")
  /// - [sleepTime]: Sleep time in "HH:mm" format (e.g., "23:30")
  /// - [nickname]: User's nickname to personalize notification messages
  /// - [testMode]: If true, schedules 5 notifications starting 1 minute from now for testing
  ///
  /// Returns [true] if notifications were scheduled successfully, [false] otherwise.
  Future<bool> scheduleHourlyNotifications({
    required String wakeTime,
    required String sleepTime,
    required String nickname,
    bool testMode = false,
  }) async {
    try {
      // Ensure notifications are initialized
      if (!_isInitialized) {
        final bool initialized = await initializeNotifications();
        if (!initialized) {
          debugPrint('Failed to initialize notifications');
          return false;
        }
      }

      // Cancel any existing notifications first
      await cancelAllNotifications();

      List<TimeOfDay> notificationTimes;

      if (testMode) {
        // 🧪 TEST MODE: Schedule notifications starting 1 minute from now
        debugPrint('⚠️ TEST MODE ENABLED: Scheduling notifications every minute');
        final tz.Location bangkok = tz.getLocation('Asia/Bangkok');
        final tz.TZDateTime now = tz.TZDateTime.now(bangkok);

        notificationTimes = [];
        // Create 5 test notifications: 1min, 2min, 3min, 4min, 5min from now
        for (int i = 0; i < 5; i++) {
          final testTime = now.add(Duration(minutes: i + 1));
          notificationTimes.add(TimeOfDay(
            hour: testTime.hour,
            minute: testTime.minute,
          ));
        }

        debugPrint('Test notifications scheduled for:');
        for (var time in notificationTimes) {
          debugPrint('  - ${time.toString()}');
        }
      } else {
        // 📅 PRODUCTION MODE: Normal hourly schedule
        // Parse wake and sleep times
        final TimeOfDay parsedWakeTime = _parseTime(wakeTime);
        final TimeOfDay parsedSleepTime = _parseTime(sleepTime);

        // Calculate start time (wakeTime + 1 hour) and end time (sleepTime - 1 hour)
        final TimeOfDay startTime = _addHours(parsedWakeTime, 1);
        final TimeOfDay endTime = _subtractHours(parsedSleepTime, 1);

        // Calculate notification hours
        notificationTimes = _calculateNotificationTimes(startTime, endTime);
        debugPrint("------------------------------");
        debugPrint('Wake: $wakeTime, Sleep: $sleepTime');
        debugPrint('StartTime (wake+1): $startTime, EndTime (sleep-1): $endTime');
        debugPrint('Calculated ${notificationTimes.length} production notification times:');
        for (final t in notificationTimes) {
          debugPrint('  - $t');
        }
      }

      if (notificationTimes.isEmpty) {
        debugPrint('No valid notification times calculated');
        return false;
      }

      // Schedule each notification
      final Random random = Random();
      for (int i = 0; i < notificationTimes.length && i < _maxNotifications; i++) {
        final TimeOfDay time = notificationTimes[i];
        final int notificationId = _baseNotificationId + i;

        // Select a random message and personalize it
        final String message = _notificationMessages[random.nextInt(_notificationMessages.length)]
            .replaceAll('{nickname}', nickname);

        await _scheduleDailyNotification(
          id: notificationId,
          time: time,
          title: testMode ? '🧪 Test Reminder' : 'Hydration Reminder',
          body: testMode ? '🧪 TEST: $message' : message,
          isTestMode: testMode,
        );
      }

      debugPrint('Scheduled ${notificationTimes.length} ${testMode ? "test" : "hourly"} notifications');

      return true;
    } catch (e) {
      debugPrint('Error scheduling hourly notifications: $e');
      return false;
    }
  }

  /// Parse time string in "HH:mm" format to TimeOfDay
  TimeOfDay _parseTime(String time) {
    final List<String> parts = time.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Add hours to a TimeOfDay (handles overflow past midnight)
  TimeOfDay _addHours(TimeOfDay time, int hours) {
    final int newHour = (time.hour + hours) % 24;
    return TimeOfDay(hour: newHour, minute: time.minute);
  }

  /// Subtract hours from a TimeOfDay (handles underflow past midnight)
  TimeOfDay _subtractHours(TimeOfDay time, int hours) {
    int newHour = time.hour - hours;
    if (newHour < 0) {
      newHour += 24;
    }
    return TimeOfDay(hour: newHour, minute: time.minute);
  }

  List<TimeOfDay> _calculateNotificationTimes(TimeOfDay startTime, TimeOfDay endTime) {
    final List<TimeOfDay> times = [];

    TimeOfDay currentTime = startTime;
    int iterations = 0;
    const int maxIterations = 24;

    while (iterations < maxIterations) {
      times.add(currentTime);

      // Stop when we reach the end time
      if (currentTime.hour == endTime.hour && currentTime.minute == endTime.minute) {
        break;
      }

      currentTime = _addHours(currentTime, 1);
      iterations++;
    }

    return times;
  }

  /// Check if time1 is after time2 (both on the same day)
  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) {
      return true;
    }
    if (time1.hour == time2.hour && time1.minute > time2.minute) {
      return true;
    }
    return false;
  }

  /// Schedule a daily notification at a specific time.
  ///
  /// The notification will repeat daily at the specified time.
  /// Uses the Asia/Bangkok timezone for scheduling.
  Future<void> _scheduleDailyNotification({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
    bool isTestMode = false,
  }) async {
    // Get the next occurrence of this time
    tz.TZDateTime scheduledDate;

    if (isTestMode) {
      // 🧪 TEST MODE: Use exact time without daily repeat
      final tz.Location bangkok = tz.getLocation('Asia/Bangkok');
      final tz.TZDateTime now = tz.TZDateTime.now(bangkok);

      scheduledDate = tz.TZDateTime(
        bangkok,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time is in the past (shouldn't happen in test mode), add 1 day
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } else {
      // 📅 PRODUCTION MODE: Calculate next daily occurrence
      scheduledDate = _nextInstanceOfTime(time);
    }

    // Notification details for Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hydration_reminder_channel',
      'Hydration Reminders',
      channelDescription: 'Hourly reminders to drink water',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Hydration Reminder',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true, // Shows even when app is in foreground
    );

    // Notification details for iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: isTestMode
          ? null  // 🧪 TEST: Fire once only
          : DateTimeComponents.time,  // 📅 PRODUCTION: Repeat daily
      payload: isTestMode ? 'test_hydration_reminder' : 'hydration_reminder',
    );
  }

  /// Calculate the next occurrence of a specific time in Asia/Bangkok timezone.
  ///
  /// If the time has already passed today, returns tomorrow's occurrence.
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.Location bangkok = tz.getLocation('Asia/Bangkok');
    final tz.TZDateTime now = tz.TZDateTime.now(bangkok);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      bangkok,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel all scheduled notifications.
  ///
  /// This will cancel all notifications, including hydration reminders
  /// and any other notifications scheduled by the app.
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Cancel only hydration reminder notifications.
  ///
  /// Cancels notifications with IDs from [_baseNotificationId] to
  /// [_baseNotificationId] + [_maxNotifications].
  Future<void> cancelHydrationNotifications() async {
    try {
      for (int i = 0; i < _maxNotifications; i++) {
        await _flutterLocalNotificationsPlugin.cancel(_baseNotificationId + i);
      }
      debugPrint('Hydration notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling hydration notifications: $e');
    }
  }

  /// Get the list of pending notifications.
  ///
  /// Useful for debugging and verifying scheduled notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Debug method to print all pending notifications
  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    debugPrint('=== Pending Notifications (${pending.length}) ===');
    for (final notification in pending) {
      debugPrint('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    debugPrint('================================');
  }

  /// Show an IMMEDIATE notification (no scheduling, appears NOW)
  /// Use this to test if notifications work at all
  Future<void> showImmediateTestNotification({String nickname = 'Friend'}) async {
    // Ensure notifications are initialized
    if (!_isInitialized) {
      final bool initialized = await initializeNotifications();
      if (!initialized) {
        debugPrint('❌ Failed to initialize notifications');
        return;
      }
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hydration_reminder_channel',
      'Hydration Reminders',
      channelDescription: 'Hourly reminders to drink water',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Test Notification',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true, // Shows even when app is in foreground
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      9999, // Unique ID for immediate test
      '🎉 Welcome $nickname!',
      'Notifications are working! You will receive hydration reminders.',
      notificationDetails,
      payload: 'immediate_test',
    );

    debugPrint('✅ Immediate notification shown!');
  }
}

/// Helper class representing a time of day.
///
/// Used internally for time calculations.
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
