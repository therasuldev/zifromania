// task_state.dart
part of 'task_bloc.dart';

class TaskState {
  final List<TaskModel> tasks;
  final TaskEvents? event;

  TaskState({required this.tasks, required this.event});

  factory TaskState.initial() => TaskState(tasks: [], event: null);
}
