// lib/main.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:zifromania/app.dart';
import 'package:zifromania/core/config/app_config.dart';
import 'package:zifromania/core/providers/shared_preferences_provider.dart';
import 'package:zifromania/core/services/daily_reward_bg_service.dart';
import 'package:zifromania/core/services/notification_service.dart';
import 'package:zifromania/core/services/rewarded_ad_service.dart';
import 'package:zifromania/core/services/shared_preferences_service.dart';
import 'package:zifromania/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await dotenv.load().catchError((_) {});
  await GoogleSignIn.instance.initialize(serverClientId: AppConfig.googleServerClientId);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final sharedPreferences = PreferencesService();
  await sharedPreferences.init();

  // Initialize RewardedAdService
  final adService = RewardedAdService();
  await adService.initialize();

  // Create the main ProviderContainer and override SharedPreferences.
  final overrides = [
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    rewardedAdServiceProvider.overrideWithValue(adService),
  ];
  final container = ProviderContainer(overrides: overrides);

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
