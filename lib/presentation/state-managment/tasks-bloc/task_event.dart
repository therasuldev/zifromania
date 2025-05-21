// task_event.dart
part of 'task_bloc.dart';

enum TaskEvents {
  fetchAllTasksStart,
  fetchAllTasksSuccess,
  fetchAllTasksFailure,
  fetchCompletedTasksStart,
  fetchCompletedTasksSuccess,
  fetchCompletedTasksFailure,
  fetchPendingTasksStart,
  fetchPendingTasksSuccess,
  fetchPendingTasksFailure,
  completeTaskStart,
  completeTaskSuccess,
  completeTaskFailure,
}

class TaskEvent {
  TaskEvents? type;
  dynamic payload;

  TaskEvent.fetchAllTasksStart() {
    type = TaskEvents.fetchAllTasksStart;
  }

  TaskEvent.fetchCompletedTasksStart({required this.payload}) {
    type = TaskEvents.fetchCompletedTasksStart;
  }

  TaskEvent.fetchPendingTasksStart({required this.payload}) {
    type = TaskEvents.fetchPendingTasksStart;
  }

  TaskEvent.completeTaskStart({required this.payload}) {
    type = TaskEvents.completeTaskStart;
  }
}
