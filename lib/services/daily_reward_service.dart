import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:rxdart/rxdart.dart';

class DailyRewardService {
  static const String LAST_CLAIM_TIME_KEY = 'last_claim_time';
  static const int REWARD_AMOUNT = 50; // Amount of coins to reward
  static const Duration REWARD_COOLDOWN = Duration(minutes: 2);

  late SharedPreferences _prefs;
  late FlutterLocalNotificationsPlugin _notifications;
  final BehaviorSubject<bool> _rewardAvailable = BehaviorSubject.seeded(false);

  // Stream to notify UI about reward availability
  Stream<bool> get rewardAvailableStream => _rewardAvailable.stream;

  // Constructor without required parameters for service locator
  DailyRewardService({SharedPreferences? prefs, FlutterLocalNotificationsPlugin? notifications}) {
    // These will be initialized in init() method
    if (prefs != null) {
      _prefs = prefs;
    }

    if (notifications != null) {
      _notifications = notifications;
    }
  }

  // Future<bool> _requestExactAlarmPermission() async {
  //   // Only needed for Android 12+
  //   if (Platform.isAndroid) {
  //     // Check Android version
  //     final androidInfo = await DeviceInfoPlugin().androidInfo;
  //     final sdkInt = androidInfo.version.sdkInt;

  //     // Android 12 is SDK version 31
  //     if (sdkInt >= 31) {
  //       final granted = await _notifications
  //           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //           ?.requestExactAlarmsPermission();
  //       return granted ?? false;
  //     }
  //   }
  //   return true; // Permission not needed or already granted
  // }

// Add this method to your DailyRewardService class to request notification permissions for Android 13+
  Future<bool> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Android 13 is SDK version 33
      if (sdkInt >= 33) {
        final granted = await _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? false;
      }
    }

    return true; // Permission not needed
  }

  Future<void> init() async {
    // Initialize shared preferences
    _prefs = await SharedPreferences.getInstance();

    // Initialize notifications
    _notifications = FlutterLocalNotificationsPlugin();

    // Initialize timezone for scheduling notifications
    tz_data.initializeTimeZones();

    // Initialize notification settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Request permissions
    // await _requestExactAlarmPermission();
    await _requestNotificationPermission();

    // Check reward availability
    await _checkRewardAvailability();
  }

  // Check if reward is available to claim
  Future<bool> isRewardAvailable() async {
    final lastClaimTime = _getLastClaimTime();

    if (lastClaimTime == null) {
      return true; // First time users can claim immediately
    }

    final now = DateTime.now();
    final difference = now.difference(lastClaimTime);

    return difference >= REWARD_COOLDOWN;
  }

  // Claim daily reward
  Future<int> claimDailyReward() async {
    final isAvailable = await isRewardAvailable();

    if (!isAvailable) {
      return 0; // No reward available yet
    }

    // Save claim time
    final now = DateTime.now();
    await _prefs.setString(LAST_CLAIM_TIME_KEY, now.toIso8601String());

    // Schedule next notification
    _scheduleNextRewardNotification();

    // Update state
    _rewardAvailable.add(false);

    // Start timer to check availability again
    _startAvailabilityTimer();

    return REWARD_AMOUNT;
  }

  // Get time remaining until next reward
  Future<Duration> getTimeUntilNextReward() async {
    final lastClaimTime = _getLastClaimTime();

    if (lastClaimTime == null) {
      return Duration.zero; // Available immediately
    }

    final now = DateTime.now();
    final nextAvailableTime = lastClaimTime.add(REWARD_COOLDOWN);

    if (now.isAfter(nextAvailableTime)) {
      return Duration.zero; // Available now
    }

    return nextAvailableTime.difference(now);
  }

  // Schedule notification for when reward becomes available
  Future<void> _scheduleNextRewardNotification() async {
    // Cancel any existing notifications
    await _notifications.cancelAll();

    // Schedule the notification for 24 hours from now
    final scheduledDate = tz.TZDateTime.now(tz.local).add(REWARD_COOLDOWN);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_rewards',
      'Daily Rewards',
      channelDescription: 'Notifications for daily rewards',
      importance: Importance.high,
      priority: Priority.high,
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

    const title = 'Daily Reward Available!';
    const body = 'Your free coins are ready to claim!';

    // 2-а. Пишем в консоль
    debugPrint('🔔 $title — $body');

    await _notifications.zonedSchedule(
      0, // Notification ID
      'Daily Reward Available!',
      'Your free coins are ready to claim!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Get last claim time from storage
  DateTime? _getLastClaimTime() {
    final lastClaimTimeStr = _prefs.getString(LAST_CLAIM_TIME_KEY);

    if (lastClaimTimeStr == null) {
      return null;
    }

    return DateTime.parse(lastClaimTimeStr);
  }

  // Check reward availability and update stream
  Future<void> _checkRewardAvailability() async {
    final isAvailable = await isRewardAvailable();
    _rewardAvailable.add(isAvailable);

    if (!isAvailable) {
      _startAvailabilityTimer();
    }
  }

  // Start timer to check when reward becomes available
  void _startAvailabilityTimer() async {
    final timeUntilNextReward = await getTimeUntilNextReward();

    if (timeUntilNextReward > Duration.zero) {
      Timer(timeUntilNextReward, () {
        _rewardAvailable.add(true);
      });
    }
  }

  // Format remaining time as string (e.g. "23h 59m")
  static String formatRemainingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }
}
