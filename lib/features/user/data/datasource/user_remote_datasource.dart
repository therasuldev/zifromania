import 'package:zifromania/features/user/data/models/game_update_data.dart';

import 'package:zifromania/features/user/data/models/subscription_model.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

abstract interface class UserRemoteDataSource {
  // User

  Future<void> createUserProfile({required UserModel user});

  Future<UserModel> getUser({required String uid});

  Stream<UserModel> watchUser({required String uid});

  Future<void> deleteUser({required String uid});

  // Coins

  Future<UserModel> addCoins({
    required String uid,
    required int amount,
  });

  Future<UserModel> spendCoins({
    required String uid,
    required int amount,
  });

  // XP

  Future<UserModel> addXp({
    required String uid,
    required int xpEarned,
  });

  // Subscription

  Future<void> updateSubscriptionDetails({
    required String uid,
    required SubscriptionModel subscription,
  });

  Future<void> updateSubscriptionStatus({
    required String uid,
    required bool isActive,
  });

  Future<void> expireSubscription({required String uid});

  // Achievements & Tasks

  Future<void> completeTask({
    required String uid,
    required String taskId,
    required int xpReward,
    required int coinsReward,
  });

  Future<void> addAchievement({
    required String uid,
    required String achievementId,
  });

  // Streak

  Future<void> updateDailyStreak({required String uid});

  Future<int> getCurrentStreak({required String uid});

  // Statistics

  Future<void> updateGameStatistics({
    required String uid,
    required GameUpdateData data,
  });

  Future<Set<String>> getDistinctCategoriesPlayed({required String uid});

  Future<double> getCategoryAverageTime({
    required String uid,
    required String category,
  });
}
