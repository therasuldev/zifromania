import '../entities/task_entity.dart';

abstract interface class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();

  Future<TaskEntity> getTaskById(String taskId);

  Future<List<TaskEntity>> getTasksByIds(List<String> taskIds);
}
