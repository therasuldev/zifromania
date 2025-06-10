import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/models/task_model.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/user_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tasksCollection = 'tasks';
  final UserService _userService = UserService();

  // Get all available tasks
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_tasksCollection).get();

      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      throw Exception('Failed to get tasks: $e');
    }
  }

  // Get specific task by ID
  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_tasksCollection).doc(taskId).get();

      if (doc.exists) {
        return TaskModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      print('Error getting task: $e');
      throw Exception('Failed to get task: $e');
    }
  }

  // Mark a task as completed for a user
  Future<void> completeTask(String uid, String taskId) async {
    try {
      // Get task details to retrieve rewards
      final TaskModel task = await getTaskById(taskId);

      // Mark task as completed and award rewards
      await _userService.completeTask(uid, taskId, task.xpReward, task.coinsReward);
    } catch (e) {
      print('Error completing task: $e');
      throw Exception('Failed to complete task: $e');
    }
  }

  // Get tasks completed by a user
  Future<List<TaskModel>> getCompletedTasks(String uid) async {
    try {
      // Get user data
      final UserModel user = await _userService.fetchFullUser(uid);

      // Get completed task IDs
      final List<String> completedTaskIds = user.completedTasks;

      if (completedTaskIds.isEmpty) {
        return [];
      }

      // Fetch task details for each ID
      final List<TaskModel> completedTasks = [];
      for (final taskId in completedTaskIds) {
        try {
          final task = await getTaskById(taskId);
          completedTasks.add(task);
        } catch (e) {
          print('Error fetching task $taskId: $e');
          // Continue with next task
        }
      }

      return completedTasks;
    } catch (e) {
      print('Error getting completed tasks: $e');
      throw Exception('Failed to get completed tasks: $e');
    }
  }

  // Get tasks not yet completed by a user
  Future<List<TaskModel>> getPendingTasks(String uid) async {
    try {
      // Get all tasks
      final List<TaskModel> allTasks = await getAllTasks();

      // Get completed task IDs
      final UserModel user = await _userService.fetchFullUser(uid);
      final List<String> completedTaskIds = user.completedTasks;

      // Filter out completed tasks
      return allTasks.where((task) => !completedTaskIds.contains(task.id)).toList();
    } catch (e) {
      print('Error getting pending tasks: $e');
      throw Exception('Failed to get pending tasks: $e');
    }
  }
}
