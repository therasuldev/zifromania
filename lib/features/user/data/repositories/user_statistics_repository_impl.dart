import 'package:zifromania/features/user/data/datasource/user_remote_datasource.dart';
import 'package:zifromania/features/user/data/models/game_update_data.dart';
import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class UserStatisticsRepositoryImpl implements UserStatisticsRepository {
  final UserRemoteDataSource remoteDataSource;

  const UserStatisticsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<void> completeTask({
    required String uid,
    required String taskId,
    required int xpReward,
    required int coinsReward,
  }) {
    return remoteDataSource.completeTask(
      uid: uid,
      taskId: taskId,
      xpReward: xpReward,
      coinsReward: coinsReward,
    );
  }

  @override
  Future<void> addAchievement({
    required String uid,
    required String achievementId,
  }) {
    return remoteDataSource.addAchievement(
      uid: uid,
      achievementId: achievementId,
    );
  }

  @override
  Future<void> updateDailyStreak({required String uid}) {
    return remoteDataSource.updateDailyStreak(uid: uid);
  }

  @override
  Future<void> updateGameStatistics({
    required String uid,
    required GameUpdateData data,
  }) {
    return remoteDataSource.updateGameStatistics(
      uid: uid,
      data: data,
    );
  }

  @override
  Future<int> getCurrentStreak({required String uid}) {
    return remoteDataSource.getCurrentStreak(uid: uid);
  }

  @override
  Future<Set<String>> getDistinctCategoriesPlayed({required String uid}) {
    return remoteDataSource.getDistinctCategoriesPlayed(uid: uid);
  }

  @override
  Future<double> getCategoryAverageTime({
    required String uid,
    required String category,
  }) {
    return remoteDataSource.getCategoryAverageTime(
      uid: uid,
      category: category,
    );
  }
}
