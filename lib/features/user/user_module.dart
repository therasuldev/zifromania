import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/firebase_provider.dart';
import 'package:zifromania/core/services/secure_storage_service.dart';

import 'package:zifromania/features/user/data/datasource/user_local_data_source.dart';
import 'package:zifromania/features/user/data/datasource/user_local_data_source_impl.dart';
import 'package:zifromania/features/user/data/datasource/user_remote_datasource.dart';
import 'package:zifromania/features/user/data/datasource/user_remote_datasource_impl.dart';
import 'package:zifromania/features/user/data/helpers/game_statistics_calculator.dart';
import 'package:zifromania/features/user/data/repositories/subscription_repository_impl.dart';
import 'package:zifromania/features/user/data/repositories/user_repository_impl.dart';
import 'package:zifromania/features/user/data/repositories/user_statistics_repository_impl.dart';

import 'package:zifromania/features/user/domain/repositories/subscription_repository.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';
import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';
import 'package:zifromania/features/user/domain/usecases/statistics/add_achievement.dart';
import 'package:zifromania/features/user/domain/usecases/statistics/get_category_average_time.dart';
import 'package:zifromania/features/user/domain/usecases/statistics/get_current_streak.dart';
import 'package:zifromania/features/user/domain/usecases/statistics/get_distinct_categories_played_usecase.dart';
import 'package:zifromania/features/user/domain/usecases/statistics/update_daily_streak.dart';
import 'package:zifromania/features/user/domain/usecases/statistics/update_game_statistics.dart';
import 'package:zifromania/features/user/domain/usecases/subscription/expire_subscription.dart';
import 'package:zifromania/features/user/domain/usecases/subscription/update_subscription_details.dart';
import 'package:zifromania/features/user/domain/usecases/subscription/update_subscription_status.dart';
import 'package:zifromania/features/user/domain/usecases/user/add_coins.dart';
import 'package:zifromania/features/user/domain/usecases/user/add_xp.dart';
import 'package:zifromania/features/user/domain/usecases/user/create_user_profile.dart';
import 'package:zifromania/features/user/domain/usecases/user/delete_user.dart';
import 'package:zifromania/features/user/domain/usecases/user/get_user.dart';
import 'package:zifromania/features/user/domain/usecases/user/spend_coins.dart';
import 'package:zifromania/features/user/domain/usecases/user/watch_user.dart';

final gameStatisticsCalculatorProvider = Provider<GameStatisticsCalculator>((ref) {
  return const GameStatisticsCalculator();
});

// User Remote Data Source, Repository and Use Case Providers
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final calculator = ref.watch(gameStatisticsCalculatorProvider);
  return UserRemoteDataSourceImpl(firestore: firestore, calculator: calculator);
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  return UserLocalDataSourceImpl(storage: secureStorageService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

final spendCoinsUseCaseProvider = Provider<SpendCoinsUseCase>((ref) {
  return SpendCoinsUseCase(ref.watch(userRepositoryProvider));
});

final watchUserUseCaseProvider = Provider<WatchUserUseCase>((ref) {
  return WatchUserUseCase(ref.watch(userRepositoryProvider));
});

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  return DeleteUserUseCase(ref.watch(userRepositoryProvider));
});

final addCoinsUseCaseProvider = Provider<AddCoinsUseCase>((ref) {
  return AddCoinsUseCase(ref.watch(userRepositoryProvider));
});

final addXpUseCaseProvider = Provider<AddXpUseCase>((ref) {
  return AddXpUseCase(ref.watch(userRepositoryProvider));
});

final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.watch(userRepositoryProvider));
});

final createUserProfileUseCaseProvider = Provider<CreateUserProfileUseCase>((ref) {
  return CreateUserProfileUseCase(ref.watch(userRepositoryProvider));
});

// User Statistics Repository and Use Case Providers
final userStatisticsRepositoryProvider = Provider<UserStatisticsRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserStatisticsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final updateGameStatisticsUseCaseProvider = Provider<UpdateGameStatisticsUseCase>((ref) {
  return UpdateGameStatisticsUseCase(ref.watch(userStatisticsRepositoryProvider));
});

final updateDailyStreakUseCaseProvider = Provider<UpdateDailyStreakUseCase>((ref) {
  return UpdateDailyStreakUseCase(ref.watch(userStatisticsRepositoryProvider));
});

final getCurrentStreakUseCaseProvider = Provider<GetCurrentStreakUseCase>((ref) {
  return GetCurrentStreakUseCase(ref.watch(userStatisticsRepositoryProvider));
});

final getDistinctCategoriesPlayedUseCaseProvider = Provider<GetDistinctCategoriesPlayedUseCase>((ref) {
  return GetDistinctCategoriesPlayedUseCase(ref.watch(userStatisticsRepositoryProvider));
});

final getCategoryAverageTimeUseCaseProvider = Provider<GetCategoryAverageTimeUseCase>((ref) {
  return GetCategoryAverageTimeUseCase(ref.watch(userStatisticsRepositoryProvider));
});

final addAchievementUseCaseProvider = Provider<AddAchievementUseCase>((ref) {
  return AddAchievementUseCase(ref.watch(userStatisticsRepositoryProvider));
});

// Subscription repository providers
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return SubscriptionRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Subscription Use Cases
final updateSubscriptionDetailsUseCaseProvider = Provider<UpdateSubscriptionDetailsUseCase>((ref) {
  return UpdateSubscriptionDetailsUseCase(ref.watch(subscriptionRepositoryProvider));
});

final updateSubscriptionStatusUseCaseProvider = Provider<UpdateSubscriptionStatusUseCase>((ref) {
  return UpdateSubscriptionStatusUseCase(ref.watch(subscriptionRepositoryProvider));
});

final expireSubscriptionUseCaseProvider = Provider<ExpireSubscriptionUseCase>((ref) {
  return ExpireSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});
