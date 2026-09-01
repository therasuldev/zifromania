import 'package:easy_localization/easy_localization.dart';

extension DurationFormatterExt on Duration {
  String toFormattedRewardTime() {
    if (this <= Duration.zero) {
      return 'coin.daily_reward.reward_time_ready'.tr();
    }

    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0) {
      return 'coin.daily_reward.reward_time_hours_minutes'.tr(namedArgs: {
        'hours': hours.toString(),
        'minutes': minutes.toString(),
      });
    } else {
      final displayMinutes = minutes == 0 ? 1 : minutes;
      return 'coin.daily_reward.reward_time_minutes'.tr(args: [displayMinutes.toString()]);
    }
  }
}
