import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class CompleteTaskUseCase {
  final UserStatisticsRepository repository;

  const CompleteTaskUseCase(
    this.repository,
  );

  Future<void> call({
    required String uid,
    required String taskId,
    required int xpReward,
    required int coinsReward,
  }) {
    return repository.completeTask(
      uid: uid,
      taskId: taskId,
      xpReward: xpReward,
      coinsReward: coinsReward,
    );
  }
}