import 'package:zifromania/features/daily_reward/domain/repositories/daily_reward_repository.dart';

class ClaimDailyRewardUseCase {
  final DailyRewardRepository _repository;

  ClaimDailyRewardUseCase(this._repository);

  Future<void> call() async {
    await _repository.claimReward();
  }
}
