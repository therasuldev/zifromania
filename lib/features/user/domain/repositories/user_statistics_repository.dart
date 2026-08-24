import 'package:zifromania/features/user/data/models/game_update_data.dart';

abstract interface class UserStatisticsRepository {
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

  Future<void> updateDailyStreak({required String uid});

  Future<void> updateGameStatistics({
    required String uid,
    required GameUpdateData data,
  });

  Future<int> getCurrentStreak({required String uid});

  Future<Set<String>> getDistinctCategoriesPlayed({required String uid});

  Future<double> getCategoryAverageTime({
    required String uid,
    required String category,
  });
}
