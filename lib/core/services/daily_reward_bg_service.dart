import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'local_notification_service.dart';

const kDailyRewardTaskName = 'dailyRewardTask';
const _kLastClaimKey = 'lastClaimMillis';
const _kNotificationIdReady = 100;
const _kCooldown = Duration(hours: 24);

class DailyRewardBgService {
  static Future<void> initWorkManager() async {
    tz.initializeTimeZones();

    await Workmanager().initialize(_callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kDailyRewardTaskName,
      kDailyRewardTaskName,
      frequency: _kCooldown,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      initialDelay: const Duration(minutes: 1),
    );
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    tz.initializeTimeZones();

    // Initialize local notifications plugin 
    await LocalNotificationService.initialize();

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_kLastClaimKey) ?? 0;
    final ready = DateTime.now().millisecondsSinceEpoch - last >= _kCooldown.inMilliseconds;

    if (ready) {
      final alreadyShown = await LocalNotificationService.isNotificationPending(_kNotificationIdReady);

      if (!alreadyShown) {
        await LocalNotificationService.showDailyRewardNotification(
          notificationId: _kNotificationIdReady,
          title: 'Your daily reward is waiting! 🎉',
          body: 'Open the app to claim your coins.',
        );
      }
    }
    return Future.value(true);
  });
}
