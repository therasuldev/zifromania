import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/services/rewarded_ad_service.dart';
import 'package:zifromania/features/game_usage/domain/entities/global_ad_status.dart';
import 'package:zifromania/features/game_usage/game_usage_module.dart';

class AdRewardNotifier extends Notifier<GlobalAdStatus> {
  static const int maxAdsForReward = 3;

  @override
  GlobalAdStatus build() => _readStatus();

  Future<void> watchAd() async {
    if (!state.canWatchMore) return;

    final completed = Completer<bool>();
    ref.read(rewardedAdServiceProvider).showRewardedAd(
      onUserEarnedReward: (_, __) {
        if (!completed.isCompleted) completed.complete(true);
      },
      onAdNotReady: () {
        if (!completed.isCompleted) completed.complete(false);
      },
    );

    final rewarded = await completed.future;
    if (!rewarded) return;

    final repository = ref.read(gameUsageRepositoryProvider);
    final today = DateTime.now();
    final watchedAds = repository.getGlobalAdWatchedCount(today) + 1;
    await repository.setGlobalAdWatchedCount(today, watchedAds);

    if (watchedAds >= maxAdsForReward && !repository.hasEarnedGlobalAdReward(today)) {
      await repository.setGlobalAdRewardEarned(today, true);
      final flexibleGames = repository.getFlexibleGamesCount(today);
      await repository.setFlexibleGamesCount(today, flexibleGames + 3);
    }

    state = _readStatus();
  }

  GlobalAdStatus _readStatus() {
    final repository = ref.read(gameUsageRepositoryProvider);
    final today = DateTime.now();
    final watchedAds = repository.getGlobalAdWatchedCount(today);
    final hasEarnedReward = repository.hasEarnedGlobalAdReward(today);
    final flexibleGames = repository.getFlexibleGamesCount(today);

    return GlobalAdStatus(
      watchedAds: watchedAds,
      maxAds: maxAdsForReward,
      remainingAds: hasEarnedReward ? 0 : (maxAdsForReward - watchedAds).clamp(0, maxAdsForReward),
      hasEarnedReward: hasEarnedReward,
      canWatchMore: watchedAds < maxAdsForReward && !hasEarnedReward,
      flexibleGames: flexibleGames,
    );
  }
}

final adRewardProvider = NotifierProvider<AdRewardNotifier, GlobalAdStatus>(AdRewardNotifier.new);
