import 'package:zifromania/features/task/data/datasource/task_datasource.dart';

import 'package:zifromania/features/task/domain/entities/task_entity.dart';
import 'package:zifromania/features/task/domain/repositories/task_repository.dart';

final class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({required this.remoteDataSource});

  final TaskRemoteDataSource remoteDataSource;

  @override
  Future<List<TaskEntity>> getAllTasks() => remoteDataSource.getAllTasks();

  @override
  Future<TaskEntity> getTaskById(String taskId) => remoteDataSource.getTaskById(taskId);

  @override
  Future<List<TaskEntity>> getTasksByIds(List<String> taskIds) => remoteDataSource.getTasksByIds(taskIds);
}