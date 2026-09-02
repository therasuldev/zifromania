import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/shared_preferences_provider.dart';

import 'package:zifromania/features/daily_reward/data/datasources/daily_reward_local_datasource.dart';
import 'package:zifromania/features/daily_reward/data/datasources/daily_reward_local_datasource_impl.dart';
import 'package:zifromania/features/daily_reward/data/repositories/daily_reward_repository_impl.dart';
import 'package:zifromania/features/daily_reward/domain/repositories/daily_reward_repository.dart';
import 'package:zifromania/features/daily_reward/domain/usecases/claim_daily_reward_usecase.dart';
import 'package:zifromania/features/daily_reward/domain/usecases/get_daily_reward_status_usecase.dart';

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
