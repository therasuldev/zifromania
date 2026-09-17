abstract interface class GameUsageLocalDataSource {
  // Device
  String? getDeviceId();
  Future<void> setDeviceId(String id);
  int? getInstallDate();
  Future<void> setInstallDate(int ms);

  // Subscription
  String? getSubscriptionTypeRaw();
  Future<void> setSubscriptionTypeRaw(String name);

  // Daily request count
  int getDailyRequestCountRaw(String key);
  Future<void> setDailyRequestCountRaw(String key, int value);

  // Flexible games
  int getFlexibleGamesRaw(String key);
  Future<void> setFlexibleGamesRaw(String key, int value);

  // Global ad
  int getGlobalAdWatchedRaw(String key);
  Future<void> setGlobalAdWatchedRaw(String key, int value);
  bool getGlobalAdRewardRaw(String key);
  Future<void> setGlobalAdRewardRaw(String key, bool value);

  // Cleanup
  Future<void> removeKey(String key);
}
