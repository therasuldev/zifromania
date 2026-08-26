abstract class DailyRewardRepository {
  // Returns true if the daily reward is ready to be claimed, false otherwise.
  Future<bool> isRewardReady();

  // Returns the remaining time until the daily reward is ready to be claimed.
  Future<Duration> timeUntilReady();

  // Claims the daily reward and returns a Future that completes when the operation is done.
  Future<void> claimReward();
}
