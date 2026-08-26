import 'package:shared_preferences/shared_preferences.dart';

abstract class DailyRewardLocalDataSource {
  Future<int> getLastClaimMillis();
  Future<void> saveLastClaimMillis(int millis);
}

class DailyRewardLocalDataSourceImpl implements DailyRewardLocalDataSource {
  final SharedPreferences prefs;

  DailyRewardLocalDataSourceImpl(this.prefs);

  static const _kLastClaimKey = 'lastClaimMillis';

  @override
  Future<int> getLastClaimMillis() async {
    return prefs.getInt(_kLastClaimKey) ?? 0;
  }

  @override
  Future<void> saveLastClaimMillis(int millis) async {
    await prefs.setInt(_kLastClaimKey, millis);
  }
}