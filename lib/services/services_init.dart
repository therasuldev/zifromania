// lib/services/services_init.dart

import '../locator.dart';
import 'auth_service.dart';
import 'cache_service.dart';
import 'in_app_purchase_service.dart';
import 'settings_service.dart';
import 'sound_service.dart';
import '../presentation/state_managment/ad_manager.dart';
import 'user_service.dart';

Future<void> initializeServices() async {
  // Register services into locator
  locator.registerSingleton(AuthService());
  locator.registerSingleton(InAppPurchaseService());
  locator.registerSingleton(UserService());
  locator.registerSingleton(SecureCacheService());
  locator.registerSingleton(SettingsService());
  locator.registerSingleton(SoundService());
  locator.registerSingleton(AdManager());

  // Initialize services
  await locator.get<SettingsService>().init();
  await locator.get<SoundService>().init();
  await locator.get<AdManager>().initialize();
}
