class DailyRewardState {
  final bool isReady;
  final Duration remainingTime;

  const DailyRewardState({
    required this.isReady,
    required this.remainingTime,
  });

  factory DailyRewardState.initial() => const DailyRewardState(
        isReady: false,
        remainingTime: Duration.zero,
      );

  DailyRewardState copyWith({
    bool? isReady,
    Duration? remainingTime,
  }) {
    return DailyRewardState(
      isReady: isReady ?? this.isReady,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}
