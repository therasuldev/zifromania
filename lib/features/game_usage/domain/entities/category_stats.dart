import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

class CategoryStats {
  final SubscriptionTypeEntity subscriptionType;
  final GameCategory category;
  final int dailyRequestCount;
  final int categoryLimit;
  final int flexibleGamesAvailable;
  final int remainingNormalGames;
  final bool canPlayGame;
  final int totalAvailableGames;

  const CategoryStats({
    required this.subscriptionType,
    required this.category,
    required this.dailyRequestCount,
    required this.categoryLimit,
    required this.flexibleGamesAvailable,
    required this.remainingNormalGames,
    required this.canPlayGame,
    required this.totalAvailableGames,
  });
}