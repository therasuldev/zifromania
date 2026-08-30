import 'package:zifromania/core/services/shared_preferences_service.dart';
import 'game_usage_local_datasource.dart';

final class GameUsageLocalDataSourceImpl implements GameUsageLocalDataSource {
  const GameUsageLocalDataSourceImpl({required this.sharedPreferences});

  final PreferencesService sharedPreferences;
  static const String _dailyRequestCountPrefix = 'daily_request_count_';
  static const String _deviceIdPrefix = 'device_id_';
  static const String _installDatePrefix = 'install_date_';
  static const String _subscriptionTypePrefix = 'subscription_type_';

  // Flexible Games üçün key-lər
  static const String _flexibleGamesCountPrefix = 'flexible_games_count_';

  // Ümumi reklam sayğacları üçün key-lər
  static const String _globalAdWatchedCountPrefix = 'global_ad_watched_count_';
  static const String _globalAdRewardEarnedPrefix = 'global_ad_reward_earned_';

  // Device
  @override
  String? getDeviceId() {
    return sharedPreferences.getString(_deviceIdPrefix);
  }

  @override
  Future<void> setDeviceId(String id) {
    return sharedPreferences.setString(_deviceIdPrefix, id);
  }

  @override
  int? getInstallDate() {
    return sharedPreferences.getInt(_installDatePrefix);
  }

  @override
  Future<void> setInstallDate(int ms) {
    return sharedPreferences.setInt(_installDatePrefix, ms);
  }

  // Subscription
  @override
  String? getSubscriptionTypeRaw() {
    return sharedPreferences.getString(_subscriptionTypePrefix);
  }

  @override
  Future<void> setSubscriptionTypeRaw(String name) {
    return sharedPreferences.setString(_subscriptionTypePrefix, name);
  }

  // Daily request count
  @override
  int getDailyRequestCountRaw(String key) {
    return sharedPreferences.getInt(key) ?? 0;
  }

  @override
  Future<void> setDailyRequestCountRaw(String key, int value) {
    return sharedPreferences.setInt(key, value);
  }

  // Flexible games
  @override
  int getFlexibleGamesRaw(String key) {
    return sharedPreferences.getInt(key) ?? 0;
  }

  @override
  Future<void> setFlexibleGamesRaw(String key, int value) {
    return sharedPreferences.setInt(key, value);
  }

  // Global ad
  @override
  bool getGlobalAdRewardRaw(String key) {
    return sharedPreferences.getBool(key) ?? false;
  }

  @override
  int getGlobalAdWatchedRaw(String key) {
    return sharedPreferences.getInt(key) ?? 0;
  }

  @override
  Future<void> setGlobalAdRewardRaw(String key, bool value) {
    return sharedPreferences.setBool(key, value);
  }

  @override
  Future<void> setGlobalAdWatchedRaw(String key, int value) {
    return sharedPreferences.setInt(key, value);
  }

  // Cleanup
  @override
  Future<void> removeKey(String key) {
    return sharedPreferences.remove(key);
  }
}
