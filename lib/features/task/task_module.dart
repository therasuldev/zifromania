import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/firebase_provider.dart';
import 'package:zifromania/features/user/user_module.dart';

import 'package:zifromania/features/task/data/datasource/task_datasource.dart';
import 'package:zifromania/features/task/data/datasource/task_datasource_impl.dart';
import 'package:zifromania/features/task/data/repositories/task_repository_impl.dart';
import 'package:zifromania/features/task/domain/repositories/task_repository.dart';
import 'package:zifromania/features/task/domain/usecases/complete_task_usecase.dart';
import 'package:zifromania/features/task/domain/usecases/get_completed_tasks_usecase.dart';
import 'package:zifromania/features/task/domain/usecases/get_pending_tasks_usecase.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return TaskRemoteDataSourceImpl(firestore: firestore);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final taskRemoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remoteDataSource: taskRemoteDataSource);
});

final completeTaskUseCaseprovider = Provider<CompleteTaskUseCase>((ref) {
  final userStatisticsRepository = ref.watch(userStatisticsRepositoryProvider);
  return CompleteTaskUseCase(userStatisticsRepository: userStatisticsRepository, taskRepository: ref.watch(taskRepositoryProvider));
});

final getPendingTasksUseCaseProvider = Provider<GetPendingTasksUseCase>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return GetPendingTasksUseCase(taskRepository: taskRepository, userRepository: userRepository);
});

final getCompletedTasksUseCaseProvider = Provider<GetCompletedTasksUseCase>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return GetCompletedTasksUseCase(taskRepository: taskRepository, userRepository: userRepository);
});
