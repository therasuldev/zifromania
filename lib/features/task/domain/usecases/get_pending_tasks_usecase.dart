import 'package:zifromania/features/user/domain/repositories/user_repository.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

final class GetPendingTasksUseCase {
  const GetPendingTasksUseCase({
    required this.taskRepository,
    required this.userRepository,
  });

  final TaskRepository taskRepository;
  final UserRepository userRepository;

  Future<List<TaskEntity>> call(String uid) async {
    final user = await userRepository.getUser(uid: uid);
    final allTasks = await taskRepository.getAllTasks();

    final completedTaskIds = user.completedTasks.toSet();

    return allTasks.where((task) => !completedTaskIds.contains(task.id)).toList();
  }
}
