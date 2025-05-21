// task_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/services/task_service.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskState.initial()) {
    on<TaskEvent>((event, emit) async {
      switch (event.type) {
        case TaskEvents.fetchAllTasksStart:
          await _onFetchAllTasks(event, emit);
          break;
        case TaskEvents.fetchCompletedTasksStart:
          await _onFetchCompletedTasks(event, emit);
          break;
        case TaskEvents.fetchPendingTasksStart:
          await _onFetchPendingTasks(event, emit);
          break;
        case TaskEvents.completeTaskStart:
          await _onCompleteTask(event, emit);
          break;
        default:
      }
    });
  }

  final TaskService _taskService = TaskService();

  Future<void> _onFetchAllTasks(TaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskState(tasks: [], event: TaskEvents.fetchAllTasksStart));
    try {
      final tasks = await _taskService.getAllTasks();
      emit(TaskState(tasks: tasks, event: TaskEvents.fetchAllTasksSuccess));
    } catch (e) {
      emit(TaskState(tasks: [], event: TaskEvents.fetchAllTasksFailure));
    }
  }

  Future<void> _onFetchCompletedTasks(
      TaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskState(tasks: [], event: TaskEvents.fetchCompletedTasksStart));
    try {
      final tasks = await _taskService.getCompletedTasks(event.payload);
      emit(TaskState(tasks: tasks, event: TaskEvents.fetchCompletedTasksSuccess));
    } catch (e) {
      emit(TaskState(tasks: [], event: TaskEvents.fetchCompletedTasksFailure));
    }
  }

  Future<void> _onFetchPendingTasks(
      TaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskState(tasks: [], event: TaskEvents.fetchPendingTasksStart));
    try {
      final tasks = await _taskService.getPendingTasks(event.payload);
      emit(TaskState(tasks: tasks, event: TaskEvents.fetchPendingTasksSuccess));
    } catch (e) {
      emit(TaskState(tasks: [], event: TaskEvents.fetchPendingTasksFailure));
    }
  }

  Future<void> _onCompleteTask(
      TaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskState(tasks: state.tasks, event: TaskEvents.completeTaskStart));
    try {
      final data = event.payload as Map<String, String>;
      await _taskService.completeTask(data['uid']!, data['taskId']!);
      emit(TaskState(tasks: state.tasks, event: TaskEvents.completeTaskSuccess));
    } catch (e) {
      emit(TaskState(tasks: state.tasks, event: TaskEvents.completeTaskFailure));
    }
  }
}