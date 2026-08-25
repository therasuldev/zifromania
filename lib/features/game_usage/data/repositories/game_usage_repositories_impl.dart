// data/repositories/game_usage_repository_impl.dart
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/features/game_usage/data/datasource/game_usage_local_datasource.dart';
import 'package:zifromania/features/game_usage/domain/repositories/game_usage_repositories.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

final class GameUsageRepositoryImpl implements GameUsageRepository {
  GameUsageRepositoryImpl({required this.dataSource});

  final GameUsageLocalDataSource dataSource;

  // Köhnə servisdəki kateqoriya limit cədvəli - domain konfiqurasiyası
  static const Map<SubscriptionTypeEntity, Map<GameCategory, int>> _categoryLimits = {
    SubscriptionTypeEntity.free: {
      GameCategory.quickThinking: 3,
      GameCategory.multiplyDivide: 3,
      GameCategory.trueOrFalse: 3,
      GameCategory.expert: 2,
      GameCategory.training: 1,
    },
    SubscriptionTypeEntity.oneMonth: {
      GameCategory.quickThinking: 5,
      GameCategory.multiplyDivide: 5,
      GameCategory.trueOrFalse: 5,
      GameCategory.expert: 3,
      GameCategory.training: 2,
    },
    SubscriptionTypeEntity.threeMonths: {
      GameCategory.quickThinking: 10,
      GameCategory.multiplyDivide: 10,
      GameCategory.trueOrFalse: 10,
      GameCategory.expert: 5,
      GameCategory.training: 4,
    },
    SubscriptionTypeEntity.sixMonths: {
      GameCategory.quickThinking: 20,
      GameCategory.multiplyDivide: 20,
      GameCategory.trueOrFalse: 20,
      GameCategory.expert: 15,
      GameCategory.training: 10,
    },
  };

  // ---- Key generasiyası (yalnız burada, repository daxilində) ----
  String _dailyRequestKey(GameCategory category, DateTime date) => 'daily_request_count_${category.name}_${date.year}_${date.month}_${date.day}';
  String _flexibleGamesKey(DateTime date) => 'flexible_games_count_${date.year}_${date.month}_${date.day}';
  String _globalAdWatchedKey(DateTime date) => 'global_ad_watched_count_${date.year}_${date.month}_${date.day}';
  String _globalAdRewardKey(DateTime date) => 'global_ad_reward_earned_${date.year}_${date.month}_${date.day}';

  // ---- Device ----
  @override
  String getDeviceId() {
    return dataSource.getDeviceId() ?? '';
  }

  @override
  Future<void> initializeDeviceIfNeeded() async {
    final existingId = dataSource.getDeviceId();
    if (existingId == null) {
      final newId = _generateDeviceId();
      await dataSource.setDeviceId(newId);
      await dataSource.setInstallDate(DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  int getInstallDate() {
    return dataSource.getInstallDate() ?? DateTime.now().millisecondsSinceEpoch;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // ---- Subscription ----
  @override
  SubscriptionTypeEntity getSubscriptionType() {
    final name = dataSource.getSubscriptionTypeRaw();
    if (name == null) return SubscriptionTypeEntity.free;
    return SubscriptionTypeEntity.values.firstWhere(
      (type) => type.name == name,
      orElse: () => SubscriptionTypeEntity.free,
    );
  }

  @override
  Future<void> setSubscriptionType(SubscriptionTypeEntity type) {
    return dataSource.setSubscriptionTypeRaw(type.name);
  }

  // ---- Daily request count ----
  @override
  int getDailyRequestCount(GameCategory category, DateTime date) {
    return dataSource.getDailyRequestCountRaw(_dailyRequestKey(category, date));
  }

  @override
  Future<void> setDailyRequestCount(GameCategory category, DateTime date, int value) {
    return dataSource.setDailyRequestCountRaw(_dailyRequestKey(category, date), value);
  }

  // ---- Flexible games ----
  @override
  int getFlexibleGamesCount(DateTime date) {
    return dataSource.getFlexibleGamesRaw(_flexibleGamesKey(date));
  }

  @override
  Future<void> setFlexibleGamesCount(DateTime date, int value) {
    return dataSource.setFlexibleGamesRaw(_flexibleGamesKey(date), value);
  }

  // ---- Global ad ----
  @override
  int getGlobalAdWatchedCount(DateTime date) {
    return dataSource.getGlobalAdWatchedRaw(_globalAdWatchedKey(date));
  }

  @override
  Future<void> setGlobalAdWatchedCount(DateTime date, int value) {
    return dataSource.setGlobalAdWatchedRaw(_globalAdWatchedKey(date), value);
  }

  @override
  bool hasEarnedGlobalAdReward(DateTime date) {
    return dataSource.getGlobalAdRewardRaw(_globalAdRewardKey(date));
  }

  @override
  Future<void> setGlobalAdRewardEarned(DateTime date, bool value) {
    return dataSource.setGlobalAdRewardRaw(_globalAdRewardKey(date), value);
  }

  // ---- Category limits ----
  @override
  int getCategoryLimit(SubscriptionTypeEntity subscriptionType, GameCategory category) {
    return _categoryLimits[subscriptionType]![category]!;
  }

  // ---- Admin ----
  @override
  Future<void> clearDailyCounters(DateTime date) async {
    await dataSource.removeKey(_flexibleGamesKey(date));
    await dataSource.removeKey(_globalAdWatchedKey(date));
    await dataSource.removeKey(_globalAdRewardKey(date));

    for (final category in GameCategory.values) {
      await dataSource.removeKey(_dailyRequestKey(category, date));
    }
  }
}
