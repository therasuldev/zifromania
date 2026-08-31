import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';
import '../repositories/task_repository.dart';

final class CompleteTaskUseCase {
  const CompleteTaskUseCase({
    required this.taskRepository,
    required this.userStatisticsRepository,
  });

  final TaskRepository taskRepository;
  final UserStatisticsRepository userStatisticsRepository;

  Future<void> call({required String uid, required String taskId}) async {
    // 1. Task mükafatlarını öyrənmək üçün detalı alırıq
    final task = await taskRepository.getTaskById(taskId);

    // 2. User statistics/profile üzərində tapşırığı tamamlayıb XP və Coin veririk
    await userStatisticsRepository.completeTask(
      uid: uid,
      taskId: taskId,
      xpReward: task.xpReward,
      coinsReward: task.coinsReward,
    );
  }
}
