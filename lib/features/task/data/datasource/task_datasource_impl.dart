import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/task/data/models/task_model.dart';

import 'task_datasource.dart';

final class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const String _tasksCollection = 'tasks';

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final snapshot = await _firestore.collection(_tasksCollection).get();
      return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw ServerException('Failed to get tasks: $e');
    }
  }

  @override
  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection(_tasksCollection).doc(taskId).get();
      if (!doc.exists || doc.data() == null) {
        throw const ServerException('Task not found');
      }
      return TaskModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get task: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByIds(List<String> taskIds) async {
    if (taskIds.isEmpty) return [];

    final List<TaskModel> tasks = [];
    for (final id in taskIds) {
      try {
        final task = await getTaskById(id);
        tasks.add(task);
      } catch (_) {
        continue;
      }
    }
    return tasks;
  }
}
