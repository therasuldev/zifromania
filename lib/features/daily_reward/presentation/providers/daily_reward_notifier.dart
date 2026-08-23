import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/daily_reward/daily_reward_module.dart';
import 'package:zifromania/features/daily_reward/presentation/state/daily_reward_state.dart';

class DailyRewardNotifier extends Notifier<DailyRewardState> {
  Timer? _timer;

  @override
  DailyRewardState build() {
    ref.onDispose(() => _timer?.cancel());
    _checkStatus();
    return DailyRewardState.initial();
  }

  Future<void> _checkStatus() async {
    final getStatusUseCase = ref.read(getDailyRewardStatusUseCaseProvider);
    final status = await getStatusUseCase();

    state = state.copyWith(isReady: status.isReady, remainingTime: status.remainingTime);

    if (!status.isReady) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final remaining = state.remainingTime - const Duration(seconds: 1);

      if (remaining <= Duration.zero) {
        _timer?.cancel();
        await _checkStatus();
      } else {
        state = state.copyWith(isReady: false, remainingTime: remaining);
      }
    });
  }

  Future<void> claimReward() async {
    final claimUseCase = ref.read(claimDailyRewardUseCaseProvider);
    await claimUseCase();
    await _checkStatus();
  }
}

// Provider for the DailyRewardNotifier
final dailyRewardNotifierProvider = NotifierProvider<DailyRewardNotifier, DailyRewardState>(
  DailyRewardNotifier.new,
);
