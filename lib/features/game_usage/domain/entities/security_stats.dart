import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'global_ad_status.dart';

class SecurityStats {
  final String deviceId;
  final int daysSinceInstall;
  final int totalDailyRequests;
  final int flexibleGamesAvailable;
  final SubscriptionTypeEntity subscriptionType;
  final GlobalAdStatus globalAdStatus;

  const SecurityStats({
    required this.deviceId,
    required this.daysSinceInstall,
    required this.totalDailyRequests,
    required this.flexibleGamesAvailable,
    required this.subscriptionType,
    required this.globalAdStatus,
  });
}
