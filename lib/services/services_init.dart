// lib/services/services_init.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';

import 'firebase_auth_service.dart';
import 'api_client.dart';
import 'audio_service.dart';
import 'auth_service.dart';
import 'cache_service.dart';
import 'daily_reward_service.dart';
import 'in_app_purchase_service.dart';
import 'log_service.dart';
import 'notification_service.dart';
import 'question_service.dart';
import 'game_limit_service.dart';
import 'settings_service.dart';
import 'sound_service.dart';
import 'task_service.dart';
import 'title_service.dart';
import 'user_service.dart';
import 'xp_service.dart';

final locator = GetIt.instance;

Future<void> initializeServices() async {
  /// Core singletons
  locator
    ..registerLazySingleton(() => LogService())
    ..registerLazySingleton(() => Dio())
    ..registerLazySingleton(() => FirebaseAuthService())
    ..registerLazySingleton(
      () => ApiClient(
        dio: locator<Dio>(),
        firebaseAuthService: locator<FirebaseAuthService>(),
      ),
    );

  /// Domain singletons
  locator
    ..registerLazySingleton(() => AuthService())
    ..registerLazySingleton(() => InAppPurchaseService())
    ..registerLazySingleton(() => UserService())
    ..registerLazySingleton(() => SecureCacheService())
    ..registerSingleton<SharedPreferences>(await SharedPreferences.getInstance())
    ..registerLazySingleton(() => GameLimitService(locator<SharedPreferences>()))
    ..registerLazySingleton(() => SettingsService())
    ..registerLazySingleton(() => SoundService())
    ..registerLazySingleton(() => AdManager())
    ..registerLazySingleton(() => XpService())
    ..registerLazySingleton(() => AudioService())
    ..registerLazySingleton(() => DailyRewardService())
    ..registerLazySingleton(() => TaskService())
    ..registerLazySingleton(() => TitleService())
    ..registerLazySingleton(
      () => QuestionService(
        gameLimitService: locator<GameLimitService>(),
      ),
    )
    ..registerLazySingleton(
      () => NotificationService(
        apiClient: locator<ApiClient>(),
        logger: locator<LogService>(),
      ),
    );

  /// Async initialisation
  await Future.wait([
    locator<SettingsService>().init(),
    locator<SoundService>().init(),
    locator<AdManager>().initialize(),
    locator<DailyRewardService>().init(),
    LocalNotificationService.initialize(),
    locator<NotificationService>().init(),
  ]);
}
