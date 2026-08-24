import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/firebase_provider.dart';

import 'data/datasource/user_remote_datasource.dart';
import 'data/datasource/user_remote_datasource_impl.dart';
import 'data/helpers/game_statistics_calculator.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/user_statistics_repository_impl.dart';

import 'domain/repositories/subscription_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/user_statistics_repository.dart';
import 'domain/usecases/statistics/add_achievement.dart';
import 'domain/usecases/statistics/complete_task.dart';
import 'domain/usecases/statistics/get_category_average_time.dart';
import 'domain/usecases/statistics/get_current_streak.dart';
import 'domain/usecases/statistics/get_distinct_categories_played_usecase.dart';
import 'domain/usecases/statistics/update_daily_streak.dart';
import 'domain/usecases/statistics/update_game_statistics.dart';
import 'domain/usecases/subscription/expire_subscription.dart';
import 'domain/usecases/subscription/update_subscription_details.dart';
import 'domain/usecases/subscription/update_subscription_status.dart';
import 'domain/usecases/user/add_coins.dart';
import 'domain/usecases/user/add_xp.dart';
import 'domain/usecases/user/create_user_profile.dart';
import 'domain/usecases/user/delete_user.dart';
import 'domain/usecases/user/get_user.dart';
import 'domain/usecases/user/spend_coins.dart';
import 'domain/usecases/user/watch_user.dart';

final gameStatisticsCalculatorProvider = Provider<GameStatisticsCalculator>((ref) {
  return const GameStatisticsCalculator();
});

// User Remote Data Source, Repository and Use Case Providers
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final calculator = ref.watch(gameStatisticsCalculatorProvider);
  return UserRemoteDataSourceImpl(firestore: firestore, calculator: calculator);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: remoteDataSource);
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

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return CompleteTaskUseCase(ref.watch(userStatisticsRepositoryProvider));
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
  return UpdateSubscriptionDetailsUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
});

final updateSubscriptionStatusUseCaseProvider = Provider<UpdateSubscriptionStatusUseCase>((ref) {
  return UpdateSubscriptionStatusUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
});

final expireSubscriptionUseCaseProvider = Provider<ExpireSubscriptionUseCase>((ref) {
  return ExpireSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
});
