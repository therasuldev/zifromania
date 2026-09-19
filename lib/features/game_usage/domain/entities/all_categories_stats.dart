import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

import 'package:zifromania/features/game_usage/domain/entities/category_stats.dart';

class AllCategoriesStats {
  final SubscriptionTypeEntity subscriptionType;
  final int totalDailyRequests;
  final int totalDailyLimits;
  final int flexibleGamesAvailable;
  final int totalRemainingNormalGames;
  final Map<GameCategory, CategoryStats> categories;

  const AllCategoriesStats({
    required this.subscriptionType,
    required this.totalDailyRequests,
    required this.totalDailyLimits,
    required this.flexibleGamesAvailable,
    required this.totalRemainingNormalGames,
    required this.categories,
  });
}
