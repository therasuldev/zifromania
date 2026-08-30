import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/shared_preferences_provider.dart';

import 'data/datasources/daily_reward_local_datasource.dart';
import 'data/repositories/daily_reward_repository_impl.dart';
import 'domain/repositories/daily_reward_repository.dart';
import 'domain/usecases/claim_daily_reward_usecase.dart';
import 'domain/usecases/get_daily_reward_status_usecase.dart';

final dailyRewardLocalDataSourceProvider = Provider<DailyRewardLocalDataSource>((ref) {
  return DailyRewardLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final dailyRewardRepositoryProvider = Provider<DailyRewardRepository>((ref) {
  return DailyRewardRepositoryImpl(ref.watch(dailyRewardLocalDataSourceProvider));
});

final getDailyRewardStatusUseCaseProvider = Provider<GetDailyRewardStatusUseCase>((ref) {
  return GetDailyRewardStatusUseCase(ref.watch(dailyRewardRepositoryProvider));
});

final claimDailyRewardUseCaseProvider = Provider<ClaimDailyRewardUseCase>((ref) {
  return ClaimDailyRewardUseCase(ref.watch(dailyRewardRepositoryProvider));
});
