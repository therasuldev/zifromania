import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/entities/category_stats.dart';
import 'package:zifromania/features/game_usage/domain/repositories/game_usage_repositories.dart';

final class GetCategoryStatsUseCase {
  const GetCategoryStatsUseCase(this.repository);

  final GameUsageRepository repository;

  CategoryStats call(GameCategory category) {
    final date = DateTime.now();
    final subscriptionType = repository.getSubscriptionType();
    final categoryLimit = repository.getCategoryLimit(subscriptionType, category);
    final dailyRequestCount = repository.getDailyRequestCount(category, date);
    final flexibleGamesAvailable = repository.getFlexibleGamesCount(date);
    final remainingNormalGames = (categoryLimit - dailyRequestCount).clamp(0, categoryLimit);

    return CategoryStats(
      subscriptionType: subscriptionType,
      category: category,
      dailyRequestCount: dailyRequestCount,
      categoryLimit: categoryLimit,
      flexibleGamesAvailable: flexibleGamesAvailable,
      remainingNormalGames: remainingNormalGames,
      canPlayGame: dailyRequestCount < categoryLimit || flexibleGamesAvailable > 0,
      totalAvailableGames: remainingNormalGames + flexibleGamesAvailable,
    );
  }
}
