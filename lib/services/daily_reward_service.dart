import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';

/// Key names & constants
const _kTaskName = 'dailyRewardTask';
const _kLastClaimKey = 'lastClaimMillis';
const _kNotificationIdReady = 100;
const _kChannelId = 'daily_reward';
const _kChannelName = 'Daily Reward';
const _kChannelDescription = 'Alerts you when your free daily coin reward is ready.';
const _kCooldown = Duration(hours: 24);

class DailyRewardService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// Call this once — e.g. in main() before runApp().
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialise timezone db so zoned schedules fire at the expected local time.
    tz.initializeTimeZones();

    // Init local‑notifications plugin.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (resp) {
        // Handle tap — you might navigate to the reward screen here.
      },
    );

    // Register a WorkManager background task that runs once a day.
    await Workmanager().initialize(_callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _kTaskName,
      _kTaskName,
      frequency: _kCooldown, // 24 h
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      initialDelay: const Duration(minutes: 1), // gives system time to settle
    );

    // Ensure next scheduled notification exists (e.g. fresh install).
    // await _ensureScheduled();
  }

  // ---------------------------------------------------------------------------
  // Public API your UI/business layer can call.

  /// Returns true if 24 h passed since the last successful claim.
  Future<bool> isRewardReady() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_kLastClaimKey) ?? 0;
    return DateTime.now().millisecondsSinceEpoch - last >= _kCooldown.inMilliseconds;
  }

  /// Returns the duration until the next reward is ready.
  /// If already ready, returns [Duration.zero].
  Future<Duration> timeUntilReady() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_kLastClaimKey) ?? 0;
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - last;
    if (elapsedMs >= _kCooldown.inMilliseconds) return Duration.zero;
    return Duration(milliseconds: _kCooldown.inMilliseconds - elapsedMs);
  }

  /// Convenience helper to render a nice short string from a [Duration].
  static String formatRemainingTime(Duration d) {
    if (d <= Duration.zero) return '0 dk';

    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    // Əgər ümumilikdə 1 dəqiqədən az qalıbsa (amma sıfırdan çoxdursa), 1 dəq göstər
    if (d.inMinutes == 0) return '1 dk';

    if (hours > 0) return '$hours saat $minutes dk';
    return '$minutes dk';
  }

  /// Call this when the user collects their daily reward.
  Future<void> claimReward() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _kLastClaimKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    // Əgər əvvəlki "reward ready" notification-u qalıbsa sil.
    await _notifications.cancel(id: _kNotificationIdReady);
  }

  // ---------------------------------------------------------------------------
  // Private helpers

  // Future<void> _ensureScheduled() async {
  //   final pending = await _notifications.pendingNotificationRequests();
  //   if (!pending.any((n) => n.id == _kNotificationIdScheduled)) {
  //     await _scheduleNextReadyNotification();
  //   }
  // }

  // Future<void> _scheduleNextReadyNotification() async {
  //   final next = tz.TZDateTime.now(tz.local).add(_kCooldown);
  //   await _notifications.zonedSchedule(
  //     id: _kNotificationIdScheduled,
  //     title: 'Daily reward ready! 🎁',
  //     body: 'Tap to collect your free coins.',
  //     scheduledDate: next,
  //     notificationDetails: const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         _kChannelId,
  //         _kChannelName,
  //         channelDescription: _kChannelDescription,
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  //   );
  // }
}

// -----------------------------------------------------------------------------
// Background isolate (runs *even if* the app was swiped away / process killed)
// -----------------------------------------------------------------------------
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Each isolate needs its own plugin instance + zone DB.
    tz.initializeTimeZones();
    final notifications = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await notifications.initialize(settings: const InitializationSettings(android: androidInit));

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_kLastClaimKey) ?? 0;
    final ready = DateTime.now().millisecondsSinceEpoch - last >= _kCooldown.inMilliseconds;

    if (ready) {
      final pending = await notifications.pendingNotificationRequests();

      final alreadyShown = pending.any(
        (e) => e.id == _kNotificationIdReady,
      );

      if (!alreadyShown) {
        await notifications.show(
          id: _kNotificationIdReady,
          title: 'Your daily reward is waiting! 🎉',
          body: 'Open the app to claim your coins.',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _kChannelId,
              _kChannelName,
              channelDescription: _kChannelDescription,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'daily_reward_ready',
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    }

    return Future.value(true);
  });
}
