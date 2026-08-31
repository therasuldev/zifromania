import 'package:zifromania/features/task/data/models/task_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<List<TaskModel>> getAllTasks();

  Future<TaskModel> getTaskById(String taskId);
  
  Future<List<TaskModel>> getTasksByIds(List<String> taskIds);
}
