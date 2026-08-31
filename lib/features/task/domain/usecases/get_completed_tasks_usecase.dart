import 'package:zifromania/features/user/domain/repositories/user_repository.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

final class GetCompletedTasksUseCase {
  const GetCompletedTasksUseCase({
    required this.taskRepository,
    required this.userRepository,
  });

  final TaskRepository taskRepository;
  final UserRepository userRepository;

  Future<List<TaskEntity>> call(String uid) async {
    final user = await userRepository.getUser(uid: uid);
    final List<String> completedTaskIds = user.completedTasks;

    if (completedTaskIds.isEmpty) {
      return [];
    }

    return taskRepository.getTasksByIds(completedTaskIds);
  }
}
