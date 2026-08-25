// domain/repositories/game_usage_repository.dart
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

abstract interface class GameUsageRepository {
  // Device
  String getDeviceId();
  Future<void> initializeDeviceIfNeeded();
  int getInstallDate();

  // Subscription
  SubscriptionTypeEntity getSubscriptionType();
  Future<void> setSubscriptionType(SubscriptionTypeEntity type);

  // Daily request count
  int getDailyRequestCount(GameCategory category, DateTime date);
  Future<void> setDailyRequestCount(GameCategory category, DateTime date, int value);

  // Flexible games
  int getFlexibleGamesCount(DateTime date);
  Future<void> setFlexibleGamesCount(DateTime date, int value);

  // Global ad
  int getGlobalAdWatchedCount(DateTime date);
  Future<void> setGlobalAdWatchedCount(DateTime date, int value);
  bool hasEarnedGlobalAdReward(DateTime date);
  Future<void> setGlobalAdRewardEarned(DateTime date, bool value);

  // Category limits (config)
  int getCategoryLimit(SubscriptionTypeEntity subscriptionType, GameCategory category);

  // Admin
  Future<void> clearDailyCounters(DateTime date);
}
