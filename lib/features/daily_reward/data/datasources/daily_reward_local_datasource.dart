abstract class DailyRewardLocalDataSource {
  Future<int> getLastClaimMillis();
  Future<void> saveLastClaimMillis(int millis);
}
