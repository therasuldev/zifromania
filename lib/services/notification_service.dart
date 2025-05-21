// lib/services/notification_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'access_token_service.dart';
import 'api_client.dart';
import 'log_service.dart';

final _locator = GetIt.instance;

class NotificationService {
  NotificationService({
    FirebaseMessaging? fcm,
    required ApiClient apiClient,
    required LogService logger,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _apiClient = apiClient,
        _log = logger;

  final FirebaseMessaging _fcm;
  final ApiClient _apiClient;
  final LogService _log;

  // === Public API ============================================================
  Future<void> init() async {
    _log.i('Initializing FCM…');
    await _requestPermission();
    await _subscribeToTopic('all');
    _bindMessageStreams();
  }

  // === Permission ============================================================
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission();
    _log.i('FCM permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _log.w('User denied notification permission – skipping FCM config');
    }
  }

  // === Topic subscription ====================================================
  Future<void> _subscribeToTopic(String topic) async {
    try {
      final token = await _locator<AccessTokenService>().getAccessToken();
      if (token == null) {
        _log.w('Skipped topic subscription – server token is null');
        return;
      }

      const url = 'https://fcm.googleapis.com/v1/projects/zifromania/messages:send';

      await _apiClient.dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: Headers.jsonContentType,
        ),
        data: jsonEncode({
          'message': {
            'topic': topic,
            'data': {'type': 'topic_subscription', 'topic': topic},
          }
        }),
      );

      _log.i('Subscribed to FCM topic «$topic»');
    } on DioException catch (e, s) {
      _log.e('FCM topic subscription failed: ${e.message}', e, s);
    }
  }

  // === Message handling ======================================================
  void _bindMessageStreams() {
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);
    _fcm.getInitialMessage().then(_handleRemoteMessage);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    _log.d('Foreground push: ${jsonEncode(message.data)}');
    final data = RemoteMessageData.fromJson(message.data);

    await _showLocalNotification(
      title: message.notification?.title ?? data.title ?? '',
      body: message.notification?.body ?? data.body ?? '',
    );
  }

  void _handleRemoteMessage(RemoteMessage? message) {
    if (message == null) return;
    final data = RemoteMessageData.fromJson(message.data);
    // Навигация, аналитика — что душе угодно.
    _log.i('Tapped push routed to «${data.route}» with value «${data.value}»');
  }

  // === Local notifications ===================================================
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    await LocalNotificationService.show(title: title, body: body);
  }
}

// -----------------------------------------------------------------------------

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: _backgroundTap,
    );
  }

  static Future<void> show({
    required String title,
    required String body,
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

    await _plugin.show(0, title, body, details);
  }

  // Must be a top-level/tear-off for Android background isolate
  @pragma('vm:entry-point')
  static void _backgroundTap(NotificationResponse r) {
    _locator<LogService>().d('Background notification tapped: ${r.payload}');
  }
}

// -----------------------------------------------------------------------------

class RemoteMessageData {
  final String? title;
  final String? body;
  final String? route;
  final String? value;

  RemoteMessageData({
    this.title,
    this.body,
    this.route,
    this.value,
  });

  factory RemoteMessageData.fromJson(Map<String, dynamic> json) => RemoteMessageData(
        title: json['title'] as String?,
        body: json['body'] as String?,
        route: json['route'] as String?,
        value: json['value'] as String?,
      );
}
