// lib/main.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zifromania/app.dart';
import 'package:zifromania/core/services/notification_service.dart';
import 'package:zifromania/core/providers/shared_prefs_provider.dart';
import 'package:zifromania/firebase_options.dart';

import 'core/services/daily_reward_bg_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load();

  // Retrieve the SharedPreferences instance.
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create the main ProviderContainer and override SharedPreferences.
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  // Initialize NotificationService using the Riverpod container.
  await container.read(notificationServiceProvider).init();
  // Initialize DailyRewardBgService to set up background tasks and notifications.
  await DailyRewardBgService.initWorkManager();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('tr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ZifroMania(),
      ),
    ),
  );
}
