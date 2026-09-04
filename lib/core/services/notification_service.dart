import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/models/remote_message_data.dart';
import 'package:zifromania/core/services/local_notification_service.dart';
import 'package:zifromania/core/services/log_service.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? fcm,
    required LogService logger,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _log = logger;

  final FirebaseMessaging _fcm;
  final LogService _log;

  Future<void> init() async {
    _log.i('Initializing FCM…');
    await LocalNotificationService.initialize(_log);
    await _requestPermission();
    await _subscribeToTopic('all');
    _bindMessageStreams();
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission();
    _log.i('FCM permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _log.w('User denied notification permission – skipping FCM config');
    }
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      _log.i('Subscribed to FCM topic «$topic»');
    } catch (e, s) {
      _log.e('FCM topic subscription failed: $e', e, s);
    }
  }

  void _bindMessageStreams() {
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);
    _fcm.getInitialMessage().then(_handleRemoteMessage);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    _log.d('Foreground push: ${jsonEncode(message.data)}');
    final data = RemoteMessageData.fromJson(message.data);

    await LocalNotificationService.show(
      title: message.notification?.title ?? data.title ?? '',
      body: message.notification?.body ?? data.body ?? '',
    );
  }

  void _handleRemoteMessage(RemoteMessage? message) {
    if (message == null) return;
    final data = RemoteMessageData.fromJson(message.data);
    _log.i('Tapped push routed to «${data.route}» with value «${data.value}»');
  }
}

// Global NotificationService Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(logger: ref.watch(logServiceProvider));
});
