import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/repositories/game_usage_repositories.dart';

class CanPlayGameUseCase {
  final GameUsageRepository repository;

  CanPlayGameUseCase({required this.repository});

  bool call(GameCategory category, {bool willPayWithCoin = false}) {
    final date = DateTime.now();
    final subscriptionType = repository.getSubscriptionType();
    final categoryLimit = repository.getCategoryLimit(subscriptionType, category);
    final dailyRequests = repository.getDailyRequestCount(category, date);
    final flexibleGames = repository.getFlexibleGamesCount(date);

    // Köhnə koddakı eyni şərt: normal limit, flexible games və ya coin payment
    return dailyRequests < categoryLimit || flexibleGames > 0 || willPayWithCoin;
  }
}