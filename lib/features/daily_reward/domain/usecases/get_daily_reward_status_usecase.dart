import 'package:zifromania/features/daily_reward/presentation/state/daily_reward_state.dart';
import '../repositories/daily_reward_repository.dart';

class GetDailyRewardStatusUseCase {
  final DailyRewardRepository _repository;

  GetDailyRewardStatusUseCase(this._repository);

  Future<DailyRewardState> call() async {
    final isReady = await _repository.isRewardReady();
    if (isReady) return DailyRewardState.initial().copyWith(isReady: true);

    final remainingTime = await _repository.timeUntilReady();

    return DailyRewardState(isReady: false, remainingTime: remainingTime);
  }
}
