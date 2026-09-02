import 'package:zifromania/core/services/shared_preferences_service.dart';

import 'package:zifromania/features/daily_reward/data/datasources/daily_reward_local_datasource.dart';

class DailyRewardLocalDataSourceImpl implements DailyRewardLocalDataSource {
  final PreferencesService prefs;

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
