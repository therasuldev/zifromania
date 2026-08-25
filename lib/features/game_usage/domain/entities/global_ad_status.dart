class GlobalAdStatus {
  final int watchedAds;
  final int maxAds;
  final int remainingAds;
  final bool hasEarnedReward;
  final bool canWatchMore;
  final int flexibleGames;

  const GlobalAdStatus({
    required this.watchedAds,
    required this.maxAds,
    required this.remainingAds,
    required this.hasEarnedReward,
    required this.canWatchMore,
    required this.flexibleGames,
  });
}
