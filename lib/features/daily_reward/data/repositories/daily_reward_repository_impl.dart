import 'package:zifromania/features/daily_reward/data/datasources/daily_reward_local_datasource.dart';
import 'package:zifromania/features/daily_reward/domain/repositories/daily_reward_repository.dart';

class DailyRewardRepositoryImpl implements DailyRewardRepository {
  final DailyRewardLocalDataSource localDataSource;

  DailyRewardRepositoryImpl(this.localDataSource);

  static const _kCooldown = Duration(hours: 24);

  @override
  Future<bool> isRewardReady() async {
    final last = await localDataSource.getLastClaimMillis();
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - last;
    return elapsedMs >= _kCooldown.inMilliseconds;
  }

  @override
  Future<Duration> timeUntilReady() async {
    final last = await localDataSource.getLastClaimMillis();
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - last;
    if (elapsedMs >= _kCooldown.inMilliseconds) return Duration.zero;
    return Duration(milliseconds: _kCooldown.inMilliseconds - elapsedMs);
  }

  @override
  Future<void> claimReward() async {
    await localDataSource.saveLastClaimMillis(DateTime.now().millisecondsSinceEpoch);
  }
}
