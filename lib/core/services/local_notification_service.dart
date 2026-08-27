import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'log_service.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize([LogService? logger]) async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        logger?.d('Foreground notification tapped: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: _backgroundTap,
    );
  }

  /// Ümumi bildiriş göstərmək üçün (FCM daxili bildirişlər və s.)
  static Future<void> show({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Daily Reward üçün xüsusi bildiriş göstərən metod
  static Future<void> showDailyRewardNotification({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reward_channel',
        'Daily Reward Notifications',
        channelDescription: 'Alerts you when your free daily reward is ready.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Gözləmədə olan bildirişləri yoxlamaq üçün
  static Future<bool> isNotificationPending(int notificationId) async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((e) => e.id == notificationId);
  }

  @pragma('vm:entry-point')
  static void _backgroundTap(NotificationResponse response) {
    LogService().d('Background notification tapped: ${response.payload}');
  }
}
