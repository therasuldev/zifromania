import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/repositories/game_usage_repositories.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

class CanPlayGameUseCase {
  final GameUsageRepository repository;

  CanPlayGameUseCase({required this.repository});

  bool call(
    GameCategory category, {
    bool willPayWithCoin = false,
    SubscriptionTypeEntity? subscriptionType,
  }) {
    final date = DateTime.now();
    final effectiveSubscriptionType = subscriptionType ?? repository.getSubscriptionType();
    final categoryLimit = repository.getCategoryLimit(effectiveSubscriptionType, category);
    final dailyRequests = repository.getDailyRequestCount(category, date);
    final flexibleGames = repository.getFlexibleGamesCount(date);

    // Köhnə koddakı eyni şərt: normal limit, flexible games və ya coin payment
    return dailyRequests < categoryLimit || flexibleGames > 0 || willPayWithCoin;
  }
}
